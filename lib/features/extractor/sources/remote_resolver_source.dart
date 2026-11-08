import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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
/// a Range-capable audio proxy for IP-locked sources.
///
/// Endpoints ship as an ordered pool. The free Cloudflare Workers quota
/// (100k requests/day) is counted per ACCOUNT, so a real pool means one
/// worker per account; the bare origin sits last as the final fallback.
/// The source rotates automatically: HTTP 429 (quota exhausted — Cloudflare
/// answers 1027 until the next UTC midnight), any network-level failure or
/// a dead route moves the request to the next endpoint, and the last
/// working one stays active ("sticky") for everything that follows.
///
/// The stored override decides what is actually used:
///   null (never configured) → the pool
///   '' (disabled in settings) → source off
///   custom url → that url only (no rotation)
class RemoteResolverSource implements MusicSource {
  /// Ordered resolver endpoints shipped with the build. Adding a worker is
  /// one line here plus a release.
  static const List<String> defaultEndpoints = [
    'https://hook-resolver.proa19ff.workers.dev/ed3b53d48fcd09aba8acb666',
    'https://atomic-rush-daixwalr.expresshost.cloud/ed3b53d48fcd09aba8acb666',
  ];

  /// The primary endpoint, for display in settings.
  static String get defaultEndpoint => defaultEndpoints.first;

  /// Storage mirror maintained by the settings layer.
  static String? endpoint;

  static const _searchTimeout = Duration(seconds: 9);
  static const _resolveTimeout = Duration(seconds: 20);

  @override
  TrackSource get source => TrackSource.remote;

  /// Test seam: when set, every data request goes through it.
  @visibleForTesting
  static Future<http.Response> Function(Uri uri)? fetchOverride;

  /// Rotation state: which pool entry is currently preferred, and until when
  /// an endpoint is known to be exhausted (429) or unreachable.
  static int _activeIndex = 0;
  static final Map<String, DateTime> _cooldownUntil = {};

  @visibleForTesting
  static String get debugActiveEndpoint =>
      defaultEndpoints[_activeIndex.clamp(0, defaultEndpoints.length - 1)];

  @visibleForTesting
  static void resetRotation() {
    _activeIndex = 0;
    _cooldownUntil.clear();
  }

  static bool _cooling(String endpoint) {
    final until = _cooldownUntil[endpoint];
    return until != null && DateTime.now().toUtc().isBefore(until);
  }

  /// HTTP 429 from a free worker means the account's daily quota is gone;
  /// Cloudflare resets it at the next UTC midnight.
  static void _markExhausted(String endpoint) {
    final now = DateTime.now().toUtc();
    _cooldownUntil[endpoint] = DateTime.utc(now.year, now.month, now.day + 1);
    if (defaultEndpoints.indexOf(endpoint) == _activeIndex) {
      for (var i = 1; i < defaultEndpoints.length; i++) {
        final candidate = defaultEndpoints[(_activeIndex + i) % defaultEndpoints.length];
        if (!_cooling(candidate)) {
          _activeIndex = defaultEndpoints.indexOf(candidate);
          break;
        }
      }
    }
  }

  /// Endpoints in try order: the sticky active one first, then the rest.
  /// A manual override pins exactly one endpoint.
  static List<String> get _candidates {
    final stored = endpoint?.trim();
    if (stored != null) {
      return stored.isEmpty ? const [] : [stored];
    }
    final ordered = <String>[];
    if (_activeIndex < defaultEndpoints.length) {
      ordered.add(defaultEndpoints[_activeIndex]);
    }
    for (var i = 0; i < defaultEndpoints.length; i++) {
      if (i == _activeIndex) continue;
      ordered.add(defaultEndpoints[i]);
    }
    return ordered;
  }

  /// Endpoint currently in effect (see the class docs for the precedence).
  /// When every pool entry is cooling down, the active one is still used —
  /// a 429 answer is better than not asking at all.
  static String get effectiveEndpoint {
    final stored = endpoint?.trim();
    if (stored != null) return stored;
    final active = defaultEndpoints[_activeIndex.clamp(0, defaultEndpoints.length - 1)];
    if (!_cooling(active)) return active;
    for (final candidate in defaultEndpoints) {
      if (!_cooling(candidate)) return candidate;
    }
    return active;
  }

  static bool get enabled => effectiveEndpoint.isNotEmpty;

  Uri _build(String path, Map<String, String> query) =>
      _buildFor(effectiveEndpoint, path, query);

  static Uri _buildFor(String base, String path, Map<String, String> query) {
    final root = base.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$root$path').replace(queryParameters: query);
  }

  Future<http.Response> _get(Uri uri, Duration timeout) {
    final override = fetchOverride;
    if (override != null) return override(uri);
    return http.get(uri).timeout(timeout);
  }

  /// Rotates across the pool: 429 cools the endpoint until the next UTC
  /// midnight, any other failure just moves on. The endpoint that answers
  /// becomes sticky.
  Future<http.Response?> _getRotating(
    String path,
    Map<String, String> query,
    Duration timeout,
  ) async {
    Object? lastError;
    for (final base in _candidates) {
      try {
        final response = await _get(_buildFor(base, path, query), timeout);
        if (response.statusCode == 429) {
          _markExhausted(base);
          PlaybackDiagnostics.record(
            'remote.endpoint.exhausted',
            source: source.name,
            detail: Uri.parse(base).host,
          );
          lastError = 'endpoint quota exhausted';
          continue;
        }
        if (response.statusCode != 200) {
          lastError = StateError('HTTP ${response.statusCode}');
          continue;
        }
        if (endpoint?.trim() == null) _stickTo(base);
        return response;
      } catch (error) {
        lastError = error;
        continue;
      }
    }
    if (lastError != null) {
      PlaybackDiagnostics.record(
        'remote.pool.exhausted',
        source: source.name,
        error: lastError,
      );
    }
    return null;
  }

  static void _stickTo(String endpoint) {
    final index = defaultEndpoints.indexOf(endpoint);
    if (index >= 0) _activeIndex = index;
  }

  /// A server-side packaged download for a track we only know by its page
  /// URL (SoundCloud permalinks live in [MediaTrack.streamUrl]). The server
  /// runs yt-dlp and returns one audio file with a real content-length, so
  /// the explicit download button works where the device's own network
  /// cannot fetch or cannot save the stream (HLS-only uploads).
  ResolvedStream? serverDownloadFor(MediaTrack track) {
    if (!enabled) return null;
    final page = track.streamUrl?.trim();
    if (page == null ||
        page.isEmpty ||
        !page.startsWith('https://soundcloud.com/')) {
      return null;
    }
    return ResolvedStream(
      _build('/download', {'url': page}).toString(),
      source: source,
      duration: track.duration,
      fileExtension: null,
    );
  }

  @override
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    if (!enabled || query.trim().isEmpty || limit <= 0) return const [];
    final response = await _getRotating(
      '/search',
      {'q': query.trim(), 'limit': '$limit'},
      _searchTimeout,
    );
    if (response == null) return const [];
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(_trackFromJson)
        .whereType<MediaTrack>()
        .toList(growable: false);
  }

  @override
  Future<ResolvedStream?> resolveTrack(MediaTrack track) async {
    if (!enabled) return null;
    final response = await _getRotating(
      '/resolve',
      {'id': track.id},
      _resolveTimeout,
    );
    if (response == null) return null;
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
      fileExtension: extension == null || extension.isEmpty ? null : extension,
    );
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

