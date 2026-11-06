import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// The manifest library probes the CDN before handing its URL to the player.
/// Both that probe and native playback must use the client that issued the URL;
/// a mismatched User-Agent on a googlevideo request can fail with HTTP 403.
class YouTubeRequestClient extends YoutubeHttpClient {
  YouTubeRequestClient(super.httpClient, {this.userAgent});

  /// UA of the Innertube client this transport is bound to, or null to keep
  /// the library default. Only googlevideo requests are affected.
  final String? userAgent;

  static final String streamUserAgent =
      YoutubeApiClient.androidSdkless.payload['context']['client']['userAgent']
          as String;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final host = request.url.host.toLowerCase();
    final userAgent = this.userAgent;
    if (userAgent != null &&
        (host == 'googlevideo.com' || host.endsWith('.googlevideo.com'))) {
      request.headers['user-agent'] = userAgent;
    }
    return super.send(request);
  }
}
