import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show min;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Resolves square album covers for tracks and keeps them on disk.
///
/// Two problems this exists for:
///
///  * Server-resolved recordings carry a YouTube video frame as their
///    "artwork". A frame with faces, titles and black bars is not a cover and
///    never should be shown in a music app, so those urls are treated as
///    missing and replaced with a real album cover.
///  * Imported and saved playlists are full of empty artwork urls, and every
///    cover that *is* stored is re-downloaded on each launch. Resolved covers
///    are remembered in `SharedPreferences` and the image bytes are copied to
///    the app support directory, so the second render and the next launch are
///    instant and work offline.
class ArtworkService {
  ArtworkService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 10),
              headers: const {
                'User-Agent': 'Hook-Music-Player/1.0',
                'Accept': 'application/json',
              },
            ),
          );

  ArtworkService._() : this();

  /// Shared instance used by the widgets, the player and the notification.
  ///
  /// Not `final` so a test can swap in a service backed by a fake HTTP
  /// adapter; production code never assigns to it.
  static ArtworkService instance = ArtworkService._();

  /// Restores the default shared instance after a test replaced it.
  @visibleForTesting
  static void resetInstance() {
    instance = ArtworkService._();
  }

  static const String _cacheKey = 'hook_artwork_urls_v2';
  static const int _maxEntries = 900;
  static const int _maxFiles = 500;
  static const int _maxConcurrentLookups = 4;

  /// A genuine "the catalog has nothing for this recording" answer. Retrying
  /// it costs several requests per tile, so it rests for a while.
  static const Duration _missTtl = Duration(hours: 6);

  /// A lookup that failed because the network failed, not because the cover
  /// does not exist. Short-lived, so a flaky moment does not leave a tile
  /// empty for the rest of the session.
  static const Duration _transientTtl = Duration(minutes: 3);

  static const double _minScore = 120;

  final Dio _dio;

  /// `artist|title` -> resolved cover url.
  final Map<String, String> _resolved = <String, String>{};
  final Map<String, ({DateTime at, bool transient})> _misses =
      <String, ({DateTime at, bool transient})>{};
  final Map<String, Future<String?>> _pending = <String, Future<String?>>{};
  final List<Completer<void>> _queue = <Completer<void>>[];
  int _active = 0;
  bool _hydrated = false;
  Future<void>? _hydrating;
  Timer? _persistTimer;

  Directory? _cacheDir;
  bool _cacheDirFailed = false;
  final Map<String, File?> _knownFiles = <String, File?>{};
  final Set<String> _warming = <String>{};

  // --- Url classification -------------------------------------------------

  /// True when [url] points at a YouTube video frame rather than a cover.
  ///
  /// `i.ytimg.com` serves 4:3 stills with black bars; album art from YouTube
  /// Music lives on `lh3.googleusercontent.com`/`yt3.ggpht.com` and is kept.
  static bool isVideoThumbnail(String url) {
    if (url.isEmpty) {
      return false;
    }
    final lower = url.toLowerCase();
    return lower.contains('ytimg.com/') ||
        lower.contains('img.youtube.com/') ||
        lower.contains('youtube.com/vi/');
  }

  /// True when [url] is an http(s) url that can be shown as a track cover.
  static bool isUsable(String url) {
    if (url.isEmpty || isVideoThumbnail(url)) {
      return false;
    }
    final uri = Uri.tryParse(url);
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll('\u0451', '\u0435')
      .replaceAll(RegExp(r'\(.*?\)|\[.*?\]'), ' ')
      .replaceAll(RegExp(r'[^a-z\u0430-\u044f0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Like [normalize], but keeps text inside brackets. A cover usually marks
  /// itself there ("Addiction (Cover)"), and stripping brackets would hide the
  /// only hint that the hit is not the real recording.
  static String _normalizeFull(String value) => value
      .toLowerCase()
      .replaceAll('\u0451', '\u0435')
      .replaceAll(RegExp(r'[^a-z\u0430-\u044f0-9]+'), ' ')
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');

  /// Maps stylized digits to letters so "madk1d" matches "madkid".
  static String _looseDigits(String value) => value
      .replaceAll('0', 'o')
      .replaceAll('1', 'i')
      .replaceAll('3', 'e')
      .replaceAll('4', 'a')
      .replaceAll('5', 's');

  static int _editDistance(String a, String b, {int max = 2}) {
    if ((a.length - b.length).abs() > max) {
      return max + 1;
    }
    if (a.isEmpty) {
      return b.length;
    }
    if (b.isEmpty) {
      return a.length;
    }
    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final current = <int>[i];
      var rowMin = i;
      for (var j = 1; j <= b.length; j++) {
        final value = min(
          min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
        );
        current.add(value);
        rowMin = min(rowMin, value);
      }
      if (rowMin > max) {
        return max + 1;
      }
      previous = current;
    }
    return previous.last;
  }

  /// True when two normalized titles differ only by a typo ("sunflowee").
  static bool _fuzzyTitle(String a, String b) {
    if (a == b) {
      return true;
    }
    final aWords = a.split(' ');
    final bWords = b.split(' ');
    if (aWords.length != bWords.length) {
      return false;
    }
    for (var i = 0; i < aWords.length; i++) {
      final left = aWords[i];
      final right = bWords[i];
      if (left == right) {
        continue;
      }
      if (left.length < 5 || right.length < 5) {
        return false;
      }
      if (_editDistance(left, right, max: 1) > 1) {
        return false;
      }
    }
    return true;
  }

  /// Strips channel artifacts from artist names: "Artist - Topic" -> "Artist",
  /// "EminemVEVO" -> "Eminem".
  static String cleanArtist(String artist) {
    var a = artist.trim();
    if (a.isEmpty) return a;
    a = a.replaceAll(RegExp(r'\s*-\s*topic$', caseSensitive: false), '');
    a = a.replaceAll(RegExp(r'vevo$', caseSensitive: false), '');
    return a.trim();
  }

  /// Strips bracketed video noise tags ("[Official Video]", "(Lyrics)", etc.)
  /// and trailing markers from titles.
  static String cleanTitle(String title) {
    var t = title.trim();
    if (t.isEmpty) return t;

    t = t.replaceAll(
      RegExp(
        r'[\(\[\{][^\)\]\}]*(?:official\s*(?:music\s*)?video|official\s*audio|lyrics?|lyric\s*video|visualizer|remaster(?:ed)?|4k(?:\s*remaster(?:ed)?)?|hd|hq|1080p|performance\s*video|clip\s*officiel|video\s*clip|music\s*video|\bmv\b)[^\)\]\}]*[\)\]\}]',
        caseSensitive: false,
      ),
      ' ',
    );

    t = t.replaceAll(
      RegExp(
        r'\s*[\-|–|—|/|\|]\s*(?:official\s*(?:music\s*)?video|official\s*audio|lyrics?|lyric\s*video|visualizer|audio|clip\s*officiel|4k|hd|hq)\s*$',
        caseSensitive: false,
      ),
      '',
    );

    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  /// Separates "Artist - Title" patterns embedded in YouTube titles and
  /// strips video-specific tags from artist and title.
  static (String artist, String title) extractArtistAndTitle(
    String? rawArtist,
    String? rawTitle,
  ) {
    final cleanedArtist = cleanArtist(rawArtist ?? '');
    final cleanedTitle = cleanTitle(rawTitle ?? '');
    if (cleanedTitle.isEmpty) {
      return (cleanedArtist, cleanedTitle);
    }

    final match = RegExp(r'^(.+?)\s+[\-–—]\s+(.+)$').firstMatch(cleanedTitle);
    if (match != null) {
      final left = match.group(1)!.trim();
      final right = match.group(2)!.trim();
      if (left.isNotEmpty && right.isNotEmpty) {
        final normArtist = normalize(cleanedArtist);
        final normLeft = normalize(left);
        if (normArtist.isEmpty ||
            normArtist == normLeft ||
            cleanedArtist.toLowerCase().contains('topic') ||
            cleanedArtist.toLowerCase().contains('vevo') ||
            !normArtist.contains(normLeft)) {
          return (left, right);
        }
      }
    }

    return (cleanedArtist, cleanedTitle);
  }

  /// Stable cache key for a recording, or null when there is nothing to look
  /// up. Artist and title are normalized so punctuation and bracket suffixes
  /// do not produce duplicate lookups.
  static String? resolveKey(String? artist, String? title) {
    if (title == null || title.trim().isEmpty) {
      return null;
    }
    final (cleanA, cleanT) = extractArtistAndTitle(artist, title);
    final a = normalize(cleanA);
    final t = normalize(cleanT);
    if (t.isEmpty) {
      return null;
    }
    return '$a|$t';
  }

  // --- Persistent url cache ----------------------------------------------

  /// Loads the persisted `artist|title -> cover` map. Safe to call many times.
  Future<void> hydrate() {
    if (_hydrated) {
      return Future<void>.value();
    }
    return _hydrating ??= _hydrate();
  }

  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final key = entry.key;
            final value = entry.value;
            if (key is String && value is String && isUsable(value)) {
              _resolved[key] = value;
            }
          }
        }
      }
    } catch (_) {
      // A broken cache is not fatal: lookups just start from scratch.
    }
    _hydrated = true;
  }

  /// Synchronously returns a previously resolved cover, if any.
  String? cached(String? artist, String? title) {
    final key = resolveKey(artist, title);
    return key == null ? null : _resolved[key];
  }

  /// Best known cover for a track: the stored url when it is a real cover,
  /// otherwise a previously resolved one.
  String? displayUrl(String rawUrl, {String? artist, String? title}) {
    final cachedUrl = cached(artist, title);
    if (cachedUrl != null) {
      return cachedUrl;
    }
    return isUsable(rawUrl) ? rawUrl : null;
  }
  // --- Resolution ---------------------------------------------------------

  /// Resolves a proper cover for [artist]/[title].
  ///
  /// Returns the cached url when known, otherwise queries Deezer and then
  /// iTunes. Concurrent requests for the same recording share one lookup and
  /// at most [_maxConcurrentLookups] requests run at a time. Failures are
  /// remembered for [_missTtl] so scrolling never hammers the apis.
  Future<String?> resolve({
    required String artist,
    required String title,
    Duration? duration,
  }) {
    final key = resolveKey(artist, title);
    if (key == null) {
      return Future<String?>.value();
    }
    final cachedUrl = _resolved[key];
    if (cachedUrl != null) {
      return Future<String?>.value(cachedUrl);
    }
    final miss = _misses[key];
    if (miss != null) {
      final ttl = miss.transient ? _transientTtl : _missTtl;
      if (DateTime.now().difference(miss.at) < ttl) {
        return Future<String?>.value();
      }
    }
    final pending = _pending[key];
    if (pending != null) {
      return pending;
    }
    final future = _lookup(key, artist, title, duration);
    _pending[key] = future;
    return future.whenComplete(() => _pending.remove(key));
  }

  Future<String?> _lookup(
    String key,
    String artist,
    String title,
    Duration? duration,
  ) async {
    await hydrate();
    final cachedUrl = _resolved[key];
    if (cachedUrl != null) {
      return cachedUrl;
    }
    await _acquire();
    try {
      var url = await _searchDeezer(artist, title, duration);
      url ??= await _searchItunes(artist, title, duration);
      if (url == null || !isUsable(url)) {
        _misses[key] = (at: DateTime.now(), transient: false);
        return null;
      }
      _remember(key, url);
      return url;
    } catch (_) {
      _misses[key] = (at: DateTime.now(), transient: true);
      return null;
    } finally {
      _release();
    }
  }

  void _remember(String key, String url) {
    _resolved[key] = url;
    while (_resolved.length > _maxEntries) {
      _resolved.remove(_resolved.keys.first);
    }
    _schedulePersist();
  }

  void _schedulePersist() {
    _persistTimer?.cancel();
    _persistTimer = Timer(const Duration(seconds: 2), () {
      _persistTimer = null;
      unawaited(persistNow());
    });
  }

  /// Writes the resolved url map to `SharedPreferences` immediately.
  @visibleForTesting
  Future<void> persistNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, jsonEncode(_resolved));
    } catch (_) {
      // Persistence is an optimisation; ignore storage failures.
    }
  }

  Future<void> _acquire() async {
    if (_active < _maxConcurrentLookups) {
      _active++;
      return;
    }
    final completer = Completer<void>();
    _queue.add(completer);
    await completer.future;
  }

  void _release() {
    _active--;
    if (_queue.isNotEmpty) {
      _queue.removeAt(0).complete();
    }
  }

  Future<String?> _searchDeezer(
    String artist,
    String title,
    Duration? duration,
  ) async {
    final (cleanA, cleanT) = extractArtistAndTitle(artist, title);
    final queries = <String>[];
    if (cleanA.isNotEmpty && cleanT.isNotEmpty) {
      queries.add(
        'artist:"${_escapeDeezer(cleanA)}" track:"${_escapeDeezer(cleanT)}"',
      );
    } else {
      queries.add(_escapeDeezer(cleanT.isNotEmpty ? cleanT : cleanA));
    }
    final prim = primaryArtist(cleanA);
    if (prim.isNotEmpty && prim != cleanA && cleanT.isNotEmpty) {
      queries.add(
        'artist:"${_escapeDeezer(prim)}" track:"${_escapeDeezer(cleanT)}"',
      );
    }
    if (cleanA.isNotEmpty && cleanT.isNotEmpty) {
      queries.add('${_escapeDeezer(cleanA)} ${_escapeDeezer(cleanT)}');
    }
    if (artist.isNotEmpty && cleanA != artist && cleanT.isNotEmpty) {
      queries.add('${_escapeDeezer(artist)} ${_escapeDeezer(cleanT)}');
    }
    queries.removeWhere((q) => q.trim().isEmpty);

    for (var i = 0; i < queries.length; i++) {
      final query = queries[i];
      final response = await _dio.get<dynamic>(
        'https://api.deezer.com/search',
        queryParameters: {'q': query, 'limit': 12},
      );
      final data = response.data;
      if (data is! Map || data['data'] is! List) {
        continue;
      }
      final items = data['data'] as List;
      String? best;
      var bestScore = _minScore;
      for (final item in items) {
        if (item is! Map) {
          continue;
        }
        final album = item['album'];
        final albumMap = album is Map ? album : const <dynamic, dynamic>{};
        final url =
            (albumMap['cover_xl'] ??
                    albumMap['cover_big'] ??
                    albumMap['cover_medium'])
                ?.toString() ??
            '';
        if (!isUsable(url)) {
          continue;
        }
        final artistItem = item['artist'];
        final candidateArtist =
            (artistItem is Map ? artistItem['name'] : null)?.toString() ?? '';
        final score = scoreCandidate(
          artist: artist,
          title: title,
          candidateArtist: candidateArtist,
          candidateTitle: item['title']?.toString() ?? '',
          expectedSeconds: duration?.inSeconds,
          candidateSeconds: item['duration'] is num
              ? (item['duration'] as num).toInt()
              : null,
        );
        if (score > bestScore) {
          bestScore = score;
          best = url;
        }
      }
      if (best != null) {
        return best;
      }
      if (items.isNotEmpty) {
        break;
      }
    }
    return null;
  }

  Future<String?> _searchItunes(
    String artist,
    String title,
    Duration? duration,
  ) async {
    final (cleanA, cleanT) = extractArtistAndTitle(artist, title);
    final terms = <String>[];
    if (cleanA.isNotEmpty && cleanT.isNotEmpty) {
      terms.add('$cleanA $cleanT');
    } else {
      terms.add(cleanT.isNotEmpty ? cleanT : cleanA);
    }
    final prim = primaryArtist(cleanA);
    if (prim.isNotEmpty && prim != cleanA && cleanT.isNotEmpty) {
      terms.add('$prim $cleanT');
    }
    if (artist.isNotEmpty && cleanA != artist && cleanT.isNotEmpty) {
      terms.add('$artist $cleanT');
    }
    terms.removeWhere((t) => t.trim().isEmpty);

    for (final term in terms.toSet()) {
      final cyrillic = RegExp(r'[\u0400-\u04FF]').hasMatch(term);
      final response = await _dio.get<dynamic>(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': term,
          'entity': 'song',
          'limit': 12,
          'country': cyrillic ? 'ru' : 'us',
        },
      );
      final data = response.data;
      if (data is! Map || data['results'] is! List) {
        continue;
      }
      final items = data['results'] as List;
      String? best;
      var bestScore = _minScore;
      for (final item in items) {
        if (item is! Map) {
          continue;
        }
        final rawArt = item['artworkUrl100']?.toString() ?? '';
        if (rawArt.isEmpty) {
          continue;
        }
        final url = rawArt
            .replaceAll(RegExp(r'/\d+x\d+bb\.'), '/1000x1000bb.')
            .replaceAll(RegExp(r'/\d+x\d+-\d+\.'), '/1000x1000bb.');
        if (!isUsable(url)) {
          continue;
        }
        final millis = item['trackTimeMillis'];
        final score = scoreCandidate(
          artist: artist,
          title: title,
          candidateArtist: item['artistName']?.toString() ?? '',
          candidateTitle: item['trackName']?.toString() ?? '',
          expectedSeconds: duration?.inSeconds,
          candidateSeconds: millis is num ? (millis / 1000).round() : null,
        );
        if (score > bestScore) {
          bestScore = score;
          best = url;
        }
      }
      if (best != null) {
        return best;
      }
      if (items.isNotEmpty) {
        break;
      }
    }
    return null;
  }

  static String _escapeDeezer(String value) =>
      value.replaceAll('"', ' ').trim();

  // --- Matching -----------------------------------------------------------

  static const Set<String> _junkWords = {
    'cover',
    'covers',
    'karaoke',
    'tribute',
    'instrumental',
    'remake',
    'made famous',
  };

  /// Scores how likely a catalog hit is the same recording as
  /// [artist]/[title]. Returns a value below [_minScore] for anything that is
  /// not a plausible match, including covers and karaoke versions unless the
  /// wanted title asks for them.
  @visibleForTesting
  static double scoreCandidate({
    required String artist,
    required String title,
    required String candidateArtist,
    required String candidateTitle,
    int? expectedSeconds,
    int? candidateSeconds,
  }) {
    var best = _scoreCandidateCore(
      artist: artist,
      title: title,
      candidateArtist: candidateArtist,
      candidateTitle: candidateTitle,
      expectedSeconds: expectedSeconds,
      candidateSeconds: candidateSeconds,
    );
    final (extractedArtist, extractedTitle) =
        extractArtistAndTitle(artist, title);
    if (extractedArtist != artist || extractedTitle != title) {
      final alt = _scoreCandidateCore(
        artist: extractedArtist,
        title: extractedTitle,
        candidateArtist: candidateArtist,
        candidateTitle: candidateTitle,
        expectedSeconds: expectedSeconds,
        candidateSeconds: candidateSeconds,
      );
      if (alt > best) {
        best = alt;
      }
    }
    return best;
  }

  static double _scoreCandidateCore({
    required String artist,
    required String title,
    required String candidateArtist,
    required String candidateTitle,
    int? expectedSeconds,
    int? candidateSeconds,
  }) {
    final wantArtist = normalize(primaryArtist(artist));
    final wantTitle = normalize(title);
    final gotArtist = normalize(primaryArtist(candidateArtist));
    final gotTitle = normalize(candidateTitle);
    // Brackets are kept for these two: they carry the "cover"/"karaoke"
    // markers, which [normalize] would strip along with the noise.
    final wantTitleFull = _normalizeFull(title);
    final gotTitleFull = _normalizeFull(candidateTitle);
    if (wantTitle.isEmpty || gotTitle.isEmpty) {
      return -1;
    }

    double score = 0;
    if (gotTitle == wantTitle) {
      score += 120;
    } else if (_fuzzyTitle(gotTitle, wantTitle)) {
      score += 100;
    } else if (gotTitle.startsWith(wantTitle) || gotTitle.contains(wantTitle)) {
      score += 70;
    } else {
      final wantWords = wantTitle.split(' ').where((w) => w.length > 2).toSet();
      if (wantWords.isEmpty) {
        return -1;
      }
      final gotWords = gotTitle.split(' ').toSet();
      final hits = wantWords.where(gotWords.contains).length;
      final ratio = hits / wantWords.length;
      if (ratio < 0.75) {
        return -1;
      }
      score += 50 * ratio;
    }

    if (wantArtist.isEmpty) {
      score += 40;
    } else if (_looseDigits(gotArtist) == _looseDigits(wantArtist)) {
      score += 100;
    } else if (gotArtist.contains(wantArtist) ||
        wantArtist.contains(gotArtist)) {
      score += 65;
    } else {
      final wantWords = wantArtist
          .split(' ')
          .where((w) => w.length > 2)
          .toSet();
      final gotWords = gotArtist.split(' ').toSet();
      final hits = wantWords.where(gotWords.contains).length;
      if (hits == 0) {
        return -1;
      }
      score += 45 * (hits / wantWords.length);
    }

    if (expectedSeconds != null &&
        expectedSeconds > 20 &&
        candidateSeconds != null &&
        candidateSeconds > 0) {
      final delta = (expectedSeconds - candidateSeconds).abs();
      if (delta <= 4) {
        score += 30;
      } else if (delta <= 12) {
        score += 12;
      } else if (delta > 60) {
        score -= 80;
      }
    }

    for (final word in _junkWords) {
      if (gotTitleFull.contains(word) && !wantTitleFull.contains(word)) {
        score -= 250;
      }
    }
    return score;
  }

  /// Splits a credit string with multiple artists into individual artist names.
  /// Handles "MadK1d & Villian", "MadK1d и Villian", "A, B feat. C", "A x B", etc.
  static List<String> splitArtists(String artist) {
    final trimmed = artist.trim();
    if (trimmed.isEmpty) return const [];

    final rawParts = trimmed.split(
      RegExp(
        r'\s*(?:[,;&/]|(?:\s+(?:feat\.?|ft\.?|and|with|vs\.?|versus|x|и)(?=\s|$)))\s*',
        caseSensitive: false,
      ),
    );

    final results = <String>[];
    final seen = <String>{};
    for (var part in rawParts) {
      part = part
          .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
          .replaceAll(RegExp(r'\s*-\s*topic$', caseSensitive: false), '')
          .replaceAll(RegExp(r'vevo$', caseSensitive: false), '')
          .trim();
      if (part.isNotEmpty && seen.add(part.toLowerCase())) {
        results.add(part);
      }
    }
    return results.isNotEmpty ? results : [trimmed];
  }

  /// First artist of a credit list: "Post Malone, Swae Lee" -> "Post Malone".
  @visibleForTesting
  static String primaryArtist(String artist) {
    final list = splitArtists(artist);
    return list.isNotEmpty ? list.first : artist.trim();
  }

  // --- Disk image cache ---------------------------------------------------

  /// Returns the cached file for [url] when its bytes were downloaded before.
  Future<File?> existingFile(String url) async {
    if (url.isEmpty) {
      return null;
    }
    if (_knownFiles.containsKey(url)) {
      return _knownFiles[url];
    }
    final dir = await _ensureCacheDir();
    if (dir == null) {
      return null;
    }
    final file = File('${dir.path}${Platform.pathSeparator}${_hash(url)}.img');
    File? result;
    try {
      if (await file.exists() && await file.length() > 512) {
        result = file;
      }
    } catch (_) {
      result = null;
    }
    _knownFiles[url] = result;
    return result;
  }

  /// Downloads [url] in the background so the next launch (and any later
  /// render) can read it from disk.
  void warm(String url) {
    if (url.isEmpty) {
      return;
    }
    if (_knownFiles[url] != null) {
      return;
    }
    if (!_warming.add(url)) {
      return;
    }
    unawaited(_download(url));
  }

  Future<void> _download(String url) async {
    try {
      final dir = await _ensureCacheDir();
      if (dir == null) {
        return;
      }
      final response = await _dio.get<dynamic>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          headers: const {'Accept': 'image/*'},
        ),
      );
      final data = response.data;
      if (data is! List<int> || data.isEmpty) {
        return;
      }
      final file = File(
        '${dir.path}${Platform.pathSeparator}${_hash(url)}.img',
      );
      final temp = File('${file.path}.tmp');
      await temp.writeAsBytes(data, flush: true);
      await temp.rename(file.path);
      _knownFiles[url] = file;
      await _prune(dir);
    } catch (_) {
      // A failed warm-up just means the network image is used again.
    } finally {
      _warming.remove(url);
    }
  }

  Future<Directory?> _ensureCacheDir() async {
    final current = _cacheDir;
    if (current != null) {
      return current;
    }
    if (_cacheDirFailed) {
      return null;
    }
    try {
      final base = await getApplicationSupportDirectory();
      final dir = Directory('${base.path}${Platform.pathSeparator}artwork');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _cacheDir = dir;
      return dir;
    } catch (_) {
      _cacheDirFailed = true;
      return null;
    }
  }

  Future<void> _prune(Directory dir) async {
    try {
      final files = await dir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.img'))
          .cast<File>()
          .toList();
      if (files.length <= _maxFiles) {
        return;
      }
      final stats = <MapEntry<File, DateTime>>[];
      for (final file in files) {
        try {
          stats.add(MapEntry(file, (await file.stat()).modified));
        } catch (_) {
          // Ignore files that disappeared mid-scan.
        }
      }
      stats.sort((a, b) => a.value.compareTo(b.value));
      final removeCount = stats.length - _maxFiles;
      for (var i = 0; i < removeCount; i++) {
        final file = stats[i].key;
        try {
          await file.delete();
          _knownFiles.removeWhere((_, value) => value?.path == file.path);
        } catch (_) {
          // The file may already be gone.
        }
      }
    } catch (_) {
      // Pruning is best effort.
    }
  }

  static String _hash(String value) {
    var hash = 0xcbf29ce484222325;
    for (final unit in value.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x100000001b3) & 0x7FFFFFFFFFFFFFFF;
    }
    return hash.toRadixString(16).padLeft(12, '0');
  }
}
