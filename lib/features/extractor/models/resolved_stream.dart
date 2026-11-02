import 'media_track.dart';

/// A playable full-length stream and the headers required by its CDN.
/// [source] is the actual audio provider, not the catalog used for discovery.
class ResolvedStream {
  final String url;
  final Map<String, String> headers;
  final TrackSource? source;
  final Duration? duration;

  const ResolvedStream(
    this.url, {
    this.headers = const {},
    this.source,
    this.duration,
  });

  bool get isEmpty => url.isEmpty;

  // Android YouTube manifests may issue URLs that cannot be reopened. Keep
  // recording matches cached, but obtain a fresh manifest for every new load.
  bool get isReusable => source != TrackSource.youtubeMusic;
}
