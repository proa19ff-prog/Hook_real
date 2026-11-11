import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

/// Immutable snapshot of the machine's output volume.
@immutable
class SystemVolumeState {
  const SystemVolumeState({
    this.volume = 1,
    this.muted = false,
    this.supported = false,
    this.step = 0.02,
  });

  /// 0..1
  final double volume;
  final bool muted;

  /// False when the platform has no audio endpoint API (tests, Linux, web).
  final bool supported;

  /// One OS volume step — Windows uses 2%.
  final double step;

  double get effective => muted ? 0 : volume;

  SystemVolumeState copyWith({
    double? volume,
    bool? muted,
    bool? supported,
    double? step,
  }) => SystemVolumeState(
    volume: volume ?? this.volume,
    muted: muted ?? this.muted,
    supported: supported ?? this.supported,
    step: step ?? this.step,
  );

  @override
  bool operator ==(Object other) =>
      other is SystemVolumeState &&
      other.volume == volume &&
      other.muted == muted &&
      other.supported == supported &&
      other.step == step;

  @override
  int get hashCode => Object.hash(volume, muted, supported, step);
}

/// The machine's output volume, not a private in-app slider.
///
/// On Windows this is the real endpoint volume — the same level the Windows
/// mixer and the laptop's volume keys change — so the number inside Hook and
/// the number in the Windows flyout can never disagree. Where the platform
/// channel is missing the service degrades to `supported: false` and the UI
/// simply does not render the system control.
class SystemVolumeService {
  SystemVolumeService({this.readOnly = false});

  /// Widget tests have no platform channel; this keeps the surface honest.
  final bool readOnly;

  StreamSubscription<double>? _subscription;

  static bool get _platformHasEndpoint =>
      Platform.isWindows || Platform.isAndroid || Platform.isIOS;

  /// Reads the current level. Returns the untouched default when unsupported so
  /// callers can still construct a notifier synchronously.
  Future<SystemVolumeState> read() async {
    if (readOnly || !_platformHasEndpoint) {
      return const SystemVolumeState();
    }
    try {
      await FlutterVolumeController.updateShowSystemUI(false);
      final volume = await FlutterVolumeController.getVolume();
      final muted = await FlutterVolumeController.getMute();
      final level = (volume ?? 1).clamp(0.0, 1.0);
      return SystemVolumeState(
        volume: level,
        muted: muted ?? false,
        supported: true,
        step: Platform.isWindows ? 0.02 : 0.05,
      );
    } catch (_) {
      return const SystemVolumeState();
    }
  }

  /// Receives every endpoint volume change, including OS volume keys.
  Stream<double>? watch() {
    if (readOnly || !_platformHasEndpoint) return null;
    try {
      final controller = StreamController<double>.broadcast();
      _subscription = FlutterVolumeController.addListener(
        controller.add,
        emitOnStart: false,
      );
      controller.onCancel = () {
        _subscription?.cancel();
        FlutterVolumeController.removeListener();
      };
      return controller.stream;
    } catch (_) {
      return null;
    }
  }

  Future<bool> setVolume(double value) async {
    if (readOnly) return false;
    return _guard(() => FlutterVolumeController.setVolume(value.clamp(0, 1)));
  }

  Future<bool> setMuted(bool muted) async {
    if (readOnly) return false;
    return _guard(() => FlutterVolumeController.setMute(muted));
  }

  Future<bool> _guard(Future<void> Function() action) async {
    if (!_platformHasEndpoint) return false;
    try {
      await action();
      return true;
    } catch (_) {
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }
}

/// Owns the snapshot and writes back to the OS. Optimistic: the slider moves
/// immediately, then the real endpoint value arrives and reconciles.
class SystemVolumeNotifier extends StateNotifier<SystemVolumeState> {
  SystemVolumeNotifier({bool readOnly = false, SystemVolumeService? service})
    : _service = service ?? SystemVolumeService(readOnly: readOnly),
      super(const SystemVolumeState()) {
    unawaited(_bootstrap());
  }

  final SystemVolumeService _service;
  StreamSubscription<double>? _watch;

  Future<void> _bootstrap() async {
    final initial = await _service.read();
    if (!mounted) return;
    state = initial;
    _unmutedVolume = initial.volume <= 0.01 ? 1 : initial.volume;

    final changes = _service.watch();
    if (changes == null) return;
    _watch = changes.listen((value) {
      if (!mounted) return;
      final level = value.clamp(0.0, 1.0);
      if (level > 0.01) _unmutedVolume = level;
      state = state.copyWith(volume: level, muted: level <= 0.001);
    });
  }

  double _unmutedVolume = 1;

  void setVolume(double value) {
    final level = value.clamp(0.0, 1.0);
    // Mute may have been set from the Windows flyout or a laptop key, so ask
    // the state rather than only our own last action; otherwise the write
    // lands on a still-muted endpoint and the watcher puts mute back.
    final wasMuted = state.muted || _lastMuted;
    if (level > 0.01) _unmutedVolume = level;
    _lastMuted = false;
    state = state.copyWith(volume: level, muted: false);
    unawaited(_service.setVolume(level));
    if (wasMuted) unawaited(_service.setMuted(false));
  }

  bool _lastMuted = false;

  void toggleMute() {
    if (state.muted) {
      final restored = _unmutedVolume <= 0.01 ? 0.4 : _unmutedVolume;
      _lastMuted = false;
      state = state.copyWith(volume: restored, muted: false);
      unawaited(_service.setMuted(false));
      unawaited(_service.setVolume(restored));
      return;
    }
    _unmutedVolume = state.volume <= 0.01 ? 0.4 : state.volume;
    _lastMuted = true;
    state = state.copyWith(muted: true);
    unawaited(_service.setMuted(true));
  }

  /// Steps by whole OS units, like the volume keys.
  void nudge(int steps) {
    if (state.muted) {
      // Windows keeps the endpoint muted when you press volume-down; only a
      // volume-up gesture is treated as "bring the sound back".
      if (steps <= 0) return;
      toggleMute();
      return;
    }
    final stepped =
        ((state.volume + state.step * steps) / state.step).round() * state.step;
    setVolume(stepped);
  }

  @override
  void dispose() {
    _watch?.cancel();
    _service.dispose();
    super.dispose();
  }
}

final systemVolumeProvider =
    StateNotifierProvider<SystemVolumeNotifier, SystemVolumeState>(
      (ref) => SystemVolumeNotifier(),
    );
