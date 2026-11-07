import '../domain/lyric_line.dart';

class LyricsResult {
  final String? plainLyrics;
  final List<LyricLine> lines;

  /// False for estimated timings synthesized from plain text.
  final bool isRealSync;
  final bool hasWordSync;

  /// Duration of the exact record the synced timings came from. YouTube
  /// reuploads often carry an intro the canonical timing does not know
  /// about: playing duration minus this value is the intro length the
  /// karaoke view can compensate for automatically.
  final int? sourceDurationMs;

  const LyricsResult({
    this.plainLyrics,
    this.lines = const [],
    this.isRealSync = false,
    this.hasWordSync = false,
    this.sourceDurationMs,
  });

  bool get hasSynced => lines.isNotEmpty;
  bool get isEmpty =>
      !hasSynced && (plainLyrics == null || plainLyrics!.isEmpty);

  Map<String, dynamic> toJson() => {
    'plainLyrics': plainLyrics,
    'isRealSync': isRealSync,
    'hasWordSync': hasWordSync,
    if (sourceDurationMs != null) 'sourceDurationMs': sourceDurationMs,
    'lines': lines.map(_lineToJson).toList(),
  };

  factory LyricsResult.fromJson(Map<String, dynamic> json) => LyricsResult(
    plainLyrics: json['plainLyrics'] as String?,
    isRealSync: json['isRealSync'] == true,
    hasWordSync: json['hasWordSync'] == true,
    sourceDurationMs: (json['sourceDurationMs'] as num?)?.toInt(),
    lines: (json['lines'] as List? ?? [])
        .map((value) => _lineFromJson(Map<String, dynamic>.from(value as Map)))
        .toList(),
  );

  /// The intro compensation the playing version needs, or null when there is
  /// nothing sane to compensate: the playing audio is longer than the record
  /// the timings were matched against by a plausible intro length (2–40 s).
  static double? autoIntroOffsetSeconds({
    required bool isRealSync,
    required int? sourceDurationMs,
    required Duration? playingDuration,
  }) {
    if (!isRealSync || sourceDurationMs == null || sourceDurationMs <= 0) {
      return null;
    }
    if (playingDuration == null || playingDuration <= Duration.zero) {
      return null;
    }
    final introMs = playingDuration.inMilliseconds - sourceDurationMs;
    if (introMs < 2000 || introMs > 40000) return null;
    return -(introMs / 1000).roundToDouble();
  }

  static Map<String, dynamic> _lineToJson(LyricLine line) => {
    'text': line.text,
    'startUs': line.startTime.inMicroseconds,
    'endUs': line.endTime?.inMicroseconds,
    'hasRealWordTimings': line.hasRealWordTimings,
    'singer': line.singer,
    'placement': line.placement.name,
    'isBacking': line.isBacking,
    'words': line.words
        .map(
          (word) => {
            'text': word.text,
            'startUs': word.startTime.inMicroseconds,
            'endUs': word.endTime.inMicroseconds,
          },
        )
        .toList(),
    'backingVocals': line.backingVocals.map(_lineToJson).toList(),
  };

  static LyricLine _lineFromJson(Map<String, dynamic> json) => LyricLine(
    text: json['text'] as String,
    startTime: Duration(microseconds: (json['startUs'] as num).toInt()),
    endTime: json['endUs'] == null
        ? null
        : Duration(microseconds: (json['endUs'] as num).toInt()),
    hasRealWordTimings: json['hasRealWordTimings'] == true,
    singer: json['singer'] as String?,
    placement: LyricPlacement.values.firstWhere(
      (value) => value.name == json['placement'],
      orElse: () => LyricPlacement.left,
    ),
    isBacking: json['isBacking'] == true,
    words: (json['words'] as List? ?? []).map((value) {
      final word = value as Map;
      return LyricWord(
        text: word['text'] as String,
        startTime: Duration(microseconds: (word['startUs'] as num).toInt()),
        endTime: Duration(microseconds: (word['endUs'] as num).toInt()),
      );
    }).toList(),
    backingVocals: (json['backingVocals'] as List? ?? [])
        .map((value) => _lineFromJson(Map<String, dynamic>.from(value as Map)))
        .toList(),
  );
}
