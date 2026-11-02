import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/search/data/lyrics_search_service.dart';

import 'support/fake_music_sources.dart';

Map<String, dynamic> song(int id, {String? lyrics}) => {
      'id': id,
      'name': 'A light beyond the bridge',
      'artists': [
        {'name': 'Test Artist'}
      ],
      'duration': 157560,
      'album': {'name': 'Test album'},
      if (lyrics != null) 'lyrics': {'txt': lyrics},
    };

void main() {
  test('lyrics mode uses body search, returns a snippet and catalog metadata',
      () async {
    final adapter = FakeHttpAdapter((request) {
      expect(request.queryParameters['type'], 1006);
      expect(request.queryParameters['s'], 'follow the light');
      return jsonResponse({
        'code': 200,
        'result': {
          'songs': [
            song(1,
                lyrics:
                    'Across the river\nFollow the light beyond the bridge\nA new day starts'),
            song(2,
                lyrics: 'Across the river\nFollow the light beyond the bridge'),
            song(3),
          ]
        }
      });
    });
    final service =
        LyricsSearchService(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(service.close);
    final hits = await service.search('follow the light');
    expect(hits, hasLength(1));
    expect(hits.single.snippet, contains('Follow the light'));
    expect(hits.single.track.source, TrackSource.spotify);
    expect(hits.single.track.id, 'lyrics_netease_1');
    expect(hits.single.track.duration, const Duration(seconds: 158));
    expect(hits.single.track.streamUrl, isNull);
  });

  test('metadata-only matches are not mislabeled as lyric-body matches',
      () async {
    final adapter = FakeHttpAdapter((_) => jsonResponse({
          'code': 200,
          'result': {
            'songs': [
              song(1),
              song(2, lyrics: 'A completely different sentence with no match'),
            ]
          }
        }));
    final service =
        LyricsSearchService(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(service.close);
    expect(await service.search('follow the light'), isEmpty);
  });

  test('provider errors remain distinguishable from no matching lyrics',
      () async {
    final service = LyricsSearchService(
        dio: Dio()
          ..httpClientAdapter =
              FakeHttpAdapter((_) => jsonResponse({'code': 503})));
    addTearDown(service.close);
    await expectLater(service.search('follow the light'), throwsStateError);
  });

  test(
      'snippets strip markup, match Cyrillic and preserve words near a long-line match',
      () {
    expect(
        LyricsSearchService.snippetFor(
            'Follow <b>the</b> light', 'follow the light'),
        'Follow the light');
    expect(
        LyricsSearchService.snippetFor('Пойдём туда, где свет', 'пойдем туда'),
        contains('Пойдём туда'));
    final long =
        '${List.filled(100, 'intro').join(' ')} follow the light ${List.filled(100, 'outro').join(' ')}';
    final snippet = LyricsSearchService.snippetFor(long, 'follow the light');
    expect(snippet, contains('follow the light'));
    expect(snippet.length, lessThanOrEqualTo(180));
    expect(LyricsSearchService.snippetFor('words', ''), isEmpty);
  });

  test('empty requests do not reach the network', () async {
    final adapter =
        FakeHttpAdapter((_) => throw StateError('Unexpected request'));
    final service =
        LyricsSearchService(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(service.close);
    expect(await service.search('  '), isEmpty);
    expect(adapter.requests, isEmpty);
  });
}
