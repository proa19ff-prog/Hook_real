import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/diagnostics/playback_diagnostics.dart';
import 'package:hook/features/extractor/sources/audio_stream_probe.dart';

void main() {
  late HttpServer server;
  late HttpClient client;
  late Uri uri;
  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    client = HttpClient();
    uri = Uri.parse('http://127.0.0.1:${server.port}/audio?signed=secret');
  });
  tearDown(() async {
    client.close(force: true);
    await server.close(force: true);
  });

  test(
    'probe uses native initial GET and headers, not HEAD or Range',
    () async {
      server.listen((request) async {
        expect(request.method, 'GET');
        expect(request.headers.value('user-agent'), 'signed-client');
        expect(request.headers.value('range'), isNull);
        expect(request.headers.value('cookie'), isNull);
        expect(request.headers.value('accept-encoding'), 'identity');
        request.response.headers.contentType = ContentType('audio', 'mp4');
        request.response.add([0, 0, 0, 24, 102, 116, 121, 112]);
        await request.response.close();
      });
      await probeAudioStream(client, uri, {'User-Agent': 'signed-client'});
    },
  );

  test('HEAD and Range success cannot hide denied initial audio GET', () async {
    server.listen((request) async {
      request.response.statusCode =
          request.method == 'HEAD' || request.headers.value('range') != null
          ? 206
          : 403;
      await request.response.close();
    });
    Object? failure;
    try {
      await probeAudioStream(client, uri, {'User-Agent': 'signed-client'});
    } catch (error) {
      failure = error;
    }
    expect(failure, isA<AudioStreamProbeException>());
    expect(PlaybackDiagnostics.failureLabel(failure!), 'HTTP 403');
    expect(failure.toString(), isNot(contains('signed')));
    expect(failure.toString(), isNot(contains('secret')));
  });

  test('successful HTML response is not considered playable audio', () async {
    server.listen((request) async {
      request.response.headers.contentType = ContentType.html;
      request.response.write('<html>Unavailable</html>');
      await request.response.close();
    });
    await expectLater(
      probeAudioStream(client, uri, {}),
      throwsA(isA<AudioStreamProbeException>()),
    );
  });

  test('empty audio response is not considered playable', () async {
    server.listen((request) async {
      request.response.headers.contentType = ContentType('audio', 'mp4');
      await request.response.close();
    });
    await expectLater(
      probeAudioStream(client, uri, {}),
      throwsA(isA<AudioStreamProbeException>()),
    );
  });

  test('probe does not wait for or download a whole audio response', () async {
    server.listen((request) async {
      request.response.headers.contentType = ContentType('audio', 'mp4');
      request.response.bufferOutput = false;
      request.response.add(List.filled(1024, 1));
      await request.response.flush();
      // Keep the response open, as for a very long song. The probe must finish.
    });
    await probeAudioStream(client, uri, {}).timeout(const Duration(seconds: 2));
  });
}
