import 'lyric_line.dart';

class LrcParser {
  static final RegExp _lineRegex =
      RegExp(r'^\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)$');
  static final RegExp _wordTokenRegex =
      RegExp(r'<(\d{2}):(\d{2})\.(\d{2,3})>([^<]*)');

  /// Parses raw LRC formatted lyrics into a structured list of [LyricLine]
  static List<LyricLine> parse(String rawLrc) {
    if (rawLrc.trim().isEmpty) return [];

    final rawLines = rawLrc.split('\n');
    final parsedLines = <LyricLine>[];

    for (final line in rawLines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final match = _lineRegex.firstMatch(trimmed);
      if (match == null) continue;

      final minutes = int.parse(match.group(1)!);
      final seconds = int.parse(match.group(2)!);
      final rawMillis = match.group(3)!;
      final millis = rawMillis.length == 2
          ? int.parse(rawMillis) * 10
          : int.parse(rawMillis);

      final lineStartTime = Duration(
        minutes: minutes,
        seconds: seconds,
        milliseconds: millis,
      );

      final lineBody = match.group(4)!.trim();

      // Check if line contains word-level tags: <mm:ss.xx>word
      final wordMatches = _wordTokenRegex.allMatches(lineBody).toList();
      final words = <LyricWord>[];
      var cleanLineText = lineBody;

      if (wordMatches.isNotEmpty) {
        final textBuffer = StringBuffer();

        for (int i = 0; i < wordMatches.length; i++) {
          final wMatch = wordMatches[i];
          final wMin = int.parse(wMatch.group(1)!);
          final wSec = int.parse(wMatch.group(2)!);
          final wRawMs = wMatch.group(3)!;
          final wMs =
              wRawMs.length == 2 ? int.parse(wRawMs) * 10 : int.parse(wRawMs);

          final wStart = Duration(
            minutes: wMin,
            seconds: wSec,
            milliseconds: wMs,
          );

          final wText = wMatch.group(4) ?? '';
          textBuffer.write(wText);

          // Calculate end time using next word's start time if available
          Duration wEnd = wStart + const Duration(milliseconds: 400);
          if (i + 1 < wordMatches.length) {
            final nextMatch = wordMatches[i + 1];
            final nMin = int.parse(nextMatch.group(1)!);
            final nSec = int.parse(nextMatch.group(2)!);
            final nRawMs = nextMatch.group(3)!;
            final nMs =
                nRawMs.length == 2 ? int.parse(nRawMs) * 10 : int.parse(nRawMs);

            wEnd = Duration(minutes: nMin, seconds: nSec, milliseconds: nMs);
          }

          words.add(
            LyricWord(
              text: wText,
              startTime: wStart,
              endTime: wEnd,
            ),
          );
        }

        cleanLineText = textBuffer.toString().trim();
      }

      parsedLines.add(
        LyricLine(
          startTime: lineStartTime,
          text: cleanLineText,
          words: words,
        ),
      );
    }

    // Sort chronologically
    parsedLines.sort((a, b) => a.startTime.compareTo(b.startTime));

    // Calculate line end times based on the next line's start time
    final result = <LyricLine>[];
    for (int i = 0; i < parsedLines.length; i++) {
      final current = parsedLines[i];
      final next = i + 1 < parsedLines.length ? parsedLines[i + 1] : null;

      result.add(
        LyricLine(
          startTime: current.startTime,
          endTime: next?.startTime ??
              (current.startTime + const Duration(seconds: 5)),
          text: current.text,
          words: current.words,
        ),
      );
    }

    return result;
  }
}
