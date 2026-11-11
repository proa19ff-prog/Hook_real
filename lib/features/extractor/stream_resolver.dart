import 'dart:async';
import 'dart:math' as math;

import '../../core/diagnostics/playback_diagnostics.dart';
import '../search/domain/search_query_normalizer.dart';
import 'models/media_track.dart';
import 'models/resolved_stream.dart';
import 'soundcloud/soundcloud_extractor.dart';
import 'sources/music_source.dart';
import 'sources/remote_resolver_source.dart';
import 'sources/youtube_music_source.dart';
import 'spotify/spotify_catalog_service.dart';

class StreamResolver {
  /// How long a DIRECT YouTube attempt (playback manifest or download
  /// resolve) may take before the request moves to the resolver server.
  /// Tune this one value to make the fallback faster or more patient.
  static const Duration directYouTubeTimeout = Duration(seconds: 4);

  final SoundCloudExtractor _scExtractor;
  final SpotifyCatalogService _spotifyCatalog;
  final List<MusicSource> _additionalSources;
  final Duration _searchTimeout;
  final Duration _resolveTimeout;
  final Map<String, List<MediaTrack>> _searchCache = {};
  bool _disposed = false;

  StreamResolver({
    SoundCloudExtractor? scExtractor,
    SpotifyCatalogService? spotifyCatalog,
    List<MusicSource>? additionalSources,
    this._searchTimeout = const Duration(seconds: 9),
    // Room for the YouTube client chain (7s cap per client) to try several
    // Innertube clients before the source is declared unavailable.
    this._resolveTimeout = const Duration(seconds: 20),
  }) : _scExtractor = scExtractor ?? SoundCloudExtractor(),
       _spotifyCatalog = spotifyCatalog ?? SpotifyCatalogService(),
       _additionalSources =
           additionalSources ?? [YouTubeMusicSource(), RemoteResolverSource()];

  static String fixKeyboardLayout(String input) =>
      SearchQueryNormalizer.fixKeyboardLayout(input);

  /// The self-hosted resolver, when one is wired in. The download path uses
  /// it to package tracks the device cannot save on its own network.
  RemoteResolverSource? get remoteSource {
    for (final source in _additionalSources) {
      if (source is RemoteResolverSource) return source;
    }
    return null;
  }

  List<String> getSearchQueries(String query) =>
      SearchQueryNormalizer.variants(query);

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
    for (
      var start = 0;
      start <= textWords.length - queryWords.length;
      start++
    ) {
      if (List.generate(
        queryWords.length,
        (i) => _fuzzyWordEquals(queryWords[i], textWords[start + i]),
      ).every((value) => value)) {
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

  // Permit joined stage names (PostMalone), not substrings in another artist
  // (MadKid inside NotMadKid). Uploader titles may carry the performer credit.
  static bool _hasArtist(String text, String artist) {
    final wanted = _compact(_loose(_norm(artist)));
    if (wanted.isEmpty) return false;
    final words = _words(_loose(_normFull(text)));
    for (var start = 0; start < words.length; start++) {
      var phrase = '';
      for (var end = start; end < words.length; end++) {
        phrase += words[end];
        if (phrase == wanted) return true;
        if (phrase.length >= wanted.length) break;
      }
    }
    return false;
  }

  static List<String> _artists(String value) => value
      .split(
        RegExp(
          r'\s*(?:[,;&]|\bfeat\.?|\bft\.?)\s*|\s+(?:and|x)\s+',
          caseSensitive: false,
        ),
      )
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  /// Importing catalog metadata is not a free-text search: keep the exact
  /// song and every supplied performer. A title-only hit must not replace a
  /// precise export just because it scored above a generic search threshold.
  static bool isCatalogMetadataMatch(MediaTrack target, MediaTrack candidate) {
    if (_loose(_norm(_cleanTitle(target.title))) !=
        _loose(_norm(_cleanTitle(candidate.title)))) {
      return false;
    }
    final wantedTags = _variantTags(target.title);
    final foundTags = _variantTags(candidate.title);
    if (wantedTags.length != foundTags.length ||
        !wantedTags.containsAll(foundTags)) {
      return false;
    }
    return _artists(target.artist)
        .every((artist) => _hasArtist(candidate.artist, artist));
  }

  static final Map<String, RegExp> _variantPatterns = {
    'remix': RegExp(r'\b(remix|rmx|rework|vip)\b'),
    'edit': RegExp(r'\b(edit|bootleg|flip)\b'),
    'mashup': RegExp(r'\bmash ?up\b'),
    'cover': RegExp(r'\b(cover|tribute)\b'),
    'speed': RegExp(
      r'\b(slowed|reverb|sped|speed ?up|nightcore|8d|bass ?boost(ed)?)\b',
    ),
    'live': RegExp(r'\blive\b'),
    'acoustic': RegExp(r'\bacoustic\b'),
    'instrumental': RegExp(r'\b(instrumental|karaoke)\b|минус'),
    'extended': RegExp(r'\bextended\b'),
    'demo': RegExp(r'\b(demo|snippet|preview|teaser)\b'),
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
        s += 90.0 - diff * 15.0;
      } else if (diff <= 12) {
        s += 40.0;
      } else if (diff > 30) {
        s -= 120.0;
      }
    }

    final count = plays > 0 ? plays : candidate.playbackCount;
    if (count > 0) {
      s += math.min(math.log(count) / math.ln10 * 15.0, 120.0);
    }
    return s;
  }

