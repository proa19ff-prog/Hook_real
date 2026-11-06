import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/models/resolved_stream.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

const original = MediaTrack(
  id: 'original-video',
  title: 'Original',
  artist: 'Artist',
  album: 'Album',
  duration: Duration(minutes: 3),
  artworkUrl: '',
  source: TrackSource.youtubeMusic,
);

class FakePlayer extends AudioPlayer {
  final states = StreamController<PlayerState>.broadcast();
  final events = StreamController<PlaybackEvent>.broadcast();
  final loaded = <Uri>[];
  final initialPositions = <Duration?>[];
  bool failRemote = true;
  bool failLocal = false;
  bool failLocalPlay = false;
  bool active = false;
  Duration currentPosition = Duration.zero;
  ProcessingState state = ProcessingState.idle;
  @override
  bool get playing => active;
  @override
  ProcessingState get processingState => state;
  @override
  Duration get position => currentPosition;
  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Stream<PlaybackEvent> get playbackEventStream => events.stream;
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    final uri = (source as UriAudioSource).uri;
    loaded.add(uri);
    initialPositions.add(initialPosition);
    currentPosition = initialPosition ?? Duration.zero;
    if ((uri.scheme != 'file' && failRemote) ||
        (uri.scheme == 'file' && failLocal)) {
      throw const HttpException('Native streaming failed');
    }
    state = ProcessingState.ready;
    return original.duration;
  }

  @override
  Future<void> play() async {
    if (failLocalPlay && loaded.last.scheme == 'file') {
      throw const HttpException('Local decoder failed during play');
    }
    active = true;
  }

  @override
  Future<void> pause() async {
    active = false;
  }

  @override
  Future<void> stop() async {
    active = false;
    state = ProcessingState.idle;
  }

  @override
  Future<void> seek(Duration? position, {int? index}) async {
    currentPosition = position ?? Duration.zero;
  }

  @override
  Future<void> setVolume(double volume) async {}
  @override
  Future<void> dispose() async {
    await states.close();
    await events.close();
    await super.dispose();
  }
}

class FakeResolver extends StreamResolver {
  int resolutions = 0;
  int downloadResolutions = 0;
  bool noNativeStream = false;
  @override
  Future<ResolvedStream?> resolveStream(MediaTrack track) async {
    resolutions++;
    if (noNativeStream) return null;
    return ResolvedStream(
      'https://audio.example/${track.id}',
      source: track.source,
    );
  }

  @override
  Future<ResolvedStream?> resolveDownloadStream(MediaTrack track) async {
    downloadResolutions++;
    return ResolvedStream(
      'https://audio.example/${track.id}',
      source: track.source,
    );
  }
}

class FakeCache extends AudioCacheManager {
  final File file;
  int downloads = 0;
  MediaTrack? savedTrack;
  bool cached = false;
  Future<File?> Function(CancelToken?)? onDownload;
  FakeCache(this.file);
  @override
  Future<String?> getLocalCachedUrl(String trackId) async =>
      cached ? file.uri.toString() : null;
  @override
  Future<File?> downloadTrack(
    MediaTrack track,
    String streamUrl, {
    String? cacheKey,
    Map<String, String>? headers,
    String? fileExtension,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  }) async {
    downloads++;
    savedTrack = track;
    if (onDownload != null) return onDownload!(cancelToken);
    cached = true;
    return file;
  }

  @override
  Future<void> removeCachedTrack(String trackId) async {
    cached = false;
  }
}

