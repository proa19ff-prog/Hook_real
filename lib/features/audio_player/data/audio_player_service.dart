import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart';

import '../../../core/diagnostics/playback_diagnostics.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../extractor/models/media_track.dart';
import '../../extractor/models/resolved_stream.dart';
import '../../extractor/stream_resolver.dart';
import '../../recommendations/track_wave_service.dart';

enum PlayerLoopMode { off, all, one }

enum AudioPlaybackErrorKind { forbidden, catalogUnavailable, sourceUnavailable }

class AudioPlaybackError {
  final MediaTrack track;
  final AudioPlaybackErrorKind kind;
  final String message;
  final Object? cause;

  const AudioPlaybackError({
    required this.track,
    required this.kind,
    required this.message,
    this.cause,
  });
}

class AudioPlayerService extends audio_service.BaseAudioHandler
    with audio_service.QueueHandler, audio_service.SeekHandler {
  final AudioPlayer _player;
  final StreamResolver _resolver;
  final AudioCacheManager _cacheManager;
  final LocalStorageService? _storageService;
  late final TrackWaveService _waveService;

  bool get _usesRussian {
    final selected = _storageService?.getLocaleCode();
    if (selected == 'ru') return true;
    if (selected == 'en') return false;
    return Platform.localeName.toLowerCase().startsWith('ru');
  }

  MediaTrack? _currentTrack;
  final List<MediaTrack> _queue = [];
  final StreamController<AudioPlaybackError?> _errorController =
      StreamController<AudioPlaybackError?>.broadcast();
  final StreamController<MediaTrack?> _trackController =
      StreamController<MediaTrack?>.broadcast();

  /// Resolved stream URLs keyed by cache key, so replays and "previous" are
  /// instant. SoundCloud signs URLs for about two hours; the TTL stays well
  /// under that so a cached URL never reaches the player already expired.
  final Map<String, ({ResolvedStream stream, DateTime resolvedAt})> _urlCache =
      {};
  final StreamController<TrackSource?> _sourceController =
      StreamController<TrackSource?>.broadcast();
  TrackSource? _playbackSource;
  TrackSource? get playbackSource => _playbackSource;
  Stream<TrackSource?> get playbackSourceStream => _sourceController.stream;
  final Map<String, Future<ResolvedStream?>> _pendingStreams = {};
  static const _urlTtl = Duration(minutes: 60);
  static const _toggleFavoriteAction = 'toggleFavorite';

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
  StreamSubscription<void>? _favoritesSubscription;
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
  final Set<String> _waveSeen = <String>{};
  final StreamController<int> _queueController =
      StreamController<int>.broadcast();
  int _queueVersion = 0;

  AudioPlayerService({
    AudioPlayer? player,
    StreamResolver? resolver,
    AudioCacheManager? cacheManager,
    this._storageService,
  }) : _player =
           player ??
           AudioPlayer(
             audioLoadConfiguration: _loadConfiguration,
             // just_audio 0.9's header proxy overwrites a source User-Agent
             // with Dart's default. Android supports per-source headers natively.
             useProxyForRequestHeaders: !Platform.isAndroid,
           ),
       _resolver = resolver ?? StreamResolver(),
       _cacheManager = cacheManager ?? AudioCacheManager() {
    _waveService = TrackWaveService(_resolver);
  }

  AudioPlayer get rawPlayer => _player;
  MediaTrack? get currentTrack => _currentTrack;
  List<MediaTrack> get trackQueue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  PlayerLoopMode get loopMode => _loopMode;
  bool get isShuffle => _isShuffle;
  bool get waveActive => _waveActive;
  String? get playbackContext => _playbackContext;
  Stream<int> get queueChanges => _queueController.stream;

  void _notifyQueue() {
    _queueVersion++;
    queue.add(_queue.map(_toMediaItem).toList(growable: false));
    if (!_queueController.isClosed) _queueController.add(_queueVersion);
    _broadcastPlaybackState();
  }

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<Duration> get bufferedPositionStream => _player.bufferedPositionStream;
  Stream<AudioPlaybackError?> get errorStream => _errorController.stream;
  Stream<MediaTrack?> get currentTrackStream => _trackController.stream;

  audio_service.MediaItem _toMediaItem(MediaTrack track) =>
      audio_service.MediaItem(
        id: '${track.source.name}:${track.id}',
        album: track.album ?? track.artist,
        title: track.title,
        artist: track.artist,
        artUri: track.artworkUrl.isNotEmpty
            ? Uri.tryParse(track.artworkUrl)
            : null,
        duration: track.duration,
      );

  bool _isFavorite(MediaTrack track) =>
      _storageService?.getFavorites().any(
        (favorite) =>
            favorite.id == track.id && favorite.source == track.source,
      ) ??
      false;

  audio_service.AudioProcessingState _toAudioProcessingState(
    ProcessingState state,
  ) {
    switch (state) {
      case ProcessingState.idle:
        return audio_service.AudioProcessingState.idle;
      case ProcessingState.loading:
        return audio_service.AudioProcessingState.loading;
      case ProcessingState.buffering:
        return audio_service.AudioProcessingState.buffering;
      case ProcessingState.ready:
        return audio_service.AudioProcessingState.ready;
      case ProcessingState.completed:
        return audio_service.AudioProcessingState.completed;
    }
  }

  void _broadcastPlaybackState() {
    final track = _currentTrack;
    final controls = <audio_service.MediaControl>[
      audio_service.MediaControl.skipToPrevious,
      if (track != null)
        audio_service.MediaControl.custom(
          androidIcon: _isFavorite(track)
              ? 'drawable/ic_notification_favorite'
              : 'drawable/ic_notification_favorite_border',
          label: _isFavorite(track)
              ? (_usesRussian ? 'Убрать из избранного' : 'Remove favorite')
              : (_usesRussian ? 'В избранное' : 'Add favorite'),
          name: _toggleFavoriteAction,
        ),
      _player.playing
          ? audio_service.MediaControl.pause
          : audio_service.MediaControl.play,
      audio_service.MediaControl.skipToNext,
    ];
    final playPauseIndex = track == null ? 1 : 2;
    playbackState.add(
      audio_service.PlaybackState(
        controls: controls,
        systemActions: const {audio_service.MediaAction.seek},
        androidCompactActionIndices: [0, playPauseIndex, controls.length - 1],
        processingState: _toAudioProcessingState(_player.processingState),
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _currentIndex < 0 ? null : _currentIndex,
      ),
    );
  }

  void _setCurrentTrack(MediaTrack? track) {
    _currentTrack = track;
    _playbackSource = null;
    if (!_sourceController.isClosed) _sourceController.add(null);
    mediaItem.add(track == null ? null : _toMediaItem(track));
    _broadcastPlaybackState();
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
      return Future.value(cached.stream);
    }

    return _pendingStreams[key] ??= () async {
      try {
        final local = await _cacheManager.getLocalCachedUrl(key);
        if (local != null) {
          return ResolvedStream(local, source: TrackSource.local);
        }

        final resolved = await _resolver
            .resolveStream(track)
            .timeout(const Duration(seconds: 25));
        if (resolved != null && !resolved.isEmpty) {
          if (resolved.isReusable) {
            if (_urlCache.length >= 100) _urlCache.remove(_urlCache.keys.first);
            _urlCache[key] = (stream: resolved, resolvedAt: DateTime.now());
          }
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
    if (_waveActive && _currentIndex >= _queue.length - 3) {
      unawaited(_extendWave());
    }
    if (_isShuffle || _currentIndex + 1 >= _queue.length) return;
    prefetch([_queue[_currentIndex + 1]]);
  }

  /// Resolves streams ahead of a tap (e.g. the top search results), so the
  /// tap only has to buffer audio. Failures are ignored; a tap resolves again.
  void prefetch(Iterable<MediaTrack> tracks) {
    for (final track in tracks) {
      if (track.source == TrackSource.local ||
          track.source == TrackSource.youtubeMusic) {
        continue;
      }
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
    _favoritesSubscription = _storageService?.favoritesChanges.listen(
      (_) => _broadcastPlaybackState(),
    );

    // Auto-advance to next track when finished
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      _broadcastPlaybackState();
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
    });
  }

  /// Sets track queue and plays the track at [startIndex]
  Future<void> setQueue(List<MediaTrack> tracks, {int startIndex = 0}) async {
    _waveActive = false;
    _waveSeed = null;
    _waveSeen.clear();
    _playbackContext = null;
    _waveGeneration++;
    _queue.clear();
    _queue.addAll(tracks);
    _currentIndex = tracks.isEmpty
        ? -1
        : startIndex.clamp(0, tracks.length - 1);
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
  /// On failure refreshes the same recording's signed URL first. Only catalog
  /// records may then try another matching public source.
  Future<void> playTrack(MediaTrack track) async {
    final requestId = ++_playRequestId;
    if (!_errorController.isClosed) _errorController.add(null);

    // Show the tapped track right away; the stream resolves in the background.
    _setCurrentTrack(track);
    var attemptedPlayback = false;
    TrackSource? attemptedSource;
    Object? lastError;

    void reportError(Object? cause) {
      if (requestId != _playRequestId) return;
      _urlCache.remove(_cacheKey(track));
      if (attemptedPlayback) _resolver.forgetMatch(track);
      _player.stop().ignore();
      _setCurrentTrack(null);
      PlaybackDiagnostics.record(
        'playback.failed',
        source: track.source.name,
        error: cause,
      );
      final forbidden =
          cause != null &&
          PlaybackDiagnostics.failureLabel(cause) == 'HTTP 403';
      if (!_errorController.isClosed) {
        _errorController.add(
          AudioPlaybackError(
            track: track,
            kind: forbidden
                ? AudioPlaybackErrorKind.forbidden
                : track.source.isCatalog
                ? AudioPlaybackErrorKind.catalogUnavailable
                : AudioPlaybackErrorKind.sourceUnavailable,
            message: forbidden
                ? 'Сервер аудио отклонил доступ (HTTP 403). Трек найден, но поток недоступен. VPN не гарантирует доступ к аудио.'
                : track.source.isCatalog
                ? 'Полная версия не найдена в доступных источниках. Проверьте сеть или попробуйте позже.'
                : 'Источник ${track.source.label} не смог воспроизвести трек. Проверьте сеть или попробуйте позже.',
            cause: cause,
          ),
        );
      }
    }

    Future<bool> startWith(ResolvedStream? stream) async {
      // Check before touching the native player, not only after setAudioSource:
      // a slow previous tap must never replace the newly selected song.
      if (requestId != _playRequestId) return true;
      final playUrl = stream?.url;
      if (playUrl == null || playUrl.isEmpty) return false;
      attemptedPlayback = true;
      attemptedSource = stream?.source;

      final isRemote =
          playUrl.startsWith('http://') || playUrl.startsWith('https://');
      final isLocal =
          !isRemote &&
          (playUrl.startsWith('file:') || File(playUrl).existsSync());
      final audioSource = isLocal
          ? AudioSource.file(
              playUrl.startsWith('file:')
                  ? Uri.parse(playUrl).toFilePath()
                  : playUrl,
              tag: _toMediaItem(track),
            )
          : AudioSource.uri(
              Uri.parse(playUrl),
              tag: _toMediaItem(track),
              headers: stream == null || stream.headers.isEmpty
                  ? null
                  : stream.headers,
            );

      PlaybackDiagnostics.record(
        'native.load',
        source: (stream?.source ?? track.source).name,
        url: playUrl,
      );
      Duration? actualDuration;
      try {
        actualDuration = await _player
            .setAudioSource(audioSource)
            .timeout(const Duration(seconds: 20));
      } catch (error) {
        PlaybackDiagnostics.record(
          'native.failed',
          source: (stream?.source ?? track.source).name,
          url: playUrl,
          error: error,
        );
        rethrow;
      }
      if (requestId != _playRequestId) return true;
      // Metadata alone cannot prove a CDN returned the full song. Reject an
      // obvious preview after the native decoder reports its real duration.
      if (track.duration.inSeconds >= 60 &&
          actualDuration != null &&
          (actualDuration.inMilliseconds <
                  track.duration.inMilliseconds * 0.8 ||
              (track.source.isCatalog &&
                  !StreamResolver.isPlayableMatch(
                    track,
                    track.copyWith(duration: actualDuration),
                  )))) {
        await _player.stop();
        return false;
      }
      PlaybackDiagnostics.record(
        'native.ready',
        source: (stream?.source ?? track.source).name,
        url: playUrl,
        durationMs: actualDuration?.inMilliseconds,
      );
      _playbackSource =
          stream?.source ?? (track.source.isCatalog ? null : track.source);
      if (!_sourceController.isClosed) _sourceController.add(_playbackSource);

      // just_audio's play() future completes only when playback pauses or
      // ends, so it must not be awaited with a timeout.
      unawaited(
        _player.play().catchError((Object error) => reportError(error)),
      );
      unawaited(_storageService?.addToHistory(track));
      _prefetchNext();
      return true;
    }

    Future<bool> tryStart(
      Future<ResolvedStream?> Function() resolve, {
      required Duration timeout,
    }) async {
      try {
        return await startWith(await resolve().timeout(timeout));
      } catch (error) {
        lastError = error;
        return false;
      }
    }

    try {
      // Resolve while the session finishes initializing instead of after it.
      // Handle early errors immediately, but retain their cause: resolution can
      // fail with HTTP 403 before any native audio load has even been attempted.
      final firstStream = _resolveStream(track).catchError((Object error) {
        lastError = error;
        PlaybackDiagnostics.record(
          'resolve.failed',
          source: track.source.name,
          error: error,
        );
        return null;
      });
      await initialize();
      if (requestId != _playRequestId) return;

      // Unload the previous track. The stream is already resolving in
      // parallel, so this wait costs nothing; the idle state also drives
      // the loading indicator.
      await _player.stop();

      // Attempt 1: cached, prefetched, or freshly resolved stream.
      if (await tryStart(
        () => firstStream,
        timeout: const Duration(seconds: 25),
      )) {
        return;
      }

      if (requestId != _playRequestId) return;

      if (attemptedPlayback) {
        // Refresh only the signed URL first. Banning the matched recording at
        // this point would lose the only original just because its URL expired.
        _urlCache.remove(_cacheKey(track));
        if (await tryStart(
          () => _resolveStream(track),
          timeout: const Duration(seconds: 25),
        )) {
          return;
        }
        if (requestId != _playRequestId) return;

        // Only a catalog entry may switch recordings, and only after refreshing
        // the original URL failed too. Direct uploads retain their identity.
        if (track.source.isCatalog) {
          // A fast manifest is not proof that Android can read the audio. After
          // refreshing failed, stop racing the same unusable provider against
          // slower working ones. Exclusions last for this play request only.
          final failedSources = <TrackSource>{
            if (attemptedSource != null) attemptedSource!,
          };
          for (var attempt = 0; attempt < 3; attempt++) {
            if (requestId != _playRequestId) return;
            _resolver.forgetMatch(track);
            attemptedSource = null;
            if (await tryStart(
              () => _resolver.resolveSpotifyTrack(
                track,
                excludedSources: Set.unmodifiable(failedSources),
              ),
              timeout: const Duration(seconds: 25),
            )) {
              return;
            }
            final failedSource = attemptedSource;
            if (failedSource == null || !failedSources.add(failedSource)) break;
          }
        }
      }
      // No stream at all: don't repeat the same expensive multi-source search
      // three times. The listener can explicitly retry when their network changes.
      reportError(lastError);
    } catch (error) {
      reportError(error);
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
    _playbackContext = '${_usesRussian ? 'Волна' : 'Wave'}: ${seed.title}';
    _waveGeneration++;
    _waveSeen
      ..clear()
      ..add(TrackWaveService.trackKey(seed));
    // Do not replay tracks recently heard by the listener when a new radio
    // session begins. The queue is included again before every extension.
    for (final track in _storageService?.getHistory() ?? const <MediaTrack>[]) {
      _waveSeen.add(TrackWaveService.trackKey(track));
    }
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
    final relatedSeed = _queue.isNotEmpty ? _queue.last : _waveSeed!;
    _waveSeen.addAll(_queue.map(TrackWaveService.trackKey));
    final future = _waveService.nextBatch(
      _waveSeed!,
      relatedSeed: relatedSeed,
      excluded: _waveSeen,
    );
    _waveExtension = future
        .then((tracks) {
          if (generation != _waveGeneration || !_waveActive || tracks.isEmpty) {
            return;
          }
          _waveSeen.addAll(tracks.map(TrackWaveService.trackKey));
          _queue.addAll(tracks);
          _notifyQueue();
          _prefetchNext();
        })
        .whenComplete(() => _waveExtension = null);
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

  @override
  Future<void> play() async => await _player.play();

  @override
  Future<void> pause() async => await _player.pause();

  @override
  Future<void> stop() async {
    _playRequestId++;
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async => await _player.seek(position);

  @override
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

    await previousTrack();
  }

  Future<void> previousTrack() async {
    if (_queue.isEmpty) return;

    if (_currentIndex - 1 >= 0) {
      _currentIndex--;
      await playTrack(_queue[_currentIndex]);
    } else if (_loopMode == PlayerLoopMode.all) {
      _currentIndex = _queue.length - 1;
      await playTrack(_queue[_currentIndex]);
    }
  }

  @override
  Future<void> skipToNext() => next();

  @override
  Future<void> skipToPrevious() => previous();

  @override
  Future<dynamic> customAction(
    String name, [
    Map<String, dynamic>? extras,
  ]) async {
    if (name == _toggleFavoriteAction &&
        _currentTrack != null &&
        _storageService != null) {
      await _storageService.toggleFavorite(_currentTrack!);
    }
    return null;
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
    await _favoritesSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _errorController.close();
    await _trackController.close();
    await _sourceController.close();
    await _queueController.close();
    await _player.dispose();
    _resolver.dispose();
  }
}
