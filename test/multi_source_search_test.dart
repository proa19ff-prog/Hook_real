import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/models/resolved_stream.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/search/domain/search_query_normalizer.dart';

import 'support/fake_music_sources.dart';

const target = MediaTrack(
    id: 'catalog',
    title: 'Sunflower',
    artist: 'Post Malone & Swae Lee',
    duration: Duration(seconds: 158),
    artworkUrl: '',
    source: TrackSource.spotify);

void main() {
  test('phonetics are compositional and bounded, not only a fixed song alias',
      () {
    expect(SearchQueryNormalizer.variants('  МАРТИН   РОЗ '),
        contains('martin rose'));
    expect(SearchQueryNormalizer.variants('Дуа Липа'), contains('dua lipa'));
    expect(SearchQueryNormalizer.variants('алан волкер фейдед'),
        contains('alan walker faded'));
    expect(
        SearchQueryNormalizer.variants('fkfy djkrth'), contains('alan walker'));
    expect(
        SearchQueryNormalizer.variants('madkid rise'), contains('madk1d rise'));
    expect(SearchQueryNormalizer.variants('   '), isEmpty);
    expect(SearchQueryNormalizer.variants('алан волкер фейдед').length,
        lessThanOrEqualTo(5));
    expect(SearchQueryNormalizer.variants('квинтет').contains('queenтет'),
        isFalse);
  });

  test('15 irrelevant hits never suppress the Cyrillic phonetic variant',
      () async {
    final wanted =
        target.copyWith(id: 'wanted', title: 'Martin Rose', artist: 'Artist');
    final catalog = FakeCatalog(
        onSearch: (query) => query == 'martin rose'
            ? [wanted]
            : [
                for (var i = 0; i < 18; i++)
                  target.copyWith(
                      id: '$i', title: 'Other song $i', artist: 'Other'),
              ]);
    final soundCloud = FakeSoundCloud();
    final resolver = StreamResolver(
        scExtractor: soundCloud,
        spotifyCatalog: catalog,
        additionalSources: []);
    addTearDown(resolver.dispose);
    final results = await resolver
        .search(query: 'Мартин роз', sources: {TrackSource.spotify});
    expect(catalog.queries, contains('martin rose'));
    expect(results.first.id, 'wanted');
    expect(soundCloud.queries, isEmpty);
  });

  test('an explicit source filter stays isolated and has its own cache',
      () async {
    final catalog = FakeCatalog(onSearch: (_) => [target]);
    final soundCloud = FakeSoundCloud(
        onSearch: (_) => [target.copyWith(source: TrackSource.soundcloud)]);
    final youtube = FakeMusicSource(TrackSource.youtubeMusic,
        onSearch: (_) => [target.copyWith(source: TrackSource.youtubeMusic)]);
    final resolver = StreamResolver(
        scExtractor: soundCloud,
        spotifyCatalog: catalog,
        additionalSources: [youtube]);
    addTearDown(resolver.dispose);
    final videos = await resolver
        .search(query: 'Sunflower', sources: {TrackSource.youtubeMusic});
    expect(videos.every((track) => track.source == TrackSource.youtubeMusic),
        isTrue);
    expect(soundCloud.queries, isEmpty);
    expect(catalog.queries, isEmpty);
    final records = await resolver
        .search(query: 'Sunflower', sources: {TrackSource.spotify});
    expect(records.single.source, TrackSource.spotify);
    final count = youtube.queries.length;
    await resolver
        .search(query: 'Sunflower', sources: {TrackSource.youtubeMusic});
    expect(youtube.queries.length, count);
  });

  test('one failed source cannot erase another source results', () async {
    final youtube = FakeMusicSource(TrackSource.youtubeMusic,
        onSearch: (_) => throw StateError('network unavailable'));
    final audius = FakeMusicSource(TrackSource.audius,
        onSearch: (_) => [target.copyWith(source: TrackSource.audius)]);
    final resolver = StreamResolver(
        scExtractor: FakeSoundCloud(),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [youtube, audius]);
    addTearDown(resolver.dispose);
    final results = await resolver.search(query: 'Sunflower');
    expect(results.single.source, TrackSource.audius);
    expect(await resolver.search(query: ''), isEmpty);
    expect(await resolver.search(query: 'Sunflower', sources: {}), isEmpty);
  });

  test(
      'catalog playback returns a usable source without waiting for a blocked source',
      () async {
    final blocked = Completer<List<MediaTrack>>();
    final youtubeTrack =
        target.copyWith(id: 'video', source: TrackSource.youtubeMusic);
    final youtube = FakeMusicSource(TrackSource.youtubeMusic,
        onSearch: (_) => [youtubeTrack],
        onResolve: (_) => const ResolvedStream('https://audio.example/full.m4a',
            source: TrackSource.youtubeMusic,
            headers: {'User-Agent': 'required-client'}));
    final resolver = StreamResolver(
        scExtractor: FakeSoundCloud(onSearch: (_) => blocked.future),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [youtube]);
    addTearDown(resolver.dispose);
    final stream = await resolver
        .resolveStream(target)
        .timeout(const Duration(seconds: 2));
    expect(blocked.isCompleted, isFalse);
    expect(stream?.source, TrackSource.youtubeMusic);
    expect(stream?.headers['User-Agent'], 'required-client');
    blocked.complete([]);
  });

  test(
      'wrong duration, previews, unknown duration and versions are never automatic matches',
      () async {
    final candidates = [
      target.copyWith(
          id: 'preview',
          source: TrackSource.audius,
          duration: const Duration(seconds: 30)),
      target.copyWith(
          id: 'unknown', source: TrackSource.audius, duration: Duration.zero),
      target.copyWith(
          id: 'long',
          source: TrackSource.audius,
          duration: const Duration(seconds: 180)),
      target.copyWith(
          id: 'remix', source: TrackSource.audius, title: 'Sunflower (Remix)'),
      target.copyWith(
          id: 'cover',
          source: TrackSource.audius,
          artist: 'Acoustic Collective'),
    ];
    for (final candidate in candidates) {
      expect(StreamResolver.isPlayableMatch(target, candidate), isFalse,
          reason: candidate.id);
    }
    final source =
        FakeMusicSource(TrackSource.audius, onSearch: (_) => candidates);
    final resolver = StreamResolver(
        scExtractor: FakeSoundCloud(),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [source]);
    addTearDown(resolver.dispose);
    expect(await resolver.resolveStream(target), isNull);
    expect(source.resolved, isEmpty);
  });

  test('same numeric IDs in different sources do not share failed-match state',
      () async {
    final scTrack =
        target.copyWith(id: 'shared', source: TrackSource.soundcloud);
    final video =
        target.copyWith(id: 'shared', source: TrackSource.youtubeMusic);
    final sc = FakeSoundCloud(
        onSearch: (_) => [scTrack],
        onResolve: (_) => 'https://sc.example/audio');
    final youtube = FakeMusicSource(TrackSource.youtubeMusic,
        onSearch: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          return [video];
        },
        onResolve: (_) => const ResolvedStream('https://yt.example/audio',
            source: TrackSource.youtubeMusic));
    final resolver = StreamResolver(
        scExtractor: sc,
        spotifyCatalog: FakeCatalog(),
        additionalSources: [youtube]);
    addTearDown(resolver.dispose);
    expect(
        (await resolver.resolveStream(target))?.source, TrackSource.soundcloud);
    resolver.forgetMatch(target);
    expect((await resolver.resolveStream(target))?.source,
        TrackSource.youtubeMusic);
  });

  test('selecting a particular upload never falls back to another recording',
      () async {
    final sc = FakeSoundCloud();
    final youtube =
        FakeMusicSource(TrackSource.youtubeMusic, onResolve: (_) => null);
    final resolver = StreamResolver(
        scExtractor: sc,
        spotifyCatalog: FakeCatalog(),
        additionalSources: [youtube]);
    addTearDown(resolver.dispose);
    final video = target.copyWith(source: TrackSource.youtubeMusic);
    expect(await resolver.resolveStream(video), isNull);
    expect(await resolver.resolveSpotifyTrack(video), isNull);
    expect(sc.queries, isEmpty);
    expect(youtube.queries, isEmpty);
  });

  test('invalidated in-flight matches cannot win or update the cache',
      () async {
    final resolving = Completer<ResolvedStream?>();
    final started = Completer<void>();
    final youtube = FakeMusicSource(TrackSource.youtubeMusic,
        onSearch: (_) => [target.copyWith(source: TrackSource.youtubeMusic)],
        onResolve: (_) {
          if (!started.isCompleted) started.complete();
          return resolving.future;
        });
    final resolver = StreamResolver(
        scExtractor: FakeSoundCloud(),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [youtube]);
    addTearDown(resolver.dispose);
    final pending = resolver.resolveStream(target);
    await started.future;
    resolver.forgetMatch(target);
    resolving.complete(const ResolvedStream('https://old.example/audio'));
    expect(await pending, isNull);
  });
}
