import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/recommendations/recommendation_service.dart';
import 'package:hook/features/recommendations/track_wave_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

MediaTrack _track(
  String id, {
  required String artist,
  TrackSource source = TrackSource.soundcloud,
}) =>
    MediaTrack(
      id: id,
      title: 'Song $id',
      artist: artist,
      duration: const Duration(minutes: 3),
      artworkUrl: '',
      source: source,
    );

/// StreamResolver stub: only what the wave touches. Real ranking and source
/// fan-out are covered by the resolver's own tests.
class _StubResolver extends StreamResolver {
  final List<MediaTrack> related;
  final Map<String, List<MediaTrack>> searches;

  _StubResolver({required this.related, required this.searches});

  @override
  Future<List<MediaTrack>> relatedTracks(
    MediaTrack seed, {
    int limit = 20,
  }) async =>
      related;

  @override
  Future<List<MediaTrack>> search({
    required String query,
    bool includeSoundCloud = true,
    bool includeSpotify = true,
    Set<TrackSource>? sources,
  }) async =>
      searches[query] ?? const [];
}

void main() {
  late LocalStorageService storage;
  late RecommendationService recommender;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    recommender = RecommendationService(
      storage: storage,
      resolver: _StubResolver(related: const [], searches: const {}),
    );
  });

  test('replay counts boost artist affinity and fade with idle time', () async {
    for (var i = 0; i < 9; i++) {
      await storage.registerPlay('artist a|song one');
    }
    expect(storage.getPlayCounts()['artist a|song one'], 9);
    expect(storage.getPlayTimestamps().keys, contains('artist a|song one'));

    // Nine fresh plays (weight 9*0.4=3.6) beat a single favorite (3.5) and
    // both clearly outrank an artist with no signals at all.
    await storage.toggleFavorite(_track('f', artist: 'Artist B'));
    final top = recommender.topPersonalArtists(limit: 2);
    expect(top, containsAll(<String>['artist a', 'Artist B']));
    expect(top.first, 'artist a');
  });

  test('nextBatch interleaves related, seed artist and personal picks', () async {
    final seed = _track('seed', artist: 'Seed Artist');
    final resolver = _StubResolver(
      related: [
        _track('r1', artist: 'Other One'),
        _track('r2', artist: 'Other Two'),
        _track('r3', artist: 'Other Three'),
        _track('r4', artist: 'Other Four'),
        _track('r5', artist: 'Other Five'),
        _track('r6', artist: 'Other Six'),
      ],
      searches: {
        'Seed Artist': [_track('a1', artist: 'Seed Artist', source: TrackSource.spotify)],
        'Personal Artist': [
          _track('p1', artist: 'Personal Artist', source: TrackSource.spotify),
          _track('p2', artist: 'Personal Artist', source: TrackSource.spotify),
        ],
      },
    );
    final service = TrackWaveService(resolver);

    final batch = await service.nextBatch(
      seed,
      personalArtists: const ['Personal Artist'],
      limit: 12,
    );

    // 2 related : 1 seed artist : 1 personal, repeating.
    final titles = batch.map((t) => t.id).toList();
    expect(titles.take(4), ['r1', 'r2', 'a1', 'p1']);
    expect(titles, containsAll(<String>['r3', 'r4', 'p2']));
    expect(batch, everyElement(isA<MediaTrack>()));
  });

  test('nextBatch without personal artists keeps the classic blend', () async {
    final seed = _track('seed', artist: 'Seed Artist');
    final resolver = _StubResolver(
      related: List.generate(6, (i) => _track('r$i', artist: 'Other $i')),
      searches: {
        'Seed Artist': [
          _track('a1', artist: 'Seed Artist', source: TrackSource.spotify),
        ],
      },
    );
    final service = TrackWaveService(resolver);

    final batch = await service.nextBatch(seed, limit: 12);
    expect(batch.map((t) => t.id).take(3), ['r0', 'r1', 'a1']);
  });

  test('nextBatch respects excluded keys', () async {
    final seed = _track('seed', artist: 'Seed Artist');
    final excluded = TrackWaveService.trackKey(_track('r1', artist: 'Other One'));
    final resolver = _StubResolver(
      related: [
        _track('r1', artist: 'Other One'),
        _track('r2', artist: 'Other Two'),
      ],
      searches: const {},
    );
    final service = TrackWaveService(resolver);

    final batch = await service.nextBatch(seed, excluded: {excluded});
    expect(batch.map((t) => t.id), ['r2']);
  });
}
