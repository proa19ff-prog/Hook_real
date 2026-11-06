import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// The manifest library probes the CDN before handing its URL to the player.
/// Both that probe and native playback must use the client that issued the URL;
/// a desktop browser User-Agent on the probe can otherwise fail an Android URL.
class YouTubeRequestClient extends YoutubeHttpClient {
  YouTubeRequestClient(super.httpClient);

  static final String streamUserAgent =
      YoutubeApiClient.androidSdkless.payload['context']['client']['userAgent']
          as String;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final host = request.url.host.toLowerCase();
    if (host == 'googlevideo.com' || host.endsWith('.googlevideo.com')) {
      request.headers['user-agent'] = streamUserAgent;
    }
    return super.send(request);
  }
}
