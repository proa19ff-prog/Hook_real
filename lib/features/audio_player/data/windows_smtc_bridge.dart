import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'audio_player_service.dart';

/// Mirrors Hook's playback into Windows System Media Transport Controls so
/// the taskbar media flyout, hardware media keys and the lock screen drive
/// the app exactly like the Android notification does.
class WindowsSmtcBridge {
  WindowsSmtcBridge(this._service, this._smtc) {
    _subscriptions = [
      _service.mediaItem.listen(_onMediaItem),
      _service.playbackState.listen(_onPlaybackState),
      _smtc.buttonPressStream.listen(_onButton),
    ];
    // SMTC interpolates progress from an anchor timestamp; refreshing once a
    // second keeps the seek bar honest across pauses and seeks.
    _positionTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncTimeline(),
    );
  }

  final AudioPlayerService _service;
  final SMTCWindows _smtc;
  late final List<StreamSubscription<void>> _subscriptions;
  late final Timer _positionTimer;

  void _onMediaItem(MediaItem? item) {
    if (item == null) return;
    _smtc.updateMetadata(
      MusicMetadata(
        title: item.title,
        artist: item.artist,
        album: item.album,
        thumbnail: item.artUri?.toString(),
      ),
    );
  }

  void _onPlaybackState(PlaybackState state) {
    _smtc.setPlaybackStatus(
      state.playing ? PlaybackStatus.playing : PlaybackStatus.paused,
    );
  }

  void _onButton(PressedButton button) {
    switch (button) {
      case PressedButton.play:
        _service.play();
      case PressedButton.pause:
        _service.pause();
      case PressedButton.next:
        _service.skipToNext();
      case PressedButton.previous:
        _service.skipToPrevious();
      case PressedButton.stop:
        _service.pause();
      default:
        break;
    }
  }

  void _syncTimeline() {
    final player = _service.rawPlayer;
    final duration = player.duration;
    if (duration == null || duration <= Duration.zero) return;
    final position = player.position;
    final anchor = DateTime.now().subtract(position).millisecondsSinceEpoch;
    _smtc.updateTimeline(
      PlaybackTimeline(
        positionMs: position.inMilliseconds,
        startTimeMs: anchor,
        endTimeMs: anchor + duration.inMilliseconds,
      ),
    );
  }

  Future<void> dispose() async {
    _positionTimer.cancel();
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
  }
}
