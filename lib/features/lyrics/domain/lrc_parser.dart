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
          hasRealWordTimings: words.isNotEmpty,
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
      final endTime = next?.startTime ??
          (current.startTime + const Duration(seconds: 5));

      var words = current.words;
      // Lines lacking word-level tags keep their (optional) synthesized word
      // list for data consumers, but `hasRealWordTimings` stays false so the
      // karaoke UI never animates fake per-word timelines.
      if (words.isEmpty && current.text.isNotEmpty) {
        words = _synthesizeWords(current.text, current.startTime, endTime);
      }

      result.add(
        LyricLine(
          startTime: current.startTime,
          endTime: endTime,
          text: current.text,
          words: words,
          hasRealWordTimings: current.hasRealWordTimings,
        ),
      );
    }

    return result;
  }

  /// Synthesizes progressive word-level timings across a line's duration.
  static List<LyricWord> _synthesizeWords(
    String text,
    Duration start,
    Duration end,
  ) {
    final tokens =
        text.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return const [];

    final totalLineMs = (end - start).inMilliseconds;
    if (totalLineMs <= 0) return const [];

    final totalChars = tokens.fold<int>(0, (sum, word) => sum + word.length);
    if (totalChars <= 0) return const [];

    final words = <LyricWord>[];
    var currentStartMs = start.inMilliseconds;

    for (int i = 0; i < tokens.length; i++) {
      final token = tokens[i];
      final isLast = i == tokens.length - 1;

      final wordMs = isLast
          ? (end.inMilliseconds - currentStartMs).clamp(50, totalLineMs)
          : ((token.length / totalChars) * totalLineMs)
              .round()
              .clamp(80, totalLineMs);

      final wEndMs = isLast ? end.inMilliseconds : (currentStartMs + wordMs);

      words.add(
        LyricWord(
          text: i < tokens.length - 1 ? '$token ' : token,
          startTime: Duration(milliseconds: currentStartMs),
          endTime: Duration(milliseconds: wEndMs),
        ),
      );

      currentStartMs = wEndMs;
    }

    return words;
  }

  /// Synthesizes progressive synchronized lines from plain unsynchronized lyrics.
  static List<LyricLine> synthesizeFromPlainText(
    String plainText,
    Duration totalDuration,
  ) {
    final rawLines = plainText
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty && !l.startsWith('[') && !l.startsWith('('))
        .toList();

    if (rawLines.isEmpty) return const [];

    final startOffsetMs = 6000;
    final totalMs = totalDuration.inMilliseconds > 25000
        ? totalDuration.inMilliseconds - 15000
        : totalDuration.inMilliseconds;

    final lineIntervalMs =
        (totalMs / rawLines.length).round().clamp(2000, 6000);
    final result = <LyricLine>[];

    var currentLineStart = startOffsetMs;
    for (int i = 0; i < rawLines.length; i++) {
      final text = rawLines[i];
      final lineStart = Duration(milliseconds: currentLineStart);
      final lineEnd =
          Duration(milliseconds: currentLineStart + lineIntervalMs);

      final words = _synthesizeWords(text, lineStart, lineEnd);
      result.add(
        LyricLine(
          startTime: lineStart,
          endTime: lineEnd,
          text: text,
          words: words,
        ),
      );

      currentLineStart += lineIntervalMs;
    }

    return result;
  }
}
