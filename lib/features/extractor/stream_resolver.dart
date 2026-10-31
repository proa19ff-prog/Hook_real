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

  /// Calculates a quality and relevance score for a track given the user's query.
  /// Original tracks get high bonuses; covers, 1-hour loops, and bootlegs are penalized.
  static double scoreTrack(MediaTrack track, String query) {
    final q = query.trim().toLowerCase();
    final title = track.title.toLowerCase();
    final artist = track.artist.toLowerCase();

    double score = 100.0;

    // 1. Title matching
    if (title == q) {
      score += 200.0; // exact title match
    } else if (title.startsWith(q) || title.contains(q)) {
      score += 100.0;
    }

    // 2. Artist matching
    if (q.contains(artist) && artist.isNotEmpty) {
      score += 120.0; // user typed the artist
    } else if (artist.contains(q)) {
      score += 80.0;
    }

    // 3. Word-level overlap
    final qWords = q.split(RegExp(r'\s+')).where((w) => w.length > 2);
    for (final word in qWords) {
      if (title.contains(word)) score += 30.0;
      if (artist.contains(word)) score += 40.0;
    }

    // 4. Heavily penalize unofficial edits, bootlegs, and loops
    final isQueryLookingForRemix = q.contains('remix');
    final isQueryLookingForCover = q.contains('cover');
    final isQueryLookingForSpeed = q.contains('sped') || q.contains('slow');

    if (!isQueryLookingForRemix && (title.contains('remix') || title.contains('rmx'))) {
      score -= 80.0;
    }
    if (!isQueryLookingForCover && (title.contains('cover') || title.contains('tribute'))) {
      score -= 100.0;
    }
    if (!isQueryLookingForSpeed) {
      if (title.contains('slowed') ||
          title.contains('reverb') ||
          title.contains('sped up') ||
          title.contains('speed up') ||
          title.contains('nightcore') ||
          title.contains('bass boosted') ||
          title.contains('bassboost') ||
          title.contains('8d audio')) {
        score -= 140.0;
      }
    }

    if (title.contains('1 hour') ||
        title.contains('10 hour') ||
        title.contains('loop') ||
        title.contains('instrumental') ||
        title.contains('karaoke') ||
        title.contains('parody')) {
      score -= 150.0;
    }

    // 5. Prefer normal song durations (between 1:45 and 6:00)
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

    for (final q in searchQueries) {
      final futures = <Future<List<MediaTrack>>>[];
      if (includeSoundCloud) {
        futures.add(_scExtractor.searchTracks(q));
      }
      if (includeSpotify) {
        futures.add(_spotifyCatalog.searchTracks(q));
      }

      if (futures.isEmpty) continue;

      final responses = await Future.wait(
        futures.map(
          (future) => future.timeout(
            const Duration(seconds: 8),
            onTimeout: () => <MediaTrack>[],
          ),
        ),
      );
      for (final list in responses) {
        rawResults.addAll(list);
      }

      // If primary query gave ample results, no need to query subsequent variants
      if (rawResults.length >= 15) break;
    }

    if (rawResults.isEmpty) return const [];

    // Deduplicate by ID and source
    final unique = <String, MediaTrack>{};
    for (final track in rawResults) {
      unique['${track.source.name}:${track.id}'] = track;
    }

    final trackList = unique.values.toList();

    // Rank tracks: original official songs rise to the top!
    trackList.sort((a, b) {
      final scoreA = scoreTrack(a, normalizedQuery);
      final scoreB = scoreTrack(b, normalizedQuery);
      return scoreB.compareTo(scoreA);
    });

    final output = trackList.take(30).toList(growable: false);
    if (output.isNotEmpty) _searchCache[cacheKey] = output;
    return output;
  }

  /// Resolves the actual playable stream for a given track based on its source.
  /// The result carries the HTTP headers the player must send, otherwise
  /// YouTube CDN rejects the request with 403.
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

  /// Normalizes a title/artist string for strict matching: lowercase, strip
  /// parenthetical/bracketed extras, collapse whitespace.
  static String _norm(String s) {
    var v = s
        .toLowerCase()
        .replaceAll(RegExp(r'[\(\[\{].*?[\)\]\}]'), '')
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return v;
  }

  static bool _containsWord(String haystack, Iterable<String> words) =>
      words.any((w) => haystack.contains(w));

  Future<ResolvedStream?> resolveSpotifyTrack(MediaTrack track) async {
    // 1. Clean primary artist and title to form a laser-targeted query
    final primaryArtist = track.artist
        .split(RegExp(r'[,&]'))
        .first
        .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
        .trim();

    final cleanTitle = track.title
        .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
        .trim();

    final query = '$primaryArtist $cleanTitle';

    // 2. Fetch candidates from SoundCloud (extra candidates since junk
    //    re-uploads are common on SoundCloud search).
    final candidates = <MediaTrack>[];

    try {
      final scResults = await _scExtractor.searchTracks(query, limit: 12);
      candidates.addAll(scResults);
    } catch (_) {}

    final normTitle = _norm(cleanTitle);
    final normArtist = _norm(primaryArtist);
    final titleWords = normTitle
        .split(' ')
        .where((w) => w.length > 2)
        .toList();
    final artistWords = normArtist
        .split(' ')
        .where((w) => w.length > 2)
        .toList();

    if (candidates.isEmpty) return null;

    // 3. Score candidates: strict title/artist bonuses on top of the generic
    //    scoreTrack heuristics (which alone lets junk reposts through).
    double candidateScore(MediaTrack c) {
      final t = _norm(c.title);
      final a = _norm(c.artist);
      double s = scoreTrack(c, query);

      if (t == normTitle) {
        s += 150.0;
      } else if (normTitle.isNotEmpty && t.contains(normTitle)) {
        s += 60.0;
      }
      if (a == normArtist) {
        s += 120.0;
      } else if (normArtist.isNotEmpty && a.contains(normArtist)) {
        s += 50.0;
      }
      // Harmonic junk guard: nobody in the whole candidate is the requested
      // artist — distrust uploader-name-only matches.
      if (artistWords.isNotEmpty && !_containsWord(t, artistWords) && !_containsWord(a, artistWords)) {
        s -= 160.0;
      }
      return s;
    }

    candidates.sort((a, b) => candidateScore(b).compareTo(candidateScore(a)));

    // 4. Verify candidate quality: require BOTH a title signal and an artist
    //    signal (word-level, normalized). This blocks reposts like
    //    "NCM - Alan Walker Faded" when the true artist never matches.
    for (final candidate in candidates) {
      final t = _norm(candidate.title);
      final a = _norm(candidate.artist);

      final titleOk = t == normTitle ||
          (normTitle.isNotEmpty && t.contains(normTitle)) ||
          _containsWord(t, titleWords);
      final artistOk = a == normArtist ||
          (normArtist.isNotEmpty && a.contains(normArtist)) ||
          _containsWord(a, artistWords) ||
          _containsWord(t, artistWords);

      if (!titleOk || !artistOk) continue;

      try {
        final resolved = await resolveStream(candidate);
        if (resolved != null && !resolved.isEmpty) return resolved;
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
