import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/import/presentation/import_bottom_sheet.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/features/youtube_account/data/youtube_account_service.dart';
import 'package:hook/features/youtube_account/presentation/youtube_account_screen.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const video = MediaTrack(
  id: 'aBcDeFgHiJ1',
  title: 'Sample recording',
  artist: 'Channel',
  duration: Duration(seconds: 180),
  artworkUrl: '',
  source: TrackSource.youtubeMusic,
);
const playlist = YouTubePlaylist(
  id: 'PLtest',
  title: 'My YouTube playlist',
  itemCount: 2,
);
const account = YouTubeProfile(channelId: 'UCtest', name: 'Test channel');

class FakeAccount extends YouTubeAccountService {
  YouTubeProfile? connected;
  Future<YouTubeProfile> Function()? onConnect;
  Future<YouTubePage<MediaTrack>> Function(String?)? onTracks;
  int connectCalls = 0;
  int disconnectCalls = 0;
  int cancelCalls = 0;
  final requestedPages = <String?>[];
  @override
  Future<YouTubeAccountStatus> status() async => const YouTubeAccountStatus(
    supported: true,
    systemServicesAvailable: true,
    systemServicesVersion: '26',
    revancedGmsCoreVersion: '7.3.0',
    revancedMusicInstalled: true,
  );
  @override
  Future<YouTubeProfile?> profile() async => connected;
  @override
  Future<YouTubeProfile> connect() async {
    connectCalls++;
    final result = await (onConnect?.call() ?? Future.value(account));
    connected = result;
    return result;
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    connected = null;
  }

  @override
  Future<void> cancel() async {
    cancelCalls++;
  }