  static bool isPlayableMatch(MediaTrack target, MediaTrack candidate) {
    final primaryArtist = _primaryArtist(target.artist);
    final targetArtist = _loose(_norm(primaryArtist));
    final targetTitle = _loose(_norm(_cleanTitle(target.title)));
    final candidateFullTitle = _loose(_norm(candidate.title));
    final candidateTitle = _stripArtist(candidateFullTitle, targetArtist);
    if (targetArtist.isEmpty ||
        targetTitle.isEmpty ||
        candidateFullTitle.isEmpty) {
      return false;
    }

    final titleMatches =
        candidateTitle == targetTitle ||
        _hasPhrase(candidateTitle, targetTitle);
    final artistMatches = _artists(target.artist).every((artist) {
      final credit = _primaryArtist(artist);
      // Credits inside '(feat. ...)' are identity evidence too. Title matching
      // above still ignores decorations; alternate-version checks stay strict.
      return _hasArtist(candidate.artist, credit) ||
          _hasArtist(candidate.title, credit);
    });
    if (!titleMatches || !artistMatches) return false;

    final targetTags = _variantTags(target.title);
    final candidateTags = _variantTags(candidate.title);
    if (targetTags.length != candidateTags.length ||
        !targetTags.containsAll(candidateTags)) {
      return false;
    }

    final targetSeconds = target.duration.inSeconds;
    final candidateSeconds = candidate.duration.inSeconds;
    if (targetSeconds > 0) {
      // Unknown lengths and 30-second previews cannot satisfy a known release.
      if (candidateSeconds <= 0) return false;
      final allowedDifference = math.max(4, (targetSeconds * 0.03).round());
      if ((targetSeconds - candidateSeconds).abs() > allowedDifference) {
        return false;
      }
    }

    return true;
  }

