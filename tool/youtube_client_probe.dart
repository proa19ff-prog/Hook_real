// Optional live check; never part of the offline test suite.
// dart run tool/youtube_client_probe.dart [videoId|search query]
//
// Probes every Innertube client individually: manifest fetch timing, the best
// audio-only stream and a real ranged GET against googlevideo. Each client runs
// in an isolated session stamped with its own User-Agent, mirroring playback.
// Prints one line per client so it is obvious which clients currently serve
// playable audio (and which get 403 or throttled). Stream URLs are never
// printed.
import 'dart:async';
import 'dart:io';

import 'package:hook/features/extractor/sources/youtube_http_client.dart';
import 'package:http/io_client.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final _clients = <String, YoutubeApiClient>{
  'ios': YoutubeApiClient.ios,
  'tv': YoutubeApiClient.tv,
  'mweb': YoutubeApiClient.mweb,
  'androidVr': YoutubeApiClient.androidVr,
  'safari': YoutubeApiClient.safari,
  'androidSdkless': YoutubeApiClient.androidSdkless,
  'androidMusic': YoutubeApiClient.androidMusic,
};

String? _clientUserAgent(YoutubeApiClient client) {
  final context = client.payload['context'];
  final info = context is Map ? context['client'] : null;
  final userAgent = info is Map ? info['userAgent'] : null;
  return userAgent is String && userAgent.isNotEmpty ? userAgent : null;
}

String _sanitize(Object error) {
  final firstLine = error.toString().split('\n').first;
  final query = firstLine.indexOf('?');
  final safe = query == -1 ? firstLine : firstLine.substring(0, query);
  return safe.length > 140 ? safe.substring(0, 140) : safe;
}

Future<void> main(List<String> args) async {
  final transport0 = HttpClient()
    ..connectionTimeout = const Duration(seconds: 8);
  final explode0 = YoutubeExplode(
    httpClient: YouTubeRequestClient(IOClient(transport0)),
  );
  var videoId = args.isNotEmpty ? args.first : 'dQw4w9WgXcQ';
  if (!RegExp(r'^[\w-]{11}$').hasMatch(videoId)) {
    final query = args.join(' ');
    stdout.writeln('Searching "$query"...');
    final results = await explode0.search.search(query).timeout(
      const Duration(seconds: 20),
    );
    final playable = results.where(
      (video) =>
          !video.isLive &&
          video.duration != null &&
          video.duration!.inSeconds >= 45,
    );
    if (playable.isEmpty) {
      stdout.writeln('Search returned no playable videos.');
      explode0.close();
      return;
    }
    videoId = playable.first.id.value;
    stdout.writeln(
      'Probing first result: ${playable.first.author} — '
      '${playable.first.title} ($videoId)',
    );
  } else {
    stdout.writeln('Probing video $videoId');
  }
  explode0.close();

  for (final entry in _clients.entries) {
    final userAgent =
        _clientUserAgent(entry.value) ?? YouTubeRequestClient.streamUserAgent;
    final watch = Stopwatch()..start();
    HttpClient? transport;
    final explode = YoutubeExplode(
      httpClient: YouTubeRequestClient(
        IOClient(transport = HttpClient()
          ..connectionTimeout = const Duration(seconds: 8)
          ..idleTimeout = const Duration(seconds: 8)),
        userAgent: userAgent,
      ),
    );
    try {
      final manifest = await explode.videos.streamsClient
          .getManifest(
            videoId,
            ytClients: [entry.value],
            requireWatchPage: false,
          )
          .timeout(const Duration(seconds: 25));
      final audio =
          manifest.audioOnly
              .where((stream) => stream.fragments.isEmpty)
              .toList()
            ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      if (audio.isEmpty) {
        stdout.writeln(
          '${entry.key.padRight(15)} manifest ${watch.elapsedMilliseconds}ms, '
          'no audio-only streams',
        );
        continue;
      }
      final stream = audio.first;
      final request = await transport.getUrl(stream.url);
      request.headers.set('user-agent', userAgent);
      request.headers.set('range', 'bytes=0-65535');
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final bytes = await response.fold<int>(
        0,
        (sum, chunk) => sum + chunk.length,
      );
      stdout.writeln(
        '${entry.key.padRight(15)} ${watch.elapsedMilliseconds}ms, '
        'HTTP ${response.statusCode}, itag ${stream.tag}, '
        '${stream.container.name}, '
        '${stream.bitrate.kiloBitsPerSecond.round()}kbps, '
        'probe $bytes bytes',
      );
    } catch (error) {
      stdout.writeln(
        '${entry.key.padRight(15)} FAILED '
        '(${watch.elapsedMilliseconds}ms) ${_sanitize(error)}',
      );
    } finally {
      explode.close();
    }
  }
}
