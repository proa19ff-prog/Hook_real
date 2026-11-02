enum LyricsDisplayMode {
  lines,
  karaoke,
  focus;

  String get label => switch (this) {
        lines => 'Строки',
        karaoke => 'Караоке',
        focus => 'Фокус',
      };

  String get description => switch (this) {
        lines => 'Спокойный текст, подсветка текущей строки',
        karaoke => 'Плавная подсветка слов в ритме вокала',
        focus => 'Одна крупная строка. Ничего лишнего',
      };

  String get assetPath => 'assets/animations/lyrics_$name.json';

  static LyricsDisplayMode fromName(String? value) => values.firstWhere(
        (mode) => mode.name == value,
        orElse: () => karaoke,
      );
}
