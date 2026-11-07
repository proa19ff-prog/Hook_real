// ignore_for_file: avoid_print
// Optional live check; never part of the offline test suite.
// dart run tool/download_probe.dart [query]
// Probes what the explicit download button does vs what playback does:
// resolves SoundCloud/YouTube download streams and attempts the full-file
// GET the cache manager performs, printing status codes and headers.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/models/resolved_stream.dart';
import 'package:hook/features/extractor/sources/remote_resolver_source.dart';
import 'package:hook/features/extractor/sources/youtube_music_source.dart';
import 'package:hook/features/extractor/soundcloud/soundcloud_extractor.dart';
import 'package:hook/features/extractor/stream_resolver.dart';

final dio = Dio(
  BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    validateStatus: (status) => status != null && status < 500,
  ),
);

Future<void> probeGet(
  String label,
  ResolvedStream stream, {
  bool withRange = true,
}) async {
  final uri = Uri.tryParse(stream.url);
  if (uri == null || !uri.isScheme('https') && !uri.isScheme('http')) {
    print('$label: not an http url (${stream.url.length} chars)');
    return;
  }
  final sw = Stopwatch()..start();
  try {
    final response = await dio.get<ResponseBody>(
      stream.url,
      options: Options(
        headers: {
          if (withRange) 'Range': 'bytes=0-',
          ...stream.headers,
        },
        responseType: ResponseType.stream,
      ),
    );
    final body = response.data!;
    final first = <int>[];
    await for (final chunk in body.stream) {
      first.addAll(chunk.take(16));
      if (first.length >= 16) break;
    }
    print(
      '$label: HTTP ${response.statusCode} in ${sw.elapsedMilliseconds}ms, '
      'content-length=${response.headers.value('content-length')}, '
      'content-range=${response.headers.value('content-range')}, '
      'type=${response.headers.value('content-type')}, '
      'head=${first.take(8).map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',
    );
  } catch (error) {
    print('$label: FAILED in ${sw.elapsedMilliseconds}ms -> $error');
  }
}

Future<void> main(List<String> args) async {
  final query = args.isEmpty ? 'Calvin Harris My Way' : args.join(' ');

  final sc = SoundCloudExtractor();
  final youtube = YouTubeMusicSource();
  final remote = RemoteResolverSource();
  final resolver = StreamResolver(additionalSources: [youtube, remote]);

  // --- SoundCloud -----------------------------------------------------------
  try {
    final found = await sc.searchTracks(query, limit: 3);
    print('SC search: ${found.length} results');
    for (final track in found.take(2)) {
      final fullFile = await sc.resolveAudioStream(
        track.id,
        fullFileOnly: true,
      );
      final any = await sc.resolveAudioStream(track.id);
      print(
        'SC "${track.title}": full-file=${fullFile != null ? 'yes' : 'NO'} '
        'any=${any != null ? 'yes' : 'NO'}',
      );
      if (fullFile != null) {
        await probeGet('SC download GET (Range)', ResolvedStream(fullFile.url));
        await probeGet('SC download GET (no Range)', ResolvedStream(fullFile.url), withRange: false);
      }
      if (any != null && fullFile != null && any.url != fullFile.url) {
        await probeGet('SC playback stream GET', ResolvedStream(any.url));
      }
    }
  } catch (error) {
    print('SC probe failed: $error');
  }

  // --- YouTube Music --------------------------------------------------------
  try {
    final found = await youtube.searchTracks(query, limit: 2);
    print('YT search: ${found.length} results');
    for (final track in found.take(1)) {
      final sw = Stopwatch()..start();
      ResolvedStream? stream;
      String? resolveError;
      try {
        stream = await youtube
            .resolveDownloadTrack(track)
            .timeout(const Duration(seconds: 25));
      } catch (error) {
        resolveError = '$error';
      }
      print(
        'YT resolveDownloadTrack "${track.title}": '
        '${stream != null ? 'ok in ${sw.elapsedMilliseconds}ms' : 'null/err ${sw.elapsedMilliseconds}ms $resolveError'}',
      );
      if (stream != null) {
        await probeGet('YT download GET (Range)', stream);
      }
      // What the playback matcher would pick for the same recording.
      try {
        final catalogTrack = track.copyWith(source: TrackSource.youtubeMusic);
        final playback = await resolver
            .resolveStream(catalogTrack)
            .timeout(const Duration(seconds: 30));
        print(
          'YT resolveStream (playback matcher): ${playback?.source?.name ?? 'null'}',
        );
        if (playback != null) await probeGet('YT playback GET', playback);
      } catch (error) {
        print('YT resolveStream failed: $error');
      }
    }
  } catch (error) {
    print('YT probe failed: $error');
  }

  sc.close();
  youtube.close();
  remote.close();
  exit(0);
}
