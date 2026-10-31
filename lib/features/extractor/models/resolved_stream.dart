/// A playable audio stream: the direct URL plus the HTTP headers the request
/// must carry. YouTube's googlevideo CDN rejects requests whose User-Agent
/// does not match the one that signed the URL, which is what makes ExoPlayer
/// fail with "Response code: 403" when the headers are simply dropped.
class ResolvedStream {
  final String url;
  final Map<String, String> headers;

  const ResolvedStream(this.url, {this.headers = const {}});

  bool get isEmpty => url.isEmpty;
}
