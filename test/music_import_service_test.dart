import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
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
    expect(
      MusicImportService.detectPlatform(
          'Post Malone — Sunflower\nMADKID — Rise'),
      ImportPlatform.text,
    );
  });

  test('parses Russian artist-title text and removes numbering/durations', () {
    final tracks = MusicImportService.parseTrackList('''
1. Post Malone — Sunflower (Spider-Man) 2:38
MADKID - Rise
MADKID - Rise
''');

    expect(tracks, hasLength(2));
    expect(tracks.first.artist, 'Post Malone');
    expect(tracks.first.title, 'Sunflower (Spider-Man)');
    expect(tracks.first.source, TrackSource.spotify);
  });

  test('parses Exportify-style CSV columns', () {
    final tracks = MusicImportService.parseTrackList('''
Track Name,Artist Name(s),Album Name
Sunflower,"Post Malone; Swae Lee",Hollywood's Bleeding
Rise,MADKID,RISE
''');

    expect(tracks, hasLength(2));
    expect(tracks.first.title, 'Sunflower');
    expect(tracks.first.artist, 'Post Malone, Swae Lee');
  });

  test(
      'TrackArtwork.getHighResUrl upgrades low-res thumbnails to crystal clear resolution',
      () {
    // SoundCloud
    final scLow =
        'https://i1.sndcdn.com/artworks-000123456789-abcdef-large.jpg';
    expect(
      TrackArtwork.getHighResUrl(scLow),
      'https://i1.sndcdn.com/artworks-000123456789-abcdef-t500x500.jpg',
    );

    final scMedium =
        'https://i1.sndcdn.com/artworks-000123456789-abcdef-t300x300.jpg';
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
