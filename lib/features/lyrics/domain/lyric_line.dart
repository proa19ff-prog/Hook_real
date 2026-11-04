enum LyricPlacement { left, right, center }

class LyricWord {
  final String text;
  final Duration startTime;
  final Duration endTime;

  const LyricWord({
    required this.text,
    required this.startTime,
    required this.endTime,
  });

  bool isActiveAt(Duration position) =>
      position >= startTime && position < endTime;
}

class LyricLine {
  final Duration startTime;
  final Duration? endTime;
  final String text;
  final List<LyricWord> words;
  final bool hasRealWordTimings;
  final String? singer;
  final LyricPlacement placement;
  final bool isBacking;
  final List<LyricLine> backingVocals;

  const LyricLine({
    required this.startTime,
    this.endTime,
    required this.text,
    this.words = const [],
    this.hasRealWordTimings = false,
    this.singer,
    this.placement = LyricPlacement.left,
    this.isBacking = false,
    this.backingVocals = const [],
  });

  bool get hasWordTimings => words.isNotEmpty;

  Duration get vocalEnd => words.isNotEmpty
      ? words.fold(
          startTime,
          (end, word) => word.endTime > end ? word.endTime : end,
        )
      : (endTime ?? startTime);

  Duration get groupEnd => backingVocals.fold(
    endTime ?? vocalEnd,
    (end, line) => line.groupEnd > end ? line.groupEnd : end,
  );

  bool isActiveAt(Duration position) =>
      position >= startTime && (endTime == null || position < endTime!);

  LyricLine copyWith({
    List<LyricLine>? backingVocals,
    String? singer,
    LyricPlacement? placement,
  }) => LyricLine(
    startTime: startTime,
    endTime: endTime,
    text: text,
    words: words,
    hasRealWordTimings: hasRealWordTimings,
    singer: singer ?? this.singer,
    placement: placement ?? this.placement,
    isBacking: isBacking,
    backingVocals: backingVocals ?? this.backingVocals,
  );
}
