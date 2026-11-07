import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/audio_player/presentation/track_downloads_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';

MediaTrack _track([String id = 't1']) => MediaTrack(
      id: id,
      title: 'Song $id',
      artist: 'Artist',
      duration: const Duration(minutes: 3),
      artworkUrl: '',
      source: TrackSource.youtubeMusic,
    );

class _FakeApi {
  final Map<String, bool> disk = {};
  final List<double> progressValues = [];
  int? resolvedBitrate;
  bool failDownload = false;

  Future<File?> download(
    MediaTrack track, {
    void Function(double progress)? onProgress,
    void Function(int? bitrateKbps)? onResolved,
  }) async {
    // Yield like a real network transfer would, so the download is genuinely
    // in flight when the test inspects the notifier.
    await Future<void>.delayed(Duration.zero);
    onResolved?.call(resolvedBitrate);
    for (final progress in const [0.25, 0.5, 1.0]) {
      onProgress?.call(progress);
    }
    if (failDownload) return null;
    disk[TrackDownloadsNotifier.keyOf(track)] = true;
    return File('cached.m4a');
  }

  Future<bool> check(String cacheKey) async => disk[cacheKey] ?? false;

  Future<void> remove(String cacheKey) async {
    disk.remove(cacheKey);
  }
}

void main() {
  test('download reports progress and lands on downloaded', () async {
    final api = _FakeApi()..resolvedBitrate = 160;
    final notifier = TrackDownloadsNotifier(
      downloadTrackFn: api.download,
      cacheChecker: api.check,
      cacheRemover: api.remove,
    );
    addTearDown(notifier.dispose);

    final future = notifier.download(_track());
    expect(
      notifier.state[TrackDownloadsNotifier.keyOf(_track())]!.status,
      TrackDownloadStatus.downloading,
    );
    await future;

    final state = notifier.state[TrackDownloadsNotifier.keyOf(_track())]!;
    expect(state.status, TrackDownloadStatus.downloaded);
    expect(state.progress, 1);
    expect(state.bitrateKbps, 160);
  });

  test('failed download flips to failed and refresh recovers the badge',
      () async {
    final api = _FakeApi()..failDownload = true;
    final notifier = TrackDownloadsNotifier(
      downloadTrackFn: api.download,
      cacheChecker: api.check,
      cacheRemover: api.remove,
    );
    addTearDown(notifier.dispose);

    await notifier.download(_track());
    final key = TrackDownloadsNotifier.keyOf(_track());
    expect(notifier.state[key]!.status, TrackDownloadStatus.failed);

    // Once the file is really on disk, the badge trusts the disk again.
    api.disk[key] = true;
    await notifier.refresh(_track());
    expect(notifier.state[key]!.status, TrackDownloadStatus.downloaded);
  });

  test('remove resets to notDownloaded', () async {
    final api = _FakeApi();
    final notifier = TrackDownloadsNotifier(
      downloadTrackFn: api.download,
      cacheChecker: api.check,
      cacheRemover: api.remove,
    );
    addTearDown(notifier.dispose);

    await notifier.download(_track());
    await notifier.remove(_track());
    expect(
      notifier.state[TrackDownloadsNotifier.keyOf(_track())]!.status,
      TrackDownloadStatus.notDownloaded,
    );
  });

  test('a download in flight is not overwritten by a refresh', () async {
    final api = _FakeApi();
    final notifier = TrackDownloadsNotifier(
      downloadTrackFn: api.download,
      cacheChecker: api.check,
      cacheRemover: api.remove,
    );
    addTearDown(notifier.dispose);

    final key = TrackDownloadsNotifier.keyOf(_track());
    final pending = notifier.download(_track());
    await notifier.refresh(_track());
    expect(notifier.state[key]!.status, TrackDownloadStatus.downloading);
    await pending;
    expect(notifier.state[key]!.status, TrackDownloadStatus.downloaded);
  });
}