  static String _primaryArtist(String artist) =>
      (_artists(artist).firstOrNull ?? '')
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
      } else if (qWords.length >= 2) {
        // Popularity never compensates for missing the explicitly typed artist.
        score -= (qWords.length - matched) * 100.0;
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
    final qWords = _words(_loose(_norm(query)))
        .where((w) => w.length >= 2)
        .toList();
    if (qWords.isEmpty) return true;
    return tracks.any((t) {
      final words = _words(_loose(_norm('${t.title} ${t.artist}')));
      return qWords.every(
            (q) => words.any((w) => w.startsWith(q) || _fuzzyWordEquals(w, q)),
          ) ||
          _hasFuzzyPhrase(_normFull(t.title), _normFull(query));
    });
  }

  /// Popularity signal from the source's own ordering. The catalog orders by
  /// popularity; SoundCloud ordering is noisier, so its play count weighs in.
  int _playCount(MediaTrack track) => track.playbackCount > 0
      ? track.playbackCount
      : track.source == TrackSource.soundcloud
      ? _scExtractor.playbackCount(track.id)
      : 0;

  double _rankBonus(MediaTrack track, int position) {
    final plays = _playCount(track);
    if (plays > 0) {
      // Comparable matches use the source's real views/plays, not just the
      // opaque search position. Bounded below one missing query-word penalty.
      return math.min(math.log(plays) / math.ln10 * 12.0, 90.0);
    }
    return math.max(0.0, 30.0 - 4.0 * position);
  }

  /// Searches independent sources in parallel. An explicit [sources] filter is
  /// respected exactly; catalog discovery never masquerades as Spotify audio.
  Future<List<MediaTrack>> search({
    required String query,
    bool includeSoundCloud = true,
    bool includeSpotify = true,
    Set<TrackSource>? sources,
  }) async {
    final normalizedQuery = SearchQueryNormalizer.normalize(query);
    if (normalizedQuery.isEmpty || _disposed) return const [];
    final selected =
        sources ??
        {
          if (includeSoundCloud) TrackSource.soundcloud,
          if (includeSpotify) TrackSource.spotify,
          ..._additionalSources.map((source) => source.source),
        };
    if (selected.isEmpty) return const [];
    final names = selected.map((source) => source.name).toList()..sort();
    final cacheKey = '$normalizedQuery|${names.join(',')}';
    final cached = _searchCache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);

    final searchQueries = getSearchQueries(normalizedQuery);
    final rawResults = <MediaTrack>[];
    final bonus = <String, double>{};
    var hadFailure = false;

    Future<void> collect(
      Future<List<MediaTrack>> request,
      int queryIndex,
      TrackSource source,
    ) async {
      try {
        final list = await request.timeout(_searchTimeout);
        PlaybackDiagnostics.record(
          'search.completed',
          source: source.name,
          count: list.length,
        );
        for (var i = 0; i < list.length; i++) {
          final track = list[i];
          if (!selected.contains(track.source)) continue;
          final rank = _rankBonus(track, i) * (queryIndex == 0 ? 1.0 : 0.8);
          bonus[_matchKey(track)] = math.max(
            bonus[_matchKey(track)] ?? 0,
            rank,
          );
          rawResults.add(track);
        }
      } catch (error) {
        // One blocked source must not discard another source's results.
        PlaybackDiagnostics.record(
          'search.failed',
          source: source.name,
          error: error,
        );
        hadFailure = true;
      }
    }

    Future<void> retrieve(String q) => Future.wait<void>([
      if (selected.contains(TrackSource.spotify))
        collect(
          _spotifyCatalog.searchTracks(
            q,
            country: _cyrillic.hasMatch(q) ? 'ru' : 'us',
          ),
          searchQueries.indexOf(q),
          TrackSource.spotify,
        ),
      if (selected.contains(TrackSource.soundcloud))
        collect(
          _scExtractor.searchTracks(q),
          searchQueries.indexOf(q),
          TrackSource.soundcloud,
        ),
      for (final source in _additionalSources)
        if (selected.contains(source.source))
          collect(
            source.searchTracks(q),
            searchQueries.indexOf(q),
            source.source,
          ),
    ]).then((_) {});

    final layout = fixKeyboardLayout(normalizedQuery);
    // Always retrieve meaningful phonetic variants, even if the original query
    // already returned many irrelevant uploads. Pure layout guessing is last.
    final primary = searchQueries.where(
      (q) => q == normalizedQuery || q != layout,
    );
    await Future.wait(primary.map(retrieve));
    if (layout != normalizedQuery &&
        searchQueries.contains(layout) &&
        !primary.any((q) => _hasFullMatch(rawResults, q))) {
      await retrieve(layout);
    }
    if (_disposed || rawResults.isEmpty) return const [];

    double scoreOf(MediaTrack track) {
      var best = scoreTrack(track, normalizedQuery);
      for (final variant in searchQueries.skip(1)) {
        best = math.max(best, scoreTrack(track, variant) - 25);
      }
      if (track.source.isCatalog &&
          searchQueries.any((q) => _hasFullMatch([track], q))) {
        best += 55;
      }
      return best + (bonus[_matchKey(track)] ?? 0);
    }

    final groups = <String, ({MediaTrack track, double score})>{};
    for (final track in rawResults) {
      if (!track.source.isCatalog) _rememberDiscovery(track);
      final score = scoreOf(track);
      final tags = _variantTags(track.title).toList()..sort();
      var key =
          '${_norm(track.title)}|${_loose(_norm(track.artist))}|${tags.join(',')}';
      var existing = groups[key];
      // Don't hide a materially different recording with identical metadata.
      if (existing != null &&
          track.duration > Duration.zero &&
          existing.track.duration > Duration.zero &&
          (existing.track.duration - track.duration).inSeconds.abs() > 5) {
        key = '$key|${track.duration.inSeconds}';
        existing = groups[key];
      }
      final preferNew =
          existing == null ||
          (!existing.track.source.isCatalog &&
              (track.source.isCatalog || score > existing.score));
      groups[key] = (
        track: preferNew ? track : existing.track,
        score: math.max(score, existing?.score ?? score),
      );
    }
    final ranked = groups.values.toList()
      ..sort((a, b) {
        final score = b.score.compareTo(a.score);
        return score != 0
            ? score
            : _matchKey(a.track).compareTo(_matchKey(b.track));
      });
    final output = ranked
        .take(40)
        .map((entry) => entry.track)
        .toList(growable: false);
    if (!hadFailure) {
      if (_searchCache.length >= 50) {
        _searchCache.remove(_searchCache.keys.first);
      }
      _searchCache[cacheKey] = output;
    }
    return List.unmodifiable(output);
  }

  /// Recordings by one artist for the artist screen: the structured catalog
  /// discography merged with a multi-source text search. The search half
  /// keeps its relevance order at the top, canonical album tracks follow.
  /// Anything not actually by the wanted performer is dropped — text search
  /// freely returns same-titled songs by someone else.
  Future<List<MediaTrack>> artistTracks(String artistName, {int limit = 50}) async {
    final name = artistName.trim();
    if (name.isEmpty || _disposed) return const [];
    final results = await Future.wait([
      _spotifyCatalog.artistTopSongs(name, limit: limit),
      search(
        query: name,
        sources: {
          TrackSource.spotify,
          TrackSource.soundcloud,
          ..._additionalSources.map((source) => source.source),
        },
      ),
    ]);
    if (_disposed) return const [];
    final discography = results[0];
    final searched = results[1];

    bool byArtist(MediaTrack track) {
      final wanted = _artists(name);
      final got = _artists(track.artist);
      return wanted.any((w) =>
          got.any((g) => _hasArtist(g, w) || _hasArtist(w, g)));
    }

    String dedupKey(MediaTrack track) =>
        '${_norm(track.title)}|${_loose(_norm(track.artist))}';

    final output = <MediaTrack>[];
    final seen = <String>{};
    void addAll(Iterable<MediaTrack> list) {
      for (final track in list) {
        if (!byArtist(track)) continue;
        if (!seen.add(dedupKey(track))) continue;
        output.add(track);
      }
    }

    addAll(searched);
    addAll(discography);
    return List.unmodifiable(output.take(limit));
  }

  /// Source-specific entries retain their identity. Only catalog entries are
  /// matched across providers; a selected upload never silently becomes another.
  Future<ResolvedStream?> resolveStream(MediaTrack track) async {    if (_disposed) return null;
    if (track.source.isCatalog) return resolveSpotifyTrack(track);
    if (track.source == TrackSource.local) {
      final url = track.streamUrl;
      return url == null || url.isEmpty
          ? null
          : ResolvedStream(url, source: track.source);
    }
    if (track.source == TrackSource.soundcloud) {
      final stream = await _scExtractor.resolveAudioStream(track.id);
      return stream == null || stream.url.isEmpty
          ? null
          : ResolvedStream(
              stream.url,
              source: track.source,
              duration: track.duration,
              bitrateKbps: stream.bitrateKbps,
            );
    }
    for (final source in _additionalSources) {
      if (source.source != track.source) continue;
      final remote = remoteSource;
      // YouTube is the one source where the direct url fails often enough to
      // matter, and waiting out a 4 s timeout before asking the server was the
      // longest single stall in the playback path. Ask both at once instead:
      // the server answers a cached track in about a millisecond, the direct
      // attempt wins whenever the carrier lets it through.
      if (source is YouTubeMusicSource && remote != null) {
        return _raceDirectAndServer(track, source, remote);
      }
      Object? directFailure;
      StackTrace? directStack;
      Object? ageFailure;
      try {
        final attempt = source.resolveTrack(track);
        // Only YouTube gets the short leash: its direct URLs are the ones
        // carriers refuse, and the server fallback is strictly better there.
        final direct = source is YouTubeMusicSource
            ? await attempt.timeout(directYouTubeTimeout)
            : await attempt;
        if (direct != null && !direct.isEmpty) return direct;
      } catch (error, stack) {
        directFailure = error;
        directStack = stack;
      }
      // A direct source answered 403/region-locked (everyday reality on
      // carrier networks): the server can still proxy the very same
      // recording, so a YouTube search result stays playable everywhere.
      if (remote != null && remote != source) {
        try {
          final viaServer = await remote.resolveTrack(track);
          if (viaServer != null && !viaServer.isEmpty) {
            PlaybackDiagnostics.record(
              'playback.server.fallback',
              source: source.source.name,
            );
            return viaServer;
          }
        } on AgeRestrictedStreamException catch (error) {
          // Keep the honest reason: the direct source failed too, and "needs
          // signed-in cookies" is far more useful than "no stream".
          ageFailure = error;
        } catch (_) {
          // Fall through to the original failure below.
        }
      }
      if (ageFailure != null) throw ageFailure;
      if (directFailure != null) {
        Error.throwWithStackTrace(directFailure, directStack!);
      }
      return null;
    }
    return null;
  }

  /// Resolves a YouTube track through both paths at once and returns whichever
  /// produces a playable url first. The direct attempt keeps its short leash;
  /// the server call is only started for a real resolver, never in tests.
  Future<ResolvedStream?> _raceDirectAndServer(
    MediaTrack track,
    MusicSource direct,
    RemoteResolverSource remote,
  ) async {
    Object? directFailure;
    StackTrace? directStack;
    Object? serverAgeFailure;
    var directFailed = false;

    final directAttempt = () async {
      try {
        final stream = await direct.resolveTrack(track).timeout(directYouTubeTimeout);
        if (stream != null && !stream.isEmpty) return stream;
        directFailed = true;
        return null;
      } catch (error, stack) {
        directFailure = error;
        directStack = stack;
        directFailed = true;
        return null;
      }
    }();

    final serverAttempt = () async {
      try {
        final stream = await remote.resolveTrack(track);
        if (stream != null && !stream.isEmpty) return stream;
      } on AgeRestrictedStreamException catch (error) {
        serverAgeFailure = error;
      } catch (_) {
        // The direct result (or its error) still decides below.
      }
      return null;
    }();

    // Wait for the first success instead of a fixed order: a direct url that
    // arrives in 300 ms beats a server url that arrives in 900 ms.
    final first = await Future.any<ResolvedStream?>([
      directAttempt,
      serverAttempt,
    ]);
    if (first != null) {
      if (directFailed) {
        PlaybackDiagnostics.record(
          'playback.server.fallback',
          source: direct.source.name,
        );
      }
      return first;
    }
    // Neither answered in time; give the remaining one a fair chance while
    // still surfacing the original error if both are empty.
    final settled = await Future.wait<ResolvedStream?>([
      directAttempt,
      serverAttempt,
    ]);
    final winner = settled.whereType<ResolvedStream>().firstOrNull;
    if (winner != null) {
      PlaybackDiagnostics.record(
        'playback.server.fallback',
        source: direct.source.name,
      );
      return winner;
    }
    // The server's refusal is the actionable one: cookies are missing or
    // stale, which the user can fix, unlike a carrier-level 403.
    if (serverAgeFailure != null) throw serverAgeFailure!;
    if (directFailure != null) {
      Error.throwWithStackTrace(directFailure!, directStack!);
    }
    return null;
  }

  /// Resolve the selected recording for an unchanged, full-file download.
  /// YouTube's native playback probe uses Range; a full GET can still work
  /// when that probe or the device's streaming decoder fails.
  Future<ResolvedStream?> resolveDownloadStream(MediaTrack track) async {
    if (_disposed) return null;
    if (track.source == TrackSource.youtubeMusic) {
      for (final provider in _additionalSources) {
        if (provider is YouTubeMusicSource) {
          return provider
              .resolveDownloadTrack(track)
              .timeout(directYouTubeTimeout);
        }
      }
    }
    if (track.source == TrackSource.soundcloud) {
      // A single saveable file only: skip HLS playlists that stream fine but
      // cannot be stored as one audio file.
      final stream = await _scExtractor.resolveAudioStream(
        track.id,
        fullFileOnly: true,
      );
      return stream == null || stream.url.isEmpty
          ? null
          : ResolvedStream(
              stream.url,
              source: track.source,
              duration: track.duration,
              bitrateKbps: stream.bitrateKbps,
            );
    }
    // A catalog entry still goes through the strict recording matcher. Direct
    // uploads must never silently become another provider's upload.
    return resolveStream(track);
  }

  Future<String?> resolveStreamUrl(MediaTrack track) async =>
      (await resolveStream(track))?.url;

  Future<bool> checkYouTubeAvailability() {
    if (_disposed) return Future.value(false);
    for (final source in _additionalSources) {
      if (source is YouTubeMusicSource) return source.checkAvailability();
    }
    return Future.value(false);
  }

  final Map<String, MediaTrack> _matchCache = {};
  final Map<String, int> _matchGeneration = {};
  final Map<String, DateTime> _badMatches = {};
  final Map<String, List<MediaTrack>> _discoveryCache = {};

  String _matchKey(MediaTrack track) => '${track.source.name}:${track.id}';
  String _recordingKey(MediaTrack track) {
    final tags = _variantTags(track.title).toList()..sort();
    return '${_norm(_primaryArtist(track.artist))}|${_norm(_cleanTitle(track.title))}|${tags.join(',')}';
  }

  void _rememberDiscovery(MediaTrack track) {
    final key = _recordingKey(track);
    if (!_discoveryCache.containsKey(key) && _discoveryCache.length >= 200) {
      _discoveryCache.remove(_discoveryCache.keys.first);
    }
    final candidates = _discoveryCache.putIfAbsent(key, () => []);
    if (!candidates.contains(track) && candidates.length < 12) {
      candidates.add(track);
    }
  }

  bool _isBadMatch(MediaTrack track) {
    final failedAt = _badMatches[_matchKey(track)];
    return failedAt != null &&
        DateTime.now().difference(failedAt) < const Duration(minutes: 2);
  }

  void _markBad(MediaTrack track) {
    if (_badMatches.length >= 200) _badMatches.remove(_badMatches.keys.first);
    _badMatches[_matchKey(track)] = DateTime.now();
  }

  /// Blacklist failed matches briefly, with source-qualified IDs. A transient
  /// CDN failure must not ban a recording for the lifetime of the app.
  void forgetMatch(MediaTrack track) {
    final key = _matchKey(track);
    _matchGeneration[key] = (_matchGeneration[key] ?? 0) + 1;
    final previous = _matchCache.remove(key);
    if (previous != null) _markBad(previous);
  }

  Future<List<MediaTrack>> _searchSource(
    TrackSource source,
    String query,
  ) async {
    if (source == TrackSource.soundcloud) {
      return _scExtractor.searchTracks(query, limit: 24);
    }
    for (final provider in _additionalSources) {
      if (provider.source == source) {
        return provider.searchTracks(query, limit: 24);
      }
    }
    return const [];
  }

  /// Kept under its historical name for imports/saved catalog records. Each
  /// provider has its own search + resolve path; a blocked one cannot hold up
  /// a usable match from another. The winner alone is remembered.
  Future<ResolvedStream?> resolveSpotifyTrack(
    MediaTrack track, {
    Set<TrackSource> excludedSources = const {},
  }) async {
    if (_disposed || !track.source.isCatalog) return null;
    final key = _matchKey(track);
    final generation = _matchGeneration[key] ?? 0;
    final completion = Completer<ResolvedStream?>();
    final sources = {
      TrackSource.soundcloud,
      ..._additionalSources.map((s) => s.source),
    }.difference(excludedSources);
    if (sources.isEmpty) return null;
    var remaining = sources.length;
    bool active() =>
        !_disposed &&
        !completion.isCompleted &&
        (_matchGeneration[key] ?? 0) == generation;

    for (final source in sources) {
      var finished = false;
      bool sourceActive() => !finished && active();
      unawaited(() async {
        try {
          final match = await _resolveCatalogAtSource(
            track,
            source,
            sourceActive,
          ).timeout(_searchTimeout + _resolveTimeout, onTimeout: () => null);
          if (match != null && active()) {
            if (_matchCache.length >= 200) {
              _matchCache.remove(_matchCache.keys.first);
            }
            _matchCache[key] = match.track;
            completion.complete(match.stream);
          }
        } catch (error) {
          PlaybackDiagnostics.record(
            'catalog.failed',
            source: source.name,
            error: error,
          );
          // Continue with another independent provider.
        } finally {
          finished = true;
          remaining--;
          if (remaining == 0 && !completion.isCompleted) {
            completion.complete(null);
          }
        }
      }());
    }
    return completion.future;
  }

  Future<({MediaTrack track, ResolvedStream stream})?> _resolveCatalogAtSource(
    MediaTrack target,
    TrackSource source,
    bool Function() active,
  ) async {
    final tried = <String>{};
    Future<({MediaTrack track, ResolvedStream stream})?> tryCandidates(
      Iterable<MediaTrack> candidates,
    ) async {
      final ranked =
          candidates
              .where(
                (candidate) =>
                    candidate.source == source &&
                    !_isBadMatch(candidate) &&
                    isPlayableMatch(target, candidate),
              )
              .toList()
            ..sort(
              (a, b) => scoreCandidate(
                target,
                b,
                plays: _playCount(b),
              ).compareTo(scoreCandidate(target, a, plays: _playCount(a))),
            );
      for (final candidate in ranked.take(3)) {
        if (!active()) return null;
        if (!tried.add(_matchKey(candidate))) continue;
        try {
          final resolved = await resolveStream(candidate)
              .timeout(_resolveTimeout);
          if (resolved != null && !resolved.isEmpty && active()) {
            final duration = resolved.duration;
            if (duration != null &&
                !isPlayableMatch(
                  target,
                  candidate.copyWith(duration: duration),
                )) {
              continue;
            }
            return (track: candidate, stream: resolved);
          }
        } catch (error) {
          PlaybackDiagnostics.record(
            'catalog.resolve.failed',
            source: source.name,
            error: error,
          );
        }
      }
      return null;
    }

    final known = _matchCache[_matchKey(target)];
    final cached = await tryCandidates([
      if (known != null) known,
      ...?_discoveryCache[_recordingKey(target)],
    ]);
    if (cached != null || !active()) return cached;

    final compact =
        '${_primaryArtist(target.artist)} ${_cleanTitle(target.title)}'.trim();
    if (compact.isEmpty) return null;
    final queries = <String>{
      compact,
      '${target.artist} ${target.title}'.trim(),
      if (source == TrackSource.youtubeMusic) '$compact audio',
    };
    final batches = await Future.wait(
      queries.map((query) async {
        try {
          return await _searchSource(source, query).timeout(_searchTimeout);
        } catch (error) {
          PlaybackDiagnostics.record(
            'catalog.search.failed',
            source: source.name,
            error: error,
          );
          return <MediaTrack>[];
        }
      }),
    );
    if (!active()) return null;
    final candidates = batches.expand((batch) => batch).toList();
    PlaybackDiagnostics.record(
      'catalog.candidates',
      source: source.name,
      count: candidates.length,
    );
    PlaybackDiagnostics.record(
      'catalog.matches',
      source: source.name,
      count: candidates
          .where(
            (candidate) =>
                candidate.source == source &&
                isPlayableMatch(target, candidate),
          )
          .length,
    );
    return tryCandidates(candidates);
  }

  /// Gets related SoundCloud tracks for a seed, resolving a catalog seed to
  /// the best matching SoundCloud upload when necessary.
  Future<List<MediaTrack>> relatedTracks(
    MediaTrack seed, {
    int limit = 20,
  }) async {
    if (seed.source == TrackSource.soundcloud) {
      return _scExtractor.relatedTracks(seed.id, limit: limit);
    }
    final match = await _findSoundCloudMatch(seed);
    if (match == null) return const [];
    return _scExtractor.relatedTracks(match.id, limit: limit);
  }

  Future<MediaTrack?> _findSoundCloudMatch(MediaTrack track) async {
    final query = '${_primaryArtist(track.artist)} ${_cleanTitle(track.title)}'
        .trim();
    final candidates = await _scExtractor.searchTracks(query, limit: 12);
    final usable = candidates.where(
      (candidate) =>
          !_isBadMatch(candidate) && isPlayableMatch(track, candidate),
    );
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
    _disposed = true;
    _scExtractor.close();
    _spotifyCatalog.close();
    for (final source in _additionalSources) {
      source.close();
    }
  }
}
