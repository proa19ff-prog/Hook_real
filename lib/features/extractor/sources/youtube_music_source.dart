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

  @override
  TrackSource get source => TrackSource.youtubeMusic;

  Future<T> _request<T>(
    Future<T> Function(YoutubeExplode client, HttpClient transport) action,
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
        final result = await action(client, transport).timeout(remaining);
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
      return await _request((client, transport) async {
        final manifest = await client.videos.streamsClient.getManifest(
          'dQw4w9WgXcQ',
          ytClients: [YoutubeApiClient.androidSdkless],
          requireWatchPage: false,
        );
        return await _selectPlayableAudio(manifest, transport) != null;
      }, const Duration(seconds: 9));
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
    return _request((client, transport) async {
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
    return _request((client, transport) async {
      // Use the public Android client only. Protected/unavailable videos fail
      // normally rather than being routed through restriction-bypass services.
      final manifest = await client.videos.streamsClient.getManifest(
        track.id,
        ytClients: [YoutubeApiClient.androidSdkless],
        requireWatchPage: false,
      );
      return _selectPlayableAudio(
        manifest,
        transport,
        duration: track.duration,
      );
    }, const Duration(seconds: 12));
  }

  /// Download the same video without relying on a Range probe. This does not
  /// bypass an unavailable/blocked source: the full GET must still succeed.
  Future<ResolvedStream?> resolveDownloadTrack(MediaTrack track) async {
    if (track.source != source || !RegExp(r'^[\w-]{11}$').hasMatch(track.id)) {
      return null;
    }
    return _request((client, transport) async {
      final manifest = await client.videos.streamsClient.getManifest(
        track.id,
        ytClients: [YoutubeApiClient.androidSdkless],
        requireWatchPage: false,
      );
      final streams =
          manifest.audioOnly
              .where(
                (stream) =>
                    stream.fragments.isEmpty &&
                    (stream.audioTrack == null ||
                        stream.audioTrack!.audioIsDefault),
              )
              .toList()
            ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      if (streams.isEmpty) return null;
      final stream = streams.first;
      return ResolvedStream(
        stream.url.toString(),
        headers: {'User-Agent': YouTubeRequestClient.streamUserAgent},
        source: source,
        duration: track.duration,
        fileExtension: stream.container.name == 'mp4'
            ? 'm4a'
            : stream.container.name,
      );
    }, const Duration(seconds: 12));
  }

  Future<ResolvedStream?> _selectPlayableAudio(
    StreamManifest manifest,
    HttpClient transport, {
    Duration? duration,
  }) async {
    final streams = manifest.audioOnly
        .where(
          (stream) =>
              stream.fragments.isEmpty &&
              (stream.audioTrack == null || stream.audioTrack!.audioIsDefault),
        )
        .toList();
    // AAC in MP4 has broad native decoder support; then take the best bitrate.
    streams.sort((a, b) {
      final container = (b.container.name == 'mp4' ? 1 : 0).compareTo(
        a.container.name == 'mp4' ? 1 : 0,
      );
      return container != 0 ? container : b.bitrate.compareTo(a.bitrate);
    });
    if (streams.isEmpty) return null;
    final headers = {'User-Agent': YouTubeRequestClient.streamUserAgent};
    Object? failure;
    // The library only HEAD-checks a manifest entry, not necessarily this
    // selected audio. A real initial GET must work before this provider wins
    // against another catalog source. Check only a few offered audio formats.
    for (final stream in streams.take(3)) {
      try {
        await probeAudioStream(transport, stream.url, headers);
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
