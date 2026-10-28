import 'package:flutter_test/flutter_test.dart';
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
    final lines = LrcParser.parse(
      '[00:01.00]<00:01.00>Hello <00:01.40>world',
    );

    expect(lines.single.text, 'Hello world');
    expect(lines.single.words, hasLength(2));
    expect(
        lines.single.words.first.endTime, const Duration(milliseconds: 1400));
  });
}
