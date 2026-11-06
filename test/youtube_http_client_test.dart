import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hook/features/extractor/sources/youtube_http_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  test('googlevideo requests carry the bound client User-Agent', () async {
    const boundAgent = 'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU)';
    final transport = MockClient((request) async {
      expect(request.headers['user-agent'], boundAgent);
      return http.Response('', 200);
    });
    final client = YouTubeRequestClient(transport, userAgent: boundAgent);
    addTearDown(client.close);
    await client.head(
      Uri.parse('https://r1---sn-test.googlevideo.com/videoplayback'),
    );
  });

  test(
    'bound User-Agent does not affect search or unrelated hosts',
    () async {
      const boundAgent = 'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU)';
      final transport = MockClient((request) async {
        expect(request.headers['user-agent'], 'existing-agent');
        return http.Response('', 200);
      });
      final client = YouTubeRequestClient(transport, userAgent: boundAgent);
      addTearDown(client.close);
      for (final host in ['www.youtube.com', 'googlevideo.com.example.org']) {
        await client.get(
          Uri.https(host, '/'),
          headers: {'user-agent': 'existing-agent'},
        );
      }
    },
  );

  test('without a bound agent the library default stays untouched', () async {
    final transport = MockClient((request) async {
      expect(request.headers['user-agent'], 'keep-me');
      return http.Response('', 200);
    });
    final client = YouTubeRequestClient(transport);
    addTearDown(client.close);
    await client.get(
      Uri.https('rr1---sn-test.googlevideo.com', '/videoplayback'),
      headers: {'user-agent': 'keep-me'},
    );
  });

  test('streamUserAgent still exposes the androidSdkless payload UA', () {
    final expected =
        YoutubeApiClient.androidSdkless.payload['context']['client']['userAgent']
            as String;
    expect(YouTubeRequestClient.streamUserAgent, expected);
  });
}
