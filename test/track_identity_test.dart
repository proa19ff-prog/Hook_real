import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/models/resolved_stream.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/import/music_import_service.dart';

import 'support/fake_music_sources.dart';

const dynasty = MediaTrack(
  id: 'requested',
  title: 'Династия',
  artist: 'MadKid & VILLIAN',
  duration: Duration(seconds: 150),
  artworkUrl: '',
  source: TrackSource.spotify,
);

void main() {
  test(
    'same title by unrelated artist cannot replace imported metadata',
    () async {
      final wrong = dynasty.copyWith(id: 'wrong', artist: 'Vito Meltor');
      final service = MusicImportService(
        catalog: FakeCatalog(onSearch: (_) => [wrong]),
      );
      addTearDown(service.close);
      final result = await service.importFromText(
        'MadKid & VILLIAN — Династия',
      );
      expect(result.tracks.single.artist, 'MadKid & VILLIAN');
      expect(result.tracks.single.title, 'Династия');
      expect(result.tracks.single.id, startsWith('txt_'));
    },
  );

  test('catalog metadata accepts artist order and stylized digits, not another collaboration', () {
    expect(
      StreamResolver.isCatalogMetadataMatch(
        dynasty,
        dynasty.copyWith(artist: 'VILLIAN, madk1d'),
      ),
      isTrue,
    );
    expect(
      StreamResolver.isCatalogMetadataMatch(
        dynasty,
        dynasty.copyWith(artist: 'MadKid & Someone Else'),
      ),
      isFalse,
    );
    expect(
      StreamResolver.isCatalogMetadataMatch(
        dynasty,
        dynasty.copyWith(title: 'распять', artist: 'greyrock, tewiq & madk1d'),
      ),
      isFalse,
    );
  });

  test(
    'more views choose the same recording but never a different artist',
    () async {
      final unpopular = dynasty.copyWith(
        id: 'quiet',
        source: TrackSource.youtubeMusic,
        playbackCount: 12,
      );
      final popular = unpopular.copyWith(id: 'popular', playbackCount: 1200000);
      final wrong = popular.copyWith(
        id: 'wrong',
        artist: 'Vito Meltor',
        playbackCount: 999999999,
      );
      final source = FakeMusicSource(
        TrackSource.youtubeMusic,
        onSearch: (_) => [wrong, unpopular, popular],
        onResolve: (_) => const ResolvedStream(
          'https://audio.example/full',
          source: TrackSource.youtubeMusic,
        ),
      );
      final resolver = StreamResolver(
        scExtractor: FakeSoundCloud(),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [source],
      );
      addTearDown(resolver.dispose);
      expect(await resolver.resolveStream(dynasty), isNotNull);
      expect(source.resolved.single.id, 'popular');
    },
  );

  test('search deduplication prefers more viewed matching upload', () async {
    final rare = dynasty.copyWith(
      id: 'rare',
      source: TrackSource.youtubeMusic,
      playbackCount: 10,
    );
    final common = rare.copyWith(id: 'common', playbackCount: 1000000);
    final wrong = common.copyWith(
      id: 'wrong',
      artist: 'Vito Meltor',
      playbackCount: 1000000000,
    );
    final source = FakeMusicSource(
      TrackSource.youtubeMusic,
      onSearch: (_) => [wrong, rare, common],
    );
    final resolver = StreamResolver(
      scExtractor: FakeSoundCloud(),
      spotifyCatalog: FakeCatalog(),
      additionalSources: [source],
    );
    addTearDown(resolver.dispose);
    final results = await resolver.search(
      query: 'MadKid VILLIAN Династия',
      sources: {TrackSource.youtubeMusic},
    );
    expect(results.first.id, 'common');
  });

  test(
    'playback rejects a different collaboration even with the lead artist',
    () {
      expect(
        StreamResolver.isPlayableMatch(
          dynasty,
          dynasty.copyWith(artist: 'MadKid & Someone Else'),
        ),
        isFalse,
      );
      expect(
        StreamResolver.isPlayableMatch(
          dynasty,
          dynasty.copyWith(artist: 'VILLIAN, madk1d'),
        ),
        isTrue,
      );
    },
  );

  test('featured artist credits in upload title remain matching evidence', () {
    expect(
      StreamResolver.isPlayableMatch(
        dynasty,
        dynasty.copyWith(artist: 'madk1d', title: 'Династия (feat. VILLIAN)'),
      ),
      isTrue,
    );
    expect(
      StreamResolver.isPlayableMatch(
        dynasty,
        dynasty.copyWith(
          artist: 'madk1d',
          title: 'Династия (feat. Someone Else)',
        ),
      ),
      isFalse,
    );
  });

  test(
    'catalog search includes full collaboration instead of only lead artist',
    () async {
      final fullQuery = '${dynasty.artist} ${dynasty.title}';
      final youtube = FakeMusicSource(
        TrackSource.youtubeMusic,
        onSearch: (query) => query == fullQuery
            ? [dynasty.copyWith(source: TrackSource.youtubeMusic)]
            : [],
        onResolve: (_) => const ResolvedStream(
          'https://audio.example/full',
          source: TrackSource.youtubeMusic,
        ),
      );
      final resolver = StreamResolver(
        scExtractor: FakeSoundCloud(),
        spotifyCatalog: FakeCatalog(),
        additionalSources: [youtube],
      );
      addTearDown(resolver.dispose);
      expect(await resolver.resolveStream(dynasty), isNotNull);
      expect(youtube.queries, contains(fullQuery));
    },
  );

  test(
    'artist name must match word boundaries, not substring of other name',
    () {
      expect(
        StreamResolver.isPlayableMatch(
          dynasty,
          dynasty.copyWith(artist: 'NotMadKid & VILLIAN'),
        ),
        isFalse,
      );
      final post = dynasty.copyWith(title: 'Sunflower', artist: 'Post Malone');
      expect(
        StreamResolver.isPlayableMatch(
          post,
          post.copyWith(artist: 'PostMalone'),
        ),
        isTrue,
      );
    },
  );

  test(
    'view count round-trips and older saved libraries default to unknown',
    () {
      final popular = dynasty.copyWith(playbackCount: 1234);
      expect(MediaTrack.fromJson(popular.toJson()).playbackCount, 1234);
      expect(MediaTrack.fromJson(dynasty.toJson()).playbackCount, 0);
      expect(
        MediaTrack.fromJson({...dynasty.toJson(), 'playbackCount': -5})
            .playbackCount,
        0,
      );
    },
  );
}
