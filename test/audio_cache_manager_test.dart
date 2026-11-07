import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/features/extractor/models/media_track.dart';

import 'support/fake_music_sources.dart';

const track = MediaTrack(
  id: 'original-video',
  title: 'Original',
  artist: 'Artist',
  album: 'Album',
  duration: Duration(minutes: 3),
  artworkUrl: 'https://images.example/art',
  source: TrackSource.youtubeMusic,
);

Uint8List _audio({bool webm = false}) {
  final bytes = Uint8List(2048);
  if (webm) {
    bytes.setRange(0, 4, [0x1a, 0x45, 0xdf, 0xa3]);
  } else {
    bytes.setRange(4, 8, 'ftyp'.codeUnits);
  }
  return bytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Dio dio;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hook_audio_cache_test_');
    dio = Dio();
  });
  tearDown(() async {
    dio.close(force: true);
    await directory.delete(recursive: true);
  });

  test(
    'stores original WebM bytes and source-qualified metadata, not renamed MP4',
    () async {
      final bytes = _audio(webm: true);
      dio.httpClientAdapter = FakeHttpAdapter(
        (request) => ResponseBody.fromBytes(
          bytes,
          200,
          headers: {
            'content-type': ['audio/webm'],
            'content-length': ['${bytes.length}'],
          },
        ),
      );
      final manager = AudioCacheManager(dio: dio, directory: directory);
      final file = await manager.downloadTrack(
        track,
        'https://audio.example/original',
        cacheKey: 'youtubeMusic_original-video',
        headers: {'User-Agent': 'Hook', 'Range': 'bytes=0-'},
      );
      expect(file, isNotNull);
      expect(file!.path, endsWith('.webm'));
      expect(await file.readAsBytes(), bytes);
      final saved = (await manager.getCachedTracks()).single;
      expect(saved.track, track);
      expect(saved.track.title, track.title);
      expect(saved.track.album, track.album);
      expect(saved.track.artworkUrl, track.artworkUrl);
      expect(
        await manager.getLocalCachedUrl(saved.cacheKey),
        file.uri.toString(),
      );
      final request =
          (dio.httpClientAdapter as FakeHttpAdapter).requests.single;
      expect(request.headers['User-Agent'], 'Hook');
      // The download asks like the player does: a from-zero Range, so CDNs
      // that reject range-less GETs still serve the whole recording.
      expect(request.headers['Range'], 'bytes=0-');
      expect(await manager.getTotalCacheSize(), bytes.length);
      await manager.removeCachedTrack(saved.cacheKey);
      expect(await manager.getCachedTracks(), isEmpty);
    },
  );

  test(
    'coalesces concurrent downloads and never publishes part files',
    () async {
      final response = Completer<ResponseBody>();
      final adapter = FakeHttpAdapter((_) => response.future);
      dio.httpClientAdapter = adapter;
      final manager = AudioCacheManager(dio: dio, directory: directory);
      final first = manager.downloadTrack(
        track,
        'https://audio.example/original',
      );
      final second = manager.downloadTrack(
        track,
        'https://audio.example/original',
      );
      expect(identical(first, second), true);
      expect(await manager.getCachedTracks(), isEmpty);
      response.complete(ResponseBody.fromBytes(_audio(), 200));
      expect(await first, isNotNull);
      expect(await second, isNotNull);
      expect(adapter.requests, hasLength(1));
      expect(
        (await directory.list().toList()).any(
          (file) => file.path.endsWith('.part'),
        ),
        false,
      );
    },
  );

  test(
    'rejects HTML or HLS disguised as successful audio and partial responses',
    () async {
      final manager = AudioCacheManager(dio: dio, directory: directory);
      for (final body in [
        '<html>${'error' * 600}</html>',
        '#EXTM3U\n${'segment.ts\n' * 300}',
      ]) {
        dio.httpClientAdapter = FakeHttpAdapter(
          (_) => ResponseBody.fromString(
            body,
            200,
            headers: {
              'content-type': ['audio/mp4'],
            },
          ),
        );
        expect(
          await manager.downloadTrack(track, 'https://audio.example/original'),
          isNull,
        );
        expect(await manager.getCachedTracks(), isEmpty);
      }
      // A 206 without a content-range (or one starting mid-file) cannot be
      // trusted as the whole recording.
      dio.httpClientAdapter = FakeHttpAdapter(
        (_) => ResponseBody.fromBytes(_audio(), 206),
      );
      expect(
        await manager.downloadTrack(track, 'https://audio.example/original'),
        isNull,
      );
      expect(await directory.list().toList(), isEmpty);
      dio.httpClientAdapter = FakeHttpAdapter(
        (_) => ResponseBody.fromBytes(
          _audio(),
          206,
          headers: {
            'content-range': ['bytes 100-2147/2048'],
          },
        ),
      );
      expect(
        await manager.downloadTrack(track, 'https://audio.example/original'),
        isNull,
      );
      expect(await directory.list().toList(), isEmpty);
      // But a from-zero 206 IS the whole file and must be stored.
      final bytes = _audio();
      dio.httpClientAdapter = FakeHttpAdapter(
        (_) => ResponseBody.fromBytes(
          bytes,
          206,
          headers: {
            'content-range': ['bytes 0-2047/2048'],
            'content-type': ['audio/webm'],
          },
        ),
      );
      final file = await manager.downloadTrack(
        track,
        'https://audio.example/original',
      );
      expect(file, isNotNull);
      expect(await file!.readAsBytes(), bytes);
    },
  );

  test('failed and cancelled downloads leave no cache entry', () async {
    final manager = AudioCacheManager(dio: dio, directory: directory);
    dio.httpClientAdapter = FakeHttpAdapter(
      (_) => ResponseBody.fromString('Forbidden', 403),
    );
    expect(
      await manager.downloadTrack(track, 'https://audio.example/original'),
      isNull,
    );
    final token = CancelToken()..cancel('Track changed');
    expect(
      await manager.downloadTrack(
        track,
        'https://audio.example/original',
        cancelToken: token,
      ),
      isNull,
    );
    expect(await manager.getCachedTracks(), isEmpty);
    expect(await directory.list().toList(), isEmpty);
  });

  test(
    'a fresh same-key download does not join a cancelled old transfer',
    () async {
      final oldResponse = Completer<ResponseBody>();
      var requests = 0;
      final adapter = FakeHttpAdapter((_) {
        requests++;
        return requests == 1
            ? oldResponse.future
            : ResponseBody.fromBytes(_audio(), 200);
      });
      dio.httpClientAdapter = adapter;
      final manager = AudioCacheManager(dio: dio, directory: directory);
      final token = CancelToken();
      final oldDownload = manager.downloadTrack(
        track,
        'https://audio.example/original',
        cancelToken: token,
      );
      for (var i = 0; i < 100 && adapter.requests.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      token.cancel('Previous playback request ended');
      final newDownload = manager.downloadTrack(
        track,
        'https://audio.example/original',
      );
      expect(identical(oldDownload, newDownload), false);
      oldResponse.complete(ResponseBody.fromBytes(_audio(), 200));
      expect(await oldDownload, isNull);
      expect(await newDownload, isNotNull);
      expect(adapter.requests, hasLength(2));
    },
  );

  test('refuses incomplete content length without publishing a file', () async {
    dio.httpClientAdapter = FakeHttpAdapter(
      (_) => ResponseBody.fromBytes(
        _audio(),
        200,
        headers: {
          'content-length': ['4096'],
        },
      ),
    );
    final manager = AudioCacheManager(dio: dio, directory: directory);
    expect(
      await manager.downloadTrack(track, 'https://audio.example/original'),
      isNull,
    );
    expect(await directory.list().toList(), isEmpty);
  });
}
