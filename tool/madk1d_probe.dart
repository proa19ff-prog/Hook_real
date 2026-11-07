// ignore_for_file: avoid_print
// One-off probe for the Madk1d "Так похуй" matching question.
// dart run tool/madk1d_probe.dart
import 'dart:io';

import 'package:hook/features/extractor/sources/remote_resolver_source.dart';
import 'package:hook/features/extractor/sources/youtube_music_source.dart';
import 'package:hook/features/extractor/soundcloud/soundcloud_extractor.dart';
import 'package:hook/features/extractor/stream_resolver.dart';

Future<void> main() async {
  final sc = SoundCloudExtractor();
  final yt = YouTubeMusicSource();
  final remote = RemoteResolverSource();
  final resolver = StreamResolver(additionalSources: [yt, remote]);

  final query = 'Madk1d Так похуй';

  // What SoundCloud search returns (and whether the original is importable).
  try {
    final found = await sc.searchTracks(query, limit: 5);
    print('SC search (${found.length}):');
    for (final t in found) {
      final stream = await sc.resolveAudioStream(t.id);
      print(
        ' - "${t.title}" by ${t.artist} id=${t.id} '
        'plays=${t.playbackCount} -> ${stream == null ? 'NO STREAM' : 'ok ${stream.bitrateKbps}kbps'}',
      );
    }
  } catch (e) {
    print('SC failed: $e');
  }

  // What YouTube search returns for the same query, and what the server
  // fallback yields for the first entry.
  try {
    final found = await yt.searchTracks(query, limit: 3);
    print('YT search (${found.length}):');
    for (final t in found) {
      print(' - "${t.title}" id=${t.id}');
    }
    if (found.isNotEmpty) {
      final viaServer = await remote.resolveTrack(found.first);
      print(
        'server proxy for ${found.first.id}: '
        '${viaServer == null ? 'null' : 'ok (${viaServer.url.length} chars)'}',
      );
    }
  } catch (e) {
    print('YT failed: $e');
  }

  // Full pipeline for the catalog-style entry (what the app search shows).
  try {
    final tracks = await resolver.search(query: query);
    print('resolver.search: ${tracks.length} results');
    for (final t in tracks.take(5)) {
      print(' - [${t.source.name}] "${t.title}" by ${t.artist}');
    }
  } catch (e) {
    print('resolver.search failed: $e');
  }

  sc.close();
  yt.close();
  remote.close();
  exit(0);
}
