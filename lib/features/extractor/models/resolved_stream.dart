import 'media_track.dart';

/// A playable full-length stream and the headers required by its CDN.
/// [source] is the actual audio provider, not the catalog used for discovery.
class ResolvedStream {
  final String url;
  final Map<String, String> headers;
  final TrackSource? source;
  final Duration? duration;

  /// Container hint for an unchanged audio-only download (never transcoded).
  final String? fileExtension;

  /// Source-reported audio bitrate, when the provider exposes one. Powers the
  /// "high bitrate" download badge; null simply means "not advertised".
  final int? bitrateKbps;

  const ResolvedStream(
    this.url, {
    this.headers = const {},
    this.source,
    this.duration,
    this.fileExtension,
    this.bitrateKbps,
  });

  bool get isEmpty => url.isEmpty;

  // Android YouTube manifests may issue URLs that cannot be reopened. Keep
  // recording matches cached, but obtain a fresh manifest for every new load.
  bool get isReusable => source != TrackSource.youtubeMusic;
}
