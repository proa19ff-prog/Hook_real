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

  /// Searches tracks across selected sources or both.
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

    final results = <MediaTrack>[];

    final futures = <Future<List<MediaTrack>>>[];
    if (includeYouTube) {
      futures.add(_ytExtractor.searchTracks(normalizedQuery));
    }
    if (includeSoundCloud) {
      futures.add(_scExtractor.searchTracks(normalizedQuery));
    }

    if (futures.isEmpty) return const [];

    // A broken source must not make the other source look like it failed.
    // Also keep a hung extractor from leaving the search screen in a spinner.
    final responses = await Future.wait(
      futures.map(
        (future) => future.timeout(
          const Duration(seconds: 10),
          onTimeout: () => <MediaTrack>[],
        ),
      ),
    );
    for (final list in responses) {
      results.addAll(list);
    }

    final unique = <String, MediaTrack>{};
    for (final track in results) {
      unique['${track.source.name}:${track.id}'] = track;
    }
    final output = unique.values.take(30).toList(growable: false);
    // Do not cache an empty result: it is usually a network hiccup, and
    // caching it would make the same query fail until the app restarts.
    if (output.isNotEmpty) _searchCache[cacheKey] = output;
    return output;
  }

  /// Resolves the actual playable stream URL for a given track based on its source.
  Future<String?> resolveStreamUrl(MediaTrack track) async {
    // Extractor URLs are commonly signed and expire. Persisted search results
    // must not blindly reuse one after it has gone stale; local tracks are the
    // only source whose URL is durable by definition.
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
      case TrackSource.local:
        return track.streamUrl;
    }
  }

  void dispose() {
    _ytExtractor.close();
    _scExtractor.close();
  }
}
