import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../extractor/models/media_track.dart';
import '../../import/music_import_service.dart';

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

final musicImportServiceProvider = Provider<MusicImportService>((ref) {
  final service = MusicImportService();
  ref.onDispose(() => service.close());
  return service;
});

// Favorites State Notifier
class FavoritesNotifier extends StateNotifier<List<MediaTrack>> {
  final LocalStorageService _storage;
  late final StreamSubscription<void> _favoritesSubscription;

  FavoritesNotifier(this._storage) : super(_storage.getFavorites()) {
    _favoritesSubscription = _storage.favoritesChanges.listen((_) {
      if (mounted) state = _storage.getFavorites();
    });
  }

  void refresh() {
    state = _storage.getFavorites();
  }

  Future<void> toggleFavorite(MediaTrack track) async {
    await _storage.toggleFavorite(track);
  }

  bool isFavorite(String trackId, {TrackSource? source}) {
    return state.any(
      (t) => t.id == trackId && (source == null || t.source == source),
    );
  }

  @override
  void dispose() {
    _favoritesSubscription.cancel();
    super.dispose();
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

// Playlists State Notifier
class PlaylistsNotifier extends StateNotifier<Map<String, List<MediaTrack>>> {
  final LocalStorageService _storage;

  PlaylistsNotifier(this._storage) : super(_storage.getPlaylists());

  void refresh() {
    state = _storage.getPlaylists();
  }

  Future<void> savePlaylist(String name, List<MediaTrack> tracks) async {
    await _storage.savePlaylist(name, tracks);
    state = _storage.getPlaylists();
  }

  Future<void> deletePlaylist(String name) async {
    await _storage.deletePlaylist(name);
    state = _storage.getPlaylists();
  }
}

final playlistsProvider =
    StateNotifierProvider<PlaylistsNotifier, Map<String, List<MediaTrack>>>(
        (ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PlaylistsNotifier(storage);
});

// Cache size future provider
final cacheSizeProvider = FutureProvider<int>((ref) async {
  final cacheManager = ref.watch(audioCacheManagerProvider);
  return await cacheManager.getTotalCacheSize();
});
