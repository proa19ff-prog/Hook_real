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

  /// Normalizes a search query and expands it if a transliteration, layout slip,
  /// or common digit-styled spelling is detected. Variants are used to retrieve
  /// catalog records; scoring still happens against the exact user query.
  List<String> getSearchQueries(String query) {
    final normalized = query.trim().toLowerCase();
    final queries = <String>[normalized];

    void add(String value) {
      final candidate = value.trim();
      if (candidate.isNotEmpty && !queries.contains(candidate)) {
        queries.add(candidate);
      }
    }

    // 1. Check phonetic dictionary.
    for (final entry in _phoneticMap.entries) {
      if (normalized.contains(entry.key)) {
        add(normalized.replaceAll(entry.key, entry.value));
      }
    }

    // 2. Check keyboard layout conversion if input looks like mixed/scrambled text.
    final fixedLayout = fixKeyboardLayout(normalized);
    if (fixedLayout != normalized) add(fixedLayout);

    // 3. Artists and aliases often replace letters with digits. Querying the
    // catalog with the stylized spelling is essential: normalizing only during
    // ranking cannot return a record that the storefront never found.
    final digitLoose = <String, String>{
      'madkid': 'madk1d',
      'madk1d': 'madkid',
      'k1d': 'kid',
    };
    for (final entry in digitLoose.entries) {
      if (normalized.contains(entry.key)) {
        add(normalized.replaceAll(entry.key, entry.value));
      }
      if (fixedLayout.contains(entry.key)) {
        add(fixedLayout.replaceAll(entry.key, entry.value));
      }
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

  /// Like [_norm], but keeps text inside parentheses/brackets. This matters
  /// for catalogue titles such as "Sunflower (Spider-Man...)": a cover often
  /// writes the subtitle plainly while the original keeps it in brackets.
  static String _normFull(String s) => s
      .toLowerCase()
      .replaceAll('ё', 'е')
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

  static int _editDistance(String a, String b, {int max = 3}) {
    if ((a.length - b.length).abs() > max) return max + 1;
    if (a.isEmpty) return b.length;
    if (b.isEmpty) return a.length;
    var previous = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final current = <int>[i];
      var rowMin = i;
      for (var j = 1; j <= b.length; j++) {
        final value = math.min(
          math.min(current[j - 1] + 1, previous[j] + 1),
          previous[j - 1] + (a[i - 1] == b[j - 1] ? 0 : 1),
        );
        current.add(value);
        rowMin = math.min(rowMin, value);
      }
      if (rowMin > max) return max + 1;
      previous = current;
    }
    return previous.last;
  }

  static bool _fuzzyWordEquals(String a, String b) {
    if (a == b) return true;
    if (a.length < 4 || b.length < 4) return false;
    final limit = math.max(a.length, b.length) >= 8 ? 2 : 1;
    return _editDistance(a, b, max: limit) <= limit;
  }

  static bool _hasFuzzyPhrase(String text, String query) {
    final queryWords = _words(query);
    final textWords = _words(text);
    if (queryWords.isEmpty || textWords.length < queryWords.length) {
      return false;
    }
    for (var start = 0;
        start <= textWords.length - queryWords.length;
        start++) {
      if (List.generate(queryWords.length,
              (i) => _fuzzyWordEquals(queryWords[i], textWords[start + i]))
          .every((value) => value)) {
        return true;
      }
    }
    return false;
  }

  /// Whole-word phrase containment ("faded" in "alan walker faded").
  static bool _hasPhrase(String haystack, String needle) =>
      needle.isNotEmpty && ' $haystack '.contains(' $needle ');

  /// Spaces removed, so the uploader "theneighbourhood" equals "The Neighbourhood".
  static String _compact(String s) => s.replaceAll(' ', '');

  static final Map<String, RegExp> _variantPatterns = {
    'remix': RegExp(r'\b(remix|rmx|rework|vip)\b'),
    'edit': RegExp(r'\b(edit|bootleg|flip)\b'),
    'mashup': RegExp(r'\bmash ?up\b'),
    'cover': RegExp(r'\b(cover|tribute)\b'),
    'speed': RegExp(
        r'\b(slowed|reverb|sped|speed ?up|nightcore|8d|bass ?boost(ed)?)\b'),
    'live': RegExp(r'\blive\b'),
    'acoustic': RegExp(r'\bacoustic\b'),
    'instrumental': RegExp(r'\b(instrumental|karaoke)\b|минус'),
    'extended': RegExp(r'\bextended\b'),
    'demo': RegExp(r'\b(demo|snippet)\b'),
  };

  /// Kinds of alternate versions named in a title ("remix", "live", ...).
  static Set<String> _variantTags(String rawTitle) {
    final t = rawTitle.toLowerCase();
    return {
      for (final e in _variantPatterns.entries)
        if (e.value.hasMatch(t)) e.key,
    };
  }

  /// Public variant information used by radio/import quality filters.
  static Set<String> variantTags(String rawTitle) => _variantTags(rawTitle);

  /// Drops the artist from the start or end of a title, the way SoundCloud
  /// uploads are often named ("The Neighbourhood - Sweater Weather").
  static String _stripArtist(String title, String artist) {
    final target = _compact(artist);
    if (target.isEmpty) return title;
    final words = _words(title);
    for (var k = math.min(4, words.length - 1); k >= 1; k--) {
      if (_compact(_loose(words.take(k).join(' '))) == target) {
        return words.skip(k).join(' ');
      }
      if (_compact(_loose(words.skip(words.length - k).join(' '))) == target) {
        return words.take(words.length - k).join(' ');
      }
    }
    return title;
  }

  /// Scores a SoundCloud [candidate] as the playable copy of a catalog
  /// [target]. Alternate versions the catalog title doesn't name (a remix
  /// filed under the original title) are pushed far down, and the artist's
  /// own upload, recognized by its play count, rises to the top.
  static double scoreCandidate(
    MediaTrack target,
    MediaTrack candidate, {
    int plays = 0,
  }) {
    final primaryArtist = _primaryArtist(target.artist);
    final cleanTitle = _cleanTitle(target.title);
    final query = '$primaryArtist $cleanTitle'.trim();
    final normTitle = _norm(cleanTitle);
    final normArtist = _loose(_norm(primaryArtist));
    final artistWords = _words(normArtist).where((w) => w.length > 2).toList();

    final a = _loose(_norm(candidate.artist));
    final t = _stripArtist(_norm(candidate.title), normArtist);
    final tl = _loose(_norm(candidate.title));
    double s = scoreTrack(candidate, query);

    if (t == normTitle) {
      s += 150.0;
    } else if (_hasPhrase(t, normTitle)) {
      s += 60.0;
    }
    if (_compact(a) == _compact(normArtist)) {
      s += 140.0;
    } else if (_hasPhrase(a, normArtist)) {
      s += 50.0;
    }
    if (artistWords.isNotEmpty &&
        !artistWords.any((w) => tl.contains(w) || a.contains(w))) {
      s -= 160.0;
    }

    final wanted = _variantTags(target.title);
    for (final tag in _variantTags(candidate.title)) {
      if (!wanted.contains(tag)) s -= 260.0;
    }

    final wantSec = target.duration.inSeconds;
    final gotSec = candidate.duration.inSeconds;
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

    if (plays > 0) {
      s += math.min(math.log(plays) / math.ln10 * 15.0, 120.0);
    }
    return s;
  }

  static bool isPlayableMatch(MediaTrack target, MediaTrack candidate) {
    final primaryArtist = _primaryArtist(target.artist);
    final targetArtist = _loose(_norm(primaryArtist));
    final targetTitle = _loose(_norm(_cleanTitle(target.title)));
    final candidateArtist = _loose(_norm(candidate.artist));
    final candidateFullTitle = _loose(_norm(candidate.title));
    final candidateTitle = _stripArtist(candidateFullTitle, targetArtist);

    final titleMatches = candidateTitle == targetTitle ||
        _hasPhrase(candidateTitle, targetTitle);
    final artistMatches = _compact(candidateArtist) == _compact(targetArtist) ||
        _hasPhrase(candidateArtist, targetArtist) ||
        _hasPhrase(candidateFullTitle, targetArtist) ||
        _compact(candidateFullTitle).contains(_compact(targetArtist));
    if (!titleMatches || !artistMatches) return false;

    final targetTags = _variantTags(target.title);
    final candidateTags = _variantTags(candidate.title);
    if (targetTags.length != candidateTags.length ||
        !targetTags.containsAll(candidateTags)) {
      return false;
    }

    final targetSeconds = target.duration.inSeconds;
    final candidateSeconds = candidate.duration.inSeconds;
    if (targetSeconds >= 60 && candidateSeconds >= 60) {
      final allowedDifference = math.max(12, (targetSeconds * 0.08).round());
      if ((targetSeconds - candidateSeconds).abs() > allowedDifference) {
        return false;
      }
    }

    return true;
  }

  static String _primaryArtist(String artist) => artist
      .split(RegExp(r'[,&]'))
      .first
      .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
      .trim();

  static String _cleanTitle(String title) =>
      title.replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '').trim();

  /// Calculates a quality and relevance score for a track given the user's query.
  /// Original tracks get high bonuses; covers, 1-hour loops, and bootlegs are penalized.
  static double scoreTrack(MediaTrack track, String query) {
    final q = _norm(query);
    final title = _norm(track.title);
    final fullTitle = _normFull(track.title);
    final artist = _norm(track.artist);
    final rawTitle = track.title.toLowerCase();

    double score = 100.0;
    if (q.isEmpty) return score;

    // 1. Title matching. A query that is the start of a title ("sweater" for
    //    "Sweater Weather") counts almost as much as the exact title.
    double titleScore(String candidate) {
      if (candidate == q) return 200.0;
      if (candidate.startsWith('$q ')) return 190.0;
      if (_hasPhrase(candidate, q)) return 110.0;
      if (candidate.startsWith(q)) return 90.0;
      if (_hasFuzzyPhrase(candidate, q)) return 135.0;
      return 0.0;
    }

    final titleMatchScore = math.max(titleScore(title), titleScore(fullTitle));
    if (titleMatchScore > 0) {
      score += titleMatchScore;
    }

    // 2. Artist matching (digits loosened: "madk1d" == "madkid").
    final qLoose = _loose(q);
    final artistLoose = _loose(artist);
    if (artist.isNotEmpty) {
      if (_hasPhrase(qLoose, artistLoose)) {
        score += 120.0; // user typed the artist
      } else if (_hasPhrase(artistLoose, qLoose) ||
          artistLoose.startsWith(qLoose)) {
        score += 80.0;
      }
      if ('$artist $title' == q || '$title $artist' == q) score += 150.0;
    }

    // 3. Word-level coverage, with prefix matching for partial words.
    final qWords = _words(qLoose).where((w) => w.length >= 2).toList();
    if (qWords.isNotEmpty) {
      final titleWords = _words(_loose(fullTitle));
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
        } else if (titleWords.any((w) => _fuzzyWordEquals(w, word))) {
          score += 28.0;
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
    final coverArtist = RegExp(
      r'\b(acoustic|cover|covers|tribute|karaoke|quartet|orchestra|ensemble|instrumental|piano version)\b',
    );
    if (!coverArtist.hasMatch(rawQuery) && coverArtist.hasMatch(artist)) {
      score -= 130.0;
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
      return qWords.every((q) =>
              words.any((w) => w.startsWith(q) || _fuzzyWordEquals(w, q))) ||
          _hasFuzzyPhrase(_normFull(t.title), _normFull(query));
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
    final cacheKey = '$normalizedQuery|$includeSoundCloud|$includeSpotify';
    final cached = _searchCache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);
    if (_searchCache.length >= 50) {
      _searchCache.remove(_searchCache.keys.first);
    }

    final searchQueries = getSearchQueries(normalizedQuery);
    final rawResults = <MediaTrack>[];
    final bonus = <String, double>{};
    String keyOf(MediaTrack t) => '${t.source.name}:${t.id}';

    Future<void> collect(
        Future<List<MediaTrack>> request, int queryIndex) async {
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
      final catalogRequests = <Future<List<MediaTrack>>>[];
      if (includeSpotify) {
        final countries =
            _cyrillic.hasMatch(q) ? const ['ru'] : const ['us', 'ru'];
        catalogRequests.addAll(countries.map(
          (country) => _spotifyCatalog.searchTracks(q, country: country),
        ));
      }
      await Future.wait([
        if (withSoundCloud) collect(_scExtractor.searchTracks(q), i),
        ...catalogRequests.map((request) => collect(request, i)),
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
      // The catalog's order and metadata are substantially more reliable than
      // SoundCloud upload titles. Keep that preference modest so a genuinely
      // stronger SoundCloud match can still appear, but enough to stop noisy
      // reposts from displacing a full catalog match.
      if (t.source == TrackSource.spotify &&
          _hasFullMatch(<MediaTrack>[t], normalizedQuery)) {
        best += 55.0;
      }
      return best + (bonus[keyOf(t)] ?? 0.0);
    }

    // Collapse the same song from several uploads/sources into one entry.
    // The catalog copy wins (better metadata); the group keeps its best score.
    final groups = <String, ({MediaTrack track, double score})>{};
    for (final track in rawResults) {
      final s = scoreOf(track);
      // Version tags keep "Song (Remix)" apart from "Song".
      final tags = _variantTags(track.title).toList()..sort();
      final key =
          '${_norm(track.title)}|${_loose(_norm(track.artist))}|${tags.join(',')}';
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

    final output = ranked.take(30).map((e) => e.track).toList(growable: false);
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

    // Preserve featured artists and release subtitles in precise searches.
    final primaryArtist = _primaryArtist(track.artist);
    final cleanTitle = _cleanTitle(track.title);
    final fullArtist = track.artist.trim();
    final fullTitle = track.title.trim();
    final compactQuery = '$primaryArtist $cleanTitle'.trim();
    final queries = <String>{
      '$fullArtist $fullTitle'.trim(),
      '$primaryArtist $fullTitle'.trim(),
      compactQuery,
    }.where((value) => value.isNotEmpty).toList(growable: false);

    // Merge result sets; isPlayableMatch remains authoritative.
    final candidates = <MediaTrack>[];
    final candidateIds = <String>{};
    for (final candidateQuery in queries) {
      try {
        final scResults = await _scExtractor.searchTracks(
          candidateQuery,
          limit: candidateQuery == compactQuery ? 12 : 24,
        );
        for (final candidate in scResults) {
          if (!_badMatches.contains(candidate.id) &&
              candidateIds.add(candidate.id)) {
            candidates.add(candidate);
          }
        }
      } catch (_) {}
    }
    if (candidates.isEmpty) return null;

    // 3. Score candidates, then permit only a strict original-match contract.
    final scored = [
      for (final c in candidates)
        (
          track: c,
          score:
              scoreCandidate(track, c, plays: _scExtractor.playbackCount(c.id)),
        ),
    ]..sort((a, b) => b.score.compareTo(a.score));

    for (final entry in scored) {
      final candidate = entry.track;
      if (!isPlayableMatch(track, candidate)) continue;

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

  /// Gets related SoundCloud tracks for a seed, resolving a catalog seed to
  /// the best matching SoundCloud upload when necessary.
  Future<List<MediaTrack>> relatedTracks(MediaTrack seed,
      {int limit = 20}) async {
    if (seed.source == TrackSource.soundcloud) {
      return _scExtractor.relatedTracks(seed.id, limit: limit);
    }
    final match = await _findSoundCloudMatch(seed);
    if (match == null) return const [];
    return _scExtractor.relatedTracks(match.id, limit: limit);
  }

  Future<MediaTrack?> _findSoundCloudMatch(MediaTrack track) async {
    final query =
        '${_primaryArtist(track.artist)} ${_cleanTitle(track.title)}'.trim();
    final candidates = await _scExtractor.searchTracks(query, limit: 12);
    final usable =
        candidates.where((candidate) => !_badMatches.contains(candidate.id));
    MediaTrack? best;
    var bestScore = double.negativeInfinity;
    for (final candidate in usable) {
      final score = scoreCandidate(
        track,
        candidate,
        plays: _scExtractor.playbackCount(candidate.id),
      );
      if (score > bestScore) {
        bestScore = score;
        best = candidate;
      }
    }
    return best;
  }

  void dispose() {
    _scExtractor.close();
    _spotifyCatalog.close();
  }
}
