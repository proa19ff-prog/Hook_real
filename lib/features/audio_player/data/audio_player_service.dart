import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../extractor/models/media_track.dart';
import '../../extractor/stream_resolver.dart';

enum PlayerLoopMode { off, all, one }

class AudioPlaybackError {
  final MediaTrack track;
  final String message;
  final Object? cause;

  const AudioPlaybackError(
      {required this.track, required this.message, this.cause});
}

class AudioPlayerService {
  final AudioPlayer _player;
  final StreamResolver _resolver;
  final AudioCacheManager _cacheManager;
  final LocalStorageService? _storageService;

  MediaTrack? _currentTrack;
  final List<MediaTrack> _queue = [];
  final StreamController<AudioPlaybackError?> _errorController =
      StreamController<AudioPlaybackError?>.broadcast();
  final StreamController<MediaTrack?> _trackController =
      StreamController<MediaTrack?>.broadcast();

  /// Resolved stream URLs keyed by cache key. YouTube URLs stay valid for
  /// about six hours, so reusing them makes replays and "previous" instant.
  final Map<String, ({String url, DateTime resolvedAt})> _urlCache = {};
  final Map<String, Future<String?>> _pendingResolves = {};
  static const _urlTtl = Duration(hours: 2);
  StreamSubscription<void>? _noisySubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  int _currentIndex = -1;
  int _playRequestId = 0;
  Future<void>? _initialization;

  PlayerLoopMode _loopMode = PlayerLoopMode.off;
  bool _isShuffle = false;

  AudioPlayerService({
    AudioPlayer? player,
    StreamResolver? resolver,
    AudioCacheManager? cacheManager,
    LocalStorageService? storageService,
  })  : _player = player ?? AudioPlayer(),
        _resolver = resolver ?? StreamResolver(),
        _cacheManager = cacheManager ?? AudioCacheManager(),
        _storageService = storageService;

  AudioPlayer get rawPlayer => _player;
  MediaTrack? get currentTrack => _currentTrack;
  List<MediaTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  PlayerLoopMode get loopMode => _loopMode;
  bool get isShuffle => _isShuffle;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<AudioPlaybackError?> get errorStream => _errorController.stream;

  /// Emits whenever the selected track changes, before its stream is ready,
  /// so the UI can react to a tap immediately.
  Stream<MediaTrack?> get currentTrackStream => _trackController.stream;

  void _setCurrentTrack(MediaTrack? track) {
    _currentTrack = track;
    if (!_trackController.isClosed) _trackController.add(track);
  }

  String _cacheKey(MediaTrack track) => '${track.source.name}_${track.id}';

