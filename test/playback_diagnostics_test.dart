import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/diagnostics/playback_diagnostics.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  tearDown(() => PlaybackDiagnostics.sink = null);

  test(
    'diagnostics retain stage, provider and HTTP code without credentials',
    () {
      final lines = <String>[];
      PlaybackDiagnostics.sink = lines.add;
      final error = PlayerException(
        0,
        'Source error: Response code: 403 https://cdn.example/private?signed=secret',
      );
      PlaybackDiagnostics.record(
        'native.failed',
        source: 'youtubeMusic',
        url: 'https://username:password@cdn.example/private?signed=secret',
        error: error,
      );
      expect(lines.single, contains('native.failed'));
      expect(lines.single, contains('youtubeMusic'));
      expect(lines.single, contains('cdn.example'));
      expect(lines.single, contains('HTTP 403'));
      for (final sensitive in [
        'username',
        'password',
        'private',
        'signed',
        'secret',
      ]) {
        expect(lines.single, isNot(contains(sensitive)));
      }
    },
  );

  test(
    'HTTP failures are distinct from timeout, TLS and connection failures',
    () {
      final request = RequestOptions(path: 'https://example.test');
      expect(
        PlaybackDiagnostics.failureLabel(
          DioException(
            requestOptions: request,
            response: Response(requestOptions: request, statusCode: 429),
          ),
        ),
        'HTTP 429',
      );
      expect(
        PlaybackDiagnostics.failureLabel(TimeoutException('private URL')),
        'timeout',
      );
      expect(
        PlaybackDiagnostics.failureLabel(const SocketException('private IP')),
        'connection',
      );
      expect(
        PlaybackDiagnostics.failureLabel(const HandshakeException('details')),
        'TLS',
      );
      expect(
        PlaybackDiagnostics.failureLabel(
          StateError('Video returned 403 (stream: 140)'),
        ),
        'HTTP 403',
      );
    },
  );
}
