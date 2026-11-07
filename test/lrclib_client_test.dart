import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/data/lrclib_client.dart';

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

Map<String, Object> _record({
  required String track,
  required String artist,
  int duration = 213,
}) =>
    {
      'trackName': track,
      'artistName': artist,
      'duration': duration,
      'syncedLyrics': '[00:01.00]line one\n[00:05.00]line two',
      'plainLyrics': 'line one\nline two',
    };

void main() {
  test('get endpoint result from a different artist is rejected', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        // LRCLIB /get fuzzy-matched another song with the same title.
        RegExp(r'/get'): _json(
          _record(track: 'Love Me Not', artist: 'Someone Completely Else'),
        ),
        RegExp(r'/search'): _json([]),
      });
    final source = LrclibSource(dio: dio);
    addTearDown(source.close);

    final result = await source.fetch(
      title: 'Love Me Not',
      artist: 'Ravyn Lenae',
      duration: const Duration(seconds: 213),
    );
    expect(result, isNull);
  });

  test('wrong get match falls through to a scored search result', () async {
    final right = _record(track: 'Love Me Not', artist: 'Ravyn Lenae');
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        RegExp(r'/get'):
            _json(_record(track: 'Love Me Not', artist: 'Wrong Artist')),
        RegExp(r'/search'): _json([right]),
      });
    final source = LrclibSource(dio: dio);
    addTearDown(source.close);

    final result = await source.fetch(
      title: 'Love Me Not',
      artist: 'Ravyn Lenae',
      duration: const Duration(seconds: 213),
    );
    expect(result, isNotNull);
    expect(result!.synced, right['syncedLyrics']);
  });

  test('matching get result is still used directly', () async {
    final dio = Dio()
      ..httpClientAdapter = _FakeAdapter({
        RegExp(r'/get'):
            _json(_record(track: 'Love Me Not', artist: 'Ravyn Lenae')),
        RegExp(r'/search'): _json([]),
      });
    final source = LrclibSource(dio: dio);
    addTearDown(source.close);

    final result = await source.fetch(
      title: 'Love Me Not',
      artist: 'Ravyn Lenae',
      duration: const Duration(seconds: 213),
    );
    expect(result, isNotNull);
    expect(result!.hasSynced, isTrue);
  });
}
