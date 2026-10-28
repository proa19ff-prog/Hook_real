import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../extractor/models/media_track.dart';
import '../../extractor/stream_resolver.dart';
import '../../library/presentation/library_provider.dart';
import '../../lyrics/data/lrclib_client.dart';
import '../../theme_engine/data/theme_manager.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/audio_player_service.dart';

// Core Service Singletons
final streamResolverProvider = Provider<StreamResolver>((ref) {
  final resolver = StreamResolver();
  ref.onDispose(() => resolver.dispose());
  return resolver;
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

final lrclibClientProvider = Provider<LrclibClient>((ref) {
  return LrclibClient();
});

// Theme Management Provider
class ThemeNotifier extends StateNotifier<HookTheme> {
  final ThemeManager _manager;

  ThemeNotifier(this._manager) : super(_manager.currentTheme);

  Future<void> init() async {
    await _manager.initialize();
    state = _manager.currentTheme;
  }

  void setTheme(String themeId) {
    _manager.setActiveTheme(themeId);
    state = _manager.currentTheme;
  }

  void importJson(String jsonString) {
    final imported = _manager.importThemeFromJson(jsonString);
    if (imported != null) {
      state = imported;
    }
  }

  List<HookTheme> get availableThemes => _manager.availableThemes;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, HookTheme>((ref) {
  final manager = ThemeManager();
  final notifier = ThemeNotifier(manager);
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

// State Notifier for Current Track & Queue
class QueueNotifier extends StateNotifier<List<MediaTrack>> {
  final AudioPlayerService _service;

  QueueNotifier(this._service) : super(_service.queue);

  Future<void> playTrack(MediaTrack track) async {
    state = [track];
    await _service.setQueue([track]);
  }

  Future<void> playQueue(List<MediaTrack> tracks, {int startIndex = 0}) async {
    state = tracks;
    await _service.setQueue(tracks, startIndex: startIndex);
  }

  MediaTrack? get currentTrack => _service.currentTrack;
}

final queueProvider =
    StateNotifierProvider<QueueNotifier, List<MediaTrack>>((ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  return QueueNotifier(service);
});

// Current Playing Track Provider
final currentTrackProvider = Provider<MediaTrack?>((ref) {
  ref.watch(queueProvider);
  ref.watch(playerStateStreamProvider);
  final service = ref.watch(audioPlayerServiceProvider);
  return service.currentTrack;
});

// Synchronized Lyrics Provider (reactively fetches when current track changes)
final trackLyricsProvider = FutureProvider<LyricsResult?>((ref) async {
  final track = ref.watch(currentTrackProvider);
  if (track == null) return null;

  final lrclib = ref.watch(lrclibClientProvider);
  return await lrclib.fetchLyrics(
    trackName: track.title,
    artistName: track.artist,
    duration: track.duration,
  );
});
