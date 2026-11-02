import 'dart:async';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import '../models/media_track.dart';
import '../models/resolved_stream.dart';
import 'music_source.dart';

/// Public YouTube audio. No cookies, paid previews, downloader proxy or private
/// backend. Availability still depends on the video, region and YouTube API.
class YouTubeMusicSource implements MusicSource {
  final Set<YoutubeExplode> _clients = {};
  bool _closed = false;

  @override
  TrackSource get source => TrackSource.youtubeMusic;

  // Keep the CDN User-Agent identical to the player client that issued the URL.
  static final String _streamUserAgent = YoutubeApiClient
      .androidSdkless.payload['context']['client']['userAgent'] as String;

  Future<T> _request<T>(
    Future<T> Function(YoutubeExplode client) action,
    Duration timeout,
  ) async {
    if (_closed) throw StateError('YouTube source is closed');
    final transport = HttpClient()
      ..connectionTimeout = const Duration(seconds: 5)
      ..idleTimeout = const Duration(seconds: 8);
    final client = YoutubeExplode(
      httpClient: YoutubeHttpClient(IOClient(transport)),
    );
    _clients.add(client);
    try {
      return await action(client).timeout(timeout);
    } finally {
      // A Future timeout alone does not cancel network I/O. Closing this
      // operation's own client also prevents abandoned retries piling up.
      _clients.remove(client);
      client.close();
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
    );
  }

  @override
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty || limit <= 0) return const [];
    return _request((client) async {
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
    return _request((client) async {
      // Use the public Android client only. Protected/unavailable videos fail
      // normally rather than being routed through restriction-bypass services.
      final manifest = await client.videos.streamsClient.getManifest(
        track.id,
        ytClients: [YoutubeApiClient.androidSdkless],
        requireWatchPage: false,
      );
      final streams = manifest.audioOnly
          .where((stream) =>
              stream.fragments.isEmpty &&
              (stream.audioTrack == null || stream.audioTrack!.audioIsDefault))
          .toList();
      // AAC in MP4 has broad native decoder support; then take the best bitrate.
      streams.sort((a, b) {
        final container = (b.container.name == 'mp4' ? 1 : 0)
            .compareTo(a.container.name == 'mp4' ? 1 : 0);
        return container != 0 ? container : b.bitrate.compareTo(a.bitrate);
      });
      if (streams.isEmpty) return null;
      return ResolvedStream(
        streams.first.url.toString(),
        headers: {'User-Agent': _streamUserAgent},
        source: source,
        duration: track.duration,
      );
    }, const Duration(seconds: 12));
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
