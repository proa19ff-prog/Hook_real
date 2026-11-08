import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/account/sync_engine.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/library/presentation/playlist_export.dart';
import 'package:hook/features/recommendations/recommendation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

MediaTrack _track(
  String id, {
  required String artist,
  String title = 'Song',
  TrackSource source = TrackSource.soundcloud,
}) =>
    MediaTrack(
      id: id,
      title: title,
      artist: artist,
      duration: const Duration(minutes: 3),
      artworkUrl: '',
      source: source,
    );

class _StubResolver extends StreamResolver {
  final Map<String, List<MediaTrack>> searches;

  _StubResolver(this.searches);

  @override
  Future<List<MediaTrack>> relatedTracks(
    MediaTrack seed, {
    int limit = 20,
  }) async =>
      const [];

  @override
  Future<List<MediaTrack>> search({
    required String query,
    bool includeSoundCloud = true,
    bool includeSpotify = true,
    Set<TrackSource>? sources,
  }) async =>
      searches[query] ?? const [];
}

Future<LocalStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return LocalStorageService(await SharedPreferences.getInstance());
}

void main() {
  group('disliked artists', () {
    test('toggle stores and removes the cleaned name', () async {
      final storage = await _storage();
      await storage.toggleDislikedArtist(' Madk1d ');
      expect(storage.isDislikedArtist('Madk1d'), isTrue);
      await storage.toggleDislikedArtist('Madk1d');
      expect(storage.isDislikedArtist('Madk1d'), isFalse);
    });

    test('recommendations never return a disliked artist', () async {
      final storage = await _storage();
      await storage.toggleFavorite(_track('fav1', artist: 'Madk1d'));
      await storage.toggleFavorite(_track('fav2', artist: 'Odezza'));
      await storage.toggleDislikedArtist('Madk1d');
      final recommender = RecommendationService(
        storage: storage,
        resolver: _StubResolver({
          'Madk1d': [_track('m1', artist: 'Madk1d')],
          'Odezza': [_track('o1', artist: 'Odezza')],
        }),
      );
      final picks = await recommender.getPersonalizedRecommendations(
        limit: 25,
      );
      expect(picks.any((t) => t.artist == 'Madk1d'), isFalse);
      expect(picks.any((t) => t.artist == 'Odezza'), isTrue);
    });

    test('dislikes sync as a union and honor tombstones', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.dislikedArtists: {'t': 300, 'v': ['Madk1d']},
          SyncKeys.dislikedArtistsDel: {'t': 300, 'v': {'Odezza': 300}},
        },
        remote: {
          SyncKeys.dislikedArtists: {
            't': 200,
            'v': ['Madk1d', 'Odezza', 'Rammstein'],
          },
        },
      );
      expect((merged[SyncKeys.dislikedArtists]! as Map)['v'], ['Madk1d', 'Rammstein']);
    });
  });

  group('resume state', () {
    test('whole-value LWW: the fresher device wins', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.resume: {
            't': 100,
            'v': {
              'device': 'phone',
              'positionMs': 42000,
              'track': {'id': 'a', 'source': 'spotify'},
            },
          },
        },
        remote: {
          SyncKeys.resume: {
            't': 500,
            'v': {
              'device': 'pc',
              'positionMs': 90000,
              'track': {'id': 'b', 'source': 'spotify'},
            },
          },
        },
      );
      final value = (merged[SyncKeys.resume]! as Map)['v'] as Map;
      expect(value['device'], 'pc');
      expect(value['positionMs'], 90000);
    });
  });

  group('pickRandomTrack', () {
    test('excludes the playing track and keeps the pool alive', () {
      final pool = [
        _track('a', artist: 'A'),
        _track('b', artist: 'B'),
      ];
      final picked = pickRandomTrack(
        pool,
        current: _track('a', artist: 'A'),
        avoidKeys: {'soundcloud:b'},
        random: Random(1),
      );
      expect(picked!.id, 'a');
    });
  });

  group('PlaylistExport.csv', () {
    test('produces Exportify-compatible rows with quoted fields', () {
      final csv = PlaylistExport.csv(
        'My "Mix"',
        [
          _track('v1', artist: 'Madk1d, VILLIAN',
              title: 'Track "special"', source: TrackSource.youtubeMusic),
        ],
      );
      final lines = csv.split('\r\n');
      expect(lines.first,
          'Playlist Name,Track URI,Track Name,Artist Name(s),Album Name,Duration (ms)');
      expect(lines[1], contains('"My ""Mix"""'));
      expect(lines[1], contains('"hook:youtubeMusic:v1"'));
      expect(lines[1], contains('"Track ""special"""'));
      expect(lines[1], contains('"Madk1d, VILLIAN"'));
      expect(lines[1], contains(',180000'));
    });
  });
}
