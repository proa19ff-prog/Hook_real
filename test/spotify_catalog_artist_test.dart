import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/spotify/spotify_catalog_service.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.routes);
  final Map<RegExp, ResponseBody> routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    for (final entry in routes.entries) {
      if (entry.key.hasMatch(options.uri.toString())) return entry.value;
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

Map<String, Object> _song(int id, String name, {int durationMs = 150000}) => {
      'wrapperType': 'track',
      'kind': 'song',
      'trackId': id,
      'trackName': name,
      'artistName': 'Ravyn Lenae',
      'collectionName': 'Album $id',
      'trackTimeMillis': durationMs,
      'artworkUrl100': 'https://example.com/100x100bb.jpg',
    };

void main() {
  test('artist lookup resolves the id and returns the discography', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        RegExp(r'/search'): _json({
          'results': [
            {'artistId': 77, 'artistName': 'Someone Else'},
            {'artistId': 42, 'artistName': 'Ravyn Lenae'},
          ],
        }),
        RegExp(r'/lookup'): _json({
          'results': [
            {'wrapperType': 'artist', 'artistId': 42, 'artistName': 'Ravyn Lenae'},
            _song(1, 'Love Me Not'),
            // Same song on a compilation: must collapse into one entry.
            _song(2, 'Love Me Not'),
            _song(3, 'Genius'),
          ],
        }),
      });
    final service = SpotifyCatalogService(dio: dio);
    addTearDown(service.close);

    final tracks = await service.artistTopSongs('Ravyn Lenae');
    expect(tracks.map((track) => track.title), ['Love Me Not', 'Genius']);
    expect(tracks.first.artworkUrl, contains('600x600bb'));
    expect(tracks.first.source.name, 'spotify');
  });

  test('unknown artist yields an empty list without throwing', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        RegExp(r'/search'): _json({'results': []}),
      });
    final service = SpotifyCatalogService(dio: dio);
    addTearDown(service.close);

    expect(await service.artistTopSongs('Nobody Known'), isEmpty);
  });
}
