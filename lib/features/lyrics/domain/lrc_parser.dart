import 'dart:math' as math;

import 'lyric_line.dart';

class LrcParser {
  static final RegExp _timeTag = RegExp(
    r'\[(\d{1,3}):(\d{1,2})(?:[.:](\d{1,3}))?\]',
  );
  static final RegExp _wordTokenRegex = RegExp(
    r'<(\d{1,3}):(\d{1,2})[.:](\d{1,3})>([^<]*)',
  );
  static final RegExp _yrcLine = RegExp(r'^\[(\d+),(\d+)\](.*)$');
  static final RegExp _yrcToken = RegExp(r'\((\d+),(\d+),-?\d+\)');
  static final RegExp _credit = RegExp(
    r'^\s*(作词|作曲|编曲|制作人|制作|混音|母带|和声|监制|出品|发行|录音|吉他|贝斯|鼓|弦乐|策划|统筹|词|曲|op|sp)\s*[:：]',
    caseSensitive: false,
  );
  static final RegExp _vowelGroup = RegExp(
    r'[aeiouyаеёиоуыэюяàáâäéèêëíîïóôöúûüœæ]+',
  );
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

    final entries = <_VocalEntry>[];
    final placements = <String, LyricPlacement>{};
    _VocalMarkup section = const _VocalMarkup('');

    for (final rawLine in rawLrc.split('\n')) {
      var rest = rawLine.trim();
      final starts = <Duration>[];
      while (true) {
        final m = _timeTag.matchAsPrefix(rest);
        if (m == null) break;
        starts.add(_time(m.group(1)!, m.group(2)!, m.group(3)));
        rest = rest.substring(m.end);
      }
      if (starts.isEmpty) {
        final marker = _markup(rest.trim(), placements);
        if (marker.text.isEmpty && marker.singer != null) section = marker;
        continue;
      }

      final inlineBacking = <String>[];
      final body = rest.trim().replaceAllMapped(
        RegExp(r'\[bg:(.*?)\]', caseSensitive: false),
        (match) {
          inlineBacking.add(match.group(1)!);
          return '';
        },
      );
      final markup = _markup(body, placements, section: section);
      for (final start in starts) {
        final shift = start - starts.first;
        entries.add(_enhancedEntry(markup, start, shift, placements));
        for (final backing in inlineBacking) {
          final part = _markup(backing, placements, section: markup);
          final entry = _enhancedEntry(
            part,
            start,
            shift,
            placements,
            backing: true,
          );
          entries.add(entry);
        }
      }
    }

    entries.sort((a, b) => a.start.compareTo(b.start));

    final result = <LyricLine>[];
    for (var i = 0; i < entries.length; i++) {
      final current = entries[i];
      if (current.text.isEmpty || _isCredit(current.text)) continue;

      Duration? nextStart;
      for (var j = i + 1; j < entries.length; j++) {
        final next = entries[j];
        if (next.start > current.start &&
            next.isBacking == current.isBacking &&
            (current.words.isEmpty ||
                next.singer == current.singer ||
                next.text.isEmpty)) {
          nextStart = next.start;
          break;
        }
      }

      var words = current.words;
      final hasReal = words.isNotEmpty;
      if (hasReal && !current.hasExplicitEnd) {
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
      } else if (!hasReal) {
        words = estimateWords(current.text, current.start, nextStart);
      }
      final endTime = hasReal
          ? words.fold(current.start, (end, w) => _maxDuration(end, w.endTime))
          : nextStart ??
                _maxDuration(
                  current.start + const Duration(seconds: 5),
                  words.isNotEmpty ? words.last.endTime : current.start,
                );
      result.addAll(
        _splitTimedBacking(
          LyricLine(
            startTime: current.start,
            endTime: endTime,
            text: current.text,
            words: words,
            hasRealWordTimings: hasReal,
            singer: current.singer,
            placement: current.placement,
            isBacking: current.isBacking,
          ),
        ),
      );
    }

