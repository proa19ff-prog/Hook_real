import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/app.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/youtube_account/data/youtube_account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // The shader background and page transitions animate continuously, so tests
  // pump fixed durations instead of pumpAndSettle.
  Future<void> settleFrames(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<LocalStorageService> storageWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  Widget hookApp(LocalStorageService storage) => ProviderScope(
    overrides: [
      localStorageServiceProvider.overrideWithValue(storage),
      youtubeAvailabilityProvider.overrideWith((ref) async => true),
      youtubeAccountServiceProvider.overrideWithValue(
        const _StubAccountService(),
      ),
    ],
    child: const HookApp(),
  );

  testWidgets('first launch shows the language step and persists a choice', (
    WidgetTester tester,
  ) async {
    final storage = await storageWith({});
    await tester.pumpWidget(hookApp(storage));
    await settleFrames(tester);

    // Fresh install lands on onboarding, not the navigation shell.
    expect(
      find.byKey(const ValueKey('onboarding-language-grid')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('onboarding-language-en')));
    await settleFrames(tester);

    // The language choice applies immediately: navigation labels are English.
    await tester.tap(find.byKey(const ValueKey('onboarding-finish')));
    await settleFrames(tester);
    expect(find.text('Home'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-language-grid')),
      findsNothing,
    );

    // The mock SharedPreferences instance keeps values; read what a restart
    // would load.
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('hook_onboarding_done'), isTrue);
    expect(preferences.getString('hook_locale_code'), 'en');
  });

  testWidgets(
    'skipping onboarding keeps the chosen language and never returns', (
    WidgetTester tester,
  ) async {
    final storage = await storageWith({});
    await tester.pumpWidget(hookApp(storage));
    await settleFrames(tester);

    // Pick a language so the app locale is deterministic in tests, then skip.
    await tester.tap(find.byKey(const ValueKey('onboarding-language-en')));
    await settleFrames(tester);
    await tester.tap(find.byKey(const ValueKey('onboarding-skip')));
    await settleFrames(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-language-grid')),
      findsNothing,
    );
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool('hook_onboarding_done'), isTrue);
  });

  testWidgets('completed onboarding opens the main shell directly', (
    WidgetTester tester,
  ) async {
    final storage = await storageWith({
      'hook_onboarding_done': true,
      'hook_locale_code': 'en',
    });
    await tester.pumpWidget(hookApp(storage));
    await settleFrames(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-language-grid')),
      findsNothing,
    );
  });
}

class _StubAccountService implements YouTubeAccountService {
  const _StubAccountService();

  @override
  Future<YouTubeAccountStatus> status() async {
    return const YouTubeAccountStatus(supported: true);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
