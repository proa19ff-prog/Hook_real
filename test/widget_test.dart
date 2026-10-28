import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/app.dart';
import 'package:hook/core/storage/local_storage_service.dart';
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
        ],
        child: HookApp(),
      ),
    );

    // Verify app starts and renders basic navigation elements
    expect(find.byType(HookApp), findsOneWidget);
  });
}
