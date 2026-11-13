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
/// The server answered `403 {"error":"age_restricted"}` (or `cookies_stale`):
/// the track exists but YouTube refuses it without a signed-in cookie jar.
/// Distinct from a plain failure because the user can actually fix this one,
/// and because retrying another endpoint cannot help — the whole pool shares
/// the same session.
class AgeRestrictedStreamException implements Exception {
  const AgeRestrictedStreamException(this.reason, {this.detail});

  /// `age_restricted` or `cookies_stale`, as reported by the server.
  final String reason;
  final String? detail;

  bool get isStaleCookies => reason == 'cookies_stale';

  @override
  String toString() =>
      detail == null || detail!.isEmpty ? reason : '$reason: $detail';
}

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
  static const _warmTimeout = Duration(seconds: 4);

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

  /// Track IDs known to be pre-warmed or resident in the server's cache
  /// (e.g. from /popular or /warm).
  static final Set<String> _warmIds = <String>{};

  /// True when [id] is known to be pre-warmed or popular on the server.
  static bool isWarm(String id) {
    final clean = id.trim();
    return clean.isNotEmpty && _warmIds.contains(clean);
  }

  /// Marks [ids] as server-warm so resolve attempts skip direct YouTube.
  static void markWarm(Iterable<String> ids) {
    for (final id in ids) {
      final clean = id.trim();
      if (clean.isNotEmpty) {
        _warmIds.add(clean);
      }
    }
  }

  @visibleForTesting
  static void resetWarmIds() {
    _warmIds.clear();
  }

  @visibleForTesting
  static void resetRotation() {
    _activeIndex = 0;
    _cooldownUntil.clear();
    _warmIds.clear();
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
        final candidate =
            defaultEndpoints[(_activeIndex + i) % defaultEndpoints.length];
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
    final active =
        defaultEndpoints[_activeIndex.clamp(0, defaultEndpoints.length - 1)];
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
    return _client.get(uri).timeout(timeout);
  }

  /// One pooled client for the whole app. `http.get` builds a fresh client per
  /// call, so every search and resolve paid for its own TLS handshake — the
  /// single largest fixed cost on a cold tap.
  static http.Client? _sharedClient;
  static http.Client get _client => _sharedClient ??= http.Client();

  @visibleForTesting
  static void resetClient() {
    _sharedClient?.close();
    _sharedClient = null;
  }

  /// Tells the server which tracks are about to play, so it can pull them into
  /// RAM and its disk cache before the tap. Fire and forget: the answer only
  /// reports how many ids were queued.
  Future<void> warm(Iterable<String> ids) async {
    if (!enabled) return;
    final wanted = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet()
        .take(12)
        .toList(growable: false);
    if (wanted.isEmpty) return;
    markWarm(wanted);
    try {
      await _getRotating('/warm', {'ids': wanted.join(',')}, _warmTimeout);
    } catch (_) {
      // Prewarming is an optimisation; a failed hint changes nothing.
    }
  }

  /// The server's most played tracks, already resolved and usually resident in
  /// its RAM cache. Empty on any failure — the home rail simply stays hidden.
  Future<List<MediaTrack>> popular({int limit = 12}) async {
    if (!enabled || limit <= 0) return const [];
    final response = await _getRotating('/popular', {
      'limit': '$limit',
    }, _searchTimeout);
    if (response == null) return const [];
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) return const [];
    final tracks = decoded
        .whereType<Map<String, dynamic>>()
        .map(_trackFromJson)
        .whereType<MediaTrack>()
        .toList(growable: false);
    markWarm(tracks.map((t) => t.id));
    return tracks;
  }

  /// Rotates across the pool: 429 cools the endpoint until the next UTC
  /// midnight, any other failure just moves on. The endpoint that answers
  /// becomes sticky.
  Future<http.Response?> _getRotating(
    String path,
    Map<String, String> query,
    Duration timeout, {
    bool throwOnRefusal = false,
  }) async {
    Object? lastError;
    for (final base in _candidates) {
      try {
        var response = await _get(_buildFor(base, path, query), timeout);
        // 503 + Retry-After means "capacity, not a dead track": every
        // extraction slot on the server was busy. Rotating to another pool
        // entry is useless (same box), but the track will play a moment
        // later, so wait and ask the same endpoint again.
        var retries = 0;
        while (response.statusCode == 503 && retries < 2) {
          final wait = _retryAfter(response.headers['retry-after']);
          if (wait == null) break;
          retries++;
          PlaybackDiagnostics.record(
            'remote.endpoint.busy',
            source: source.name,
            detail: 'retry $retries in ${wait.inMilliseconds}ms',
          );
          await Future<void>.delayed(wait);
          response = await _get(_buildFor(base, path, query), timeout);
        }
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
        if (throwOnRefusal && response.statusCode == 403) {
          final refusal = _refusalFrom(response);
          // Both flavours are final: every pool entry talks to a server that
          // holds the same cookie jar, so rotating would only repeat the wait.
          if (refusal != null) throw refusal;
        }
        if (response.statusCode != 200) {
          lastError = StateError('HTTP ${response.statusCode}');
          continue;
        }
        if (endpoint?.trim() == null) _stickTo(base);
        return response;
      } on AgeRestrictedStreamException {
        rethrow;
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

  /// How long the server asked us to wait, capped. Returns null when the
  /// header is missing or unparsable, which means "don't retry".
  static Duration? _retryAfter(String? header) {
    final seconds = int.tryParse(header?.trim() ?? '');
    if (seconds == null || seconds <= 0) return null;
    return Duration(seconds: seconds.clamp(1, 5));
  }

  static void _stickTo(String endpoint) {
    final index = defaultEndpoints.indexOf(endpoint);
    if (index >= 0) _activeIndex = index;
  }

  /// Reads the honest refusal out of a 403. The server sends
  /// `{"error":"age_restricted","detail":…}`; anything else (a Cloudflare
  /// block page, a bare 403) is just a failed endpoint and stays one.
  static AgeRestrictedStreamException? _refusalFrom(http.Response response) {
    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;
      final code = decoded['error']?.toString();
      if (code != 'age_restricted' && code != 'cookies_stale') return null;
      return AgeRestrictedStreamException(
        code!,
        detail:
            decoded['detail']?.toString() ??
            decoded['cookie_state']?.toString(),
      );
    } catch (_) {
      return null;
    }
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
    final response = await _getRotating('/search', {
      'q': query.trim(),
      'limit': '$limit',
    }, _searchTimeout);
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
      throwOnRefusal: true,
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
    final seconds = item['duration'] is num
        ? (item['duration'] as num).toInt()
        : null;
    final streamUrl = item['url']?.toString();
    return MediaTrack(
      id: id,
      title: title,
      artist: artist,
      album: item['album']?.toString(),
      duration: seconds == null ? Duration.zero : Duration(seconds: seconds),
      artworkUrl: item['artwork']?.toString() ?? '',
      source: TrackSource.remote,
      streamUrl: streamUrl != null && streamUrl.isNotEmpty ? streamUrl : null,
    );
  }

  /// Replaces the server's cookie jar with a Netscape export.
  ///
  /// The server validates before swapping, so a wrong file leaves the working
  /// jar alone; [CookieUploadResult.error] then explains what it rejected.
  Future<CookieUploadResult> uploadCookies(String netscape) async {
    if (!enabled) {
      return const CookieUploadResult.failed('resolver is not configured');
    }
    Object? lastError;
    for (final base in _candidates) {
      try {
        final uri = _buildFor(base, '/cookies/upload', const {});
        final override = fetchOverride;
        final response =
            await (override != null
                    ? override(uri)
                    : _client.post(
                        uri,
                        headers: const {
                          'Content-Type': 'text/plain; charset=utf-8',
                        },
                        body: utf8.encode(netscape),
                      ))
                .timeout(const Duration(seconds: 40));
        final decoded = jsonDecode(utf8.decode(response.bodyBytes));
        if (decoded is! Map<String, dynamic>) {
          lastError = 'unexpected answer (HTTP ${response.statusCode})';
          continue;
        }
        if (response.statusCode != 200) {
          // A validation refusal is final; only a transport failure rotates.
          final error = decoded['error']?.toString();
          if (error != null && error.isNotEmpty) {
            return CookieUploadResult.failed(error);
          }
          lastError = 'HTTP ${response.statusCode}';
          continue;
        }
        return CookieUploadResult(
          cookies: (decoded['cookies'] as num?)?.toInt() ?? 0,
          signedIn: decoded['signed_in'] == true,
          loggedIn: decoded['logged_in'] != false,
          warning: decoded['warning']?.toString() ?? '',
        );
      } catch (error) {
        lastError = error;
      }
    }
    return CookieUploadResult.failed(
      lastError == null ? 'upload failed' : lastError.toString(),
    );
  }

  /// Whether the server's cookie jar is signed in to YouTube. Age-restricted
  /// tracks are refused without one, and this drives the settings hint.
  ///
  /// `/cookies/verify` makes a live request with the jar, so it costs a couple
  /// of seconds; `/cookies/status` only inspects the file. Both are read here:
  /// `signed_in` from the cheap one, then the live verdict when available.
  Future<CookieJarHealth?> cookieHealth() async {
    if (!enabled) return null;
    try {
      final response = await _getRotating(
        '/cookies/verify',
        const {},
        const Duration(seconds: 15),
      );
      if (response == null) return null;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;
      return CookieJarHealth(
        configured: decoded['configured'] != false,
        healthy: decoded['healthy'] == true,
        signedIn: decoded['signed_in'] == true,
        ageRestrictedReady: decoded['age_restricted_ready'] == true,
        detail: decoded['detail']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  void close() {}
}

/// What the server says about its YouTube cookie jar. [ageRestrictedReady] is
/// the only field that decides whether 18+ tracks can play.
class CookieJarHealth {
  const CookieJarHealth({
    required this.configured,
    required this.healthy,
    required this.signedIn,
    required this.ageRestrictedReady,
    required this.detail,
  });

  final bool configured;
  final bool healthy;
  final bool signedIn;
  final bool ageRestrictedReady;

  /// The server's own explanation, in English. Shown verbatim when it is the
  /// only thing that says what is wrong.
  final String detail;

  /// True when a sign-in jar is needed but absent or no longer accepted, so the
  /// settings row can offer the upload button instead of a vague warning.
  bool get needsSignIn => !ageRestrictedReady;
}

/// Outcome of posting a cookie export to the resolver.
///
/// [signedIn] says whether the file is a real account session; [loggedIn] says
/// whether YouTube accepted it on a live request. Only both together unlock
/// age-restricted tracks.
class CookieUploadResult {
  const CookieUploadResult({
    required this.cookies,
    required this.signedIn,
    required this.loggedIn,
    required this.warning,
  }) : error = null;

  const CookieUploadResult.failed(String message)
    : error = message,
      cookies = 0,
      signedIn = false,
      loggedIn = false,
      warning = '';

  final int cookies;
  final bool signedIn;
  final bool loggedIn;

  /// Non-empty when the upload succeeded but the export cannot play 18+.
  final String warning;

  /// Non-null when the server rejected the file and kept the old jar.
  final String? error;

  bool get isError => error != null && error!.isNotEmpty;
  bool get ready => !isError && signedIn && loggedIn;
}
