import '../artwork/artwork_service.dart';
import '../extractor/models/media_track.dart';
import '../extractor/stream_resolver.dart';

/// Builds repeat-free batches for track radio. Clean catalog tracks from the
/// seed artist anchor each batch; related tracks, collaborating artists, and
/// personal taste tracks keep the wave surprising, varied, and playable.
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
    List<String> personalArtists = const [],
  }) async {
    final sourceForRelated = relatedSeed ?? seed;
    final split = ArtworkService.splitArtists(seed.artist);
    final primary = split.isNotEmpty ? split.first : seed.artist;
    final secondary = split.length > 1 ? split[1] : null;

    final searchFutures = <Future<List<MediaTrack>>>[
      _resolver.relatedTracks(sourceForRelated, limit: 24),
      _resolver.search(query: primary, sources: {TrackSource.spotify}),
      if (secondary != null)
        _resolver.search(query: secondary, sources: {TrackSource.spotify}),
      for (final artist in personalArtists.take(2))
        _resolver.search(query: artist, sources: {TrackSource.spotify}),
    ];

    final results = await Future.wait(searchFutures);

    final related = results[0];
    final primaryTracks = results[1];
    var secondaryTracks = const <MediaTrack>[];
    var personalStartIdx = 2;
    if (secondary != null) {
      secondaryTracks = results[2];
      personalStartIdx = 3;
    }
    final personalBatches = results
        .skip(personalStartIdx)
        .toList(growable: false);

    final seen = <String>{
      ...excluded.map((key) => key.toLowerCase().trim()),
      trackKey(seed),
    };

    final eligibleRelated = related
        .where((t) => _eligible(t, seed, seen))
        .toList();
    final eligiblePrimary = primaryTracks
        .where((t) => _eligible(t, seed, seen))
        .toList();
    final eligibleSecondary = secondaryTracks
        .where((t) => _eligible(t, seed, seen))
        .toList();
    final eligiblePersonal = [
      for (final batch in personalBatches)
        for (final t in batch)
          if (_eligible(t, seed, seen)) t,
    ];

    final output = <MediaTrack>[];
    var rIdx = 0, pIdx = 0, sIdx = 0, persIdx = 0;

    while (output.length < limit &&
        (rIdx < eligibleRelated.length ||
            pIdx < eligiblePrimary.length ||
            sIdx < eligibleSecondary.length ||
            persIdx < eligiblePersonal.length)) {
      // 1. Up to two related discoveries
      for (
        var i = 0;
        i < 2 && rIdx < eligibleRelated.length && output.length < limit;
        i++
      ) {
        final track = eligibleRelated[rIdx++];
        if (seen.add(trackKey(track))) output.add(track);
      }
      // 2. One familiar artist release
      if (pIdx < eligiblePrimary.length && output.length < limit) {
        final track = eligiblePrimary[pIdx++];
        if (seen.add(trackKey(track))) output.add(track);
      }
      // 3. One collaborating artist track if present
      if (sIdx < eligibleSecondary.length && output.length < limit) {
        final track = eligibleSecondary[sIdx++];
        if (seen.add(trackKey(track))) output.add(track);
      }
      // 4. One personal rotation track
      if (persIdx < eligiblePersonal.length && output.length < limit) {
        final track = eligiblePersonal[persIdx++];
        if (seen.add(trackKey(track))) output.add(track);
      }
    }

    // Fallback: if output hasn't reached limit, drain any remaining candidates
    final remaining = [
      ...eligiblePrimary.skip(pIdx),
      ...eligibleSecondary.skip(sIdx),
      ...eligibleRelated.skip(rIdx),
      ...eligiblePersonal.skip(persIdx),
    ];
    for (final track in remaining) {
      if (output.length >= limit) break;
      if (seen.add(trackKey(track))) output.add(track);
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
        RegExp(
          r'\b(cover|tribute|karaoke|nightcore|slowed|reverb|sped|bootleg|mash ?up)\b',
        ).hasMatch(raw)) {
      return false;
    }
    return true;
  }
}
