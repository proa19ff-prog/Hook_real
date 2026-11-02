/// Bounded retrieval variants for Cyrillic phonetics, transliteration and
/// accidental keyboard layout. Ranking alone cannot find a record a provider
/// never returned, so these variants are sent to the providers as well.
class SearchQueryNormalizer {
  static const _aliases = <String, String>{
    'мартин роуз': 'martin rose',
    'мартин роз': 'martin rose',
    'пост малон': 'post malone',
    'свей ли': 'swae lee',
    'санфлауэр': 'sunflower',
    'санфловер': 'sunflower',
    'алан волкер': 'alan walker',
    'алан уокер': 'alan walker',
    'фейдед': 'faded',
    'зе викенд': 'the weeknd',
    'викнд': 'the weeknd',
    'викенд': 'the weeknd',
    'блайндинг лайтс': 'blinding lights',
    'линкин парк': 'linkin park',
    'ин зе энд': 'in the end',
    'билли айлиш': 'billie eilish',
    'эминем': 'eminem',
    'квин': 'queen',
    'имеджин драгонс': 'imagine dragons',
    'имаджин драгонс': 'imagine dragons',
    'белавер': 'believer',
    'радиохед': 'radiohead',
    'крип': 'creep',
    'нирвана': 'nirvana',
    'колдплей': 'coldplay',
    'фонк': 'phonk',
  };
  static const _latin =
      "qwertyuiop[]asdfghjkl;'zxcvbnm,.`QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>~";
  static const _russian =
      'йцукенгшщзхъфывапролджэячсмитьбюёЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮЁ';
  static const _letters = <String, String>{
    'а': 'a',
    'б': 'b',
    'в': 'v',
    'г': 'g',
    'д': 'd',
    'е': 'e',
    'ё': 'yo',
    'ж': 'zh',
    'з': 'z',
    'и': 'i',
    'й': 'y',
    'к': 'k',
    'л': 'l',
    'м': 'm',
    'н': 'n',
    'о': 'o',
    'п': 'p',
    'р': 'r',
    'с': 's',
    'т': 't',
    'у': 'u',
    'ф': 'f',
    'х': 'kh',
    'ц': 'ts',
    'ч': 'ch',
    'ш': 'sh',
    'щ': 'shch',
    'ъ': '',
    'ы': 'y',
    'ь': '',
    'э': 'e',
    'ю': 'yu',
    'я': 'ya',
  };

  static String normalize(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static String fixKeyboardLayout(String input) {
    final output = StringBuffer();
    for (final code in input.runes) {
      final char = String.fromCharCode(code);
      final ru = _russian.indexOf(char);
      final en = _latin.indexOf(char);
      output.write(ru >= 0 ? _latin[ru] : (en >= 0 ? _russian[en] : char));
    }
    return output.toString();
  }

  static String transliterate(String input) => input
      .toLowerCase()
      .split('')
      .map((char) => _letters[char] ?? char)
      .join();

  static String _expandAliases(String input) {
    var result = input;
    final entries = _aliases.entries.toList()
      ..sort((a, b) => b.key.length.compareTo(a.key.length));
    for (final entry in entries) {
      final pattern = RegExp(
        '(^|[^\\p{L}\\p{N}])${RegExp.escape(entry.key)}(?=\$|[^\\p{L}\\p{N}])',
        unicode: true,
      );
      result = result.replaceAllMapped(pattern, (m) => '${m[1]}${entry.value}');
    }
    return result;
  }

  static List<String> variants(String query) {
    final original = normalize(query);
    if (original.isEmpty) return const [];
    final result = <String>{original};
    void add(String value) {
      final normalized = normalize(value);
      if (normalized.isNotEmpty) result.add(normalized);
    }

    final alias = _expandAliases(original);
    add(alias);
    add(transliterate(alias));
    const styled = {'madkid': 'madk1d', 'madk1d': 'madkid'};
    for (final entry in styled.entries) {
      add(original.replaceAll(RegExp('\\b${entry.key}\\b'), entry.value));
    }
    final layout = fixKeyboardLayout(original);
    // An identified layout slip is more useful than literal transliteration of
    // gibberish. The literal layout remains the final, low-priority fallback.
    add(_expandAliases(layout));
    add(layout);
    return result.take(5).toList(growable: false);
  }
}
