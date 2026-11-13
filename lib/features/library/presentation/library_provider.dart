import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../extractor/models/media_track.dart';
import '../../artwork/artwork_service.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../../extractor/spotify/spotify_catalog_service.dart';
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

final playlistArtworkCatalogProvider = Provider<SpotifyCatalogService>((ref) {
  final service = SpotifyCatalogService();
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
class PlaylistsNotifier
    extends StateNotifier<Map<String, List<MediaTrack>>> {
  final LocalStorageService _storage;
  Future<void>? _artworkBackfill;
  final Set<String> _backfilledNames = <String>{};

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
    _backfilledNames.remove(name);
  }

  /// Imported playlists store no artwork at all, so their cards render as
  /// bare placeholders. Covers are resolved with [ArtworkService] first (a
  /// Deezer/iTunes album cover, then cached), then with the catalog and, when
  /// that is unreachable, [artworkFallback] — a candidate cover from there
  /// counts only when the duration lines up.
  ///
  /// A YouTube video frame counts as missing artwork: it is not a cover and
  /// looks wrong in a playlist grid, so it gets replaced like an empty url.
  Future<void> backfillArtwork({
    SpotifyCatalogService? catalog,
    Future<List<MediaTrack>> Function(String query)? artworkFallback,
    int perPlaylist = 12,
  }) async {
    if (_artworkBackfill != null) return _artworkBackfill;
    await ArtworkService.instance.hydrate();
    final targets = <MapEntry<String, List<int>>>[];
    for (final entry in state.entries) {
      if (_backfilledNames.contains(entry.key)) continue;
      final missing = <int>[];
      for (var i = 0; i < entry.value.length && missing.length < perPlaylist; i++) {
        final url = entry.value[i].artworkUrl.trim();
        if (!ArtworkService.isUsable(TrackArtwork.getHighResUrl(url))) {
          missing.add(i);
        }
      }
      if (missing.isNotEmpty) targets.add(MapEntry(entry.key, missing));
    }
    if (targets.isEmpty) {
      return;
    }
    final future = _runArtworkBackfill(targets, catalog, artworkFallback);
    _artworkBackfill = future;
    return future;
  }

  Future<void> _runArtworkBackfill(
    List<MapEntry<String, List<int>>> targets,
    SpotifyCatalogService? catalog,
    Future<List<MediaTrack>> Function(String query)? artworkFallback,
  ) async {
    try {
      for (final target in targets) {
        final name = target.key;
        final playlists = _storage.getPlaylists();
        final tracks = playlists[name];
        if (tracks == null) continue;
        var changed = false;
        var failures = 0;
        for (final index in target.value) {
          if (index >= tracks.length) continue;
          final track = tracks[index];
          final query = '${track.artist} ${track.title}'.trim();
          var artwork = '';
          // Album cover first: the resolver returns real square art and keeps
          // it in the shared cache, so the player and notification reuse it.
          try {
            final resolved = await ArtworkService.instance
                .resolve(
                  artist: track.artist,
                  title: track.title,
                  duration: track.duration,
                )
                .timeout(const Duration(seconds: 12));
            if (resolved != null) {
              artwork = resolved;
            }
          } catch (_) {
            failures++;
            // Fall through to the catalog.
          }
          if (artwork.isEmpty) {
            try {
              final hits = catalog == null
                  ? const <MediaTrack>[]
                  : await catalog
                        .searchTracks(query, limit: 1)
                        .timeout(const Duration(seconds: 8));
              if (hits.isNotEmpty &&
                  ArtworkService.isUsable(hits.first.artworkUrl)) {
                artwork = hits.first.artworkUrl;
              }
            } catch (_) {
              failures++;
              // Catalog unreachable or a stubborn query — try other sources.
            }
          }
          if (artwork.isEmpty && artworkFallback != null) {
            try {
              final candidates = await artworkFallback(query)
                  .timeout(const Duration(seconds: 9));
              final expected = track.duration.inMilliseconds;
              for (final candidate in candidates) {
                if (!ArtworkService.isUsable(candidate.artworkUrl)) continue;
                final closeEnough = expected <= 0 ||
                    (candidate.duration.inMilliseconds - expected).abs() <=
                        8000;
                if (closeEnough) {
                  artwork = candidate.artworkUrl;
                  break;
                }
              }
            } catch (_) {
              failures++;
              // Same story: the placeholder stays for now.
            }
          }
          if (artwork.isNotEmpty) {
            tracks[index] = track.copyWith(artworkUrl: artwork);
            changed = true;
          }
          // Be polite to the catalog when resolving a long list.
          await Future<void>.delayed(const Duration(milliseconds: 120));
        }
        // A playlist where every lookup failed is not "done": the next tab
        // visit gets another chance once the network cooperates.
        if (changed || failures == 0) _backfilledNames.add(name);
        if (changed) {
          await _storage.savePlaylist(name, tracks);
          if (mounted) state = _storage.getPlaylists();
        }
      }
    } finally {
      _artworkBackfill = null;
    }
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
