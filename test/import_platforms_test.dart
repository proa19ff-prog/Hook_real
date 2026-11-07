import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/spotify/spotify_catalog_service.dart';
import 'package:hook/features/import/music_import_service.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.routes);
  final Map<RegExp, ResponseBody Function(RequestOptions)> routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    for (final entry in routes.entries) {
      if (entry.key.hasMatch(options.uri.toString())) {
        return entry.value(options);
      }
    }
    return ResponseBody.fromString('', 404);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object body) => ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

void main() {
  group('detectPlatform', () {
    test('recognizes YouTube Music, YouTube and Deezer links', () {
      expect(
        MusicImportService.detectPlatform(
          'https://music.youtube.com/playlist?list=PL123',
        ),
        ImportPlatform.youtube,
      );
      expect(
        MusicImportService.detectPlatform(
          'https://www.youtube.com/playlist?list=PL123',
        ),
        ImportPlatform.youtube,
      );
      expect(
        MusicImportService.detectPlatform('https://youtu.be/abc-dash'),
        ImportPlatform.youtube,
      );
      expect(
        MusicImportService.detectPlatform(
          'https://www.deezer.com/ru/playlist/3155776842',
        ),
        ImportPlatform.deezer,
      );
      expect(
        MusicImportService.detectPlatform('https://link.deezer.com/s/xyz'),
        ImportPlatform.deezer,
      );
      // Spotify still wins over the dash heuristic, and links never become
      // "text".
      expect(
        MusicImportService.detectPlatform(
          'https://open.spotify.com/playlist/37i9dQZF1DXcBWIGoYBM5M',
        ),
        ImportPlatform.spotify,
      );
      expect(
        MusicImportService.detectPlatform('Artist — Title'),
        ImportPlatform.text,
      );
    });
  });

  test('YouTube Music playlist maps to playable youtubeMusic tracks',
      () async {
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter({
        RegExp(r'/playlist'): (_) => _json({
          'title': 'My Mix',
          'tracks': [
            {
              'id': 'v1',
              'title': 'Song One',
              'artist': 'Artist One',
              'duration': 210,
              'artwork': '',
            },
            {
              'id': 'v2',
              'title': 'Song Two',
              'artist': '',
              'duration': 180,
              'artwork': 'https://i.ytimg.com/vi/v2/hqdefault.jpg',
            },
            {'id': 'v1', 'title': 'Song One duplicate'},
            {'id': '', 'title': 'broken'},
          ],
        }),
      });
    final service = MusicImportService(
      dio: dio,
      catalog: SpotifyCatalogService(dio: dio),
    );

    final result = await service.importFromUrl(
      'https://music.youtube.com/playlist?list=PL1',
    );

    expect(result.platform, ImportPlatform.youtube);
    expect(result.title, 'My Mix');
    expect(result.tracks.map((track) => track.id), ['v1', 'v2']);
    expect(result.tracks.every((t) => t.source == TrackSource.youtubeMusic),
        isTrue);
    // Canonical artwork fallback for entries without one.
    expect(result.tracks.first.artworkUrl,
        'https://i.ytimg.com/vi/v1/hqdefault.jpg');
    expect(result.tracks[1].duration, const Duration(seconds: 180));
  });

  test('Deezer playlist becomes catalog-matched placeholders', () async {
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter({
        RegExp(r'/playlist'): (_) => _json({
          'title': 'Deezer Hits',
          'tracks': [
            {
              'id': 'd1',
              'title': 'Love Me Not',
              'artist': 'Ravyn Lenae',
              'duration': 213,
              'artwork': 'https://cdns-images.deezer.com/cover/med.jpg',
            },
          ],
        }),
        // The catalog matcher runs against iTunes search.
        RegExp(r'itunes'): (_) => _json({'results': []}),
      });
    final service = MusicImportService(
      dio: dio,
      catalog: SpotifyCatalogService(dio: dio),
    );

    final result = await service.importFromUrl(
      'https://www.deezer.com/ru/playlist/3155776842',
    );

    expect(result.platform, ImportPlatform.deezer);
    expect(result.title, 'Deezer Hits');
    expect(result.tracks.single.title, 'Love Me Not');
    expect(result.tracks.single.duration, const Duration(seconds: 213));
    expect(result.tracks.single.artworkUrl,
        'https://cdns-images.deezer.com/cover/med.jpg');
  });

  test('a failed server read raises an explainable error', () async {
    final dio = Dio()
      ..httpClientAdapter = _StubAdapter({
        RegExp(r'/playlist'): (_) => ResponseBody.fromString('', 502),
      });
    final service = MusicImportService(
      dio: dio,
      catalog: SpotifyCatalogService(dio: dio),
    );

    await expectLater(
      service.importFromUrl('https://music.youtube.com/playlist?list=PL1'),
      throwsA(isA<MusicImportException>()),
    );
  });
}
