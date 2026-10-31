import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/import/music_import_service.dart';
import 'package:hook/features/theme_engine/presentation/track_artwork.dart';

void main() {
  test('MusicImportService correctly detects platforms from URLs', () {
    expect(
      MusicImportService.detectPlatform(
          'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M'),
      ImportPlatform.spotify,
    );
    expect(
      MusicImportService.detectPlatform(
          'https://open.spotify.com/track/4cOdK2wGLETKBW3PvgPWqT'),
      ImportPlatform.spotify,
    );
    expect(
      MusicImportService.detectPlatform(
          'https://music.youtube.com/playlist?list=PLrAl60GSp4B_e76v7iR_t2u'),
      ImportPlatform.unknown,
    );
    expect(
      MusicImportService.detectPlatform('https://youtu.be/dQw4w9WgXcQ'),
      ImportPlatform.unknown,
    );
    expect(
      MusicImportService.detectPlatform('https://example.com/something'),
      ImportPlatform.unknown,
    );
  });

  test('TrackArtwork.getHighResUrl upgrades low-res thumbnails to crystal clear resolution', () {
    // SoundCloud
    final scLow = 'https://i1.sndcdn.com/artworks-000123456789-abcdef-large.jpg';
    expect(
      TrackArtwork.getHighResUrl(scLow),
      'https://i1.sndcdn.com/artworks-000123456789-abcdef-t500x500.jpg',
    );

    final scMedium = 'https://i1.sndcdn.com/artworks-000123456789-abcdef-t300x300.jpg';
    expect(
      TrackArtwork.getHighResUrl(scMedium),
      'https://i1.sndcdn.com/artworks-000123456789-abcdef-t500x500.jpg',
    );

    // YouTube
    final ytLow = 'https://i.ytimg.com/vi/dQw4w9WgXcQ/mqdefault.jpg';
    expect(
      TrackArtwork.getHighResUrl(ytLow),
      'https://i.ytimg.com/vi/dQw4w9WgXcQ/maxresdefault.jpg',
    );
  });
}
