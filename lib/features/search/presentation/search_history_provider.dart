import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../library/presentation/library_provider.dart';

/// Recent search queries, newest first. Backed by [LocalStorageService] so
/// the list survives restarts; the discovery state of the search screen
/// renders it as one-tap chips.
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier(this._storage) : super(_storage.getSearchHistory());

  final LocalStorageService _storage;

  Future<void> record(String query) async {
    await _storage.addSearchQuery(query);
    if (mounted) state = _storage.getSearchHistory();
  }

  Future<void> remove(String query) async {
    await _storage.removeSearchQuery(query);
    if (mounted) state = _storage.getSearchHistory();
  }

  Future<void> clear() async {
    await _storage.clearSearchHistory();
    if (mounted) state = const [];
  }
}

final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) => SearchHistoryNotifier(ref.watch(localStorageServiceProvider)),
);
