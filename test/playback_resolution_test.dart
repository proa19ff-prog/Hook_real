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

import 'support/fake_music_sources.dart';

class RecordingPlayer extends AudioPlayer {
  final urls = <String>[];
  final requestHeaders = <Map<String, String>?>[];
  Duration Function(int load)? durationForLoad;
  Object? Function(int load)? errorForLoad;
  int plays = 0;
  @override
  Future<Duration?> setAudioSource(
    AudioSource source, {
    bool preload = true,
    int? initialIndex,
    Duration? initialPosition,
  }) async {
    final uri = source as UriAudioSource;
    urls.add(uri.uri.toString());
    requestHeaders.add(uri.headers);
    final error = errorForLoad?.call(urls.length);
    if (error != null) throw error;
    return durationForLoad?.call(urls.length) ?? const Duration(seconds: 158);
  }

  @override
  Future<void> play() async {
    plays++;
  }

  @override
  Future<void> stop() async {}
}

class NoFileCache extends AudioCacheManager {
  final downloadUrls = <String>[];
  @override
  Future<String?> getLocalCachedUrl(String cacheKey) async => null;
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
    downloadUrls.add(streamUrl);
    return null;
  }
}

class ControlledResolver extends StreamResolver {
  final FutureOr<ResolvedStream?> Function(MediaTrack) onResolve;
  int catalogResolves = 0;
  ControlledResolver(this.onResolve)
    : super(
        scExtractor: FakeSoundCloud(),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [],
      );
  @override
  Future<ResolvedStream?> resolveStream(MediaTrack track) async =>
      onResolve(track);
  @override
  Future<ResolvedStream?> resolveSpotifyTrack(
    MediaTrack track, {
    Set<TrackSource> excludedSources = const {},
  }) async {
    catalogResolves++;
    return onResolve(track);
  }
}

class TestPlayerService extends AudioPlayerService {
  TestPlayerService(
    RecordingPlayer player,
    StreamResolver resolver, {
    NoFileCache? cache,
  }) : super(
         player: player,
         resolver: resolver,
         cacheManager: cache ?? NoFileCache(),
       );
  @override
  Future<void> initialize() async {}
}

