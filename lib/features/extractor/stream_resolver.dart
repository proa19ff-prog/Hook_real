import 'dart:math' as math;

import 'models/media_track.dart';
import 'models/resolved_stream.dart';
import 'soundcloud/soundcloud_extractor.dart';
import 'spotify/spotify_catalog_service.dart';

class StreamResolver {
  final SoundCloudExtractor _scExtractor;
  final SpotifyCatalogService _spotifyCatalog;
  final Map<String, List<MediaTrack>> _searchCache = {};

  StreamResolver({
    SoundCloudExtractor? scExtractor,
    SpotifyCatalogService? spotifyCatalog,
  })  : _scExtractor = scExtractor ?? SoundCloudExtractor(),
        _spotifyCatalog = spotifyCatalog ?? SpotifyCatalogService();

  // Common Russian phonetic transliterations to official artist/track names
  static const Map<String, String> _phoneticMap = {
    'алан волкер': 'alan walker',
    'алан уокер': 'alan walker',
    'фейдед': 'faded',
    'викнд': 'the weeknd',
    'викенд': 'the weeknd',
    'зе викенд': 'the weeknd',
    'блайндинг лайтс': 'blinding lights',
    'линкин парк': 'linkin park',
    'ин зе энд': 'in the end',
    'билли айлиш': 'billie eilish',
    'эминем': 'eminem',
    'квин': 'queen',
    'имеджин драгонс': 'imagine dragons',
    'имаджин драгонс': 'imagine dragons',
    'белавер': 'believer',
    'радиохед': 'radiohead',
    'крип': 'creep',
    'нирвана': 'nirvana',
    'колдплей': 'coldplay',
    'фонк': 'phonk',
  };

  // Keyboard layout slip mapping (English <-> Russian)
  static const String _enChars =
      "qwertyuiop[]asdfghjkl;'zxcvbnm,.`QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>~";
  static const String _ruChars =
      "йцукенгшщзхъфывапролджэячсмитьбюёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ";

