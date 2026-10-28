import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

MediaTrack _track(String id) {
  return MediaTrack(
    id: id,
    title: 'Track $id',
    artist: 'Artist',
    duration: const Duration(minutes: 3),
    artworkUrl: '',
    source: TrackSource.youtube,
  );
}

void main() {
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
  });

  test('favorites toggle persists and removes the same track', () async {
    final track = _track('favorite-1');

    await storage.toggleFavorite(track);
    expect(storage.getFavorites(), [track]);

    await storage.toggleFavorite(track);
    expect(storage.getFavorites(), isEmpty);
  });

  test('keeps same id when tracks come from different sources', () async {
    final youtubeTrack = _track('shared-id');
    final soundCloudTrack = youtubeTrack.copyWith(
      source: TrackSource.soundcloud,
    );

    await storage.toggleFavorite(youtubeTrack);
    await storage.toggleFavorite(soundCloudTrack);
    expect(
        storage.getFavorites(), containsAll([youtubeTrack, soundCloudTrack]));

    await storage.addToHistory(youtubeTrack);
    await storage.addToHistory(soundCloudTrack);
    expect(storage.getHistory(), containsAll([youtubeTrack, soundCloudTrack]));
  });

  test('history moves repeated tracks to the front and caps at 100', () async {
    for (var i = 0; i < 101; i++) {
      await storage.addToHistory(_track('$i'));
    }

    final history = storage.getHistory();
    expect(history, hasLength(100));
    expect(history.first.id, '100');
    expect(history.last.id, '1');

    await storage.addToHistory(_track('50'));
    expect(storage.getHistory().first.id, '50');
    expect(storage.getHistory(), hasLength(100));
  });

  test('playlists round-trip tracks and can be deleted', () async {
    final tracks = [_track('a'), _track('b')];

    await storage.savePlaylist('Favorites mix', tracks);
    expect(storage.getPlaylists()['Favorites mix'], tracks);

    await storage.deletePlaylist('Favorites mix');
    expect(storage.getPlaylists(), isEmpty);
  });
}
