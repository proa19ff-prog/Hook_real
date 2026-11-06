import '../domain/lyric_line.dart';

class LyricsResult {
  final String? plainLyrics;
  final List<LyricLine> lines;

  /// False for estimated timings synthesized from plain text.
  final bool isRealSync;
  final bool hasWordSync;

  const LyricsResult({
    this.plainLyrics,
    this.lines = const [],
    this.isRealSync = false,
    this.hasWordSync = false,
  });

  bool get hasSynced => lines.isNotEmpty;
  bool get isEmpty =>
      !hasSynced && (plainLyrics == null || plainLyrics!.isEmpty);

  Map<String, dynamic> toJson() => {
    'plainLyrics': plainLyrics,
    'isRealSync': isRealSync,
    'hasWordSync': hasWordSync,
    'lines': lines.map(_lineToJson).toList(),
  };

  factory LyricsResult.fromJson(Map<String, dynamic> json) => LyricsResult(
    plainLyrics: json['plainLyrics'] as String?,
    isRealSync: json['isRealSync'] == true,
    hasWordSync: json['hasWordSync'] == true,
    lines: (json['lines'] as List? ?? [])
        .map((value) => _lineFromJson(Map<String, dynamic>.from(value as Map)))
        .toList(),
  );

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
