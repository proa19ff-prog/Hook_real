import '../extractor/models/media_track.dart';
import '../extractor/stream_resolver.dart';

/// Builds repeat-free batches for track radio. Four clean catalog tracks from
/// the seed artist anchor each batch; up to eight filtered related SoundCloud
/// tracks keep the wave surprising and playable.
class TrackWaveService {
  final StreamResolver _resolver;

  TrackWaveService(this._resolver);

  static String trackKey(MediaTrack track) =>
      '${track.artist.toLowerCase().trim()}|${track.title.toLowerCase().trim()}';

  Future<List<MediaTrack>> nextBatch(
    MediaTrack seed, {
    MediaTrack? relatedSeed,
    Set<String> excluded = const {},
    int limit = 12,
  }) async {
    final sourceForRelated = relatedSeed ?? seed;
    final results = await Future.wait([
      _resolver.relatedTracks(sourceForRelated, limit: 24),
      _resolver.search(
        query: seed.artist,
        includeSoundCloud: false,
        includeSpotify: true,
      ),
    ]);
    final related = results[0];
    final artistTracks = results[1];

    final seen = <String>{
      ...excluded.map((key) => key.toLowerCase().trim()),
      trackKey(seed),
    };
    final artists = artistTracks
        .where((track) => _eligible(track, seed, seen))
        .take(4)
        .toList(growable: false);
    final relatedTracks = related
        .where((track) => _eligible(track, seed, seen))
        .take(8)
        .toList(growable: false);

    // Alternate two related discoveries with one familiar artist release.
    // This lands near the intended 8:4 ratio without grouping the same artist
    // tracks together.
    final output = <MediaTrack>[];
    var artistIndex = 0;
    var relatedIndex = 0;
    while (output.length < limit &&
        (artistIndex < artists.length || relatedIndex < relatedTracks.length)) {
      for (var i = 0;
          i < 2 && relatedIndex < relatedTracks.length && output.length < limit;
          i++) {
        final track = relatedTracks[relatedIndex++];
        if (seen.add(trackKey(track))) output.add(track);
      }
      if (artistIndex < artists.length && output.length < limit) {
        final track = artists[artistIndex++];
        if (seen.add(trackKey(track))) output.add(track);
      }
    }
    return output;
  }

  bool _eligible(MediaTrack track, MediaTrack seed, Set<String> seen) {
    if (seen.contains(trackKey(track))) return false;
    final seconds = track.duration.inSeconds;
    if (seconds > 0 && (seconds < 60 || seconds > 600)) return false;

    final seedTags = StreamResolver.variantTags(seed.title);
    final trackTags = StreamResolver.variantTags(track.title);
    if (seedTags.isEmpty && trackTags.isNotEmpty) return false;

    // Related feeds contain a lot of covers, karaoke and reposts. These are
    // useful only when the seed itself explicitly asks for an alternate version.
    final raw = '${track.title} ${track.artist}'.toLowerCase();
    if (seedTags.isEmpty &&
        RegExp(r'\b(cover|tribute|karaoke|nightcore|slowed|reverb|sped|bootleg|mash ?up)\b')
            .hasMatch(raw)) {
      return false;
    }
    return true;
  }
}
