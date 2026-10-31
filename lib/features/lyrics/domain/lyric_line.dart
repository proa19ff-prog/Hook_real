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

  /// True only when [words] came from real `<mm:ss.xx>` word-level LRC tags.
  /// Synthesized (invented) timelines must not drive word karaoke, otherwise
  /// the highlight visibly runs ahead of or behind the actual singing.
  final bool hasRealWordTimings;

  const LyricLine({
    required this.startTime,
    this.endTime,
    required this.text,
    this.words = const [],
    this.hasRealWordTimings = false,
  });

  bool get hasWordTimings => words.isNotEmpty;

  bool isActiveAt(Duration position) {
    if (endTime != null) {
      return position >= startTime && position < endTime!;
    }
    return position >= startTime;
  }
}
