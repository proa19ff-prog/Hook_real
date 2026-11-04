import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/app.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Hook App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final storage = LocalStorageService(preferences);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          youtubeAvailabilityProvider.overrideWith((ref) async => true),
        ],
        child: HookApp(),
      ),
    );

    // Verify app starts and renders basic navigation elements
    expect(find.byType(HookApp), findsOneWidget);
  });

  testWidgets('saved English locale is applied to navigation', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hook_locale_code': 'en'});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          youtubeAvailabilityProvider.overrideWith((ref) async => true),
        ],
        child: const HookApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });

  testWidgets('unavailable YouTube shows a dismissible network warning', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'hook_locale_code': 'ru'});
    final storage = LocalStorageService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          youtubeAvailabilityProvider.overrideWith((ref) async => false),
        ],
        child: const HookApp(),
      ),
    );
    await tester.pump();

    expect(find.text('YouTube сейчас недоступен'), findsOneWidget);
    await tester.tap(find.byTooltip('Закрыть'));
    await tester.pump();
    expect(find.text('YouTube сейчас недоступен'), findsNothing);
  });
}
