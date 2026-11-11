import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/core/ui/hook_haptics.dart';
import 'package:hook/features/account/account_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/settings/presentation/settings_screen.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService storage;
  late HookTheme theme;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    theme = HookTheme.fromJson({});
  });

  tearDown(() => AccountService.configuredForTesting = true);

  Future<void> pumpSettings(
    WidgetTester tester, {
    double width = 320,
    double scale = 1,
  }) async {
    // The account section talks to Supabase, which no widget test initialises.
    AccountService.configuredForTesting = false;
    tester.view.physicalSize = Size(width, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [localStorageServiceProvider.overrideWithValue(storage)],
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme.toThemeData(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the shortcut reference fits a narrow screen at large text', (
    tester,
  ) async {
    await pumpSettings(tester, scale: 2);
    await tester.scrollUntilVisible(
      find.text('M'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Space'), findsOneWidget);
    expect(find.text('Ctrl + ↑  ↓'), findsOneWidget);
    expect(find.text('M'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the shortcut rows spell out the muted key combination', (
    tester,
  ) async {
    await pumpSettings(tester);
    await tester.scrollUntilVisible(
      find.text('M'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Горячие клавиши'), findsOneWidget);
    expect(find.text('Ctrl + ←  →'), findsOneWidget);
    expect(find.text('Ctrl + ↑  ↓'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('playback switches persist and reach the statics they drive', (
    tester,
  ) async {
    await pumpSettings(tester);

    final haptics = find.byKey(const ValueKey('haptics-setting'));
    await tester.scrollUntilVisible(
      haptics,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(HookHaptics.enabled, isTrue);
    await tester.tap(haptics);
    await tester.pumpAndSettle();
    expect(storage.getHapticsEnabled(), isFalse);
    expect(HookHaptics.enabled, isFalse);

    final prefetch = find.byKey(const ValueKey('background-prefetch-setting'));
    await tester.scrollUntilVisible(
      prefetch,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(AudioPlayerService.prefetchEnabled, isTrue);
    await tester.tap(prefetch);
    await tester.pumpAndSettle();
    expect(storage.getBackgroundPrefetch(), isFalse);
    expect(AudioPlayerService.prefetchEnabled, isFalse);

    final motion = find.byKey(const ValueKey('reduce-motion-setting'));
    await tester.scrollUntilVisible(
      motion,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(motion);
    await tester.pumpAndSettle();
    expect(storage.getReduceMotion(), isTrue);
    expect(tester.takeException(), isNull);

    // Leave the statics as the rest of the suite expects them.
    HookHaptics.enabled = true;
    AudioPlayerService.prefetchEnabled = true;
  });

  testWidgets('the cookie row starts unknown and survives a failed check', (
    tester,
  ) async {
    await pumpSettings(tester);

    final row = find.byKey(const ValueKey('cookie-status-subtitle'));
    await tester.scrollUntilVisible(
      row,
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    // Nothing has been asked of the server yet, so the row must not claim
    // either verdict.
    expect(
      tester.widget<Text>(row).data,
      AppLocalizations.of(
        tester.element(row),
      ).cookieStatusUnknown,
    );

    await tester.tap(find.byKey(const ValueKey('cookie-status-check')));
    await tester.pumpAndSettle();
    // Widget tests answer every request with 400, so the check reports nothing
    // rather than pretending the jar is fine.
    expect(
      tester.widget<Text>(row).data,
      AppLocalizations.of(tester.element(row)).cookieStatusUnknown,
    );
    expect(tester.takeException(), isNull);
  });
}
