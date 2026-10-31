import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/domain/lrc_parser.dart';

void main() {
  test('LrcParser synthesizes animated word timings for lines without explicit tokens', () {
    const rawLrc = '''
[00:10.00]Hello world from karaoke
[00:15.00]Second line of song
''';

    final lines = LrcParser.parse(rawLrc);
    expect(lines.length, 2);
    expect(lines[0].words.isNotEmpty, isTrue);
    expect(lines[0].words.length, 4); // "Hello", "world", "from", "karaoke"
    expect(lines[0].words[0].text.trim(), 'Hello');
    expect(lines[0].words[0].startTime, const Duration(seconds: 10));
    // The sweep ends with the estimated singing, not at the next line.
    expect(lines[0].words.last.endTime, greaterThan(const Duration(seconds: 11)));
    expect(lines[0].words.last.endTime,
        lessThanOrEqualTo(const Duration(seconds: 15)));
  });

  test('LrcParser synthesizes progressive lines from plain unsynced text', () {
    const plainText = '''
First line of my song
Second verse coming through
Final line to remember
''';

    final lines = LrcParser.synthesizeFromPlainText(
      plainText,
      const Duration(minutes: 1),
    );

    expect(lines.length, 3);
    expect(lines[0].words.isNotEmpty, isTrue);
    expect(lines[0].startTime, greaterThanOrEqualTo(Duration.zero));
    expect(lines[2].endTime, greaterThan(lines[1].startTime));
  });
}
