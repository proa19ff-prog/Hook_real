import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'player_state_provider.dart';

/// Sleep timer state: null end time means the timer is off.
class SleepTimerState {
  const SleepTimerState({this.endAt});

  final DateTime? endAt;

  bool get active => endAt != null && endAt!.isAfter(DateTime.now());

  Duration? get remaining =>
      active ? endAt!.difference(DateTime.now()) : null;
}

/// Counts down to an automated, faded-out pause. Session-only: a sleep
/// timer makes no sense to persist across restarts.
class SleepTimerNotifier extends StateNotifier<SleepTimerState> {
  SleepTimerNotifier(this._ref) : super(const SleepTimerState()) {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  final Ref _ref;
  late final Timer _ticker;
  bool _firing = false;

  void start(Duration duration) {
    if (duration <= Duration.zero) return;
    _firing = false;
    state = SleepTimerState(endAt: DateTime.now().add(duration));
  }

  /// "Until the track ends": the remaining time of whatever is playing.
  void startUntilTrackEnd() {
    final service = _ref.read(audioPlayerServiceProvider);
    final duration = service.rawPlayer.duration;
    if (duration == null) return;
    final left =
        duration - service.rawPlayer.position + const Duration(seconds: 2);
    start(left <= Duration.zero ? const Duration(seconds: 5) : left);
  }

  void cancel() {
    _firing = false;
    state = const SleepTimerState();
  }

  void _onTick() {
    final endAt = state.endAt;
    if (endAt == null || _firing) return;
    if (endAt.isAfter(DateTime.now())) return;
    _firing = true;
    state = const SleepTimerState();
    final service = _ref.read(audioPlayerServiceProvider);
    // A four-second slide to silence beats an abrupt cut mid-song.
    unawaited(
      service.fadeOutAndPause().catchError((_) {}).then(
            (_) => _firing = false,
          ),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }
}

final sleepTimerProvider =
    StateNotifierProvider<SleepTimerNotifier, SleepTimerState>((ref) {
  return SleepTimerNotifier(ref);
});