Future<void> settleUntil(bool Function() done) async {
  for (var i = 0; i < 100 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(done(), true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late FakePlayer player;
  late FakeResolver resolver;
  late FakeCache cache;
  late AudioPlayerService service;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('hook_playback_test_');
    final file = File('${directory.path}/original.webm');
    await file.writeAsBytes(List.filled(2048, 0));
    player = FakePlayer();
    resolver = FakeResolver();
    cache = FakeCache(file);
    service = AudioPlayerService(
      player: player,
      resolver: resolver,
      cacheManager: cache,
    );
  });
  tearDown(() async {
    await service.dispose();
    await directory.delete(recursive: true);
  });

  test('failed native stream downloads once and plays original identity from memory', () async {
    await service.setQueue([original]);
    expect(player.loaded.map((uri) => uri.scheme), ['https', 'https', 'file']);
    expect(cache.downloads, 1);
    expect(cache.savedTrack, same(original));
    expect(service.currentTrack, same(original));
    expect(service.trackQueue, [original]);
    expect(service.currentIndex, 0);
    expect(service.mediaItem.value!.id, 'youtubeMusic:original-video');
    expect(service.playbackSource, TrackSource.local);
    expect(player.playing, true);
    await service.playTrack(original);
    expect(player.loaded.last.scheme, 'file');
    expect(cache.downloads, 1);
  });

  test('download resolver is tried even when the native Range probe yields no stream', () async {
    resolver.noNativeStream = true;
    await service.playTrack(original);
    expect(player.loaded.single.scheme, 'file');
    expect(resolver.resolutions, 1);
    expect(resolver.downloadResolutions, 1);
    expect(service.currentTrack, same(original));
  });

  test('runtime stream error recovers at the same timestamp without resetting lyrics identity', () async {
    player.failRemote = false;
    await service.setQueue([original]);
    player.currentPosition = const Duration(seconds: 47);
    player.events.addError(const HttpException('CDN interrupted'));
    await settleUntil(() => player.loaded.length == 2);
    expect(player.loaded.last.scheme, 'file');
    expect(player.initialPositions.last, const Duration(seconds: 47));
    expect(service.currentTrack, same(original));
    expect(service.currentIndex, 0);
    expect(cache.downloads, 1);
  });

  test('switching tracks cancels fallback and never plays the old downloaded track', () async {
    final pending = Completer<File?>();
    CancelToken? oldToken;
    cache.onDownload = (token) {
      oldToken = token;
      return pending.future;
    };
    final oldPlayback = service.playTrack(original);
    await settleUntil(() => cache.downloads == 1);
    player.failRemote = false;
    final next = original.copyWith(id: 'next-video');
    await service.playTrack(next);
    expect(oldToken!.isCancelled, true);
    pending.complete(cache.file);
    await oldPlayback;
    expect(service.currentTrack, same(next));
    expect(player.loaded.last.toString(), 'https://audio.example/next-video');
    expect(player.loaded.any((uri) => uri.scheme == 'file'), false);
  });

  test(
    'pause while downloading stays paused and a requested seek is retained',
    () async {
      final pending = Completer<File?>();
      cache.onDownload = (_) => pending.future;
      final playback = service.playTrack(original);
      await settleUntil(() => cache.downloads == 1);
      await service.pause();
      await service.seek(const Duration(seconds: 30));
      pending.complete(cache.file);
      await playback;
      expect(player.loaded.last.scheme, 'file');
      expect(player.playing, false);
      expect(player.initialPositions.last, const Duration(seconds: 30));
    },
  );

  test(
    'runtime fallback reports a local play failure instead of dropping it',
    () async {
      player.failRemote = false;
      await service.playTrack(original);
      player.failLocalPlay = true;
      player.events.addError(const HttpException('CDN interrupted'));
      await settleUntil(() => service.currentTrack == null);
      expect(cache.downloads, 1);
      expect(player.loaded, hasLength(2));
    },
  );

  test(
    'unavailable download reports one failure without an infinite retry',
    () async {
      cache.onDownload = (_) async => null;
      final errors = <AudioPlaybackError?>[];
      final subscription = service.errorStream.listen(errors.add);
      await service.playTrack(original);
      await Future<void>.delayed(Duration.zero);
      expect(cache.downloads, 1);
      expect(errors.whereType<AudioPlaybackError>(), hasLength(1));
      expect(service.currentTrack, isNull);
      await subscription.cancel();
    },
  );
}
