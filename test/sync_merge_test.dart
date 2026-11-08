import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/account/sync_engine.dart';

Map<String, Object?> _env(int t, Object? v) => {'t': t, 'v': v};

Map<String, Object?> _track(
  String id,
  String source, {
  String title = 'T',
  String artist = 'A',
}) =>
    {
      'id': id,
      'title': title,
      'artist': artist,
      'durationMs': 200000,
      'artworkUrl': '',
      'source': source,
    };

/// `merge` returns `Map<String, Object?>`, so an envelope lookup needs a cast.
Object? _value(Map<String, Object?> snapshot, String key) =>
    (snapshot[key]! as Map)['v'];

void main() {
  group('track list unions', () {
    test('favorites union keeps the fresher side order and appends extras',
        () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.favorites:
              _env(200, [_track('a', 'spotify'), _track('b', 'spotify')]),
        },
        remote: {
          SyncKeys.favorites:
              _env(100, [_track('c', 'spotify'), _track('a', 'spotify')]),
        },
      );
      final list = (_value(merged, SyncKeys.favorites) as List)
          .map((e) => e['id'])
          .toList();
      expect(list, ['a', 'b', 'c']);
    });

    test('remote-first order applies when the remote side is fresher', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.favorites: _env(50, [_track('a', 'spotify')]),
        },
        remote: {
          SyncKeys.favorites: _env(300, [_track('b', 'spotify')]),
        },
      );
      final list = (_value(merged, SyncKeys.favorites) as List)
          .map((e) => e['id'])
          .toList();
      expect(list, ['b', 'a']);
    });

    test('history unions across devices too', () {
      final merged = SyncMerger.merge(
        local: {SyncKeys.history: _env(10, [_track('h1', 'youtubeMusic')])},
        remote: {SyncKeys.history: _env(20, [_track('h2', 'youtubeMusic')])},
      );
      final list = (_value(merged, SyncKeys.history) as List)
          .map((e) => e['id'])
          .toList();
      expect(list, ['h2', 'h1']);
    });
  });

  group('playlists', () {
    test('merges tracks within a shared playlist name', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.playlists: _env(300, {
            'Mix': [_track('a', 'spotify')],
          }),
        },
        remote: {
          SyncKeys.playlists: _env(100, {
            'Mix': [_track('b', 'spotify')],
            'OnlyRemote': [_track('c', 'spotify')],
          }),
        },
      );
      final playlists = _value(merged, SyncKeys.playlists) as Map;
      expect(playlists.keys, ['Mix', 'OnlyRemote']);
      expect(
        (playlists['Mix'] as List).map((e) => e['id']),
        ['a', 'b'],
      );
    });

    test('tombstoned playlist names disappear even from the fresher side',
        () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.playlists: _env(300, {
            'Mix': [_track('a', 'spotify')],
          }),
          SyncKeys.playlistsDel: _env(300, {'Gone': 300}),
        },
        remote: {
          SyncKeys.playlists: _env(200, {
            'Mix': [_track('a', 'spotify')],
            'Gone': [_track('b', 'spotify')],
          }),
        },
      );
      final playlists = _value(merged, SyncKeys.playlists) as Map;
      expect(playlists.containsKey('Gone'), isFalse);
      expect(playlists.keys, ['Mix']);
    });
  });

  group('favorites tombstones', () {
    test('a deleted favorite does not resurrect from the other side', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.favorites: _env(300, [_track('keep', 'spotify')]),
          SyncKeys.favoritesDel: _env(300, {'spotify:dead': 300}),
        },
        remote: {
          SyncKeys.favorites: _env(200, [
            _track('keep', 'spotify'),
            _track('dead', 'spotify'),
          ]),
        },
      );
      final list =
          (_value(merged, SyncKeys.favorites) as List).map((e) => e['id']);
      expect(list, ['keep']);
    });
  });

  group('play signals', () {
    test('counts and timestamps take the max per entry', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.playCounts: _env(10, {'madk1d|так похуй': 3}),
          SyncKeys.playTimestamps: _env(10, {'madk1d|так похуй': 100}),
        },
        remote: {
          SyncKeys.playCounts: _env(20, {'madk1d|так похуй': 7, 'new|song': 1}),
          SyncKeys.playTimestamps:
              _env(20, {'madk1d|так похуй': 50, 'new|song': 999}),
        },
      );
      expect(_value(merged, SyncKeys.playCounts), {
        'madk1d|так похуй': 7,
        'new|song': 1,
      });
      expect(_value(merged, SyncKeys.playTimestamps), {
        'madk1d|так похуй': 100,
        'new|song': 999,
      });
    });
  });

  group('search history', () {
    test('unions case-insensitively and keeps the fresher order', () {
      final merged = SyncMerger.merge(
        local: {SyncKeys.searchHistory: _env(50, ['Madk1d', 'odezza'])},
        remote: {SyncKeys.searchHistory: _env(40, ['madk1d', 'rammstein'])},
      );
      expect(_value(merged, SyncKeys.searchHistory), ['Madk1d', 'odezza', 'rammstein']);
    });

    test('cleared queries stay cleared via tombstones', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.searchHistory: _env(300, ['fresh']),
          SyncKeys.searchHistoryDel: _env(300, {'old': 300, 'older': 300}),
        },
        remote: {
          SyncKeys.searchHistory: _env(200, ['old', 'fresh', 'older']),
        },
      );
      expect(_value(merged, SyncKeys.searchHistory), ['fresh']);
    });
  });

  group('lyrics offsets', () {
    test('per-entry: disagreements go to the fresher side', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.lyricsOffsets: _env(300, {
            'youtubeMusic:abc': 2.5,
            'youtubeMusic:local': -1.0,
          }),
        },
        remote: {
          SyncKeys.lyricsOffsets: _env(100, {
            'youtubeMusic:abc': 7.0,
            'youtubeMusic:remote': 3.0,
          }),
        },
      );
      expect(_value(merged, SyncKeys.lyricsOffsets), {
        'youtubeMusic:abc': 2.5,
        'youtubeMusic:local': -1.0,
        'youtubeMusic:remote': 3.0,
      });
    });
  });

  group('scalars', () {
    test('theme and display mode are whole-value LWW', () {
      final merged = SyncMerger.merge(
        local: {
          SyncKeys.themeId: _env(10, 'minimal_oled'),
          SyncKeys.lyricsDisplayMode: _env(300, 'karaoke'),
          SyncKeys.lyricsAutoHide: _env(10, true),
        },
        remote: {
          SyncKeys.themeId: _env(500, 'neon_dusk'),
          SyncKeys.lyricsDisplayMode: _env(100, 'plain'),
          SyncKeys.customThemeJson: _env(500, '{"id":"x"}'),
        },
      );
      expect(_value(merged, SyncKeys.themeId), 'neon_dusk');
      expect(_value(merged, SyncKeys.lyricsDisplayMode), 'karaoke');
      expect(_value(merged, SyncKeys.lyricsAutoHide), true);
      expect(_value(merged, SyncKeys.customThemeJson), '{"id":"x"}');
    });
  });

  group('envelope corners', () {
    test('missing local keys adopt remote values', () {
      final merged = SyncMerger.merge(
        local: const {},
        remote: {
          SyncKeys.favorites: _env(500, [_track('cloud', 'spotify')]),
        },
      );
      expect(
        (_value(merged, SyncKeys.favorites) as List).single['id'],
        'cloud',
      );
    });

    test('empty remote keeps the local snapshot untouched', () {
      final local = {
        SyncKeys.favorites: _env(5, [_track('a', 'spotify')]),
      };
      final merged = SyncMerger.merge(local: local, remote: const {});
      expect(_value(merged, SyncKeys.favorites), local[SyncKeys.favorites]!['v']);
    });
  });
}
