import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';

import '../../extractor/models/media_track.dart';
import '../../extractor/stream_resolver.dart';
import '../../library/presentation/library_provider.dart';
import '../../lyrics/data/lyrics_client.dart';
import '../../recommendations/recommendation_service.dart';
import '../../theme_engine/data/theme_manager.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/audio_player_service.dart';

// Core Service Singletons
final streamResolverProvider = Provider<StreamResolver>((ref) {
  final resolver = StreamResolver();
  ref.onDispose(() => resolver.dispose());
  return resolver;
});

final youtubeAvailabilityProvider = FutureProvider<bool>((ref) {
  return ref.watch(streamResolverProvider).checkYouTubeAvailability();
});

final audioPlayerServiceProvider = Provider<AudioPlayerService>((ref) {
  final resolver = ref.watch(streamResolverProvider);
  final storageService = ref.watch(localStorageServiceProvider);
  final cacheManager = ref.watch(audioCacheManagerProvider);
  final service = AudioPlayerService(
    resolver: resolver,
    storageService: storageService,
    cacheManager: cacheManager,
  );
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

final lyricsClientProvider = Provider<LyricsClient>((ref) {
  final client = LyricsClient();
  ref.onDispose(client.close);
  return client;
});

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  final resolver = ref.watch(streamResolverProvider);
  return RecommendationService(storage: storage, resolver: resolver);
});

/// A track from the listener's affinity profile for the home wave card when
/// there is no listening history yet — the "start the mix with nothing saved"
/// path. Null means even the starter seeds failed (offline first launch).
final personalMixSeedProvider = FutureProvider.autoDispose<MediaTrack?>((
  ref,
) async {
  final recommendations = await ref
      .watch(recommendationServiceProvider)
      .getPersonalizedRecommendations(limit: 3);
  return recommendations.firstOrNull;
});

// Theme Management Provider with Persistence
class ThemeNotifier extends StateNotifier<HookTheme> {
  final ThemeManager _manager;
  final Ref _ref;

  ThemeNotifier(this._manager, this._ref) : super(_manager.currentTheme);

  Future<void> init() async {
    try {
      final storage = _ref.read(localStorageServiceProvider);
      var savedThemeId = storage.getSavedThemeId();
      final savedCustomJson = storage.getSavedCustomThemeJson();
      await _manager.initialize(
        savedThemeId: savedThemeId,
        savedCustomJson: savedCustomJson,
      );
      // One-time move to OLED Monolith as the default. Later choices persist.
      if (!storage.oledDefaultApplied) {
        savedThemeId = ThemeManager.defaultThemeId;
        _manager.setActiveTheme(savedThemeId);
        await storage.saveThemeId(savedThemeId);
        await storage.markOledDefaultApplied();
      }
      state = _manager.currentTheme;
    } catch (_) {
      await _manager.initialize();
      state = _manager.currentTheme;
    }
  }

  void setTheme(String themeId) {
    _manager.setActiveTheme(themeId);
    state = _manager.currentTheme;
    try {
      final storage = _ref.read(localStorageServiceProvider);
      storage.saveThemeId(themeId);
    } catch (_) {}
  }

  void importJson(String jsonString) {
    final imported = _manager.importThemeFromJson(jsonString);
    if (imported != null) {
      state = imported;
      try {
        final storage = _ref.read(localStorageServiceProvider);
        storage.saveThemeId(imported.id);
        storage.saveCustomThemeJson(jsonString);
      } catch (_) {}
    }
  }

  List<HookTheme> get availableThemes => _manager.availableThemes;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, HookTheme>((ref) {
  final manager = ThemeManager();
  final notifier = ThemeNotifier(manager, ref);
  notifier.init();
  return notifier;
});

// Playback Streams
final playerStateStreamProvider = StreamProvider<PlayerState>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.playerStateStream;
});

final positionStreamProvider = StreamProvider<Duration>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.positionStream;
});

final durationStreamProvider = StreamProvider<Duration?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.durationStream;
});

final playbackErrorProvider = StreamProvider<AudioPlaybackError?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.errorStream;
});

