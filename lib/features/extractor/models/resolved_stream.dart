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
}
