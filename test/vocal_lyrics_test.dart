import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/data/lrclib_client.dart';
import 'package:hook/features/lyrics/data/lyrics_client.dart';
import 'package:hook/features/lyrics/data/netease_lyrics_source.dart';
import 'package:hook/features/lyrics/domain/lrc_parser.dart';
import 'package:hook/features/lyrics/domain/lyric_line.dart';
import 'package:hook/features/lyrics/presentation/karaoke_lyrics_view.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';

const _duet = '''
[00:01.00]v1:<00:01.00>Stay <00:03.00>here<00:05.00>
[00:02.00][bg]v2:<00:02.00>Oh<00:04.00>
[00:03.00]v2:<00:03.00>With me<00:06.00>
[00:07.00][v1]Again
''';

class _NeteaseFixture extends NeteaseLyricsSource {
  final String? yrc;
  _NeteaseFixture(this.yrc);

  @override
  Future<NeteaseLyrics?> fetch({
    required String title,
    required String artist,
    Duration? duration,
  }) async => yrc == null ? null : NeteaseLyrics(yrc: yrc);
}

class _LrclibFixture extends LrclibSource {
  final LrclibLyrics result;
  _LrclibFixture(this.result);

  @override
  Future<LrclibLyrics?> fetch({
    required String title,
    required String artist,
    Duration? duration,
  }) async => result;
}

