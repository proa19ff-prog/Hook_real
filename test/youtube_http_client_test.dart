import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:hook/features/extractor/sources/youtube_http_client.dart';

void main() {
  test('manifest CDN probe uses the same User-Agent as native audio', () async {
    final transport = MockClient((request) async {
      expect(
        request.headers['user-agent'],
        YouTubeRequestClient.streamUserAgent,
      );
      return http.Response('', 200);
    });
    final client = YouTubeRequestClient(transport);
    addTearDown(client.close);
    await client.head(
      Uri.parse('https://r1---sn-test.googlevideo.com/videoplayback'),
    );
  });

  test(
    'CDN header override does not affect search or unrelated hosts',
    () async {
      final transport = MockClient((request) async {
        expect(request.headers['user-agent'], 'existing-agent');
        return http.Response('', 200);
      });
      final client = YouTubeRequestClient(transport);
      addTearDown(client.close);
      for (final host in ['www.youtube.com', 'googlevideo.com.example.org']) {
        await client.get(
          Uri.https(host, '/'),
          headers: {'user-agent': 'existing-agent'},
        );
      }
    },
  );
}
