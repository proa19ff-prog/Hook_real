import 'dart:async';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/media_track.dart';
import '../models/resolved_stream.dart';
import '../../../core/diagnostics/playback_diagnostics.dart';
import 'music_source.dart';
import 'audio_stream_probe.dart';
import 'youtube_http_client.dart';
import 'youtube_proxy.dart';

/// Public YouTube audio. No cookies, paid previews, downloader proxy or private
/// backend. Availability still depends on the video, region and YouTube API.
class YouTubeMusicSource implements MusicSource {
  final Set<YoutubeExplode> _clients = {};
  bool _closed = false;

  /// Innertube clients ordered by how likely each one still serves a full
  /// audio stream without a PO token. The previous single client
  /// (`androidSdkless`) now hangs or gets HTTP 403 from many networks, and
  /// `androidVr` is heavily throttled, while `ios` still serves full audio
  /// quickly. Every resolve walks the chain and the first client whose
  /// stream passes a real GET probe wins. Availability of specific clients
  /// changes over time; this order is easy to reshuffle and diagnostics name
  /// the failing client.
  static final List<YoutubeApiClient> _clientChain = [
    YoutubeApiClient.ios,
    YoutubeApiClient.tv,
    YoutubeApiClient.mweb,
    YoutubeApiClient.androidVr,
    YoutubeApiClient.safari,
    YoutubeApiClient.androidSdkless,
  ];

  /// The last client that produced a probe-verified stream; tried first on
  /// the next resolve so a healthy client is not re-discovered per track.
  static YoutubeApiClient? _preferredClient;

  static String _clientLabel(YoutubeApiClient client) {
    final context = client.payload['context'];
    final info = context is Map ? context['client'] : null;
    if (info is! Map) return 'unknown';
    final name = info['clientName'] ?? 'unknown';
    final version = info['clientVersion'];
    return version == null ? '$name' : '${name}_$version';
  }

  static String? _clientUserAgent(YoutubeApiClient client) {
    final context = client.payload['context'];
    final info = context is Map ? context['client'] : null;
    final userAgent = info is Map ? info['userAgent'] : null;
    return userAgent is String && userAgent.isNotEmpty ? userAgent : null;
  }

  static List<YoutubeApiClient> _orderedClients() {
    final preferred = _preferredClient;
    if (preferred == null || !_clientChain.contains(preferred)) {
      return _clientChain;
    }
    return [preferred, ..._clientChain.where((c) => c != preferred)];
  }

  @override
  TrackSource get source => TrackSource.youtubeMusic;

  Future<T> _request<T>(
    Future<T> Function(YoutubeExplode client, HttpClient transport, String? proxy)
    action,
    Duration timeout,
  ) async {
    if (_closed) throw StateError('YouTube source is closed');
    Object? lastError;
    final elapsed = Stopwatch()..start();

    Future<T> attempt(String? proxy) async {
      if (_closed) throw StateError('YouTube source is closed');
      final remaining = timeout - elapsed.elapsed;
      if (remaining <= Duration.zero) throw TimeoutException('YouTube request');
      final transport = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5)
        ..idleTimeout = const Duration(seconds: 8)
        // Explicit DIRECT is essential: global overrides may still remember a
        // desktop proxy that failed after the VPN route changed.
        ..findProxy = (_) => proxy == null ? 'DIRECT' : 'PROXY $proxy';
      final client = YoutubeExplode(
        httpClient: YouTubeRequestClient(IOClient(transport)),
      );
      _clients.add(client);
      try {
        final result = await action(client, transport, proxy).timeout(
          remaining,
        );
        YouTubeProxyRegistry.address = proxy;
        return result;
      } finally {
        _clients.remove(client);
        client.close();
      }
    }

    final preferredProxy = YouTubeProxyRegistry.address;
    if (preferredProxy != null) {
      try {
        return await attempt(preferredProxy);
      } catch (error) {
        lastError = error;
        if (YouTubeProxyRegistry.address == preferredProxy) {
          YouTubeProxyRegistry.address = null;
        }
      }
    }

    try {
      return await attempt(null);
    } catch (error) {
      lastError = error;
    }

    // A VPN/proxy is commonly enabled only after the warning appears. Detect
    // again after every failed direct request instead of caching an empty list.
    final candidates = !_closed && elapsed.elapsed < timeout
        ? await LocalProxyDetector.detectCandidates()
        : const <String>[];
    for (final proxy in candidates) {
      if (_closed || elapsed.elapsed >= timeout) break;
      if (proxy == preferredProxy) continue;
      try {
        return await attempt(proxy);
      } catch (error) {
        lastError = error;
      }
    }

