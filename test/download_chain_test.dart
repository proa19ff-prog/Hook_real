import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/models/resolved_stream.dart';
import 'package:hook/features/extractor/sources/remote_resolver_source.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:just_audio/just_audio.dart';

const _ytTrack = MediaTrack(
  id: 'dQw4w9WgXcQ',
  title: 'Song',
  artist: 'Artist',
  duration: Duration(minutes: 3),
  artworkUrl: '',
  source: TrackSource.youtubeMusic,
);

/// Resolvers that fail like the real ones do on carrier networks: the direct
/// YouTube download resolves a url whose CDN answers 403 to the whole-file
/// GET, and the playback matcher throws. Only the server proxy candidate
/// actually serves bytes.
class _FailingDirectResolver extends StreamResolver {
  _FailingDirectResolver() : super(additionalSources: []);

  @override
  RemoteResolverSource? get remoteSource => _remote;
  final _RemoteStub _remote = _RemoteStub();

  @override
  Future<ResolvedStream?> resolveDownloadStream(MediaTrack track) async {
    // A signed direct url the CDN will refuse to serve.
    return const ResolvedStream('https://blocked.example/file.m4a');
  }

  @override
  Future<ResolvedStream?> resolveStream(MediaTrack track) async {
    throw StateError('playback matcher unavailable');
  }
}

class _RemoteStub extends RemoteResolverSource {
  @override
  Future<ResolvedStream?> resolveTrack(MediaTrack track) async {
    return const ResolvedStream('https://server.example/stream?id=x');
  }
}

class _SelectiveAdapter implements HttpClientAdapter {
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.uri.host == 'blocked.example') {
      return ResponseBody.fromString('Forbidden', 403);
    }
    final bytes = Uint8List(2048);
    bytes.setRange(4, 8, 'ftyp'.codeUnits);
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        'content-type': ['audio/mp4'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _TestService extends AudioPlayerService {
  _TestService(StreamResolver resolver, AudioCacheManager cache)
      : super(
          player: AudioPlayer(),
          resolver: resolver,
          cacheManager: cache,
        );

  @override
  Future<void> initialize() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hook_dl_chain_');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test('download falls through blocked direct urls to the server', () async {
    final dio = Dio();
    final adapter = _SelectiveAdapter();
    dio.httpClientAdapter = adapter;
    final cache = AudioCacheManager(dio: dio, directory: directory);

    final service = _TestService(_FailingDirectResolver(), cache);
    addTearDown(service.dispose);

    final file = await service.downloadTrack(_ytTrack);
    expect(file, isNotNull);
    // Both candidates were attempted, in order: the blocked direct url
    // first, then the server proxy — which produced the cached file.
    expect(
      adapter.requests.map((request) => request.uri.host),
      ['blocked.example', 'server.example'],
    );
    expect(
      await cache.getLocalCachedUrl('youtubeMusic_dQw4w9WgXcQ'),
      isNotNull,
    );
  });
}
