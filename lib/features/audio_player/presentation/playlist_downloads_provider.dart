import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extractor/models/media_track.dart';
import 'track_downloads_provider.dart';

class PlaylistDownloadState {
  const PlaylistDownloadState({
    this.total = 0,
    this.done = 0,
    this.failed = 0,
    this.running = false,
  });

  final int total;
  final int done;
  final int failed;
  final bool running;

  /// 0..1, or null when idle.
  double? get progress =>
      total == 0 || !running ? null : (done + failed) / total;

  PlaylistDownloadState copyWith({
    int? total,
    int? done,
    int? failed,
    bool? running,
  }) {
    return PlaylistDownloadState(
      total: total ?? this.total,
      done: done ?? this.done,
      failed: failed ?? this.failed,
      running: running ?? this.running,
    );
  }
}

/// Downloads a whole playlist track by track, reusing the per-track
/// download pipeline (candidates chain, cache, progress). One playlist at
/// a time; per-track states stay visible in the usual download rows.
class PlaylistDownloadsNotifier extends StateNotifier<PlaylistDownloadState> {
  PlaylistDownloadsNotifier(this._ref) : super(const PlaylistDownloadState());

  final Ref _ref;
  int _generation = 0;

  Future<void> downloadAll(List<MediaTrack> tracks) async {
    if (state.running || tracks.isEmpty) return;
    final generation = ++_generation;
    state = PlaylistDownloadState(total: tracks.length, running: true);
    final downloads = _ref.read(trackDownloadsProvider.notifier);
    for (final track in tracks) {
      if (generation != _generation) return;
      try {
        await downloads.download(track);
      } catch (_) {
        state = state.copyWith(failed: state.failed + 1);
        continue;
      }
      state = state.copyWith(done: state.done + 1);
    }
    if (generation != _generation) return;
    state = state.copyWith(running: false);
  }

  void cancel() {
    _generation++;
    state = const PlaylistDownloadState();
  }
}

final playlistDownloadsProvider =
    StateNotifierProvider<PlaylistDownloadsNotifier, PlaylistDownloadState>(
        (ref) {
  return PlaylistDownloadsNotifier(ref);
});