const track = MediaTrack(
  id: 'first',
  title: 'Song',
  artist: 'Artist',
  duration: Duration(seconds: 158),
  artworkUrl: '',
  source: TrackSource.spotify,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'a late resolution cannot replace a newer tap in the native player',
    () async {
      final first = Completer<ResolvedStream?>();
      final player = RecordingPlayer();
      final resolver = ControlledResolver((item) {
        if (item.id == 'first') return first.future;
        return const ResolvedStream(
          'https://audio.example/second',
          source: TrackSource.youtubeMusic,
        );
      });
      final service = TestPlayerService(player, resolver);
      addTearDown(service.dispose);
      final pending = service.playTrack(track);
      final next = track.copyWith(id: 'second');
      await service.playTrack(next);
      first.complete(const ResolvedStream('https://audio.example/first'));
      await pending;
      expect(player.urls, ['https://audio.example/second']);
      expect(service.currentTrack, next);
      expect(service.playbackSource, TrackSource.youtubeMusic);
    },
  );

  test(
    'actual 30-second audio is rejected even when metadata says full length',
    () async {
      final player = RecordingPlayer()
        ..durationForLoad = (index) => Duration(seconds: index == 1 ? 30 : 158);
      final service = TestPlayerService(
        player,
        ControlledResolver(
          (_) => const ResolvedStream(
            'https://audio.example/song',
            source: TrackSource.audius,
          ),
        ),
      );
      addTearDown(service.dispose);
      await service.playTrack(track);
      expect(player.urls, hasLength(2));
      expect(player.plays, 1);
      expect(service.playbackSource, TrackSource.audius);
    },
  );

  test(
    'YouTube replays refresh URLs and retain headers and provenance',
    () async {
      final player = RecordingPlayer();
      var resolves = 0;
      final service = TestPlayerService(
        player,
        ControlledResolver((_) {
          resolves++;
          return const ResolvedStream(
            'https://audio.example/song',
            source: TrackSource.youtubeMusic,
            headers: {'User-Agent': 'signed-client'},
          );
        }),
      );
      addTearDown(service.dispose);
      await service.playTrack(track);
      await service.playTrack(track);
      expect(resolves, 2); // YouTube URLs must be refreshed on every new load.
      expect(
        player.requestHeaders,
        everyElement({'User-Agent': 'signed-client'}),
      );
      expect(service.playbackSource, TrackSource.youtubeMusic);
    },
  );

  test('reusable source URLs keep their cache and headers', () async {
    final player = RecordingPlayer();
    var resolves = 0;
    final service = TestPlayerService(
      player,
      ControlledResolver((_) {
        resolves++;
        return const ResolvedStream(
          'https://audio.example/full',
          source: TrackSource.soundcloud,
          headers: {'User-Agent': 'source-agent'},
        );
      }),
    );
    addTearDown(service.dispose);
    await service.playTrack(track);
    await service.playTrack(track);
    expect(resolves, 1);
    expect(player.requestHeaders, everyElement({'User-Agent': 'source-agent'}));
  });

  test(
    'direct YouTube prefetch does not request an unused signed URL',
    () async {
      var resolves = 0;
      final service = TestPlayerService(
        RecordingPlayer(),
        ControlledResolver((_) {
          resolves++;
          return null;
        }),
      );
      addTearDown(service.dispose);
      service.prefetch([track.copyWith(source: TrackSource.youtubeMusic)]);
      await Future<void>.delayed(Duration.zero);
      expect(resolves, 0);
    },
  );

  test(
    'a resolution failure retains its cause without starting the player',
    () async {
      final failure = StateError('Video returned 403 (stream: 140)');
      final player = RecordingPlayer();
      final service = TestPlayerService(
        player,
        ControlledResolver((_) => throw failure),
      );
      addTearDown(service.dispose);
      final error = service.errorStream.firstWhere((event) => event != null);
      await service.playTrack(track.copyWith(source: TrackSource.youtubeMusic));
      final reported = await error;
      expect(reported!.cause, same(failure));
      expect(reported.message, contains('HTTP 403'));
      expect(player.urls, isEmpty);
    },
  );

  test(
    'failed direct uploads are not substituted through catalog fallback',
    () async {
      final player = RecordingPlayer();
      final resolver = ControlledResolver(
        (_) => throw StateError('Source unavailable'),
      );
      final service = TestPlayerService(player, resolver);
      addTearDown(service.dispose);
      await service.playTrack(track.copyWith(source: TrackSource.youtubeMusic));
      expect(resolver.catalogResolves, 0);
      expect(player.plays, 0);
      expect(service.currentTrack, isNull);
    },
  );

  test('catalog playback stops retrying an unreadable fast provider', () async {
    final youtube = FakeMusicSource(
      TrackSource.youtubeMusic,
      onSearch: (_) => [
        track.copyWith(id: 'video', source: TrackSource.youtubeMusic),
      ],
      onResolve: (_) => const ResolvedStream(
        'https://audio.example/youtube',
        source: TrackSource.youtubeMusic,
      ),
    );
    final soundcloud = FakeSoundCloud(
      onSearch: (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return [track.copyWith(id: 'sc', source: TrackSource.soundcloud)];
      },
      onResolve: (_) => 'https://audio.example/soundcloud',
    );
    final resolver = StreamResolver(
      scExtractor: soundcloud,
      spotifyCatalog: FakeCatalog(),
      additionalSources: [youtube],
    );
    final player = RecordingPlayer()
      ..errorForLoad = (load) => load <= 2
          ? PlayerException(0, 'Source error: Response code: 403')
          : null;
    final cache = NoFileCache();
    final service = TestPlayerService(player, resolver, cache: cache);
    addTearDown(service.dispose);
    await service.playTrack(track);
    expect(player.urls, [
      'https://audio.example/youtube',
      'https://audio.example/youtube',
      'https://audio.example/soundcloud',
    ]);
    // Two streaming resolutions, then one whole-file attempt of the original
    // before catalog fallback excludes the unreadable provider.
    expect(youtube.resolved, hasLength(3));
    expect(cache.downloadUrls, ['https://audio.example/youtube']);
    expect(service.currentTrack, track); // Catalog identity is not rewritten.
    expect(service.playbackSource, TrackSource.soundcloud);
    expect(player.plays, 1);
  });

  test('excluding exhausted providers completes without hanging', () async {
    final youtube = FakeMusicSource(TrackSource.youtubeMusic);
    final resolver = StreamResolver(
      scExtractor: FakeSoundCloud(),
      spotifyCatalog: FakeCatalog(),
      additionalSources: [youtube],
    );
    addTearDown(resolver.dispose);
    expect(
      await resolver.resolveSpotifyTrack(
        track,
        excludedSources: {TrackSource.soundcloud, TrackSource.youtubeMusic},
      ),
      isNull,
    );
    expect(youtube.queries, isEmpty);
  });

  test('stopping while a URL resolves prevents delayed autoplay', () async {
    final pending = Completer<ResolvedStream?>();
    final player = RecordingPlayer();
    final service = TestPlayerService(
      player,
      ControlledResolver((_) => pending.future),
    );
    addTearDown(service.dispose);
    final play = service.playTrack(track);
    await service.stop();
    pending.complete(const ResolvedStream('https://audio.example/song'));
    await play;
    expect(player.urls, isEmpty);
    expect(player.plays, 0);
  });
}