  /// Fixes accidental keyboard layout typing (e.g. "fkfy djkrth" -> "alan walker")
  static String fixKeyboardLayout(String input) {
    final sb = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final ch = input[i];
      final ruIndex = _ruChars.indexOf(ch);
      final enIndex = _enChars.indexOf(ch);
      if (ruIndex != -1) {
        sb.write(_enChars[ruIndex]);
      } else if (enIndex != -1) {
        sb.write(_ruChars[enIndex]);
      } else {
        sb.write(ch);
      }
    }
    return sb.toString();
  }

  /// Normalizes a search query and expands it if a transliteration or layout slip is detected.
  List<String> getSearchQueries(String query) {
    final normalized = query.trim().toLowerCase();
    final queries = <String>[normalized];

    // 1. Check phonetic dictionary
    for (final entry in _phoneticMap.entries) {
      if (normalized.contains(entry.key)) {
        final expanded = normalized.replaceAll(entry.key, entry.value).trim();
        if (!queries.contains(expanded)) {
          queries.add(expanded);
        }
      }
    }

    // 2. Check keyboard layout conversion if input looks like mixed/scrambled text
    final fixedLayout = fixKeyboardLayout(normalized);
    if (fixedLayout != normalized && !queries.contains(fixedLayout)) {
      queries.add(fixedLayout);
    }

    return queries;
  }

  static final _cyrillic = RegExp(r'[а-яё]', caseSensitive: false);
  static final _brackets = RegExp(r'[\(\[\{].*?[\)\]\}]');
  // `unicode: true` is required: without it `\p{L}` is not a letter class and
  // the old pattern stripped every letter, Cyrillic included.
  static final _nonWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _spaces = RegExp(r'\s+');

  /// Normalizes a title/artist string for matching: lowercase, `ё` → `е`,
  /// drops bracketed extras and punctuation, collapses whitespace.
  static String _norm(String s) => s
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(_brackets, ' ')
      .replaceAll(_nonWord, ' ')
      .replaceAll(_spaces, ' ')
      .trim();

  /// Maps stylized digits to letters so "madk1d" matches "madkid".
  static String _loose(String s) => s
      .replaceAll('0', 'o')
      .replaceAll('1', 'i')
      .replaceAll('3', 'e')
      .replaceAll('4', 'a')
      .replaceAll('5', 's');

  static List<String> _words(String s) =>
      s.split(' ').where((w) => w.isNotEmpty).toList();

  /// Whole-word phrase containment ("faded" in "alan walker faded").
  static bool _hasPhrase(String haystack, String needle) =>
      needle.isNotEmpty && ' $haystack '.contains(' $needle ');

  /// Calculates a quality and relevance score for a track given the user's query.
  /// Original tracks get high bonuses; covers, 1-hour loops, and bootlegs are penalized.
  static double scoreTrack(MediaTrack track, String query) {
    final q = _norm(query);
    final title = _norm(track.title);
    final artist = _norm(track.artist);
    final rawTitle = track.title.toLowerCase();

    double score = 100.0;
    if (q.isEmpty) return score;

    // 1. Title matching. A query that is the start of a title ("sweater" for
    //    "Sweater Weather") counts almost as much as the exact title.
    if (title == q) {
      score += 200.0;
    } else if (title.startsWith('$q ')) {
      score += 190.0;
    } else if (_hasPhrase(title, q)) {
      score += 110.0;
    } else if (title.startsWith(q)) {
      score += 90.0; // the last word is still being typed: "sweat"
    }

    // 2. Artist matching (digits loosened: "madk1d" == "madkid").
    final qLoose = _loose(q);
    final artistLoose = _loose(artist);
    if (artist.isNotEmpty) {
      if (_hasPhrase(qLoose, artistLoose)) {
        score += 120.0; // user typed the artist
      } else if (_hasPhrase(artistLoose, qLoose) || artistLoose.startsWith(qLoose)) {
        score += 80.0;
      }
      if ('$artist $title' == q || '$title $artist' == q) score += 150.0;
    }

    // 3. Word-level coverage, with prefix matching for partial words.
    final qWords = _words(qLoose).where((w) => w.length >= 2).toList();
    if (qWords.isNotEmpty) {
      final titleWords = _words(_loose(title));
      final artistWords = _words(artistLoose);
      var matched = 0;
      for (final word in qWords) {
        var hit = false;
        if (titleWords.contains(word)) {
          score += 40.0;
          hit = true;
        } else if (titleWords.any((w) => w.startsWith(word))) {
          score += 25.0;
          hit = true;
        }
        if (artistWords.any((w) => w.startsWith(word))) {
          score += 40.0;
          hit = true;
        }
        if (hit) matched++;
      }
      if (matched == 0) {
        score -= 120.0;
      } else if (qWords.length >= 2 && matched == qWords.length) {
        score += 80.0;
      }
    }

    // 4. Heavily penalize unofficial edits, bootlegs, and loops
    final rawQuery = query.toLowerCase();
    final isQueryLookingForRemix = rawQuery.contains('remix');
    final isQueryLookingForCover = rawQuery.contains('cover');
    final isQueryLookingForSpeed =
        rawQuery.contains('sped') || rawQuery.contains('slow');

    if (!isQueryLookingForRemix &&
        (rawTitle.contains('remix') || rawTitle.contains('rmx'))) {
      score -= 80.0;
    }
    if (!isQueryLookingForCover &&
        (rawTitle.contains('cover') || rawTitle.contains('tribute'))) {
      score -= 100.0;
    }
    if (!isQueryLookingForSpeed) {
      if (rawTitle.contains('slowed') ||
          rawTitle.contains('reverb') ||
          rawTitle.contains('sped up') ||
          rawTitle.contains('speed up') ||
          rawTitle.contains('nightcore') ||
          rawTitle.contains('bass boosted') ||
          rawTitle.contains('bassboost') ||
          rawTitle.contains('8d audio')) {
        score -= 140.0;
      }
    }

    if (rawTitle.contains('1 hour') ||
        rawTitle.contains('10 hour') ||
        rawTitle.contains('loop') ||
        rawTitle.contains('instrumental') ||
        rawTitle.contains('karaoke') ||
        rawTitle.contains('parody')) {
      score -= 150.0;
    }

    // 5. Prefer normal song durations (between 2:00 and 6:00)
    final sec = track.duration.inSeconds;
    if (sec > 0) {
      if (sec < 60) {
        score -= 80.0; // too short (snippets/teasers)
      } else if (sec > 600) {
        score -= 90.0; // too long (mixes/loops)
      } else if (sec >= 120 && sec <= 360) {
        score += 30.0; // optimal radio/track length
      }
    }

    return score;
  }

  /// True when some result contains every query word (as a word prefix) in
  /// its title or artist.
  static bool _hasFullMatch(Iterable<MediaTrack> tracks, String query) {
    final qWords =
        _words(_loose(_norm(query))).where((w) => w.length >= 2).toList();
    if (qWords.isEmpty) return true;
    return tracks.any((t) {
      final words = _words(_loose(_norm('${t.title} ${t.artist}')));
      return qWords.every((q) => words.any((w) => w.startsWith(q)));
    });
  }

  /// Popularity signal from the source's own ordering. The catalog orders by
  /// popularity; SoundCloud ordering is noisier, so its play count weighs in.
  double _rankBonus(MediaTrack track, int position) {
    if (track.source != TrackSource.soundcloud) {
      return math.max(0.0, 100.0 - 12.0 * position);
    }
    final plays = _scExtractor.playbackCount(track.id);
    final popularity =
        plays > 0 ? math.min(math.log(plays) / math.ln10 * 12.0, 100.0) : 0.0;
    return math.max(0.0, 60.0 - 8.0 * position) + popularity;
  }

  /// Searches tracks across selected sources with intelligent ranking and fuzzy matching.
  /// Spotify (catalog) provides discovery; SoundCloud provides playback.
  Future<List<MediaTrack>> search({
    required String query,
    bool includeSoundCloud = true,
    bool includeSpotify = true,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final cacheKey =
        '$normalizedQuery|$includeSoundCloud|$includeSpotify';
    final cached = _searchCache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);
    if (_searchCache.length >= 50) {
      _searchCache.remove(_searchCache.keys.first);
    }

    final searchQueries = getSearchQueries(normalizedQuery);
    final rawResults = <MediaTrack>[];
    final bonus = <String, double>{};
    String keyOf(MediaTrack t) => '${t.source.name}:${t.id}';

    Future<void> collect(Future<List<MediaTrack>> request, int queryIndex) async {
      final list = await request.timeout(
        const Duration(seconds: 8),
        onTimeout: () => <MediaTrack>[],
      );
      for (var i = 0; i < list.length; i++) {
        final t = list[i];
        final b = _rankBonus(t, i) * (queryIndex == 0 ? 1.0 : 0.5);
        bonus[keyOf(t)] = math.max(bonus[keyOf(t)] ?? 0.0, b);
        rawResults.add(t);
      }
    }

    // The studio catalog is missing many Russian releases (MADKID & VILLIAN
    // "Династия" is not there at all), so Cyrillic queries always pull in
    // SoundCloud too.
    var withSoundCloud = includeSoundCloud ||
        (includeSpotify && _cyrillic.hasMatch(normalizedQuery));

    for (var i = 0; i < searchQueries.length; i++) {
      final q = searchQueries[i];
      await Future.wait([
        if (withSoundCloud) collect(_scExtractor.searchTracks(q), i),
        if (includeSpotify) collect(_spotifyCatalog.searchTracks(q), i),
      ]);
      // If primary query gave ample results, no need to query subsequent variants
      if (rawResults.length >= 15) break;
    }

    // The catalog had nothing covering the whole query: fall back to SoundCloud.
    if (includeSpotify &&
        !withSoundCloud &&
        !_hasFullMatch(rawResults, normalizedQuery)) {
      withSoundCloud = true;
      await collect(_scExtractor.searchTracks(searchQueries.first), 0);
    }

    if (rawResults.isEmpty) return const [];

    double scoreOf(MediaTrack t) {
      var best = scoreTrack(t, normalizedQuery);
      for (final variant in searchQueries.skip(1)) {
        best = math.max(best, scoreTrack(t, variant) - 25.0);
      }
      return best + (bonus[keyOf(t)] ?? 0.0);
    }

    // Collapse the same song from several uploads/sources into one entry.
    // The catalog copy wins (better metadata); the group keeps its best score.
    final groups = <String, ({MediaTrack track, double score})>{};
    for (final track in rawResults) {
      final s = scoreOf(track);
      final key =
          '${_norm(track.title)}|${_loose(_norm(track.artist))}';
      final existing = groups[key];
      if (existing == null) {
        groups[key] = (track: track, score: s);
        continue;
      }
      final preferNew = existing.track.source != TrackSource.spotify &&
          (track.source == TrackSource.spotify || s > existing.score);
      groups[key] = (
        track: preferNew ? track : existing.track,
        score: math.max(s, existing.score),
      );
    }

    final ranked = groups.values.toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final output =
        ranked.take(30).map((e) => e.track).toList(growable: false);
    if (output.isNotEmpty) _searchCache[cacheKey] = output;
    return output;
  }

  /// Resolves the actual playable stream for a given track based on its source.
  Future<ResolvedStream?> resolveStream(MediaTrack track) async {
    if (track.source == TrackSource.local &&
        track.streamUrl != null &&
        track.streamUrl!.isNotEmpty) {
      return ResolvedStream(track.streamUrl!);
    }

    switch (track.source) {
      case TrackSource.youtube:
        // YouTube is cut from the app (unusable on many networks). Old saved
        // tracks keep playing through the SoundCloud search match.
        return resolveSpotifyTrack(track);

      case TrackSource.soundcloud:
        // The CDN signs the URL in its query string, so no extra headers are
        // needed here; sending them only risked a rejection.
        final url = await _scExtractor.resolveAudioStreamUrl(track.id);
        return (url == null || url.isEmpty) ? null : ResolvedStream(url);

      case TrackSource.spotify:
        return resolveSpotifyTrack(track);

      case TrackSource.local:
        return track.streamUrl == null
            ? null
            : ResolvedStream(track.streamUrl!);
    }
  }

  /// Backwards-compatible URL-only helper.
  Future<String?> resolveStreamUrl(MediaTrack track) async =>
      (await resolveStream(track))?.url;

  /// Catalog track key → matched SoundCloud track id. A repeat play (or a
  /// re-resolve after the signed URL expires) then skips the search.
  final Map<String, String> _matchCache = {};

  /// SoundCloud ids whose stream failed to play; skipped when matching.
  final Set<String> _badMatches = {};

  String _matchKey(MediaTrack t) => '${t.source.name}:${t.id}';

  /// Call after a resolved stream failed to play, so the next resolve picks
  /// a different SoundCloud upload.
  void forgetMatch(MediaTrack track) {
    final id = _matchCache.remove(_matchKey(track));
    if (id != null) _badMatches.add(id);
    if (track.source == TrackSource.soundcloud) _badMatches.add(track.id);
  }

  Future<ResolvedStream?> resolveSpotifyTrack(MediaTrack track) async {
    final matchKey = _matchKey(track);
    final knownId = _matchCache[matchKey];
    if (knownId != null) {
      try {
        final url = await _scExtractor.resolveAudioStreamUrl(knownId);
        if (url != null && url.isNotEmpty) return ResolvedStream(url);
      } catch (_) {}
      _matchCache.remove(matchKey);
    }

    // 1. Clean primary artist and title to form a laser-targeted query
    final primaryArtist = track.artist
        .split(RegExp(r'[,&]'))
        .first
        .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
        .trim();

    final cleanTitle = track.title
        .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
        .trim();

    final query = '$primaryArtist $cleanTitle'.trim();

    // 2. Fetch candidates from SoundCloud (extra candidates since junk
    //    re-uploads are common on SoundCloud search).
    final candidates = <MediaTrack>[];
    try {
      final scResults = await _scExtractor.searchTracks(query, limit: 12);
      candidates.addAll(scResults.where((c) => !_badMatches.contains(c.id)));
    } catch (_) {}
    if (candidates.isEmpty) return null;

    final normTitle = _norm(cleanTitle);
    final normArtist = _loose(_norm(primaryArtist));
    final titleWords = _words(normTitle).where((w) => w.length > 2).toList();
    final artistWords = _words(normArtist).where((w) => w.length > 2).toList();
    final wantSec = track.duration.inSeconds;

    // 3. Score candidates: strict title/artist/duration checks on top of the
    //    generic scoreTrack heuristics (which alone let junk reposts through).
    double candidateScore(MediaTrack c) {
      final t = _norm(c.title);
      final tl = _loose(t);
      final a = _loose(_norm(c.artist));
      double s = scoreTrack(c, query);

      if (t == normTitle) {
        s += 150.0;
      } else if (_hasPhrase(t, normTitle)) {
        s += 60.0;
      }
      if (a == normArtist) {
        s += 120.0;
      } else if (_hasPhrase(a, normArtist)) {
        s += 50.0;
      }
      // Nobody in the whole candidate is the requested artist: distrust it.
      if (artistWords.isNotEmpty &&
          !artistWords.any((w) => tl.contains(w) || a.contains(w))) {
        s -= 160.0;
      }
      // Same song, same length: the strongest signal against edits/covers.
      final gotSec = c.duration.inSeconds;
      if (wantSec > 0 && gotSec > 0) {
        final diff = (wantSec - gotSec).abs();
        if (diff <= 4) {
          s += 90.0;
        } else if (diff <= 12) {
          s += 40.0;
        } else if (diff > 30) {
          s -= 120.0;
        }
      }
      return s;
    }

    final scored = [
      for (final c in candidates) (track: c, score: candidateScore(c)),
    ]..sort((a, b) => b.score.compareTo(a.score));

    // 4. Require BOTH a title signal and an artist signal. This blocks
    //    reposts like "NCM - Alan Walker Faded" when the true artist never
    //    matches.
    for (final entry in scored) {
      final candidate = entry.track;
      final t = _norm(candidate.title);
      final tl = _loose(t);
      final a = _loose(_norm(candidate.artist));

      final titleOk = t == normTitle ||
          _hasPhrase(t, normTitle) ||
          titleWords.any(t.contains);
      final artistOk = artistWords.isEmpty
          ? a == normArtist || _hasPhrase(a, normArtist) || _hasPhrase(tl, normArtist)
          : artistWords.any((w) => a.contains(w) || tl.contains(w));

      if (!titleOk || !artistOk) continue;

      try {
        final resolved = await resolveStream(candidate);
        if (resolved != null && !resolved.isEmpty) {
          _matchCache[matchKey] = candidate.id;
          return resolved;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  void dispose() {
    _scExtractor.close();
    _spotifyCatalog.close();
  }
}