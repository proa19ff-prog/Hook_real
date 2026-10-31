class LyricWord {
  final String text;
  final Duration startTime;
  final Duration endTime;

  const LyricWord({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  bool isActiveAt(Duration position) {
    return position >= startTime && position < endTime;
  }
}

class LyricLine {
  final Duration startTime;
  final Duration? endTime;
  final String text;
  final List<LyricWord> words;

  /// True when [words] carry real per-word timestamps (NetEase YRC or
  /// `<mm:ss.xx>` LRC tags). False when they were estimated from the line
  /// timing, so the UI draws a softer, less precise sweep.
  final bool hasRealWordTimings;

  const LyricLine({
    required this.startTime,
    this.endTime,
    required this.text,
    this.words = const [],
    this.hasRealWordTimings = false,
  });

  bool get hasWordTimings => words.isNotEmpty;

  /// When the singer finishes this line. A long gap before the next line
  /// after this point is an instrumental break.
  Duration get vocalEnd =>
      words.isNotEmpty ? words.last.endTime : (endTime ?? startTime);

  bool isActiveAt(Duration position) {
    if (endTime != null) {
      return position >= startTime && position < endTime!;
    }
    return position >= startTime;
  }
}
