import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../extractor/models/media_track.dart';

// Providers for local storage & cache
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw StateError(
    'LocalStorageService is not configured. Override '
    'localStorageServiceProvider in main or a test ProviderScope.',
  );
});

final audioCacheManagerProvider = Provider<AudioCacheManager>((ref) {
  return AudioCacheManager();
});

// Favorites State Notifier
class FavoritesNotifier extends StateNotifier<List<MediaTrack>> {
  final LocalStorageService _storage;

  FavoritesNotifier(this._storage) : super(_storage.getFavorites());

  void refresh() {
    state = _storage.getFavorites();
  }

  Future<void> toggleFavorite(MediaTrack track) async {
    await _storage.toggleFavorite(track);
    state = _storage.getFavorites();
  }

  bool isFavorite(String trackId, {TrackSource? source}) {
    return state.any(
      (t) => t.id == trackId && (source == null || t.source == source),
    );
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, List<MediaTrack>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return FavoritesNotifier(storage);
});

// History State Notifier
class HistoryNotifier extends StateNotifier<List<MediaTrack>> {
  final LocalStorageService _storage;

  HistoryNotifier(this._storage) : super(_storage.getHistory());

  void refresh() {
    state = _storage.getHistory();
  }

  Future<void> addTrack(MediaTrack track) async {
    await _storage.addToHistory(track);
    state = _storage.getHistory();
  }

  Future<void> clear() async {
    await _storage.clearHistory();
    state = [];
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<MediaTrack>>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return HistoryNotifier(storage);
});

// Cache size future provider
final cacheSizeProvider = FutureProvider<int>((ref) async {
  final cacheManager = ref.watch(audioCacheManagerProvider);
  return await cacheManager.getTotalCacheSize();
});
