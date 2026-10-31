import 'dart:math' as math;

import 'lyric_line.dart';

class LrcParser {
  static final RegExp _timeTag =
      RegExp(r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]');
  static final RegExp _wordTokenRegex =
      RegExp(r'<(\d{1,3}):(\d{1,2})[.:](\d{1,3})>([^<]*)');
  static final RegExp _yrcLine = RegExp(r'^\[(\d+),(\d+)\](.*)$');
  static final RegExp _yrcToken = RegExp(r'\((\d+),(\d+),-?\d+\)');
  static final RegExp _credit = RegExp(
    r'^\s*(作词|作曲|编曲|制作人|制作|混音|母带|和声|监制|出品|发行|录音|吉他|贝斯|鼓|弦乐|策划|统筹|词|曲|op|sp)\s*[:：]',
    caseSensitive: false,
  );
  static final RegExp _vowelGroup =
      RegExp(r'[aeiouyаеёиоуыэюяàáâäéèêëíîïóôöúûüœæ]+');
  static final RegExp _spaces = RegExp(r'\s+');

  /// Average sung syllable, plus a short tail for the last note.
  static const _msPerSyllable = 270;
  static const _lineTailMs = 350;

  static Duration _time(String min, String sec, String? frac) {
    var ms = 0;
    if (frac != null && frac.isNotEmpty) {
      ms = int.parse(frac);
      if (frac.length == 1) ms *= 100;
      if (frac.length == 2) ms *= 10;
    }
    return Duration(
      minutes: int.parse(min),
      seconds: int.parse(sec),
      milliseconds: ms,
    );
  }

  /// Credits ("作词 : ...") and NetEase's instrumental marker are not lyrics.
  static bool _isCredit(String text) =>
      _credit.hasMatch(text) || text.contains('纯音乐');

  /// Parses LRC lyrics, including enhanced `<mm:ss.xx>` word tags and lines
  /// with several timestamps. Empty timed lines are not shown, but they still
  /// mark where the previous line's singing ends.
  static List<LyricLine> parse(String rawLrc) {
    if (rawLrc.trim().isEmpty) return [];

    final entries = <({Duration start, String text, List<LyricWord> words})>[];

    for (final rawLine in rawLrc.split('\n')) {
      var rest = rawLine.trim();
      final starts = <Duration>[];
      while (true) {
        final m = _timeTag.matchAsPrefix(rest);
        if (m == null) break;
        starts.add(_time(m.group(1)!, m.group(2)!, m.group(3)));
        rest = rest.substring(m.end);
      }
      if (starts.isEmpty) continue;

      final body = rest.trim();
      final wordMatches = _wordTokenRegex.allMatches(body).toList();
      final words = <LyricWord>[];
      var text = body;

      if (wordMatches.isNotEmpty) {
        final buffer = StringBuffer();
        for (var i = 0; i < wordMatches.length; i++) {
          final m = wordMatches[i];
          final start = _time(m.group(1)!, m.group(2)!, m.group(3));
          final wordText = m.group(4) ?? '';
          buffer.write(wordText);
          // The last word's end is fixed up once the next line is known.
          final end = i + 1 < wordMatches.length
              ? _time(wordMatches[i + 1].group(1)!,
                  wordMatches[i + 1].group(2)!, wordMatches[i + 1].group(3))
              : start + const Duration(milliseconds: 600);
          if (wordText.isEmpty) continue;
          words.add(LyricWord(text: wordText, startTime: start, endTime: end));
        }
        text = buffer.toString().trim();
      }

      for (final start in starts) {
        entries.add((start: start, text: text, words: words));
      }
    }

    entries.sort((a, b) => a.start.compareTo(b.start));

    final result = <LyricLine>[];
    for (var i = 0; i < entries.length; i++) {
      final current = entries[i];
      if (current.text.isEmpty || _isCredit(current.text)) continue;

      Duration? nextStart;
      for (var j = i + 1; j < entries.length; j++) {
        if (entries[j].start > current.start) {
          nextStart = entries[j].start;
          break;
        }
      }

      var words = current.words;
      final hasReal = words.isNotEmpty;
      if (hasReal) {
        final last = words.last;
        final cap = last.startTime + const Duration(milliseconds: 1500);
        var end = nextStart ?? cap;
        if (end > cap) end = cap;
        if (end <= last.startTime) {
          end = last.startTime + const Duration(milliseconds: 200);
        }
        words = [
          ...words.take(words.length - 1),
          LyricWord(text: last.text, startTime: last.startTime, endTime: end),
        ];
      } else {
        words = estimateWords(current.text, current.start, nextStart);
      }

      final endTime = nextStart ??
          _maxDuration(
            current.start + const Duration(seconds: 5),
            words.isNotEmpty ? words.last.endTime : current.start,
          );

      result.add(
        LyricLine(
          startTime: current.start,
          endTime: endTime,
          text: current.text,
          words: words,
          hasRealWordTimings: hasReal,
        ),
      );
    }

    return result;
  }

