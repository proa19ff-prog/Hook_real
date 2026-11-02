// Optional live check; never part of the offline test suite.
// dart run tool/source_smoke.dart [query]
import 'dart:io';

import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/sources/audius_source.dart';
import 'package:hook/features/extractor/sources/youtube_music_source.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/search/data/lyrics_search_service.dart';

Future<void> main(List<String> args) async {
  final query =
      args.isEmpty ? 'Post Malone Swae Lee Sunflower' : args.join(' ');
  final youtube = YouTubeMusicSource();
  final audius = AudiusSource();
  final resolver = StreamResolver(additionalSources: [youtube, audius]);
  final lyrics = LyricsSearchService();
  final target = MediaTrack(
      id: 'smoke',
      title: 'Sunflower',
      artist: 'Post Malone & Swae Lee',
      duration: const Duration(seconds: 158),
      artworkUrl: '',
      source: TrackSource.spotify);
  try {
    await Future.wait([
      for (final source in [youtube, audius])
        () async {
          try {
            final tracks = await source.searchTracks(query);
            stdout.writeln('${source.source.label}: ${tracks.length} results');
            for (final track in tracks.take(5)) {
              stdout.writeln(
                  '  ${track.artist} — ${track.title} (${track.duration.inSeconds}s)');
            }
            final matches = tracks.where(
                (track) => StreamResolver.isPlayableMatch(target, track));
            if (matches.isNotEmpty) {
              final stream = await source.resolveTrack(matches.first);
              stdout.writeln(
                  '  matching full stream: ${stream == null ? 'not available' : Uri.parse(stream.url).host}');
              if (stream != null) {
                final client = HttpClient()
                  ..connectionTimeout = const Duration(seconds: 6);
                try {
                  final request = await client.getUrl(Uri.parse(stream.url));
                  stream.headers.forEach(request.headers.set);
                  request.headers.set(HttpHeaders.rangeHeader, 'bytes=0-1023');
                  final response = await request
                      .close()
                      .timeout(const Duration(seconds: 10));
                  final bytes =
                      await response.first.timeout(const Duration(seconds: 10));
                  stdout.writeln(
                      '  audio probe: HTTP ${response.statusCode}, ${response.headers.contentType}, first chunk ${bytes.length} bytes');
                } finally {
                  client.close(force: true);
                }
              }
            }
          } catch (error) {
            stdout.writeln('${source.source.label}: unavailable ($error)');
          }
        }(),
      () async {
        try {
          final hits =
              await lyrics.search('needless to say I keep her in check');
          stdout.writeln('Lyrics: ${hits.length} matched recordings');
          for (final hit in hits.take(4)) {
            stdout.writeln(
                '  ${hit.track.artist} — ${hit.track.title} (${hit.track.duration.inSeconds}s)');
          }
        } catch (error) {
          stdout.writeln('Lyrics: unavailable ($error)');
        }
      }(),
    ]);
  } finally {
    resolver.dispose();
    lyrics.close();
  }
}