    return _groupBacking(result);
  }

  /// Parses NetEase YRC: `[lineStart,lineDur](wordStart,wordDur,0)word...`,
  /// all in milliseconds. Every word carries its own sung time.
  static List<LyricLine> parseYrc(String rawYrc) {
    final parsed = <LyricLine>[];
    final placements = <String, LyricPlacement>{};

    for (final rawLine in rawYrc.split('\n')) {
      final m = _yrcLine.firstMatch(rawLine.trim());
      if (m == null) continue;
      final lineStart = Duration(milliseconds: int.parse(m.group(1)!));
      final lineDur = Duration(milliseconds: int.parse(m.group(2)!));
      final marker = _markup(m.group(3)!, placements);
      final body = marker.text;

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
        words.add(
          LyricWord(text: text, startTime: start, endTime: start + dur),
        );
      }

      final rawText = words.map((w) => w.text).join();
      final content = _markup(rawText, placements, section: marker);
      if (content.text.isEmpty || _isCredit(content.text)) continue;
      final cleanWords = _trimWordPrefix(
        words,
        rawText.length - content.text.length,
      );
      parsed.addAll(
        _splitTimedBacking(
          LyricLine(
            startTime: lineStart,
            endTime: _maxDuration(
              lineStart + lineDur,
              cleanWords.fold(
                lineStart,
                (end, w) => _maxDuration(end, w.endTime),
              ),
            ),
            text: content.text.trim(),
            words: cleanWords,
            hasRealWordTimings: true,
            singer: content.singer,
            placement: content.placement,
            isBacking: content.isBacking,
          ),
        ),
      );
    }

    return _groupBacking(parsed);
  }

  static _VocalMarkup _markup(
    String raw,
    Map<String, LyricPlacement> placements, {
    _VocalMarkup? section,
  }) {
    var text = raw.trimLeft();
    var singer = section?.singer;
    var placement = section?.placement ?? LyricPlacement.left;
    var backing = section?.isBacking ?? false;
    final marker = RegExp(
      r'^(?:\[(v\d+|both|duet|bg|background)\]|(v\d+|both|duet|bg|background)\s*[:：]|\[(?:voice|singer)\s*:\s*([^\]]+)\])\s*',
      caseSensitive: false,
    );
    while (true) {
      final match = marker.firstMatch(text);
      if (match == null) break;
      final name = (match.group(1) ?? match.group(2) ?? match.group(3)!).trim();
      final key = name.toLowerCase();
      if (key == 'bg' || key == 'background') {
        backing = true;
      } else {
        singer = name;
        placement = switch (key) {
          'v1' => LyricPlacement.left,
          'v2' => LyricPlacement.right,
          'both' || 'duet' => LyricPlacement.center,
          _ => placements.putIfAbsent(
            key,
            () => placements.length.isEven
                ? LyricPlacement.left
                : LyricPlacement.right,
          ),
        };
      }
      text = text.substring(match.end);
    }
    return _VocalMarkup(
      text,
      singer: singer,
      placement: placement,
      isBacking: backing,
    );
  }

  static _VocalEntry _enhancedEntry(
    _VocalMarkup markup,
    Duration lineStart,
    Duration shift,
    Map<String, LyricPlacement> placements, {
    bool backing = false,
  }) {
    final matches = _wordTokenRegex.allMatches(markup.text).toList();
    final words = <LyricWord>[];
    for (var i = 0; i < matches.length; i++) {
      final match = matches[i];
      final start =
          _time(match.group(1)!, match.group(2)!, match.group(3)) + shift;
      final text = match.group(4)!;
      final end = i + 1 < matches.length
          ? _time(
                  matches[i + 1].group(1)!,
                  matches[i + 1].group(2)!,
                  matches[i + 1].group(3),
                ) +
                shift
          : start + const Duration(milliseconds: 600);
      if (text.trim().isEmpty || end <= start) continue;
      words.add(LyricWord(text: text, startTime: start, endTime: end));
    }
    final rawText = matches.isEmpty
        ? markup.text
        : words.map((w) => w.text).join();
    final content = _markup(rawText, placements, section: markup);
    final cleanWords = _trimWordPrefix(
      words,
      rawText.length - content.text.length,
    );
    final isBacking = backing || content.isBacking;
    return _VocalEntry(
      start: isBacking && cleanWords.isNotEmpty
          ? cleanWords.first.startTime
          : lineStart,
      text: content.text.trim(),
      words: cleanWords,
      hasExplicitEnd:
          matches.isNotEmpty && matches.last.group(4)!.trim().isEmpty,
      singer: content.singer,
      placement: content.placement,
      isBacking: isBacking,
    );
  }

  static List<LyricWord> _trimWordPrefix(List<LyricWord> words, int count) {
    final clean = <LyricWord>[];
    for (final word in words) {
      if (count >= word.text.length) {
        count -= word.text.length;
        continue;
      }
      clean.add(
        LyricWord(
          text: word.text.substring(count),
          startTime: word.startTime,
          endTime: word.endTime,
        ),
      );
      count = 0;
    }
    return clean;
  }

  static List<LyricLine> _splitTimedBacking(LyricLine line) {
    if (!line.hasRealWordTimings || line.isBacking) return [line];
    final lead = <LyricWord>[];
    final backing = <LyricLine>[];
    for (var i = 0; i < line.words.length; i++) {
      final word = line.words[i];
      if (!word.text.trimLeft().startsWith('(')) {
        lead.add(word);
        continue;
      }
      var last = i;
      while (last < line.words.length &&
          !line.words[last].text.trimRight().endsWith(')')) {
        last++;
      }
      if (last >= line.words.length) {
        lead.add(word);
        continue;
      }
      final words = <LyricWord>[];
      for (var j = i; j <= last; j++) {
        var text = line.words[j].text;
        if (j == i) text = text.replaceFirst('(', '');
        if (j == last) text = text.replaceFirst(RegExp(r'\)\s*$'), '');
        if (text.isNotEmpty) {
          words.add(
            LyricWord(
              text: text,
              startTime: line.words[j].startTime,
              endTime: line.words[j].endTime,
            ),
          );
        }
      }
      if (words.isNotEmpty) {
        backing.add(
          LyricLine(
            startTime: words.first.startTime,
            endTime: words.last.endTime,
            text: words.map((w) => w.text).join().trim(),
            words: words,
            hasRealWordTimings: true,
            singer: line.singer,
            placement: line.placement,
            isBacking: true,
          ),
        );
      }
      i = last;
    }
    if (backing.isEmpty) return [line];
    return [
      if (lead.isNotEmpty)
        LyricLine(
          startTime: line.startTime,
          endTime: line.endTime,
          text: lead.map((w) => w.text).join().trim(),
          words: lead,
          hasRealWordTimings: true,
          singer: line.singer,
          placement: line.placement,
        ),
      ...backing,
    ];
  }

  static List<LyricLine> _groupBacking(List<LyricLine> lines) {
    lines.sort((a, b) => a.startTime.compareTo(b.startTime));
    final leads = lines.where((line) => !line.isBacking).toList();
    final orphaned = <LyricLine>[];
    final backing = <int, List<LyricLine>>{};
    for (final line in lines.where((line) => line.isBacking)) {
      var best = -1;
      for (var i = 0; i < leads.length; i++) {
        final lead = leads[i];
        if (lead.startTime > line.startTime) break;
        if ((lead.endTime ?? lead.vocalEnd) > line.startTime) {
          if (best < 0 ||
              lead.singer == line.singer ||
              leads[best].singer != line.singer) {
            best = i;
          }
        }
      }
      if (best < 0) {
        orphaned.add(line);
      } else {
        backing
            .putIfAbsent(best, () => [])
            .add(
              line.singer == null
                  ? line.copyWith(
                      singer: leads[best].singer,
                      placement: leads[best].placement,
                    )
                  : line,
            );
      }
    }
    final grouped = [
      for (var i = 0; i < leads.length; i++)
        leads[i].copyWith(backingVocals: backing[i] ?? const []),
      ...orphaned,
    ];
    grouped.sort((a, b) => a.startTime.compareTo(b.startTime));
    return grouped;
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

    final estimateMs = (totalWeight - 0.8) * _msPerSyllable + _lineTailMs;
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
      words.add(
        LyricWord(
          text: i < tokens.length - 1 ? '${tokens[i]} ' : tokens[i],
          startTime: Duration(milliseconds: wordStart),
          endTime: Duration(milliseconds: cursor.round()),
        ),
      );
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

    final lineIntervalMs = (totalMs / rawLines.length).round().clamp(
      2000,
      6000,
    );
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

class _VocalMarkup {
  final String text;
  final String? singer;
  final LyricPlacement placement;
  final bool isBacking;

  const _VocalMarkup(
    this.text, {
    this.singer,
    this.placement = LyricPlacement.left,
    this.isBacking = false,
  });
}

class _VocalEntry {
  final Duration start;
  final String text;
  final List<LyricWord> words;
  final bool hasExplicitEnd;
  final String? singer;
  final LyricPlacement placement;
  final bool isBacking;

  const _VocalEntry({
    required this.start,
    required this.text,
    required this.words,
    required this.hasExplicitEnd,
    required this.singer,
    required this.placement,
    required this.isBacking,
  });
}