  /// Parses NetEase YRC: `[lineStart,lineDur](wordStart,wordDur,0)word...`,
  /// all in milliseconds. Every word carries its own sung time.
  static List<LyricLine> parseYrc(String rawYrc) {
    final parsed = <LyricLine>[];

    for (final rawLine in rawYrc.split('\n')) {
      final m = _yrcLine.firstMatch(rawLine.trim());
      if (m == null) continue;
      final lineStart = Duration(milliseconds: int.parse(m.group(1)!));
      final lineDur = Duration(milliseconds: int.parse(m.group(2)!));
      final body = m.group(3)!;

      final tokens = _yrcToken.allMatches(body).toList();
      if (tokens.isEmpty) continue;

      final words = <LyricWord>[];
      for (var j = 0; j < tokens.length; j++) {
        final t = tokens[j];
        final end = j + 1 < tokens.length ? tokens[j + 1].start : body.length;
        final text = body.substring(t.end, end);
        if (text.isEmpty) continue;
        final start = Duration(milliseconds: int.parse(t.group(1)!));
        final dur = Duration(milliseconds: int.parse(t.group(2)!));
        words.add(LyricWord(text: text, startTime: start, endTime: start + dur));
      }

      final text = words.map((w) => w.text).join().trim();
      if (text.isEmpty || _isCredit(text)) continue;

      parsed.add(LyricLine(
        startTime: lineStart,
        endTime: lineStart + lineDur,
        text: text,
        words: words,
        hasRealWordTimings: true,
      ));
    }

    parsed.sort((a, b) => a.startTime.compareTo(b.startTime));

    return [
      for (var i = 0; i < parsed.length; i++)
        LyricLine(
          startTime: parsed[i].startTime,
          endTime: i + 1 < parsed.length &&
                  parsed[i + 1].startTime > parsed[i].startTime
              ? parsed[i + 1].startTime
              : parsed[i].endTime,
          text: parsed[i].text,
          words: parsed[i].words,
          hasRealWordTimings: true,
        ),
    ];
  }

  /// True when every line has the same timestamp: the text is not synced.
  static bool looksUnsynced(List<LyricLine> lines) =>
      lines.length >= 3 &&
      lines.every((l) => l.startTime == lines.first.startTime);

  static Duration _maxDuration(Duration a, Duration b) => a > b ? a : b;

  static int _syllables(String word) =>
      math.max(1, _vowelGroup.allMatches(word.toLowerCase()).length);

  /// Estimates when each word is sung from line-level timing alone. The line
  /// takes about [_msPerSyllable] per syllable, so the highlight finishes with
  /// the singer instead of crawling through the instrumental gap that often
  /// follows. Words share that time by syllable count; the last one is held.
  static List<LyricWord> estimateWords(
    String text,
    Duration start,
    Duration? nextStart,
  ) {
    final tokens = text.split(_spaces).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return const [];

    final weights = [for (final t in tokens) _syllables(t).toDouble()];
    weights[weights.length - 1] += 0.8;
    final totalWeight = weights.fold<double>(0, (a, b) => a + b);

    final estimateMs =
        (totalWeight - 0.8) * _msPerSyllable + _lineTailMs;
    var sungMs = estimateMs * 1.15;
    if (nextStart != null) {
      final gapMs = (nextStart - start).inMilliseconds;
      if (gapMs <= 0) return const [];
      sungMs = math.min(sungMs, gapMs * 0.94);
    }
    sungMs = math.max(sungMs, 300.0);

    final words = <LyricWord>[];
    var cursor = start.inMilliseconds.toDouble();
    for (var i = 0; i < tokens.length; i++) {
      final len = sungMs * weights[i] / totalWeight;
      final wordStart = cursor.round();
      cursor += len;
      words.add(LyricWord(
        text: i < tokens.length - 1 ? '${tokens[i]} ' : tokens[i],
        startTime: Duration(milliseconds: wordStart),
        endTime: Duration(milliseconds: cursor.round()),
      ));
    }
    return words;
  }

  /// Spreads unsynced plain lyrics over the track. These timings are guesses,
  /// so the UI shows such lyrics as static text.
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

    const startOffsetMs = 6000;
    final totalMs = totalDuration.inMilliseconds > 25000
        ? totalDuration.inMilliseconds - 15000
        : totalDuration.inMilliseconds;

    final lineIntervalMs =
        (totalMs / rawLines.length).round().clamp(2000, 6000);
    final result = <LyricLine>[];

    var currentLineStart = startOffsetMs;
    for (final text in rawLines) {
      final lineStart = Duration(milliseconds: currentLineStart);
      final lineEnd = Duration(milliseconds: currentLineStart + lineIntervalMs);
      result.add(
        LyricLine(
          startTime: lineStart,
          endTime: lineEnd,
          text: text,
          words: estimateWords(text, lineStart, lineEnd),
        ),
      );
      currentLineStart += lineIntervalMs;
    }

    return result;
  }
}
