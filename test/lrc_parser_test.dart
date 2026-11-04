import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/data/lyrics_match.dart';
import 'package:hook/features/lyrics/domain/lrc_parser.dart';

void main() {
  test('parses and sorts synchronized lyric lines', () {
    final lines = LrcParser.parse('''
[00:05.50]Second line
[00:01.25]First line
''');

    expect(lines, hasLength(2));
    expect(lines.first.text, 'First line');
    expect(lines.first.startTime, const Duration(milliseconds: 1250));
    expect(lines.first.endTime, const Duration(milliseconds: 5500));
  });

  test('parses word-level timestamps', () {
    final lines = LrcParser.parse('[00:01.00]<00:01.00>Hello <00:01.40>world');

    expect(lines.single.text, 'Hello world');
    expect(lines.single.words, hasLength(2));
    expect(
      lines.single.words.first.endTime,
      const Duration(milliseconds: 1400),
    );
  });

  test('marks lines without word tags as NOT real word timings', () {
    final lines = LrcParser.parse('[00:05.50]Second line\n[00:01.25]First');

    // Words may still be synthesized as data, but the karaoke UI must not
    // animate fake per-word timelines.
    for (final line in lines) {
      expect(line.hasRealWordTimings, isFalse);
    }
    expect(
      LrcParser.parse('[00:01.00]<00:01.20>Hola').single.hasRealWordTimings,
      isTrue,
    );
  });

  test('synthesizeFromPlainText produces unsynced lines', () {
    final lines = LrcParser.synthesizeFromPlainText(
      'Line one\nLine two',
      const Duration(minutes: 3),
    );

    expect(lines, isNotEmpty);
    for (final line in lines) {
      expect(line.hasRealWordTimings, isFalse);
    }
  });

  test('parseYrc reads per-word timings', () {
    final lines = LrcParser.parseYrc(
      '{"t":0,"c":[{"tx":"credits"}]}\n'
      '[1000,2000](1000,500,0)All (1500,700,0)I (2200,800,0)am\n'
      '[4000,1000](4000,1000,0)Next',
    );

    expect(lines, hasLength(2));
    expect(lines[0].hasRealWordTimings, isTrue);
    expect(lines[0].text, 'All I am');
    expect(lines[0].words[1].startTime, const Duration(milliseconds: 1500));
    expect(lines[0].words[1].endTime, const Duration(milliseconds: 2200));
    expect(lines[0].endTime, const Duration(milliseconds: 3000));
  });

  test('parse skips credits and keeps multi-timestamp lines', () {
    final lines = LrcParser.parse(
      '[00:00.00] 作词 : Someone\n[00:10.00][00:30.00]Chorus\n[00:20.00]Verse',
    );
    expect(lines.map((l) => l.text), ['Chorus', 'Verse', 'Chorus']);
    expect(lines.last.startTime, const Duration(seconds: 30));
  });

  test('estimated words finish before a long instrumental gap', () {
    final words = LrcParser.estimateWords(
      'short line',
      Duration.zero,
      const Duration(seconds: 20),
    );
    expect(words.last.endTime, lessThan(const Duration(seconds: 3)));
  });

  test('LyricsMatch rejects remixes and other songs', () {
    double? score(String title, String artist, int sec) => LyricsMatch.score(
      wantTitle: 'Sweater Weather',
      wantArtist: 'The Neighbourhood',
      wantDuration: const Duration(seconds: 240),
      title: title,
      artists: [artist],
      duration: Duration(seconds: sec),
    );

    expect(score('Sweater Weather', 'The Neighbourhood', 240), isNotNull);
    expect(score('Sweater Weather (Remix)', 'The Neighbourhood', 238), isNull);
    expect(score('Sweater Weather', 'The Neighbourhood', 300), isNull);
    expect(score('Daddy Issues', 'The Neighbourhood', 240), isNull);
  });

  test('LyricsMatch handles Cyrillic and stylized artist names', () {
    expect(
      LyricsMatch.score(
        wantTitle: 'ДИНАСТИЯ',
        wantArtist: 'VILLIAN & madk1d',
        title: 'Династия',
        artists: ['MADKID'],
      ),
      isNotNull,
    );
  });
}
