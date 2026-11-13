import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:audio_service/audio_service.dart' as audio_service;
import 'package:just_audio/just_audio.dart';
import 'package:dio/dio.dart';

import '../../../core/diagnostics/playback_diagnostics.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../artwork/artwork_service.dart';
import '../../extractor/models/media_track.dart';
import '../../extractor/models/resolved_stream.dart';
import '../../extractor/sources/remote_resolver_source.dart';
import '../../extractor/stream_resolver.dart';
import '../../recommendations/recommendation_service.dart';
import '../../recommendations/track_wave_service.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'equalizer_controller.dart';
import '../../lyrics/data/lyrics_client.dart';

enum PlayerLoopMode { off, all, one }

enum AudioPlaybackErrorKind {
  forbidden,
  catalogUnavailable,
  sourceUnavailable,

  /// YouTube refused the track because it is age-restricted and the server
  /// has no signed-in cookie jar. The user can fix this one.
  ageRestricted,
}

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
  late final EqualizerController equalizer;
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

  /// Whether to warm the next tracks in the background. Off means every tap
  /// resolves its own stream: less data, slightly slower skips.
  ///
  /// A plain settable field rather than a provider read because resolution
  /// happens deep inside the service, often outside the widget tree.
  static bool prefetchEnabled = true;

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
  /// The Android tuning is meaningless on desktop engines (WinRT MediaPlayer),
  /// which are given no custom load configuration at all.
  static AudioLoadConfiguration? get _loadConfiguration => Platform.isAndroid
      ? const AudioLoadConfiguration(
          androidLoadControl: AndroidLoadControl(
            minBufferDuration: Duration(seconds: 15),
            maxBufferDuration: Duration(seconds: 50),
            bufferForPlaybackDuration: Duration(milliseconds: 500),
            bufferForPlaybackAfterRebufferDuration: Duration(seconds: 2),
          ),
        )
      : null;
  StreamSubscription<void>? _noisySubscription;
  StreamSubscription<void>? _favoritesSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  int _currentIndex = -1;
  int _playRequestId = 0;
  Future<void>? _initialization;
  StreamSubscription<PlaybackEvent>? _playbackErrorSubscription;
  Future<void> Function(Object error)? _runtimeErrorHandler;
  CancelToken? _fallbackDownloadToken;
  Timer? _resumeTimer;
  final LyricsClient _offlineLyrics = LyricsClient();
  bool _wantsPlayback = false;
  Duration? _pendingFallbackPosition;

  PlayerLoopMode _loopMode = PlayerLoopMode.off;
  bool _isShuffle = false;
  bool _waveActive = false;
  MediaTrack? _waveSeed;
  String? _playbackContext;
  int _waveGeneration = 0;
  Future<void>? _waveExtension;
  final Set<String> _waveSeen = <String>{};
  RecommendationService? _recommender;
  final StreamController<int> _queueController =
      StreamController<int>.broadcast();
  int _queueVersion = 0;

  AudioPlayerService({
    AudioPlayer? player,
    StreamResolver? resolver,
    AudioCacheManager? cacheManager,
    this._storageService,
    EqualizerController? equalizerController,
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
    equalizer = equalizerController ?? EqualizerController();
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

  audio_service.MediaItem _toMediaItem(MediaTrack track) {
    // Prefer a real cover: the server hands out YouTube video frames for
    // remote tracks, which look wrong in the notification and on the lock
    // screen. A resolved cover wins; otherwise a frame is simply omitted.
    final resolved = ArtworkService.instance.displayUrl(
      track.artworkUrl,
      artist: track.artist,
      title: track.title,
    );
    final artUrl = resolved == null ? '' : TrackArtwork.getHighResUrl(resolved);
    return audio_service.MediaItem(
      id: '${track.source.name}:${track.id}',
      album: track.album ?? track.artist,
      title: track.title,
      artist: track.artist,
      artUri: artUrl.isNotEmpty ? Uri.tryParse(artUrl) : null,
      duration: track.duration,
    );
  }

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
    if (track != null) _refreshArtwork(track);
  }

  /// Fills in a real cover for the notification and the now-playing screen
  /// when the stored artwork is missing or is a YouTube video frame.
  void _refreshArtwork(MediaTrack track) {
    final current = ArtworkService.instance.displayUrl(
      track.artworkUrl,
      artist: track.artist,
      title: track.title,
    );
    if (current != null) {
      return;
    }
    ArtworkService.instance
        .resolve(
          artist: track.artist,
          title: track.title,
          duration: track.duration,
        )
        .then((url) {
          if (url == null ||
              _currentTrack?.id != track.id ||
              _currentTrack?.source != track.source) {
            return;
          }
          mediaItem.add(_toMediaItem(track));
        })
        .catchError((_) {});
  }

  String _cacheKey(MediaTrack track) => '${track.source.name}_${track.id}';

  /// Resolves a playable URL, reusing recent results and sharing in-flight
  /// requests so a prefetch and a tap never resolve the same track twice.
  Future<ResolvedStream?> _resolveStream(MediaTrack track) {
    final key = _cacheKey(track);
    return _pendingStreams[key] ??= () async {
      try {
        // A downloaded file wins over a still-valid remote URL on every replay.
        final local = await _cacheManager.getLocalCachedUrl(key);
        if (local != null) {
          return ResolvedStream(local, source: TrackSource.local);
        }
        final cached = _urlCache[key];
        if (cached != null &&
            DateTime.now().difference(cached.resolvedAt) < _urlTtl) {
          return cached.stream;
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
    if (_currentIndex >= _queue.length - 3) {
      if (!_waveActive && _currentTrack != null) {
        _waveActive = true;
        _waveSeed = _currentTrack;
        _playbackContext =
            '${_usesRussian ? 'Похожие треки' : 'Similar tracks'}: ${_currentTrack!.title}';
        _waveSeen.addAll(_queue.map(TrackWaveService.trackKey));
      }
      if (_waveActive) {
        unawaited(_extendWave());
      }
    }
    if (_isShuffle || _currentIndex + 1 >= _queue.length) return;
    prefetch([_queue[_currentIndex + 1]]);
  }

  /// Resolves streams ahead of a tap (e.g. the top search results), so the
  /// tap only has to buffer audio. Failures are ignored; a tap resolves again.
  ///
  /// [deep] caps how many tracks get a full resolve. A catalog resolve is
  /// expensive (it matches a recording, then resolves a stream), so only the
  /// first one is worth paying for; the rest just heat the server cache.
  void prefetch(Iterable<MediaTrack> tracks, {int deep = 1}) {
    if (!prefetchEnabled) return;
    var resolved = 0;
    final youtubeIds = <String>[];
    for (final track in tracks) {
      if (track.source == TrackSource.local) continue;
      if (track.source == TrackSource.youtubeMusic) {
        // A prefetched direct YouTube url is wasted work: the signed link is
        // short-lived and the player resolves again on tap anyway. The server
        // hint is worth something though — it puts the audio in server RAM.
        youtubeIds.add(track.id);
        continue;
      }
      if (resolved++ >= deep) continue;
      _resolveUrl(track).catchError((_) => null).ignore();
    }
    if (youtubeIds.isNotEmpty) {
      _resolver.remoteSource?.warm(youtubeIds).ignore();
    }
  }

  /// Initializes audio session for background focus & headset unplug handling
  Future<void> initialize() async {
    if (_initialization != null) return _initialization!;
    _initialization = _initialize();
    return _initialization!;
  }

  Future<void> _initialize() async {
    if (Platform.isAndroid) {
      // audio_session has no desktop implementation; Windows playback works
      // without focus management (the OS mixer owns it).
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      // Auto-pause if headphones are unplugged
      _noisySubscription = session.becomingNoisyEventStream.listen((_) {
        pause();
      });
    }
    // Effects are optional; their hardware availability never gates playback.
    unawaited(equalizer.attachPlayer(_player));

    _favoritesSubscription = _storageService?.favoritesChanges.listen(
      (_) => _broadcastPlaybackState(),
    );

    // Native errors may happen after setAudioSource returned successfully.
    _playbackErrorSubscription = _player.playbackEventStream.listen(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        final recover = _runtimeErrorHandler;
        if (recover != null) unawaited(recover(error));
      },
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
      final current = _queue[_currentIndex];
      // When a single track is selected to play, or starting at the end of a queue,
      // start smart recommendations immediately so the next tracks are chosen
      // right away without needing any buttons!
      if (_queue.length <= 1) {
        _waveActive = true;
        _waveSeed = current;
        _waveSeen.add(TrackWaveService.trackKey(current));
        for (final track
            in _storageService?.getHistory() ?? const <MediaTrack>[]) {
          _waveSeen.add(TrackWaveService.trackKey(track));
        }
        _playbackContext =
            '${_usesRussian ? 'Похожие треки' : 'Similar tracks'}: ${current.title}';
        unawaited(_extendWave());
      }
      await playTrack(current);
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
    _fallbackDownloadToken?.cancel('Track changed');
    _fallbackDownloadToken = null;
    _runtimeErrorHandler = null;
    _pendingFallbackPosition = null;
    _wantsPlayback = true;
    if (!_errorController.isClosed) _errorController.add(null);

    // Show the tapped track right away; the stream resolves in the background.
    _setCurrentTrack(track);
    var attemptedPlayback = false;
    TrackSource? attemptedSource;
    Object? lastError;
    ResolvedStream? downloadCandidate;
    var downloadAttempted = false;
    var recovering = false;
    var loadGeneration = 0;
    Object? failedLocalPlayback;
    Future<void> Function(Object error)? runtimeRecovery;

    void reportError(Object? cause) {
      if (requestId != _playRequestId) return;
      _urlCache.remove(_cacheKey(track));
      _runtimeErrorHandler = null;
      if (attemptedPlayback) _resolver.forgetMatch(track);
      _player.stop().ignore();
      _setCurrentTrack(null);
      PlaybackDiagnostics.record(
        'playback.failed',
        source: track.source.name,
        error: cause,
      );
      final refusal = cause is AgeRestrictedStreamException ? cause : null;
      final forbidden =
          cause != null &&
          PlaybackDiagnostics.failureLabel(cause) == 'HTTP 403';
      if (!_errorController.isClosed) {
        _errorController.add(
          AudioPlaybackError(
            track: track,
            kind: refusal != null
                ? AudioPlaybackErrorKind.ageRestricted
                : forbidden
                ? AudioPlaybackErrorKind.forbidden
                : track.source.isCatalog
                ? AudioPlaybackErrorKind.catalogUnavailable
                : AudioPlaybackErrorKind.sourceUnavailable,
            message: refusal != null
                ? 'Трек с возрастным ограничением (18+). Серверу нужны куки YouTube от аккаунта, который вошёл в систему.'
                : forbidden
                ? 'Сервер аудио отклонил доступ (HTTP 403). Трек найден, но поток недоступен. VPN не гарантирует доступ к аудио.'
                : track.source.isCatalog
                ? 'Полная версия не найдена в доступных источниках. Проверьте сеть или попробуйте позже.'
                : 'Источник ${track.source.label} не смог воспроизвести трек. Проверьте сеть или попробуйте позже.',
            cause: cause,
          ),
        );
      }
    }

    Future<bool> startWith(
      ResolvedStream? stream, {
      Duration initialPosition = Duration.zero,
    }) async {
      // Check before touching the native player, not only after setAudioSource:
      // a slow previous tap must never replace the newly selected song.
      if (requestId != _playRequestId) return true;
      final playUrl = stream?.url;
      if (playUrl == null || playUrl.isEmpty) return false;
      final generation = ++loadGeneration;
      attemptedPlayback = true;
      attemptedSource = stream?.source;

      final isRemote =
          playUrl.startsWith('http://') || playUrl.startsWith('https://');
      final isLocal =
          !isRemote &&
          (playUrl.startsWith('file:') || File(playUrl).existsSync());
      if (isRemote) downloadCandidate = stream;
      // Load failures are handled by the synchronous retry path below, not by
      // the native event listener as well (which would start two recoveries).
      _runtimeErrorHandler = null;
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
            .setAudioSource(audioSource, initialPosition: initialPosition)
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
      _runtimeErrorHandler = runtimeRecovery;
      if (_wantsPlayback) {
        unawaited(
          _player.play().catchError((Object error) async {
            if (requestId == _playRequestId && generation == loadGeneration) {
              await runtimeRecovery?.call(error);
            }
          }),
        );
        final target = equalizer.volume.clamp(0.0, 1.0);
        if (target > 0) {
          unawaited(_player.setVolume(target));
        }
      }
      unawaited(_storageService?.addToHistory(track));
      // Real replay signal for the personal recommendations engine.
      unawaited(
        _storageService?.registerPlay(TrackWaveService.trackKey(track)),
      );
      _saveResumeState(track);
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

    Future<bool> tryDownloadAndStart({
      Duration position = Duration.zero,
    }) async {
      if (requestId != _playRequestId) return true;
      if (downloadAttempted || track.source == TrackSource.local) return false;
      downloadAttempted = true;
      final token = CancelToken();
      _fallbackDownloadToken = token;
      _pendingFallbackPosition = position;
      try {
        // A broken cached file must not keep winning every subsequent attempt.
        if (attemptedSource == TrackSource.local) {
          await _cacheManager.removeCachedTrack(_cacheKey(track));
        }
        ResolvedStream? stream;
        try {
          stream = await _resolver
              .resolveDownloadStream(track)
              .timeout(const Duration(seconds: 25));
        } catch (error) {
          lastError = error;
        }
        // Refresh manifests first; if refresh failed but a native stream URL
        // exists, a full GET of that same recording is still worth one try.
        stream ??= downloadCandidate;
        if (requestId != _playRequestId || token.isCancelled) return true;
        if (stream == null || stream.isEmpty) return false;
        PlaybackDiagnostics.record(
          'download.fallback.started',
          source: track.source.name,
          url: stream.url,
        );
        unawaited(_cacheOfflineLyrics(track));
        final file = await _cacheManager.downloadTrack(
          track,
          stream.url,
          cacheKey: _cacheKey(track),
          headers: stream.headers,
          fileExtension: stream.fileExtension,
          cancelToken: token,
        );
        if (requestId != _playRequestId || token.isCancelled) return true;
        if (file == null) return false;
        _urlCache.remove(_cacheKey(track));
        final loaded = await startWith(
          ResolvedStream(file.uri.toString(), source: TrackSource.local),
          initialPosition: _pendingFallbackPosition ?? position,
        );
        if (!loaded && requestId == _playRequestId) {
          await _cacheManager.removeCachedTrack(_cacheKey(track));
        }
        if (loaded) {
          PlaybackDiagnostics.record(
            'download.fallback.ready',
            source: track.source.name,
          );
        }
        return loaded;
      } catch (error) {
        lastError = error;
        return false;
      } finally {
        if (identical(_fallbackDownloadToken, token)) {
          _fallbackDownloadToken = null;
          _pendingFallbackPosition = null;
        }
      }
    }

    runtimeRecovery = (Object error) async {
      if (requestId != _playRequestId) return;
      if (recovering) {
        // A local decoder/play() failure may arrive before recovery's finally
        // block. Do not silently drop it or start another download loop.
        if (_playbackSource == TrackSource.local) failedLocalPlayback = error;
        return;
      }
      recovering = true;
      final position = _player.position;
      _runtimeErrorHandler = null;
      lastError = error;
      try {
        // Keep currentTrack and the queue untouched: lyrics, offsets, artwork
        // and favorites remain associated with the original source-qualified ID.
        await _player.stop();
        if (await tryDownloadAndStart(position: position)) return;
        reportError(lastError);
      } catch (failure) {
        reportError(failure);
      } finally {
        recovering = false;
        final localFailure = failedLocalPlayback;
        failedLocalPlayback = null;
        if (localFailure != null) reportError(localFailure);
      }
    };

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

        // Before changing providers, try a whole-file GET of the original.
        // This is useful for native streaming/Range issues, not network blocks.
        if (await tryDownloadAndStart()) return;
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
      // A Range probe may have failed before handing us a native stream. The
      // download resolver can still supply a full-file URL for the same video.
      if (!downloadAttempted && await tryDownloadAndStart()) return;
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
      personalArtists: _personalArtists(),
    );
    _waveExtension = future
        .then((tracks) {
          if (generation != _waveGeneration || !_waveActive || tracks.isEmpty) {
            return;
          }
          PlaybackDiagnostics.record(
            'wave.batch',
            source: 'wave',
            count: tracks.length,
            detail: relatedSeed.artist,
          );
          _waveSeen.addAll(tracks.map(TrackWaveService.trackKey));
          _queue.addAll(tracks);
          _notifyQueue();
          _prefetchNext();
          // The wave may have gone silent while this batch was in flight:
          // the playing track ended, next() found nothing, playback stopped.
          // Resume exactly that case — an intentional pause is never touched.
          if (!_player.playing &&
              _player.processingState == ProcessingState.completed &&
              _queue.length > _currentIndex + 1) {
            unawaited(playAt(_currentIndex + 1));
          }
        })
        .catchError((Object error) {
          PlaybackDiagnostics.record(
            'wave.batch.failed',
            source: 'wave',
            error: error,
          );
        })
        .whenComplete(() => _waveExtension = null);
    await _waveExtension;
  }

  /// Top artists by the listener's own signals; the wave blends one clean
  /// track per artist into every batch so radio follows their taste.
  List<String> _personalArtists() {
    final storage = _storageService;
    if (storage == null) return const [];
    _recommender ??= RecommendationService(
      storage: storage,
      resolver: _resolver,
    );
    return _recommender!.topPersonalArtists(limit: 2);
  }

  Future<File?> downloadTrack(
    MediaTrack track, {
    void Function(double progress)? onProgress,
    void Function(int? bitrateKbps)? onResolved,
  }) async {
    unawaited(_cacheOfflineLyrics(track));
    try {
      final local = await _cacheManager.getLocalCachedUrl(_cacheKey(track));
      if (local != null) return File(Uri.parse(local).toFilePath());

      // Candidates in trust order: the source's own full-file stream first,
      // then the server proxy for the same recording id, then the playback
      // matcher (probe-verified, includes the server), and finally a
      // server-side yt-dlp package for permalinks the device's network
      // cannot fetch or cannot save as one file. First success wins.
      final remote = _resolver.remoteSource;
      final candidates = <ResolvedStream>[];
      Future<void> add(Future<ResolvedStream?> Function() resolve) async {
        if (candidates.length >= 4) return;
        try {
          final stream = await resolve().timeout(const Duration(seconds: 25));
          if (stream == null || stream.isEmpty) return;
          if (!candidates.any((c) => c.url == stream.url)) {
            candidates.add(stream);
          }
        } catch (_) {
          // A failed resolver just leaves fewer candidates behind.
        }
      }

      await add(() => _resolver.resolveDownloadStream(track));
      if (track.source == TrackSource.youtubeMusic && remote != null) {
        // The server proxies this very video id; direct YouTube GETs are
        // commonly 403 on carrier networks while the server plays fine.
        await add(() => remote.resolveTrack(track));
      }
      await add(() => _resolver.resolveStream(track));
      final serverPackage = remote?.serverDownloadFor(track);
      if (serverPackage != null) candidates.add(serverPackage);

      for (final stream in candidates) {
        if (stream.url.startsWith('file:')) {
          return File(Uri.parse(stream.url).toFilePath());
        }
        onResolved?.call(stream.bitrateKbps);
        final file = await _cacheManager.downloadTrack(
          track,
          stream.url,
          cacheKey: _cacheKey(track),
          headers: stream.headers,
          fileExtension: stream.fileExtension,
          onProgress: onProgress,
        );
        if (file != null) return file;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _cacheOfflineLyrics(MediaTrack track) async {
    try {
      await _offlineLyrics.fetchLyrics(
        trackName: track.title,
        artistName: track.artist,
        duration: track.duration,
        trackKey: '${track.source.name}:${track.id}',
      );
    } catch (_) {
      // Missing lyrics must not block original audio from being saved/played.
    }
  }

  @override
  Future<void> play() async {
    _wantsPlayback = true;
    if (_fallbackDownloadToken != null) return;
    await _player.play();
  }

  @override
  Future<void> pause() async {
    _wantsPlayback = false;
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    _playRequestId++;
    _wantsPlayback = false;
    _runtimeErrorHandler = null;
    _fallbackDownloadToken?.cancel('Playback stopped');
    _fallbackDownloadToken = null;
    _pendingFallbackPosition = null;
    await _player.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    if (_fallbackDownloadToken != null) _pendingFallbackPosition = position;
    await _player.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) async =>
      await _player.setSpeed(speed.clamp(0.25, 2.5));
  Future<void> setPitch(double pitch) async =>
      await _player.setPitch(pitch.clamp(0.5, 2.0));
  Future<void> setVolume(double volume) async =>
      await equalizer.setVolume(volume);

  /// Writes the now-playing snapshot for cross-device "continue listening".
  /// While playing it re-writes every 15 seconds (a periodic timer keeps it
  /// fresh without a per-second write storm), plus once per track change.
  void _saveResumeState(MediaTrack track) {
    final storage = _storageService;
    if (storage == null) return;
    Future<void> write() async {
      try {
        await storage.saveResumeState({
          'track': {
            'id': track.id,
            'title': track.title,
            'artist': track.artist,
            if (track.album != null) 'album': track.album,
            'durationMs': track.duration.inMilliseconds,
            'artworkUrl': track.artworkUrl,
            'source': track.source.name,
          },
          'positionMs': _player.position.inMilliseconds,
          'device': Platform.localHostname,
          'at': DateTime.now().millisecondsSinceEpoch,
        });
      } catch (_) {
        // The resume hint is best-effort; never disturb playback.
      }
    }

    unawaited(write());
    _resumeTimer?.cancel();
    _resumeTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (_player.playing && _currentTrack == track) {
        unawaited(write());
      } else {
        _resumeTimer?.cancel();
        _resumeTimer = null;
      }
    });
  }

  /// Slides to silence before an automated pause (sleep timer) and restores
  /// the listener's volume afterwards, so the next play is not silent.
  Future<void> fadeOutAndPause({
    Duration length = const Duration(seconds: 4),
  }) async {
    final start = equalizer.volume.clamp(0.0, 1.0);
    const steps = 16;
    for (var i = steps - 1; i >= 0; i--) {
      await _player.setVolume(start * i / steps);
      await Future<void>.delayed(length ~/ steps);
    }
    await pause();
    await _player.setVolume(start);
  }

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

    if (_currentIndex + 1 >= _queue.length) {
      if (!_waveActive && _currentTrack != null) {
        _waveActive = true;
        _waveSeed = _currentTrack;
        _playbackContext =
            '${_usesRussian ? 'Похожие треки' : 'Similar tracks'}: ${_currentTrack!.title}';
        _waveSeen.addAll(_queue.map(TrackWaveService.trackKey));
      }
      if (_waveActive) {
        await _extendWave();
        if (_currentIndex + 1 >= _queue.length) {
          // The first fetch may have failed transiently (carrier throttling,
          // a blocked endpoint). Give the batch one more chance before the
          // wave dies at the end of the playing track.
          await Future<void>.delayed(const Duration(milliseconds: 800));
          await _extendWave();
        }
      }
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
    _runtimeErrorHandler = null;
    _fallbackDownloadToken?.cancel('Player disposed');
    _offlineLyrics.close();
    await _playbackErrorSubscription?.cancel();
    await _noisySubscription?.cancel();
    await _favoritesSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _errorController.close();
    await _trackController.close();
    await _sourceController.close();
    await _queueController.close();
    equalizer.dispose();
    await _player.dispose();
    _resolver.dispose();
  }
}
