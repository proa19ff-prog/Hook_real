import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/lyrics/domain/lyrics_display_mode.dart';
import 'package:hook/features/lyrics/presentation/lyrics_mode_selector.dart';
import 'package:hook/features/lyrics/presentation/lyrics_preferences_provider.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalStorageService storage;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
  });

  test(
    'lyrics presentation persists and safely handles an unknown mode',
    () async {
      final notifier = LyricsDisplayModeNotifier(storage);
      addTearDown(notifier.dispose);
      expect(notifier.state, LyricsDisplayMode.karaoke);
      await notifier.select(LyricsDisplayMode.focus);
      final restored = LyricsDisplayModeNotifier(storage);
      addTearDown(restored.dispose);
      expect(restored.state, LyricsDisplayMode.focus);
      expect(
        LyricsDisplayMode.fromName('unsupported'),
        LyricsDisplayMode.karaoke,
      );
    },
  );

  test(
    'offsets belong to a track/version, clamp and reset independently',
    () async {
      await storage.saveLyricsOffset('youtubeMusic:a:158000', 0.7);
      await storage.saveLyricsOffset('soundcloud:a:158000', -0.3);
      expect(storage.getLyricsOffset('youtubeMusic:a:158000'), 0.7);
      expect(storage.getLyricsOffset('soundcloud:a:158000'), -0.3);
      expect(storage.getLyricsOffset('youtubeMusic:a:180000'), 0);
      await storage.saveLyricsOffset('youtubeMusic:a:158000', 200);
      // The clamp covers long uploader intros, not just small nudges.
      expect(storage.getLyricsOffset('youtubeMusic:a:158000'), 45);
      await storage.saveLyricsOffset('youtubeMusic:a:158000', double.nan);
      expect(storage.getLyricsOffset('youtubeMusic:a:158000'), 45);
      await storage.saveLyricsOffset('youtubeMusic:a:158000', 0);
      expect(storage.getLyricsOffset('youtubeMusic:a:158000'), 0);
    },
  );

  test(
    'all bundled mode previews load as native Lottie compositions',
    () async {
      for (final mode in LyricsDisplayMode.values) {
        final composition = await AssetLottie(mode.assetPath).load();
        expect(composition.bounds.width, 144);
        expect(composition.bounds.height, 96);
        expect(composition.duration.inMilliseconds, closeTo(2000, 20));
        expect(composition.layers, isNotEmpty);
      }
    },
  );

  testWidgets(
    'mode selection works on narrow screens with reduced motion and large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final theme = HookTheme.fromJson({});
      await tester.pumpWidget(
        ProviderScope(
      overrides: [localStorageServiceProvider.overrideWithValue(storage)],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                disableAnimations: true,
                textScaler: TextScaler.linear(1.5),
              ),
              child: child!,
            ),
            home: Scaffold(
              body: Center(child: LyricsModeButton(theme: theme)),
            ),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('lyrics-mode-button')));
      await tester.pumpAndSettle();
      expect(find.text('Ваш ритм чтения'), findsOneWidget);
      final target = find.byKey(const ValueKey('lyrics-mode-focus'));
      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(storage.getLyricsDisplayMode(), 'focus');
      expect(find.text('Вид текста · Фокус'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