    Error.throwWithStackTrace(
      lastError ?? const SocketException('YouTube is unavailable'),
      StackTrace.current,
    );
  }

  /// Uses the same manifest path as playback, so the UI never reports a false
  /// positive merely because youtube.com answered a lightweight HTTP request.
  Future<bool> checkAvailability() async {
    try {
      return await _request((_, _, proxy) async {
        return await _resolveWithClientChain(
              videoId: 'dQw4w9WgXcQ',
              proxy: proxy,
            ) !=
            null;
      }, const Duration(seconds: 14));
    } catch (error) {
      PlaybackDiagnostics.record(
        'youtube.availability.failed',
        source: source.name,
        error: error,
      );
      return false;
    }
  }

  static String cleanArtist(String value) => value
      .replaceFirst(RegExp(r'\s*[-–]\s*Topic$', caseSensitive: false), '')
      .replaceFirst(RegExp(r'VEVO$', caseSensitive: false), '')
      .trim();

  static String cleanTitle(String title, String artist) {
    var cleaned = title.replaceAll(
      RegExp(
        r'[\[(]\s*(?:(?:official\s*)?(?:music\s*)?(?:video|audio|visuali[sz]er)|lyric(?:s| video)?|hd|hq|4k)\s*[\])]',
        caseSensitive: false,
      ),
      '',
    );
    final parts = cleaned.split(RegExp(r'\s[-–—]\s'));
    String compact(String value) => value.toLowerCase().replaceAll(
      RegExp(r'[^\p{L}\p{N}]', unicode: true),
      '',
    );
    if (parts.length > 1 &&
        compact(artist).isNotEmpty &&
        compact(parts.first).contains(compact(artist))) {
      cleaned = parts.skip(1).join(' - ');
    }
    // Never strip Remix, Live, Cover, Slowed, etc: they identify a different
    // recording and must remain visible to the strict catalog matcher.
    return cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  static MediaTrack? fromVideo(Video video) {
    final duration = video.duration;
    if (video.isLive || duration == null || duration.inSeconds < 45) {
      return null;
    }
    final music = video.musicData.length == 1 ? video.musicData.single : null;
    final artist = cleanArtist(music?.artist ?? video.author);
    // Upload version tags are authoritative even if the music metadata names
    // only the underlying song (a remix must not turn into the studio version).
    final title = cleanTitle(video.title, artist);
    if (artist.isEmpty || title.isEmpty) return null;
    return MediaTrack(
      id: video.id.value,
      title: title,
      artist: artist,
      album: music?.album,
      duration: duration,
      artworkUrl: music?.image?.toString() ?? video.thumbnails.highResUrl,
      source: TrackSource.youtubeMusic,
      playbackCount: video.engagement.viewCount,
    );
  }

  @override
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty || limit <= 0) return const [];
    return _request((client, _, _) async {
      final results = await client.search.search(query.trim());
      return results
          .map(fromVideo)
          .whereType<MediaTrack>()
          .take(limit)
          .toList(growable: false);
    }, const Duration(seconds: 8));
  }

  @override
  Future<ResolvedStream?> resolveTrack(MediaTrack track) async {
    if (track.source != source || !RegExp(r'^[\w-]{11}$').hasMatch(track.id)) {
      return null;
    }
    return _request((_, _, proxy) async {
      return _resolveWithClientChain(
        videoId: track.id,
        proxy: proxy,
        duration: track.duration,
      );
    }, const Duration(seconds: 22));
  }

  /// Walks the client chain until one yields an audio stream that passes a
  /// real GET probe. Each attempt runs in its own session so the googlevideo
  /// User-Agent matches the client that issued the URL; the winning client is
  /// remembered for later resolves and a chain-wide failure rethrows the last
  /// error for the caller's report.
  Future<ResolvedStream?> _resolveWithClientChain({
    required String videoId,
    required String? proxy,
    Duration? duration,
  }) async {
    Object? failure;
    for (final ytClient in _orderedClients()) {
      if (_closed) throw StateError('YouTube source is closed');
      try {
        final resolved = await _withClientSession(ytClient, proxy, (
          explode,
          transport,
          headers,
        ) async {
          // A hard per-client cap keeps one throttled client (which may hang
          // instead of answering) from consuming the whole resolve budget.
          final manifest = await explode.videos.streamsClient
              .getManifest(
                videoId,
                ytClients: [ytClient],
                requireWatchPage: false,
              )
              .timeout(const Duration(seconds: 7));
          return _selectPlayableAudio(
            manifest,
            transport,
            headers: headers,
            duration: duration,
          );
        });
        if (resolved != null) {
          if (_preferredClient != ytClient) {
            PlaybackDiagnostics.record(
              'youtube.client.selected',
              source: source.name,
              detail: _clientLabel(ytClient),
            );
          }
          _preferredClient = ytClient;
          return resolved;
        }
        failure = StateError('no full audio for ${_clientLabel(ytClient)}');
        PlaybackDiagnostics.record(
          'youtube.client.failed',
          source: source.name,
          detail: _clientLabel(ytClient),
          error: failure,
        );
      } catch (error) {
        failure = error;
        PlaybackDiagnostics.record(
          'youtube.client.failed',
          source: source.name,
          detail: _clientLabel(ytClient),
          error: error,
        );
      }
    }
    if (failure != null) {
      Error.throwWithStackTrace(failure, StackTrace.current);
    }
    return null;
  }

  /// Runs [action] in an isolated session for [ytClient]: its own transport
  /// (with the attempt's proxy route) stamping every googlevideo request with
  /// the User-Agent of exactly this client. A manifest URL probed or played
  /// back with another client's UA can be rejected by the CDN with HTTP 403.
  Future<ResolvedStream?> _withClientSession(
    YoutubeApiClient ytClient,
    String? proxy,
    Future<ResolvedStream?> Function(
      YoutubeExplode explode,
      HttpClient transport,
      Map<String, String> headers,
    )
    action,
  ) async {
    final userAgent =
        _clientUserAgent(ytClient) ?? YouTubeRequestClient.streamUserAgent;
    final headers = {'User-Agent': userAgent};
    final transport = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5)
      ..idleTimeout = const Duration(seconds: 8)
      ..findProxy = (_) => proxy == null ? 'DIRECT' : 'PROXY $proxy';
    final explode = YoutubeExplode(
      httpClient: YouTubeRequestClient(IOClient(transport), userAgent: userAgent),
    );
    try {
      return await action(explode, transport, headers);
    } finally {
      explode.close();
    }
  }

  /// Download the same video without relying on a Range probe. This does not
  /// bypass an unavailable/blocked source: the full GET must still succeed.
  Future<ResolvedStream?> resolveDownloadTrack(MediaTrack track) async {
    if (track.source != source || !RegExp(r'^[\w-]{11}$').hasMatch(track.id)) {
      return null;
    }
    return _request((_, _, proxy) async {
      Object? failure;
      for (final ytClient in _orderedClients()) {
        if (_closed) throw StateError('YouTube source is closed');
        try {
          final resolved = await _withClientSession(ytClient, proxy, (
            explode,
            _,
            headers,
          ) async {
            final manifest = await explode.videos.streamsClient
                .getManifest(
                  track.id,
                  ytClients: [ytClient],
                  requireWatchPage: false,
                )
                .timeout(const Duration(seconds: 7));
            final stream = _bestFullAudio(manifest);
            if (stream == null) return null;
            return ResolvedStream(
              stream.url.toString(),
              headers: headers,
              source: source,
              duration: track.duration,
              fileExtension: stream.container.name == 'mp4'
                  ? 'm4a'
                  : stream.container.name,
            );
          });
          if (resolved != null) {
            _preferredClient = ytClient;
            return resolved;
          }
          failure = StateError('no full audio for ${_clientLabel(ytClient)}');
        } catch (error) {
          failure = error;
        }
        PlaybackDiagnostics.record(
          'youtube.client.failed',
          source: source.name,
          detail: _clientLabel(ytClient),
          error: failure,
        );
      }
      if (failure != null) {
        Error.throwWithStackTrace(failure, StackTrace.current);
      }
      return null;
    }, const Duration(seconds: 22));
  }

  /// Best full (non-HLS) default-track audio-only stream: prefer AAC in MP4
  /// for broad native decoder support, then the highest bitrate.
  static AudioOnlyStreamInfo? _bestFullAudio(StreamManifest manifest) {
    final streams = _fullAudioCandidates(manifest);
    return streams.isEmpty ? null : streams.first;
  }

  static List<AudioOnlyStreamInfo> _fullAudioCandidates(
    StreamManifest manifest,
  ) {
    return manifest.audioOnly
        .where(
          (stream) =>
              stream.fragments.isEmpty &&
              (stream.audioTrack == null || stream.audioTrack!.audioIsDefault),
        )
        .toList()
      ..sort((a, b) {
        final container = (b.container.name == 'mp4' ? 1 : 0).compareTo(
          a.container.name == 'mp4' ? 1 : 0,
        );
        return container != 0 ? container : b.bitrate.compareTo(a.bitrate);
      });
  }

  Future<ResolvedStream?> _selectPlayableAudio(
    StreamManifest manifest,
    HttpClient transport, {
    required Map<String, String> headers,
    Duration? duration,
  }) async {
    final streams = _fullAudioCandidates(manifest);
    if (streams.isEmpty) return null;
    Object? failure;
    // The library only HEAD-checks a manifest entry, not necessarily this
    // selected audio. A real initial GET must work before this provider wins
    // against another catalog source. Check only a few offered audio formats.
    for (final stream in streams.take(3)) {
      try {
        await probeAudioStream(
          transport,
          stream.url,
          headers,
        ).timeout(const Duration(seconds: 8));
        return ResolvedStream(
          stream.url.toString(),
          headers: headers,
          source: source,
          duration: duration,
        );
      } catch (error) {
        failure = error;
        PlaybackDiagnostics.record(
          'youtube.audio.failed',
          source: source.name,
          url: stream.url.toString(),
          error: error,
        );
      }
    }
    Error.throwWithStackTrace(failure!, StackTrace.current);
  }

  @override
  void close() {
    _closed = true;
    for (final client in _clients.toList()) {
      client.close();
    }
    _clients.clear();
  }
}
