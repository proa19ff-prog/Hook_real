import 'innertube/youtube_extractor.dart';
import 'models/media_track.dart';
import 'soundcloud/soundcloud_extractor.dart';

class StreamResolver {
  final YouTubeExtractor _ytExtractor;
  final SoundCloudExtractor _scExtractor;
  final Map<String, List<MediaTrack>> _searchCache = {};

  StreamResolver({
    YouTubeExtractor? ytExtractor,
    SoundCloudExtractor? scExtractor,
  })  : _ytExtractor = ytExtractor ?? YouTubeExtractor(),
        _scExtractor = scExtractor ?? SoundCloudExtractor();

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
  Future<List<MediaTrack>> search({
    required String query,
    bool includeYouTube = true,
    bool includeSoundCloud = true,
  }) async {
    final normalizedQuery = query.trim().toLowerCase();
    final cacheKey = '$normalizedQuery|$includeYouTube|$includeSoundCloud';
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
      if (includeYouTube) {
        futures.add(_ytExtractor.searchTracks(q));
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

  /// Resolves the actual playable stream URL for a given track based on its source.
  Future<String?> resolveStreamUrl(MediaTrack track) async {
    if (track.source == TrackSource.local &&
        track.streamUrl != null &&
        track.streamUrl!.isNotEmpty) {
      return track.streamUrl;
    }

    switch (track.source) {
      case TrackSource.youtube:
        return _ytExtractor.resolveAudioStreamUrl(track.id);

      case TrackSource.soundcloud:
        return _scExtractor.resolveAudioStreamUrl(track.id);

      case TrackSource.spotify:
        return _resolveSpotifyTrack(track);

      case TrackSource.local:
        return track.streamUrl;
    }
  }

  Future<String?> _resolveSpotifyTrack(MediaTrack track) async {
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

    // 2. Fetch candidates from SoundCloud and YouTube
    final candidates = <MediaTrack>[];

    try {
      final scResults = await _scExtractor.searchTracks(query, limit: 6);
      candidates.addAll(scResults);
    } catch (_) {}

    try {
      final ytResults = await _ytExtractor.searchTracks(query, limit: 6);
      candidates.addAll(ytResults);
    } catch (_) {}

    if (candidates.isEmpty) return null;

    // 3. Score all candidates using intelligent relevance ranking
    candidates.sort((a, b) {
      final scoreA = StreamResolver.scoreTrack(a, query);
      final scoreB = StreamResolver.scoreTrack(b, query);
      return scoreB.compareTo(scoreA);
    });

    // 4. Verify candidate quality and resolve audio stream
    final targetWords = cleanTitle
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 2)
        .toList();
    final artistWord = primaryArtist
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .firstWhere((w) => w.length > 2, orElse: () => '');

    for (final candidate in candidates) {
      final cTitle = candidate.title.toLowerCase();
      final cArtist = candidate.artist.toLowerCase();

      final hasTitleOverlap =
          targetWords.isEmpty || targetWords.any((w) => cTitle.contains(w));
      final hasArtistOverlap = artistWord.isEmpty ||
          cArtist.contains(artistWord) ||
          cTitle.contains(artistWord);

      // Skip candidates that don't match either title or artist
      if (!hasTitleOverlap && !hasArtistOverlap) continue;

      try {
        if (candidate.source == TrackSource.soundcloud) {
          final url = await _scExtractor.resolveAudioStreamUrl(candidate.id);
          if (url != null && url.isNotEmpty) return url;
        } else if (candidate.source == TrackSource.youtube) {
          final url = await _ytExtractor.resolveAudioStreamUrl(candidate.id);
          if (url != null && url.isNotEmpty) return url;
        }
      } catch (_) {
        continue;
      }
    }

    return null;
  }

  void dispose() {
    _ytExtractor.close();
    _scExtractor.close();
  }
}