final _playbackSourceStreamProvider = StreamProvider<TrackSource?>((ref) {
  return ref.watch(audioPlayerServiceProvider).playbackSourceStream;
});

/// The provider actually serving audio, which may differ from the catalog.
final playbackSourceProvider = Provider<TrackSource?>((ref) {
  ref.watch(_playbackSourceStreamProvider);
  return ref.watch(audioPlayerServiceProvider).playbackSource;
});

// State Notifier for Current Track & Queue
class QueueNotifier extends StateNotifier<List<MediaTrack>> {
  final AudioPlayerService _service;
  late final StreamSubscription<int> _queueSubscription;

  QueueNotifier(this._service) : super(_service.trackQueue) {
    // Radio may extend the queue asynchronously after the user presses play.
    // Mirror every service mutation so queue sheets and shared track rows stay
    // in sync instead of showing the initial one-track seed forever.
    _queueSubscription = _service.queueChanges.listen((_) {
      if (mounted) state = _service.trackQueue;
    });
  }

  @override
  void dispose() {
    _queueSubscription.cancel();
    super.dispose();
  }

  Future<void> playTrack(MediaTrack track) async {
    await _service.setQueue([track]);
    state = _service.trackQueue;
  }

  Future<void> playQueue(List<MediaTrack> tracks, {int startIndex = 0}) async {
    await _service.setQueue(tracks, startIndex: startIndex);
    state = _service.trackQueue;
  }

  Future<void> startWave(MediaTrack track) async {
    await _service.startWave(track);
    state = _service.trackQueue;
  }

  Future<void> playAt(int index) async {
    await _service.playAt(index);
    state = _service.trackQueue;
  }

  void addToQueue(MediaTrack track) {
    _service.addToQueue(track);
    state = _service.trackQueue;
  }

  void playNext(MediaTrack track) {
    _service.playNext(track);
    state = _service.trackQueue;
  }

  MediaTrack? get currentTrack => _service.currentTrack;
}

final queueProvider = StateNotifierProvider<QueueNotifier, List<MediaTrack>>((
  ref,
) {
  final service = ref.watch(audioPlayerServiceProvider);
  return QueueNotifier(service);
});

final queueChangesProvider = StreamProvider<int>((ref) {
  return ref.watch(audioPlayerServiceProvider).queueChanges;
});

final waveActiveProvider = Provider<bool>((ref) {
  ref.watch(queueChangesProvider);
  return ref.watch(audioPlayerServiceProvider).waveActive;
});

final playbackContextProvider = Provider<String?>((ref) {
  ref.watch(queueChangesProvider);
  return ref.watch(audioPlayerServiceProvider).playbackContext;
});

final _currentTrackStreamProvider = StreamProvider<MediaTrack?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return service.currentTrackStream;
});

// Current Playing Track Provider. Only rebuilds dependants when the track
// itself changes, not on every buffering/playing state event.
final currentTrackProvider = Provider<MediaTrack?>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return ref.watch(_currentTrackStreamProvider).valueOrNull ??
      service.currentTrack;
});

/// True while the selected track is being resolved or buffered.
final isTrackLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(playerStateStreamProvider).valueOrNull;
  final track = ref.watch(currentTrackProvider);
  if (track == null) return false;
  final error = ref.watch(playbackErrorProvider).valueOrNull;
  if (error != null && error.track == track) return false;
  final processing = state?.processingState;
  return processing == null ||
      processing == ProcessingState.idle ||
      processing == ProcessingState.loading ||
      processing == ProcessingState.buffering;
});

final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(playerStateStreamProvider).valueOrNull?.playing ?? false;
});

// Synchronized Lyrics Provider (reactively fetches when current track changes)
final trackLyricsProvider = FutureProvider<LyricsResult?>((ref) async {
  final track = ref.watch(currentTrackProvider);
  if (track == null) return null;

  final lyrics = ref.watch(lyricsClientProvider);
  return await lyrics.fetchLyrics(
    trackName: track.title,
    artistName: track.artist,
    duration: track.duration,
    trackKey: '${track.source.name}:${track.id}',
  );
});