  /// Resolves a playable URL, reusing recent results and sharing in-flight
  /// requests so a prefetch and a tap never resolve the same track twice.
  Future<String?> _resolveUrl(MediaTrack track) {
    final key = _cacheKey(track);
    final cached = _urlCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.resolvedAt) < _urlTtl) {
      return Future.value(cached.url);
    }

    return _pendingResolves[key] ??= () async {
      try {
        final local = await _cacheManager.getLocalCachedUrl(key);
        if (local != null) return local;

        final url = await _resolver
            .resolveStreamUrl(track)
            .timeout(const Duration(seconds: 25));
        if (url != null && url.isNotEmpty) {
          _urlCache[key] = (url: url, resolvedAt: DateTime.now());
        }
        return url;
      } finally {
        _pendingResolves.remove(key);
      }
    }();
  }

  /// Resolves the next queue item in the background so skipping is instant.
  void _prefetchNext() {
    if (_isShuffle || _currentIndex + 1 >= _queue.length) return;
    _resolveUrl(_queue[_currentIndex + 1]).ignore();
  }

  /// Initializes audio session for background focus & headset unplug handling
  Future<void> initialize() async {
    if (_initialization != null) return _initialization!;
    _initialization = _initialize();
    return _initialization!;
  }

  Future<void> _initialize() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Auto-pause if headphones are unplugged
    _noisySubscription = session.becomingNoisyEventStream.listen((_) {
      pause();
    });

    // Auto-advance to next track when finished
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  /// Sets track queue and plays the track at [startIndex]
  Future<void> setQueue(List<MediaTrack> tracks, {int startIndex = 0}) async {
    _queue.clear();
    _queue.addAll(tracks);
    _currentIndex =
        tracks.isEmpty ? -1 : startIndex.clamp(0, tracks.length - 1);

    if (_queue.isNotEmpty) {
      await playTrack(_queue[_currentIndex]);
    } else {
      _setCurrentTrack(null);
      await stop();
    }
  }

  /// Adds a track to the end of current queue
  void addToQueue(MediaTrack track) {
    _queue.add(track);
  }

  /// Removes track at index from queue
  void removeFromQueue(int index) {
    if (index < 0 || index >= _queue.length) return;
    _queue.removeAt(index);
    if (index < _currentIndex) {
      _currentIndex--;
    } else if (index == _currentIndex && _queue.isNotEmpty) {
      _currentIndex = _currentIndex.clamp(0, _queue.length - 1);
      playTrack(_queue[_currentIndex]);
    } else if (_queue.isEmpty) {
      _currentIndex = -1;
      _setCurrentTrack(null);
      unawaited(stop());
    }
  }

  /// Reorders track position in the queue
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _queue.length) return;
    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }
    targetIndex = targetIndex.clamp(0, _queue.length - 1);
    final item = _queue.removeAt(oldIndex);
    _queue.insert(targetIndex, item);

    if (oldIndex == _currentIndex) {
      _currentIndex = targetIndex;
    } else if (oldIndex < _currentIndex && targetIndex >= _currentIndex) {
      _currentIndex--;
    } else if (oldIndex > _currentIndex && targetIndex <= _currentIndex) {
      _currentIndex++;
    }
  }

  /// Plays a specific track, checking local cache first, then resolving stream URL
  Future<void> playTrack(MediaTrack track) async {
    final requestId = ++_playRequestId;
    if (!_errorController.isClosed) _errorController.add(null);

    // Show the tapped track right away; the stream resolves in the background.
    _setCurrentTrack(track);

    try {
      // The provider starts initialization eagerly, but awaiting it here also
      // makes direct service usage safe and prevents a race with AudioSession.
      await initialize();

      // Stop the previous track so it does not keep playing while the new
      // one is resolving.
      if (_player.playing) unawaited(_player.pause());

      final playUrl = await _resolveUrl(track);

      if (playUrl == null || playUrl.isEmpty) {
        throw Exception(
            'Unable to resolve audio stream for track: ${track.title}');
      }

      if (requestId != _playRequestId) return;

      // Set AudioSource with MediaItem for Android lockscreen and notifications
      final mediaItem = MediaItem(
        id: track.id,
        album: track.album ?? track.artist,
        title: track.title,
        artist: track.artist,
        artUri:
            track.artworkUrl.isNotEmpty ? Uri.tryParse(track.artworkUrl) : null,
        duration: track.duration,
      );
      final audioSource = playUrl.startsWith('file:')
          ? AudioSource.file(Uri.parse(playUrl).toFilePath(), tag: mediaItem)
          : AudioSource.uri(
              Uri.parse(playUrl),
              tag: mediaItem,
            );

      await _player
          .setAudioSource(audioSource)
          .timeout(const Duration(seconds: 20));
      if (requestId != _playRequestId) return;

      // just_audio's play() future completes only when playback pauses or
      // ends, so it must not be awaited with a timeout: that used to report
      // "playback failed" for tracks that were actually playing.
      unawaited(_player.play());
      unawaited(_storageService?.addToHistory(track));
      _prefetchNext();
    } catch (e) {
      // A cached URL may have expired; drop it so a retry resolves afresh.
      _urlCache.remove(_cacheKey(track));
      if (requestId == _playRequestId && !_errorController.isClosed) {
        _errorController.add(AudioPlaybackError(
          track: track,
          message: 'Не удалось воспроизвести трек',
          cause: e,
        ));
      }
    }
  }

  Future<File?> downloadTrack(
    MediaTrack track, {
    void Function(double progress)? onProgress,
  }) async {
    final streamUrl = await _resolveUrl(track);
    if (streamUrl == null || streamUrl.isEmpty) return null;
    if (streamUrl.startsWith('file:')) return File(Uri.parse(streamUrl).toFilePath());
    return _cacheManager.downloadTrack(
      track,
      streamUrl,
      cacheKey: '${track.source.name}_${track.id}',
      onProgress: onProgress,
    );
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> stop() async => await _player.stop();
  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> setSpeed(double speed) async =>
      await _player.setSpeed(speed.clamp(0.25, 2.5));
  Future<void> setPitch(double pitch) async =>
      await _player.setPitch(pitch.clamp(0.5, 2.0));
  Future<void> setVolume(double volume) async =>
      await _player.setVolume(volume.clamp(0.0, 1.0));

  void toggleLoopMode() {
    switch (_loopMode) {
      case PlayerLoopMode.off:
        _loopMode = PlayerLoopMode.all;
        break;
      case PlayerLoopMode.all:
        _loopMode = PlayerLoopMode.one;
        break;
      case PlayerLoopMode.one:
        _loopMode = PlayerLoopMode.off;
        break;
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_isShuffle && _queue.length > 1) {
      final candidates = List<int>.generate(_queue.length, (index) => index)
        ..remove(_currentIndex);
      candidates.shuffle();
      _currentIndex = candidates.first;
      await playTrack(_queue[_currentIndex]);
    } else if (_currentIndex + 1 < _queue.length) {
      _currentIndex++;
      await playTrack(_queue[_currentIndex]);
    } else if (_loopMode == PlayerLoopMode.all) {
      _currentIndex = 0;
      await playTrack(_queue[_currentIndex]);
    }
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    if (_player.position.inSeconds > 3) {
      // If played more than 3s, restart current track
      await seek(Duration.zero);
      return;
    }

    if (_currentIndex - 1 >= 0) {
      _currentIndex--;
      await playTrack(_queue[_currentIndex]);
    } else if (_loopMode == PlayerLoopMode.all) {
      _currentIndex = _queue.length - 1;
      await playTrack(_queue[_currentIndex]);
    }
  }

  void _onTrackCompleted() {
    if (_loopMode == PlayerLoopMode.one) {
      seek(Duration.zero);
      play();
    } else {
      next();
    }
  }

  Future<void> dispose() async {
    _playRequestId++;
    await _noisySubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _errorController.close();
    await _trackController.close();
    await _player.dispose();
    _resolver.dispose();
  }
}
