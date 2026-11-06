// Optional bounded live diagnosis: dart run tool/check_track_sources.dart
// Prints metadata/status only, never signed URLs, tokens or raw exceptions.
import 'dart:io';

import 'package:hook/core/diagnostics/playback_diagnostics.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/soundcloud/soundcloud_extractor.dart';
import 'package:hook/features/extractor/sources/youtube_music_source.dart';
import 'package:hook/features/extractor/sources/youtube_proxy.dart';
import 'package:hook/features/extractor/spotify/spotify_catalog_service.dart';

Future<void> main() async {
  HttpOverrides.global = SelectiveYouTubeProxyHttpOverrides();
  final youtube = YouTubeMusicSource();
  final soundCloud = SoundCloudExtractor();
  final catalog = SpotifyCatalogService();
  const query = 'madk1d VILLIAN Династия';
  Future<void> search(String source, Future<List<MediaTrack>> request) async {
    try {
      final tracks = await request;
      stdout.writeln('$source: ${tracks.length} results');
      for (final track in tracks.take(5)) {
        stdout.writeln(
          '  ${track.artist} — ${track.title} (${track.duration.inSeconds}s)',
        );
      }
    } catch (error) {
      stdout.writeln('$source: ${PlaybackDiagnostics.failureLabel(error)}');
    }
  }

  try {
    await Future.wait([
      search('YouTube search', youtube.searchTracks(query, limit: 5)),
      search('SoundCloud search', soundCloud.searchTracks(query, limit: 5)),
      search('Catalog search', catalog.searchTracks(query, limit: 5)),
    ]);
    try {
      final stream = await youtube.resolveTrack(
        const MediaTrack(
          id: 'dQw4w9WgXcQ',
          title: 'Never Gonna Give You Up',
          artist: 'Rick Astley',
          duration: Duration(seconds: 213),
          artworkUrl: '',
          source: TrackSource.youtubeMusic,
        ),
      );
      if (stream == null) {
        stdout.writeln('YouTube manifest: no audio');
        return;
      }
      stdout.writeln('YouTube manifest: audio URL obtained');
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 5);
      try {
        final request = await client.getUrl(Uri.parse(stream.url));
        stream.headers.forEach(request.headers.set);
        request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-1023');
        final response = await request.close().timeout(
          const Duration(seconds: 8),
        );
        final first = await response.first.timeout(const Duration(seconds: 8));
        stdout.writeln(
          'YouTube audio: HTTP ${response.statusCode}, ${first.length} initial bytes',
        );
      } finally {
        client.close(force: true);
      }
    } catch (error) {
      stdout.writeln(
        'YouTube audio: ${PlaybackDiagnostics.failureLabel(error)}',
      );
    }
  } finally {
    youtube.close();
    soundCloud.close();
    catalog.close();
  }
}
