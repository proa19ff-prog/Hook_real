import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/search/presentation/search_history_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late LocalStorageService storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
  });

  test('queries are deduped, newest first and capped', () async {
    for (var i = 0; i < 20; i++) {
      await storage.addSearchQuery('query $i');
    }
    // The oldest entries fall off the 15-item cap.
    expect(storage.getSearchHistory().length, 15);
    expect(storage.getSearchHistory().first, 'query 19');

    // A repeat moves the query back to the top instead of duplicating it.
    await storage.addSearchQuery('query 15');
    final history = storage.getSearchHistory();
    expect(history.first, 'query 15');
    expect(history.where((q) => q == 'query 15'), hasLength(1));
  });

  test('short queries are not recorded', () async {
    await storage.addSearchQuery('a');
    expect(storage.getSearchHistory(), isEmpty);
  });

  test('single query can be removed and history cleared', () async {
    await storage.addSearchQuery('molchat doma');
    await storage.addSearchQuery('ravyn lenae');

    await storage.removeSearchQuery('Molchat Doma');
    expect(storage.getSearchHistory(), ['ravyn lenae']);

    await storage.clearSearchHistory();
    expect(storage.getSearchHistory(), isEmpty);
  });

  test('notifier mirrors storage mutations', () async {
    final notifier = SearchHistoryNotifier(storage);
    await notifier.record('sunflower');
    expect(notifier.state, ['sunflower']);

    await notifier.record('sudno');
    await notifier.remove('sunflower');
    expect(notifier.state, ['sudno']);

    await notifier.clear();
    expect(notifier.state, isEmpty);
  });
}
