import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../extractor/models/media_track.dart';
import '../../extractor/models/resolved_stream.dart';
import '../../extractor/stream_resolver.dart';
import '../../recommendations/track_wave_service.dart';

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
  late final TrackWaveService _waveService;

  MediaTrack? _currentTrack;
  final List<MediaTrack> _queue = [];
  final StreamController<AudioPlaybackError?> _errorController =
      StreamController<AudioPlaybackError?>.broadcast();
  final StreamController<MediaTrack?> _trackController =
      StreamController<MediaTrack?>.broadcast();

  /// Resolved stream URLs keyed by cache key, so replays and "previous" are
  /// instant. SoundCloud signs URLs for about two hours; the TTL stays well
  /// under that so a cached URL never reaches the player already expired.
  final Map<String,
          ({String url, Map<String, String> headers, DateTime resolvedAt})>
      _urlCache = {};
  final Map<String, Future<ResolvedStream?>> _pendingStreams = {};
  static const _urlTtl = Duration(minutes: 60);

  /// ExoPlayer waits for 2.5 s of audio before starting by default. Half a
  /// second is enough for SoundCloud's CDN and starts playback sooner.
  static const _loadConfiguration = AudioLoadConfiguration(
    androidLoadControl: AndroidLoadControl(
      minBufferDuration: Duration(seconds: 15),
      maxBufferDuration: Duration(seconds: 50),
      bufferForPlaybackDuration: Duration(milliseconds: 500),
      bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
    ),
  );
  StreamSubscription<void>? _noisySubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  int _currentIndex = -1;
  int _playRequestId = 0;
  Future<void>? _initialization;

  PlayerLoopMode _loopMode = PlayerLoopMode.off;
  bool _isShuffle = false;
  bool _waveActive = false;
  MediaTrack? _waveSeed;
  String? _playbackContext;
  int _waveGeneration = 0;
  Future<void>? _waveExtension;
  final StreamController<int> _queueController =
      StreamController<int>.broadcast();
  int _queueVersion = 0;

  AudioPlayerService({
    AudioPlayer? player,
    StreamResolver? resolver,
    AudioCacheManager? cacheManager,
    LocalStorageService? storageService,
  })  : _player =
            player ?? AudioPlayer(audioLoadConfiguration: _loadConfiguration),
        _resolver = resolver ?? StreamResolver(),
        _cacheManager = cacheManager ?? AudioCacheManager(),
        _storageService = storageService {
    _waveService = TrackWaveService(_resolver);
  }

  AudioPlayer get rawPlayer => _player;
  MediaTrack? get currentTrack => _currentTrack;
  List<MediaTrack> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  PlayerLoopMode get loopMode => _loopMode;
  bool get isShuffle => _isShuffle;
  bool get waveActive => _waveActive;
  String? get playbackContext => _playbackContext;
  Stream<int> get queueChanges => _queueController.stream;

  void _notifyQueue() {
    _queueVersion++;
    if (!_queueController.isClosed) _queueController.add(_queueVersion);
  }

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
  Future<ResolvedStream?> _resolveStream(MediaTrack track) {
    final key = _cacheKey(track);
    final cached = _urlCache[key];
    if (cached != null &&
        DateTime.now().difference(cached.resolvedAt) < _urlTtl) {
      return Future.value(
        ResolvedStream(cached.url, headers: cached.headers),
      );
    }

    return _pendingStreams[key] ??= () async {
      try {
        final local = await _cacheManager.getLocalCachedUrl(key);
        if (local != null) return ResolvedStream(local);

        final resolved = await _resolver
            .resolveStream(track)
            .timeout(const Duration(seconds: 25));
        if (resolved != null && !resolved.isEmpty) {
          _urlCache[key] = (
            url: resolved.url,
            headers: resolved.headers,
            resolvedAt: DateTime.now(),
          );
          return resolved;
        }
        return null;
      } finally {
        _pendingStreams.remove(key);
      }
    }();
  }

  /// URL-only helper kept for callers that do not need request headers.
  Future<String?> _resolveUrl(MediaTrack track) async =>
      (await _resolveStream(track))?.url;

  /// Resolves the next queue item in the background so skipping is instant.
  void _prefetchNext() {
    if (_isShuffle || _currentIndex + 1 >= _queue.length) return;
    _resolveUrl(_queue[_currentIndex + 1]).ignore();
  }

  /// Resolves streams ahead of a tap (e.g. the top search results), so the
  /// tap only has to buffer audio. Failures are ignored; a tap resolves again.
  void prefetch(Iterable<MediaTrack> tracks) {
    for (final track in tracks) {
      if (track.source == TrackSource.local) continue;
      _resolveUrl(track).catchError((_) => null).ignore();
    }
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
    _waveActive = false;
    _waveSeed = null;
    _playbackContext = null;
    _waveGeneration++;
    _queue.clear();
    _queue.addAll(tracks);
    _currentIndex =
        tracks.isEmpty ? -1 : startIndex.clamp(0, tracks.length - 1);
    _notifyQueue();

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
    _notifyQueue();
  }

  void playNext(MediaTrack track) {
    final index = _currentIndex < 0 ? _queue.length : _currentIndex + 1;
    _queue.insert(index.clamp(0, _queue.length), track);
    _notifyQueue();
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
    _notifyQueue();
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
    _notifyQueue();
  }

  /// Plays a specific track, checking local cache first, then resolving stream URL.
  /// On failure it retries with a freshly-resolved URL (signed SoundCloud URLs
  /// expire → CDN answers 403) and finally falls back to re-matching the song
  /// via a SoundCloud search before reporting an error.
  Future<void> playTrack(MediaTrack track) async {
    final requestId = ++_playRequestId;
    if (!_errorController.isClosed) _errorController.add(null);

    // Show the tapped track right away; the stream resolves in the background.
    _setCurrentTrack(track);

    MediaItem buildMediaItem() => MediaItem(
          id: track.id,
          album: track.album ?? track.artist,
          title: track.title,
          artist: track.artist,
          artUri: track.artworkUrl.isNotEmpty
              ? Uri.tryParse(track.artworkUrl)
              : null,
          duration: track.duration,
        );

    Future<bool> startWith(ResolvedStream? stream) async {
      final playUrl = stream?.url;
      if (playUrl == null || playUrl.isEmpty) return false;

      final isRemote =
          playUrl.startsWith('http://') || playUrl.startsWith('https://');
      final isLocal = !isRemote &&
          (playUrl.startsWith('file:') || File(playUrl).existsSync());
      final audioSource = isLocal
          ? AudioSource.file(
              playUrl.startsWith('file:')
                  ? Uri.parse(playUrl).toFilePath()
                  : playUrl,
              tag: buildMediaItem(),
            )
          : AudioSource.uri(
              Uri.parse(playUrl),
              tag: buildMediaItem(),
              headers: stream == null || stream.headers.isEmpty
                  ? null
                  : stream.headers,
            );

      await _player
          .setAudioSource(audioSource)
          .timeout(const Duration(seconds: 20));
      if (requestId != _playRequestId) return true;

      // just_audio's play() future completes only when playback pauses or
      // ends, so it must not be awaited with a timeout.
      unawaited(_player.play());
      unawaited(_storageService?.addToHistory(track));
      _prefetchNext();
      return true;
    }

    Future<bool> tryStart(Future<ResolvedStream?> Function() resolve,
        {required Duration timeout}) async {
      try {
        return await startWith(await resolve().timeout(timeout));
      } catch (_) {
        return false;
      }
    }

    try {
      // Resolve while the session finishes initializing instead of after it.
      // Errors are swallowed here because they could land before tryStart
      // listens; a failed first attempt is retried below anyway.
      final firstStream = _resolveStream(track).catchError((Object _) => null);
      await initialize();

      // Unload the previous track. The stream is already resolving in
      // parallel, so this wait costs nothing; the idle state also drives
      // the loading indicator.
      await _player.stop();

      // Attempt 1: cached, prefetched, or freshly resolved stream.
      if (await tryStart(() => firstStream,
          timeout: const Duration(seconds: 25))) {
        return;
      }

      if (requestId != _playRequestId) return;

      // Attempt 2: the cached/signed URL may have expired (HTTP 403 at the CDN)
      // or the matched upload is broken. Drop both so the resolver picks
      // afresh (SoundCloud also auto-refreshes its client_id on auth failures).
      _urlCache.remove(_cacheKey(track));
      _resolver.forgetMatch(track);
      if (await tryStart(() => _resolveStream(track),
          timeout: const Duration(seconds: 25))) {
        return;
      }

      if (requestId != _playRequestId) return;

      // Attempt 3: last resort — search SoundCloud for the same song and play
      // the best match, so the music never stops.
      if (await tryStart(() => _resolver.resolveSpotifyTrack(track),
          timeout: const Duration(seconds: 40))) {
        return;
      }

      if (requestId == _playRequestId) {
        // Completely stop playback and reset current track so old audio doesn't linger
        unawaited(_player.stop());
        _setCurrentTrack(null);
        if (!_errorController.isClosed) {
          _errorController.add(AudioPlaybackError(
            track: track,
            message:
                'Не удалось воспроизвести трек (${track.source.name.toUpperCase()})',
          ));
        }
      }
    } catch (e) {
      // A cached URL may have expired; drop it so a retry resolves afresh.
      _urlCache.remove(_cacheKey(track));

      if (requestId == _playRequestId) {
        if (await tryStart(() => _resolver.resolveSpotifyTrack(track),
            timeout: const Duration(seconds: 40))) {
          return;
        }
        if (requestId == _playRequestId) {
          unawaited(_player.stop());
          _setCurrentTrack(null);
          if (!_errorController.isClosed) {
            _errorController.add(AudioPlaybackError(
              track: track,
              message:
                  'Не удалось воспроизвести трек (${track.source.name.toUpperCase()})',
              cause: e,
            ));
          }
        }
      }
    }
  }

  Future<void> playAt(int index) async {
    if (index < 0 || index >= _queue.length) return;
    _currentIndex = index;
    await playTrack(_queue[index]);
  }

  Future<void> startWave(MediaTrack seed) async {
    final currentIsSeed = _currentTrack?.id == seed.id && _player.playing;
    _waveActive = true;
    _waveSeed = seed;
    _playbackContext = 'Волна: ${seed.title}';
    _waveGeneration++;
    _queue
      ..clear()
      ..add(seed);
    _currentIndex = 0;
    _notifyQueue();
    if (!currentIsSeed) {
      await playTrack(seed);
    }
    unawaited(_extendWave());
  }

  Future<void> _extendWave() async {
    if (!_waveActive || _waveSeed == null || _waveExtension != null) return;
    final generation = _waveGeneration;
    final seed = _queue.isNotEmpty ? _queue.last : _waveSeed!;
    final excluded =
        _queue.map((track) => '${track.artist}|${track.title}').toSet();
    final future = _waveService.nextBatch(seed, excluded: excluded);
    _waveExtension = future.then((tracks) {
      if (generation != _waveGeneration || !_waveActive || tracks.isEmpty) {
        return;
      }
      _queue.addAll(tracks);
      _notifyQueue();
      _prefetchNext();
    }).whenComplete(() => _waveExtension = null);
    await _waveExtension;
  }

  Future<File?> downloadTrack(
    MediaTrack track, {
    void Function(double progress)? onProgress,
  }) async {
    final stream = await _resolveStream(track);
    final streamUrl = stream?.url;
    if (streamUrl == null || streamUrl.isEmpty) return null;
    if (streamUrl.startsWith('file:')) {
      return File(Uri.parse(streamUrl).toFilePath());
    }
    return _cacheManager.downloadTrack(
      track,
      streamUrl,
      cacheKey: '${track.source.name}_${track.id}',
      headers: stream!.headers.isEmpty ? null : stream.headers,
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
    _notifyQueue();
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _notifyQueue();
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

    if (_waveActive && _currentIndex + 1 >= _queue.length) {
      await _extendWave();
    }
    if (_isShuffle && !_waveActive && _queue.length > 1) {
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
    await _queueController.close();
    await _player.dispose();
    _resolver.dispose();
  }
}
