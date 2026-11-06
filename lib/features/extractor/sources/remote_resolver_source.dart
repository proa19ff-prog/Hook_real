import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/diagnostics/playback_diagnostics.dart';
import '../models/media_track.dart';
import '../models/resolved_stream.dart';
import 'music_source.dart';

/// Optional self-hosted resolver. When the user configures an endpoint in
/// settings, catalog recordings can be resolved to full audio streams the
/// device could not obtain directly. The server contract is documented in
/// docs/REMOTE_RESOLVER.md:
///   GET `{base}/search?q={query}&limit={n}` → list of track objects
///   GET `{base}/resolve?id={id}`            → `{url, user_agent?, ext?}`
/// The returned url may point anywhere, including the same server acting as
/// a Range-capable audio proxy for IP-locked sources. Without an endpoint
/// every call is a no-op, so the source stays inert until opted in.
class RemoteResolverSource implements MusicSource {
  /// Base URL of the resolver server without a trailing slash; null or empty
  /// disables the source. Mirrored to storage by the settings layer.
  static String? endpoint;

  static const _searchTimeout = Duration(seconds: 9);
  static const _resolveTimeout = Duration(seconds: 20);

  @override
  TrackSource get source => TrackSource.remote;

  static bool get enabled =>
      endpoint != null && endpoint!.trim().isNotEmpty;

  Uri _build(String path, Map<String, String> query) {
    final base = endpoint!.trim().replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  @override
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    if (!enabled || query.trim().isEmpty || limit <= 0) return const [];
    try {
      final response = await http
          .get(_build('/search', {'q': query.trim(), 'limit': '$limit'}))
          .timeout(_searchTimeout);
      if (response.statusCode != 200) return const [];
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(_trackFromJson)
          .whereType<MediaTrack>()
          .toList(growable: false);
    } catch (error) {
      PlaybackDiagnostics.record(
        'remote.search.failed',
        source: source.name,
        error: error,
      );
      return const [];
    }
  }

  @override
  Future<ResolvedStream?> resolveTrack(MediaTrack track) async {
    if (!enabled) return null;
    try {
      final response = await http
          .get(_build('/resolve', {'id': track.id}))
          .timeout(_resolveTimeout);
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;
      final url = decoded['url']?.toString();
      if (url == null || url.isEmpty) return null;
      final headers = <String, String>{};
      final userAgent = decoded['user_agent']?.toString();
      if (userAgent != null && userAgent.isNotEmpty) {
        headers['User-Agent'] = userAgent;
      }
      final extension = decoded['ext']?.toString();
      return ResolvedStream(
        url,
        headers: headers,
        source: source,
        duration: track.duration,
        fileExtension:
            extension == null || extension.isEmpty ? null : extension,
      );
    } catch (error) {
      PlaybackDiagnostics.record(
        'remote.resolve.failed',
        source: source.name,
        error: error,
      );
      return null;
    }
  }

  MediaTrack? _trackFromJson(Map<String, dynamic> item) {
    final id = item['id']?.toString();
    final title = item['title']?.toString();
    final artist = item['artist']?.toString();
    if (id == null ||
        id.isEmpty ||
        title == null ||
        title.isEmpty ||
        artist == null ||
        artist.isEmpty) {
      return null;
    }
    final seconds = item['duration'] is num ? (item['duration'] as num).toInt() : null;
    return MediaTrack(
      id: id,
      title: title,
      artist: artist,
      album: item['album']?.toString(),
      duration: seconds == null ? Duration.zero : Duration(seconds: seconds),
      artworkUrl: item['artwork']?.toString() ?? '',
      source: TrackSource.remote,
    );
  }

  @override
  void close() {}
}
