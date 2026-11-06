import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/data/lyrics_client.dart';
import 'package:hook/features/lyrics/data/lyrics_disk_cache.dart';
import 'package:hook/features/lyrics/data/lrclib_client.dart';
import 'package:hook/features/lyrics/data/netease_lyrics_source.dart';
import 'package:hook/features/lyrics/domain/lyric_line.dart';

class OfflineNetease extends NeteaseLyricsSource {
  int calls = 0;
  @override
  Future<NeteaseLyrics?> fetch({
    required String title,
    required String artist,
    Duration? duration,
  }) async {
    calls++;
    return null;
  }
}

class OfflineLrclib extends LrclibSource {
  int calls = 0;
  @override
  Future<LrclibLyrics?> fetch({
    required String title,
    required String artist,
    Duration? duration,
  }) async {
    calls++;
    return null;
  }
}

const result = LyricsResult(
  plainLyrics: 'Original lyrics',
  isRealSync: true,
  hasWordSync: true,
  lines: [
    LyricLine(
      text: 'Original lyrics',
      startTime: Duration(microseconds: 1500123),
      endTime: Duration(seconds: 5),
      singer: 'Singer',
      placement: LyricPlacement.right,
      hasRealWordTimings: true,
      words: [
        LyricWord(
          text: 'Original',
          startTime: Duration(microseconds: 1500123),
          endTime: Duration(seconds: 2),
        ),
      ],
      backingVocals: [
        LyricLine(
          text: 'Oh',
          startTime: Duration(seconds: 3),
          endTime: Duration(seconds: 4),
          isBacking: true,
          hasRealWordTimings: true,
          placement: LyricPlacement.center,
          words: [
            LyricWord(
              text: 'Oh',
              startTime: Duration(seconds: 3),
              endTime: Duration(seconds: 4),
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hook_lyrics_test_');
  });
  tearDown(() async {
    await directory.delete(recursive: true);
  });

  test(
    'persists every timestamp and backing vocal exactly across cache instances',
    () async {
      await LyricsDiskCache(directory: directory)
          .write('youtubeMusic:original', result);
      final reloaded = await LyricsDiskCache(directory: directory)
          .read('youtubeMusic:original');
      expect(reloaded!.toJson(), result.toJson());
      expect(
        reloaded.lines.single.words.single.startTime.inMicroseconds,
        1500123,
      );
      expect(
        reloaded.lines.single.backingVocals.single.placement,
        LyricPlacement.center,
      );
      expect(reloaded.lines.single.singer, 'Singer');
      expect(
        (await directory.list().toList()).any(
          (file) => file.path.endsWith('.part'),
        ),
        false,
      );
    },
  );

  test('offline client reads source-qualified original lyrics without calling providers', () async {
    const key = 'youtubeMusic:original::original::artist::180000';
    final disk = LyricsDiskCache(directory: directory);
    await disk.write(key, result);
    final netease = OfflineNetease();
    final lrclib = OfflineLrclib();
    final client = LyricsClient(
      netease: netease,
      lrclib: lrclib,
      diskCache: disk,
    );
    addTearDown(client.close);
    final lyrics = await client.fetchLyrics(
      trackName: 'Original',
      artistName: 'Artist',
      duration: const Duration(minutes: 3),
      trackKey: 'youtubeMusic:original',
    );
    expect(lyrics!.toJson(), result.toJson());
    expect(netease.calls, 0);
    expect(lrclib.calls, 0);
    // Identical text metadata from a different upload must not share identity.
    expect(
      await client.fetchLyrics(
        trackName: 'Original',
        artistName: 'Artist',
        duration: const Duration(minutes: 3),
        trackKey: 'youtubeMusic:different',
      ),
      isNull,
    );
  });

  test('empty results never overwrite saved lyrics', () async {
    final disk = LyricsDiskCache(directory: directory);
    await disk.write('original', result);
    await disk.write('original', const LyricsResult());
    expect((await disk.read('original'))!.toJson(), result.toJson());
  });

  test('damaged sidecar is treated as a miss', () async {
    final disk = LyricsDiskCache(directory: directory);
    await disk.write('original', result);
    final file = (await directory.list().toList()).single as File;
    await file.writeAsString('{broken');
    expect(await disk.read('original'), isNull);
  });
}
