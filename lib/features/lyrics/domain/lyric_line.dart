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

  const LyricLine({
    required this.startTime,
    this.endTime,
    required this.text,
    this.words = const [],
  });

  bool get hasWordTimings => words.isNotEmpty;

  bool isActiveAt(Duration position) {
    if (endTime != null) {
      return position >= startTime && position < endTime!;
    }
    return position >= startTime;
  }
}