void main() {
  test('voices keep stable sides and overlapping terminal timestamps', () {
    final lines = LrcParser.parse(_duet);
    expect(lines, hasLength(3));
    expect(lines.map((line) => line.singer), ['v1', 'v2', 'v1']);
    expect(lines.map((line) => line.placement), [
      LyricPlacement.left,
      LyricPlacement.right,
      LyricPlacement.left,
    ]);
    expect(lines.first.text, 'Stay here');
    expect(lines.first.endTime, const Duration(seconds: 5));
    expect(lines[1].endTime, const Duration(seconds: 6));
    expect(lines.first.isActiveAt(const Duration(seconds: 4)), isTrue);
    expect(lines[1].isActiveAt(const Duration(seconds: 4)), isTrue);
    expect(lines.first.isActiveAt(const Duration(seconds: 5)), isFalse);
    final backing = lines.first.backingVocals.single;
    expect(backing.text, 'Oh');
    expect(backing.startTime, const Duration(seconds: 2));
    expect(backing.endTime, const Duration(seconds: 4));
    expect(backing.placement, LyricPlacement.right);
  });

  test('enhanced word tokens can contain voice and backing prefixes', () {
    final line = LrcParser.parse(
      '[00:01.00]<00:01.00>v2:Lead<00:04.00>\n'
      '[00:02.00]<00:02.00>[bg]Echo<00:05.00>',
    ).single;
    expect(line.text, 'Lead');
    expect(line.placement, LyricPlacement.right);
    expect(line.backingVocals.single.text, 'Echo');
    expect(line.backingVocals.single.placement, LyricPlacement.right);
    expect(line.isActiveAt(const Duration(milliseconds: 4500)), isFalse);
    expect(
      line.backingVocals.single.isActiveAt(const Duration(milliseconds: 4500)),
      isTrue,
    );
    expect(line.groupEnd, const Duration(seconds: 5));
  });

  test(
    'unmarked lyrics do not invent speakers or extract untimed parentheses',
    () {
      final lines = LrcParser.parse('[00:01.00]Hello (hello)\n[00:04.00]World');
      expect(lines.map((line) => line.singer), everyElement(isNull));
      expect(
        lines.map((line) => line.placement),
        everyElement(LyricPlacement.left),
      );
      expect(lines.first.text, 'Hello (hello)');
      expect(lines.first.backingVocals, isEmpty);
      expect(lines.first.hasRealWordTimings, isFalse);
    },
  );

  test('named voice sections persist, duet is centered and v2 works first', () {
    final lines = LrcParser.parse('''
[00:01.00][v2]Second voice first
[voice:Alice]
[00:02.00]One
[00:03.00]Two
[voice:Bob]
[00:04.00]Three
[00:05.00]both:Together
''');
    expect(lines.first.placement, LyricPlacement.right);
    expect(lines[1].singer, 'Alice');
    expect(lines[2].placement, lines[1].placement);
    expect(lines[3].placement, LyricPlacement.right);
    expect(lines.last.placement, LyricPlacement.center);
    expect(lines.last.text, 'Together');
  });

  test('inline explicitly timed backing has its own interval', () {
    final line = LrcParser.parse(
      '[00:01.00]v2:<00:01.00>Lead<00:05.00> [bg:<00:02.00>Echo<00:06.00>]',
    ).single;
    expect(line.text, 'Lead');
    expect(line.endTime, const Duration(seconds: 5));
    expect(line.groupEnd, const Duration(seconds: 6));
    expect(line.backingVocals.single.startTime, const Duration(seconds: 2));
    expect(line.backingVocals.single.placement, LyricPlacement.right);
  });

  test('YRC retains real overlap and strips voice prefixes within words', () {
    final lines = LrcParser.parseYrc('''
[1000,5000](1000,3000,0)v1:Lead (4000,2000,0)voice
[2000,1000](2000,1000,0)[bg]v2:Echo
[4000,4000]v2:(4000,4000,0)Second
''');
    expect(lines, hasLength(2));
    expect(lines.first.text, 'Lead voice');
    expect(lines.first.endTime, const Duration(seconds: 6));
    expect(lines.last.endTime, const Duration(seconds: 8));
    expect(lines.first.backingVocals.single.text, 'Echo');
    expect(
      lines.first.backingVocals.single.endTime,
      const Duration(seconds: 3),
    );
  });

  test('word-timed parenthetical phrases become independent backing', () {
    final line = LrcParser.parseYrc(
      '[1000,5000](1000,4000,0)Lead (2000,500,0)(oh (2500,500,0)yeah) (5000,1000,0)line',
    ).single;
    expect(line.text, 'Lead line');
    expect(line.backingVocals.single.text, 'oh yeah');
    expect(line.backingVocals.single.startTime, const Duration(seconds: 2));
    expect(line.backingVocals.single.endTime, const Duration(seconds: 3));
    expect(line.words.first.endTime, const Duration(seconds: 5));
  });

  test(
    'unclosed or mid-word parentheses are not reinterpreted as another voice',
    () {
      final lines = LrcParser.parseYrc(
        '[1000,1000](1000,1000,0)This (is a line\n[3000,1000](3000,1000,0)(Unclosed',
      );
      expect(lines, hasLength(2));
      expect(lines.every((line) => line.backingVocals.isEmpty), isTrue);
      expect(lines.first.text, 'This (is a line');
    },
  );

  test('orphan backing remains available instead of disappearing', () {
    final lines = LrcParser.parse(
      '[00:01.00][bg]<00:01.00>Echo<00:02.00>\n[00:03.00]Lead',
    );
    expect(lines, hasLength(2));
    expect(lines.first.isBacking, isTrue);
    expect(lines.first.text, 'Echo');
  });

  test('repeated enhanced lines shift their word timestamps together', () {
    final lines = LrcParser.parse(
      '[00:01.00][00:10.00]v1:<00:01.00>Hello<00:02.00>',
    );
    expect(lines, hasLength(2));
    expect(lines.last.words.single.startTime, const Duration(seconds: 10));
    expect(lines.last.words.single.endTime, const Duration(seconds: 11));
  });

  test(
    'LyricsClient delivers annotated LRC through normal source selection',
    () async {
      final client = LyricsClient(
        netease: _NeteaseFixture(null),
        lrclib: _LrclibFixture(const LrclibLyrics(synced: _duet)),
      );
      addTearDown(client.close);
      final result = await client.fetchLyrics(
        trackName: 'Fixture',
        artistName: 'Test',
      );
      expect(result!.isRealSync, isTrue);
      expect(result.lines.first.backingVocals.single.text, 'Oh');
      expect(result.lines[1].placement, LyricPlacement.right);
    },
  );

  test(
    'LyricsClient preserves a short YRC duet after grouping backing',
    () async {
      final client = LyricsClient(
        netease: _NeteaseFixture(
          '[1000,4000](1000,4000,0)v1:Lead\n[2000,1000][bg](2000,1000,0)Echo',
        ),
        lrclib: _LrclibFixture(const LrclibLyrics(plain: 'Plain fallback')),
      );
      addTearDown(client.close);
      final result = await client.fetchLyrics(
        trackName: 'Fixture',
        artistName: 'Test',
      );
      expect(result!.hasWordSync, isTrue);
      expect(result.lines.single.backingVocals.single.text, 'Echo');
    },
  );

  test('plain source still advertises no real synchronization', () async {
    final client = LyricsClient(
      netease: _NeteaseFixture(null),
      lrclib: _LrclibFixture(
        const LrclibLyrics(plain: 'No tags\nTwo voices cannot be inferred'),
      ),
    );
    addTearDown(client.close);
    final result = await client.fetchLyrics(
      trackName: 'Fixture',
      artistName: 'Test',
    );
    expect(result!.isRealSync, isFalse);
    expect(result.lines.every((line) => line.singer == null), isTrue);
  });

  testWidgets(
    'lead and backing highlight independently, seek backwards, and stay on their side',
    (tester) async {
      final clock = ValueNotifier(const Duration(milliseconds: 1500));
      addTearDown(clock.dispose);
      final line = LrcParser.parse(_duet).first;
      LyricLine? sought;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 320,
              child: VocalLyricGroup(
                line: line,
                distance: 0,
                clock: clock,
                colors: HookTheme.fromJson({}).colors,
                reduceMotion: true,
                onSeek: (part) => sought = part,
              ),
            ),
          ),
        ),
      );
      Finder part(LyricLine value) => find.byKey(
        ValueKey('vocal:${value.startTime.inMicroseconds}:${value.text}'),
      );
      bool active(LyricLine value) =>
          tester.widget<Semantics>(part(value)).properties.selected!;
      final backing = line.backingVocals.single;
      expect(active(line), isTrue);
      expect(active(backing), isFalse);
      clock.value = const Duration(milliseconds: 2500);
      await tester.pump();
      expect(active(line), isTrue);
      expect(active(backing), isTrue);
      expect(
        tester.getTopLeft(find.text('Oh')).dx,
        greaterThan(tester.getTopLeft(find.text('Stay')).dx),
      );
      expect(tester.widget<Text>(find.text('Oh')).style!.fontSize, 18);
      clock.value = const Duration(seconds: 4);
      await tester.pump();
      expect(active(line), isTrue);
      expect(active(backing), isFalse);
      clock.value = const Duration(seconds: 1);
      await tester.pump();
      expect(active(backing), isFalse);
      await tester.tap(find.text('Oh'));
      expect(sought, same(backing));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'long right-aligned lyrics and backing fit narrow large-text screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final clock = ValueNotifier(const Duration(seconds: 3));
      addTearDown(clock.dispose);
      final line = LrcParser.parse(
        '[00:01.00]v2:<00:01.00>A <00:02.00>veryveryveryveryverylongword <00:03.00>with <00:04.00>more words<00:06.00> [bg:<00:02.00>Independent echo<00:05.00>]',
      ).single;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(1.6),
                disableAnimations: true,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: VocalLyricGroup(
                    line: line,
                    distance: 0,
                    clock: clock,
                    colors: HookTheme.fromJson({}).colors,
                    reduceMotion: true,
                    onSeek: (_) {},
                    translations: {
                      line.text: 'Длинный перевод исходной строки, сохраняющий сторону исполнителя',
                      line.backingVocals.single.text: 'Независимое эхо',
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Independent echo'), findsOneWidget);
      expect(find.text('Независимое эхо'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Независимое эхо')).textAlign,
        TextAlign.right,
      );
      expect(
        tester.widget<Text>(find.text('Независимое эхо')).style!.fontSize,
        16,
      );
    },
  );
}