  @override
  Future<YouTubePage<YouTubePlaylist>> playlists({String? pageToken}) async =>
      const YouTubePage([playlist]);
  @override
  Future<YouTubePage<MediaTrack>> playlistTracks(
    String playlistId, {
    String? pageToken,
  }) async {
    requestedPages.add(pageToken);
    return onTracks?.call(pageToken) ?? const YouTubePage([video, video]);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalStorageService storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(YouTubeAccountService.channel, null);
  });

  test(
    'native account channel exposes display metadata, not access tokens',
    () async {
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(YouTubeAccountService.channel, (
            call,
          ) async {
            calls.add(call.method);
            if (call.method == 'status') {
              return {
                'supported': true,
                'systemServicesAvailable': true,
                'revancedGmsCoreVersion': '7.3.0',
              };
            }
            if (call.method == 'profile') return null;
            if (call.method == 'connect') {
              return {'channelId': 'UCtest', 'name': 'Test channel'};
            }
            return null;
          });
      final service = YouTubeAccountService();
      expect((await service.status()).revancedGmsCoreVersion, '7.3.0');
      expect(await service.profile(), isNull);
      expect(calls, [
        'status',
        'profile',
      ]); // No login merely by opening settings.
      expect((await service.connect()).name, 'Test channel');
      await service.disconnect();
      expect(calls, ['status', 'profile', 'connect', 'disconnect']);
    },
  );

  test('YouTube metadata keeps native video identity and duration', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(YouTubeAccountService.channel, (call) async {
          expect(call.method, 'playlistTracks');
          return {
            'items': [
              {
                'id': video.id,
                'title': 'Song',
                'artist': 'Artist',
                'durationMs': 180123,
              },
            ],
            'nextPageToken': 'next',
            'unavailableCount': 2,
          };
        });
    final page = await YouTubeAccountService().playlistTracks('PLtest');
    expect(page.items.single.source, TrackSource.youtubeMusic);
    expect(page.items.single.id, video.id);
    expect(page.items.single.duration.inMilliseconds, 180123);
    expect(page.unavailableCount, 2);
  });

  test('playlist pagination preserves order and repeated recordings', () async {
    final service = FakeAccount()
      ..onTracks = (token) async => token == null
          ? const YouTubePage(
              [video],
              nextPageToken: 'second',
              unavailableCount: 1,
            )
          : const YouTubePage([video]);
    final progress = <int>[];
    final result = await service.importPlaylist(
      playlist,
      isActive: () => true,
      onProgress: progress.add,
    );
    expect(result.tracks, [video, video]);
    expect(result.unavailableCount, 1);
    expect(progress, [1, 2]);
    expect(service.requestedPages, [null, 'second']);
  });

  test(
    'repeated page token fails rather than looping or silently truncating',
    () async {
      final service = FakeAccount()
        ..onTracks = (_) async =>
            const YouTubePage([video], nextPageToken: 'same');
      await expectLater(
        service.importPlaylist(
          playlist,
          isActive: () => true,
          onProgress: (_) {},
        ),
        throwsA(isA<PlatformException>()),
      );
      expect(service.requestedPages, hasLength(2));
    },
  );

  test(
    'cancelled import does not fetch another page or return partial results',
    () async {
      var active = true;
      final service = FakeAccount()
        ..onTracks = (_) async {
          active = false;
          return const YouTubePage([video], nextPageToken: 'next');
        };
      await expectLater(
        service.importPlaylist(
          playlist,
          isActive: () => active,
          onProgress: (_) {},
        ),
        throwsA(
          isA<PlatformException>().having((e) => e.code, 'code', 'cancelled'),
        ),
      );
      expect(service.requestedPages, hasLength(1));
    },
  );

  test('oversized playlist fails before accessing network', () async {
    final service = FakeAccount();
    await expectLater(
      service.importPlaylist(
        const YouTubePlaylist(id: 'big', title: 'Large', itemCount: 10001),
        isActive: () => true,
        onProgress: (_) {},
      ),
      throwsA(isA<PlatformException>()),
    );
    expect(service.requestedPages, isEmpty);
  });

  Future<void> mount(WidgetTester tester, FakeAccount service) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = HookTheme.fromJson({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          youtubeAccountServiceProvider.overrideWithValue(service),
          localStorageServiceProvider.overrideWithValue(storage),
        ],
        child: MaterialApp(
          theme: theme.toThemeData(),
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.5),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: YouTubeAccountScreen(theme: theme),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> click(WidgetTester tester, Finder finder) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets(
    'account screen detects separate GmsCore without automatic login',
    (tester) async {
      final service = FakeAccount();
      await mount(tester, service);
      expect(service.connectCalls, 0);
      await click(tester, find.text('Совместимость и конфиденциальность'));
      expect(find.text('ReVanced GmsCore 7.3.0'), findsOneWidget);
      await click(tester, find.text('Совместимость и конфиденциальность'));
      await click(tester, find.byKey(const ValueKey('youtube-connect')));
      expect(service.connectCalls, 1);
      expect(find.text('Test channel'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('My YouTube playlist'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('My YouTube playlist'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'configuration error explains OAuth instead of claiming connected',
    (tester) async {
      final service = FakeAccount()
        ..onConnect = () async =>
            throw PlatformException(code: 'configurationRequired');
      await mount(tester, service);
      await click(tester, find.byKey(const ValueKey('youtube-connect')));
      expect(find.text('Test channel'), findsNothing);
      expect(
        find.textContaining('Вход не настроен для этой сборки'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disconnect needs confirmation and leaves saved library intact', (
    tester,
  ) async {
    await storage.savePlaylist('Existing', [video]);
    final service = FakeAccount()..connected = account;
    await mount(tester, service);
    await click(tester, find.text('Отключить в Hook'));
    expect(find.byType(AlertDialog), findsOneWidget);
    await click(tester, find.widgetWithText(FilledButton, 'Отключить в Hook'));
    expect(service.disconnectCalls, 1);
    expect(find.text('Test channel'), findsNothing);
    expect(storage.getPlaylists()['Existing'], [video]);
  });

  testWidgets('import opens existing save preview without silently saving', (
    tester,
  ) async {
    final service = FakeAccount()..connected = account;
    await mount(tester, service);
    await click(tester, find.byKey(const ValueKey('youtube-import-PLtest')));
    expect(find.byType(ImportBottomSheet), findsOneWidget);
    expect(find.text('Импорт из аккаунта YouTube'), findsOneWidget);
    expect(storage.getPlaylists(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  for (final code in ['expired', 'permissionDenied', 'noChannel']) {
    testWidgets('$code clears profile without altering the library', (
      tester,
    ) async {
      await storage.savePlaylist('Existing', [video]);
      final service = FakeAccount()
        ..connected = account
        ..onTracks = (_) async => throw PlatformException(code: code);
      await mount(tester, service);
      await click(tester, find.byKey(const ValueKey('youtube-import-PLtest')));
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('youtube-connect')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Test channel'), findsNothing);
      expect(find.byKey(const ValueKey('youtube-connect')), findsOneWidget);
      expect(find.byType(ImportBottomSheet), findsNothing);
      expect(storage.getPlaylists()['Existing'], [video]);
      expect(service.connectCalls, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('unavailable tracks require confirmation before save preview', (
    tester,
  ) async {
    final service = FakeAccount()
      ..connected = account
      ..onTracks = (_) async => const YouTubePage([video], unavailableCount: 1);
    await mount(tester, service);
    await click(tester, find.byKey(const ValueKey('youtube-import-PLtest')));
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(ImportBottomSheet), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await click(tester, find.widgetWithText(TextButton, 'Отмена'));
    expect(find.byType(ImportBottomSheet), findsNothing);
    expect(storage.getPlaylists(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('late sign-in result is ignored after cancellation', (
    tester,
  ) async {
    final result = Completer<YouTubeProfile>();
    final service = FakeAccount()..onConnect = () => result.future;
    await mount(tester, service);
    await tester.ensureVisible(find.byKey(const ValueKey('youtube-connect')));
    await tester.tap(find.byKey(const ValueKey('youtube-connect')));
    await tester.pump();
    await tester.ensureVisible(find.text('Отмена'));
    await tester.tap(find.text('Отмена'));
    await tester.pump();
    result.complete(account);
    await tester.pumpAndSettle();
    expect(find.text('Test channel'), findsNothing);
    expect(service.cancelCalls, 1);
  });
}
