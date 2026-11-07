import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../data/audio_player_service.dart';
import 'player_state_provider.dart';

/// Lifecycle of one track's offline copy, kept in the audio cache.
enum TrackDownloadStatus { notDownloaded, downloading, downloaded, failed }

class TrackDownloadState {
  final TrackDownloadStatus status;

  /// 0..1 while [TrackDownloadStatus.downloading].
  final double progress;

  /// Bitrate reported by the source for the chosen stream, when known.
  final int? bitrateKbps;

  const TrackDownloadState({
    this.status = TrackDownloadStatus.notDownloaded,
    this.progress = 0,
    this.bitrateKbps,
  });
}

/// Tracks offline downloads across all screens: the track sheet, the player
/// header and the row badges all watch the same map, keyed per track.
class TrackDownloadsNotifier
    extends StateNotifier<Map<String, TrackDownloadState>> {
  TrackDownloadsNotifier({
    required this.downloadTrackFn,
    required this.cacheChecker,
    required this.cacheRemover,
  }) : super(const {});

  final Future<File?> Function(
    MediaTrack track, {
    void Function(double progress)? onProgress,
    void Function(int? bitrateKbps)? onResolved,
  })
  downloadTrackFn;
  final Future<bool> Function(String cacheKey) cacheChecker;
  final Future<void> Function(String cacheKey) cacheRemover;

  /// Same cache-key convention as [AudioPlayerService] itself.
  static String keyOf(MediaTrack track) =>
      '${track.source.name}_${track.id}';

  final Map<String, int> _generations = {};

  void _patch(String key, TrackDownloadState next) {
    if (!mounted) return;
    state = {...state, key: next};
  }

  /// Syncs the badge with what is actually on disk; a download in flight is
  /// never overwritten by a stale disk check.
  Future<void> refresh(MediaTrack track) async {
    final key = keyOf(track);
    if (state[key]?.status == TrackDownloadStatus.downloading) return;
    try {
      final cached = await cacheChecker(key);
      final current = state[key];
      if (current?.status == TrackDownloadStatus.downloading) return;
      _patch(
        key,
        TrackDownloadState(
          status: cached
              ? TrackDownloadStatus.downloaded
              : TrackDownloadStatus.notDownloaded,
          bitrateKbps: current?.bitrateKbps,
        ),
      );
    } catch (_) {
      // An unknown disk state must not flip the visible badge to "failed".
    }
  }

  Future<void> download(MediaTrack track) async {
    final key = keyOf(track);
    if (track.source == TrackSource.local) {
      _patch(key, const TrackDownloadState(
        status: TrackDownloadStatus.downloaded,
      ));
      return;
    }
    if (state[key]?.status == TrackDownloadStatus.downloading) return;
    final generation = (_generations[key] ?? 0) + 1;
    _generations[key] = generation;
    _patch(key, const TrackDownloadState(
      status: TrackDownloadStatus.downloading,
    ));
    var bitrate = state[key]?.bitrateKbps;
    try {
      final file = await downloadTrackFn(
        track,
        onProgress: (progress) {
          if ((_generations[key] ?? 0) != generation) return;
          _patch(
            key,
            TrackDownloadState(
              status: TrackDownloadStatus.downloading,
              progress: progress,
              bitrateKbps: bitrate,
            ),
          );
        },
        onResolved: (bitrateKbps) => bitrate = bitrateKbps,
      );
      if ((_generations[key] ?? 0) != generation) return;
      _patch(
        key,
        TrackDownloadState(
          status: file == null
              ? TrackDownloadStatus.failed
              : TrackDownloadStatus.downloaded,
          progress: file == null ? 0 : 1,
          bitrateKbps: bitrate,
        ),
      );
    } catch (_) {
      if ((_generations[key] ?? 0) != generation) return;
      _patch(key, const TrackDownloadState(
        status: TrackDownloadStatus.failed,
      ));
    }
  }

  Future<void> remove(MediaTrack track) async {
    final key = keyOf(track);
    if (state[key]?.status == TrackDownloadStatus.downloading) return;
    _generations[key] = (_generations[key] ?? 0) + 1;
    try {
      await cacheRemover(key);
    } catch (_) {
      // The badge follows the intent; a stubborn file is handled by cache UI.
    }
    _patch(key, const TrackDownloadState(
      status: TrackDownloadStatus.notDownloaded,
    ));
  }
}

final trackDownloadsProvider =
    StateNotifierProvider<TrackDownloadsNotifier, Map<String, TrackDownloadState>>(
        (ref) {
  final service = ref.watch(audioPlayerServiceProvider);
  final cache = ref.watch(audioCacheManagerProvider);
  return TrackDownloadsNotifier(
    downloadTrackFn: service.downloadTrack,
    cacheChecker: cache.isTrackCached,
    cacheRemover: cache.removeCachedTrack,
  );
});
