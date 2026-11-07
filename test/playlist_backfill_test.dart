import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/spotify/spotify_catalog_service.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeCatalog extends SpotifyCatalogService {
  int calls = 0;

  @override
  Future<List<MediaTrack>> searchTracks(
    String query, {
    int limit = 25,
    String? country,
  }) async {
    calls++;
    return [
      MediaTrack(
        id: 'found-$calls',
        title: 'Found',
        artist: 'Someone',
        duration: const Duration(minutes: 3),
        artworkUrl: 'https://example.com/cover-$calls.jpg',
        source: TrackSource.spotify,
      ),
    ];
  }
}

MediaTrack _noArt(String id, String artist, String title) => MediaTrack(
      id: id,
      title: title,
      artist: artist,
      duration: const Duration(minutes: 3),
      artworkUrl: '',
      source: TrackSource.spotify,
    );

void main() {
  test('backfill resolves covers for artwork-less imported tracks', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final playlist = [
      _noArt('1', 'Artist One', 'Song One'),
      _noArt('2', 'Artist Two', 'Song Two'),
      _noArt('3', 'Artist Three', 'Song Three'),
    ];
    await storage.savePlaylist('Liked_Songs', playlist);

    final notifier = PlaylistsNotifier(storage);
    addTearDown(notifier.dispose);
    final catalog = _FakeCatalog();

    await notifier.backfillArtwork(catalog: catalog, perPlaylist: 12);

    final updated = notifier.state['Liked_Songs']!;
    expect(updated.map((track) => track.artworkUrl),
        everyElement(startsWith('https://example.com/')));
    // The resolved covers were persisted, not just mirrored into state.
    expect(
      storage.getPlaylists()['Liked_Songs']!.first.artworkUrl,
      startsWith('https://example.com/'),
    );
  });

  test('playlists with artwork are not touched twice', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final track = _noArt('1', 'Artist One', 'Song One')
        .copyWith(artworkUrl: 'https://example.com/already.jpg');
    await storage.savePlaylist('Full', [track]);

    final notifier = PlaylistsNotifier(storage);
    addTearDown(notifier.dispose);
    final catalog = _FakeCatalog();

    await notifier.backfillArtwork(catalog: catalog);
    expect(catalog.calls, 0);
    expect(notifier.state['Full']!.single.artworkUrl,
        'https://example.com/already.jpg');
  });
}
