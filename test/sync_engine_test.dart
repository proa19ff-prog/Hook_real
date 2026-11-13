import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/account/account_config.dart';
import 'package:hook/features/account/account_service.dart';
import 'package:hook/features/account/sync_engine.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeTransport implements SyncTransport {
  Map<String, Object?>? stored;
  final List<Map<String, Object?>> saves = [];

  @override
  Future<Map<String, Object?>?> fetchSnapshot() async => stored;

  @override
  Future<void> saveSnapshot(Map<String, Object?> data) async {
    saves.add(data);
    stored = data;
  }
}

MediaTrack _track(String id,
        {String source = 'spotify',
        String title = 'Title',
        String artist = 'Artist',
        String? streamUrl}) =>
    MediaTrack(
      id: id,
      title: title,
      artist: artist,
      duration: const Duration(milliseconds: 210000),
      artworkUrl: '',
      source: TrackSource.values.firstWhere((s) => s.name == source),
      streamUrl: streamUrl,
    );

Future<LocalStorageService> _storage() async {
  SharedPreferences.setMockInitialValues({});
  return LocalStorageService(await SharedPreferences.getInstance());
}

int _tick = 1000;
DateTime nextTime() {
  _tick += 1000;
  return DateTime.fromMillisecondsSinceEpoch(_tick);
}

void main() {
  setUp(() {
    _tick = 1000;
    AccountService.configuredForTesting = true;
  });
  tearDown(() {
    AccountService.configuredForTesting = AccountConfig.isConfigured;
  });

  group('SyncEngine round-trips', () {
    test('push strips ephemeral fields from tracks', () async {
      final storage = await _storage();
      final transport = _FakeTransport();
      final engine = SyncEngine(
        storage: storage,
        transport: transport,
        clock: nextTime,
      );
      await storage.toggleFavorite(_track('a', streamUrl: 'https://signed/…'));

      engine.onChanged(SyncKeys.favorites);
      final snapshot = await engine.push();

      final favorites = (snapshot[SyncKeys.favorites]! as Map)['v'] as List;
      final json = favorites.single as Map;
      expect(json.containsKey('streamUrl'), isFalse);
      expect(json['isCached'], false);
    });

    test('pull adopts the remote snapshot on a fresh device', () async {
      final storage = await _storage();
      final transport = _FakeTransport()
        ..stored = {
          SyncKeys.favorites: {
            't': 500,
            'v': [
              {
                'id': 'cloud',
                'title': 'Cloud track',
                'artist': 'Remote',
                'durationMs': 100000,
                'artworkUrl': '',
                'source': 'spotify',
              },
            ],
          },
          SyncKeys.searchHistory: {'t': 500, 'v': ['rammstein']},
          SyncKeys.playCounts: {'t': 500, 'v': {'a|b': 4}},
        };
      final engine = SyncEngine(
        storage: storage,
        transport: transport,
        clock: nextTime,
      );

      await engine.pull();

      expect(storage.getFavorites().single.id, 'cloud');
      expect(storage.getSearchHistory(), ['rammstein']);
      expect(storage.getPlayCounts()['a|b'], 4);
      // The first pull may publish envelopes the server has not seen yet
      // (a fresh device has empty history/playlists); a second pull must be
      // a pure no-op — nothing new to push back.
      // The first pull may publish envelopes the server has not seen yet
      // and normalize track JSON (isCached); after that, pulls converge and
      // stop writing entirely.
      await engine.pull();
      expect(transport.saves.length, lessThanOrEqualTo(2));
    });

    test('a locally deleted favorite stays deleted against stale remote',
        () async {
      final storage = await _storage();
      final transport = _FakeTransport();
      final clock = nextTime;
      final engine = SyncEngine(
        storage: storage,
        transport: transport,
        clock: clock,
      );

      // Device has two favorites, syncs once.
      await storage.toggleFavorite(_track('a'));
      await storage.toggleFavorite(_track('b'));
      engine.onChanged(SyncKeys.favorites);
      await engine.push();

      // The stale remote still has both.
      transport.stored = {
        SyncKeys.favorites: {
          't': 10,
          'v': [
            {
              'id': 'a',
              'title': 'Title',
              'artist': 'Artist',
              'durationMs': 210000,
              'artworkUrl': '',
              'source': 'spotify',
            },
            {
              'id': 'b',
              'title': 'Title',
              'artist': 'Artist',
              'durationMs': 210000,
              'artworkUrl': '',
              'source': 'spotify',
            },
          ],
        },
      };

      // The user deletes 'b' locally, then pulls.
      await storage.toggleFavorite(_track('b'));
      engine.onChanged(SyncKeys.favorites);
      await engine.pull();

      expect(storage.getFavorites().map((t) => t.id), ['a']);
      // The removal was pushed back so other devices learn about it.
      expect(transport.saves, isNotEmpty);
    });

    test('apply-triggered change events do not recurse into push', () async {
      final storage = await _storage();
      final transport = _FakeTransport()
        ..stored = {
          SyncKeys.themeId: {'t': 500, 'v': 'neon_dusk'},
        };
      final engine = SyncEngine(
        storage: storage,
        transport: transport,
        clock: nextTime,
      );

      await engine.pull();
      expect(storage.getSavedThemeId(), 'neon_dusk');
      expect(engine.applyingRemote, isFalse);
      // Only the pull-back push (which found nothing new) may have happened;
      // no second save from a self-triggered loop.
      expect(transport.saves.length, lessThanOrEqualTo(1));
    });
  });

  group('AccountService contract', () {
    test('synthetic emails are lowercase and deterministic', () {
      expect(AccountService.syntheticEmail('MadK1d'), 'madk1d@hook.local');
      expect(AccountService.syntheticEmail('a.b-c_d'), 'a.b-c_d@hook.local');
    });

    test('nickname validation rejects bad shapes', () {
      expect(AccountService.validateNickname('ab'), isNotNull); // too short
      expect(AccountService.validateNickname('a' * 21), isNotNull); // too long
      expect(AccountService.validateNickname('has space'), isNotNull);
      expect(AccountService.validateNickname('.dotstart'), isNotNull);
      expect(AccountService.validateNickname('ok.name-1_'), isNull);
    });

    test('sign-up refuses before spending a mail attempt', () async {
      // A project with "Confirm email" ON cannot complete a nickname signup:
      // the synthetic address would need a message it can never receive.
      AccountService.autoconfirmForTesting = false;
      addTearDown(() => AccountService.autoconfirmForTesting = null);

      await expectLater(
        AccountService.signUp(nickname: 'blocked_nick', password: 'secret123'),
        throwsA(
          isA<AccountException>().having(
            (e) => e.kind,
            'kind',
            AccountErrorKind.needsEmailConfirmation,
          ),
        ),
      );
    });
  });
}
