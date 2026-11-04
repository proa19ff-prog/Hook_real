import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/import/music_import_service.dart';
import 'package:hook/features/theme_engine/presentation/track_artwork.dart';

void main() {
  test('MusicImportService correctly detects platforms from URLs', () {
    expect(
      MusicImportService.detectPlatform(
        'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M',
      ),
      ImportPlatform.spotify,
    );
    expect(
      MusicImportService.detectPlatform(
        'https://open.spotify.com/track/4cOdK2wGLETKBW3PvgPWqT',
      ),
      ImportPlatform.spotify,
    );
    expect(
      MusicImportService.detectPlatform('https://example.com/something'),
      ImportPlatform.unknown,
    );
    expect(
      MusicImportService.detectPlatform(
        'Post Malone — Sunflower\nMADKID — Rise',
      ),
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

  group('CSV import', () {
    const export =
        'Track URI,Track Name,Album Name,Artist Name(s),Duration (ms)\r\n'
        'spotify:track:abc123,"Песня, часть 1","Альбом ""Ночь""",Артист;Гость,158000\r\n'
        'spotify:track:def456,Rise,RISE,MADKID,222000\r\n';

    test('detects CSV before Spotify URIs and reads exact title column', () {
      expect(MusicImportService.detectPlatform(export), ImportPlatform.csv);
      final tracks = MusicImportService.parseCsv('﻿$export');
      expect(tracks, hasLength(2));
      expect(tracks.first.id, 'sp_abc123');
      expect(tracks.first.title, 'Песня, часть 1');
      expect(tracks.first.artist, 'Артист, Гость');
      expect(tracks.first.album, 'Альбом "Ночь"');
      expect(tracks.first.duration, const Duration(milliseconds: 158000));
      expect(tracks.last.id, 'sp_def456');
    });

    test(
      'preserves multiline quoted fields and exported order including repeats',
      () {
        final tracks = MusicImportService.parseCsv(
          'Track URI,Track Name,Artist Name(s)\n'
          'spotify:track:a,"First\nsecond",Artist\n'
          'spotify:track:b,Other,Guest\n'
          'spotify:track:a,"First\nsecond",Artist\n',
        );
        expect(tracks.map((track) => track.id), ['sp_a', 'sp_b', 'sp_a']);
        expect(tracks.first.title, 'First\nsecond');
      },
    );

    test('reads semicolon-delimited and tab-delimited exports', () {
      final semicolon = MusicImportService.parseCsv(
        'Title;Artist;Album\n"Song; title";"First; Second";Record',
      );
      expect(semicolon.single.title, 'Song; title');
      expect(semicolon.single.artist, 'First, Second');
      final tab = MusicImportService.parseCsv('Title\tArtist\nSong\tArtist');
      expect(tab.single.title, 'Song');
    });

    test('does not truncate after 500 tracks', () {
      final tracks = MusicImportService.parseCsv(
        'Title,Artist\n${List.generate(750, (index) => 'Song $index,Artist').join('\n')}',
      );
      expect(tracks, hasLength(750));
      expect(tracks.last.title, 'Song 749');
    });

    test('reports explicit track limit without returning partial import', () {
      expect(
        () => MusicImportService.parseCsv(
          'Title,Artist\n${List.generate(MusicImportService.maxTracks + 1, (index) => 'Song $index,Artist').join('\n')}',
        ),
        throwsA(
          isA<MusicImportFileException>().having(
            (error) => error.kind,
            'kind',
            ImportFileError.tooManyTracks,
          ),
        ),
      );
    });

    test('rejects malformed records instead of importing column fragments', () {
      for (final csv in [
        'Title,Artist\n"Unclosed,Artist',
        'Title,Artist\n"Song"garbage,Artist',
        'Title,Artist\nSong,Artist,Extra',
        'Title,Artist\nSong',
        'Title,Artist\n,Artist',
        'Title,Artist,Duration (ms)\nSong,Artist,-12',
      ]) {
        expect(
          () => MusicImportService.parseCsv(csv),
          throwsA(
            isA<MusicImportFileException>().having(
              (error) => error.kind,
              'kind',
              ImportFileError.invalidCsv,
            ),
          ),
        );
      }
    });

    test('rejects unsupported headers and empty exports', () {
      expect(
        () => MusicImportService.parseCsv('Track URI,URL\nx,y'),
        throwsA(
          isA<MusicImportFileException>().having(
            (error) => error.kind,
            'kind',
            ImportFileError.missingColumns,
          ),
        ),
      );
      for (final csv in ['', 'Title,Artist\n']) {
        expect(
          () => MusicImportService.parseCsv(csv),
          throwsA(
            isA<MusicImportFileException>().having(
              (error) => error.kind,
              'kind',
              ImportFileError.empty,
            ),
          ),
        );
      }
    });

    test('decodes UTF-8 BOM and validates file type, size, and encoding', () {
      expect(
        MusicImportService.decodeFile(utf8.encode('﻿$export'), 'Микс.CSV'),
        export,
      );
      expect(
        () => MusicImportService.decodeFile([0xff, 0xfe], 'mix.csv'),
        throwsA(
          isA<MusicImportFileException>().having(
            (error) => error.kind,
            'kind',
            ImportFileError.invalidEncoding,
          ),
        ),
      );
      expect(
        () => MusicImportService.decodeFile([0], 'mix.txt'),
        throwsA(
          isA<MusicImportFileException>().having(
            (error) => error.kind,
            'kind',
            ImportFileError.invalidEncoding,
          ),
        ),
      );
      expect(
        () => MusicImportService.decodeFile([], 'mix.png'),
        throwsA(
          isA<MusicImportFileException>().having(
            (error) => error.kind,
            'kind',
            ImportFileError.unsupported,
          ),
        ),
      );
      expect(
        () => MusicImportService.decodeFile(
          List.filled(MusicImportService.maxFileBytes + 1, 65),
          'mix.csv',
        ),
        throwsA(
          isA<MusicImportFileException>().having(
            (error) => error.kind,
            'kind',
            ImportFileError.tooLarge,
          ),
        ),
      );
    });

    test(
      'CSV import and pasted CSV keep source metadata without catalog calls',
      () async {
        final service = MusicImportService();
        addTearDown(service.close);
        final result = await service.importFromCsv(
          export,
          title: '  Night mix  ',
        );
        expect(result.title, 'Night mix');
        expect(result.platform, ImportPlatform.csv);
        expect(result.tracks.first.id, 'sp_abc123');
        final pasted = await service.importFromText(export);
        expect(pasted.platform, ImportPlatform.csv);
        expect(pasted.tracks.first.album, 'Альбом "Ночь"');
      },
    );

    test('does not treat unrelated hosts mentioning Spotify as links', () {
      expect(
        MusicImportService.detectPlatform(
          'https://spotify.com.evil.test/playlist/abc',
        ),
        ImportPlatform.unknown,
      );
      expect(
        MusicImportService.detectPlatform('https://example.com/?spotify.com'),
        ImportPlatform.unknown,
      );
    });
  });

  test('parses modern Spotify entity.trackList embed data', () {
    final collection = MusicImportService.parseSpotifyData(
      {
        'entity': {
          'name': 'Мой микс',
          'owner': {'name': 'Hook User'},
          'coverArt': {
            'sources': [
              {'url': 'https://example.com/cover.jpg'},
            ],
          },
          'trackList': {
            'items': [
              {
                'track': {
                  'uri': 'spotify:track:abc123',
                  'name': 'Sunflower (Spider-Man)',
                  'artists': [
                    {'name': 'Post Malone'},
                    {'name': 'Swae Lee'},
                  ],
                  'duration': 158000,
                },
              },
              {
                'track': {
                  'uri': 'spotify:track:def456',
                  'title': 'Rise',
                  'artists': [
                    {'name': 'MADKID'},
                  ],
                  'duration': '3:42',
                },
              },
            ],
          },
        },
      },
      type: 'playlist',
      id: 'playlist-id',
    );

    expect(collection.title, 'Мой микс');
    expect(collection.tracks, hasLength(2));
    expect(collection.tracks.first.id, 'sp_abc123');
    expect(collection.tracks.first.artist, 'Post Malone, Swae Lee');
    expect(
      collection.tracks.last.duration,
      const Duration(minutes: 3, seconds: 42),
    );
  });
  test('TrackArtwork upgrades known low-resolution URLs', () {
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
  });
}
