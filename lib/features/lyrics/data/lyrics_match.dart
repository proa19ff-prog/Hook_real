/// Decides whether a lyrics record from a provider belongs to the playing
/// track. A wrong match is worse than none: lyrics from another song (or a
/// remix with a different structure) never line up with the audio.
class LyricsMatch {
  static final _brackets = RegExp(r'[\(\[\{].*?[\)\]\}]');
  static final _feat = RegExp(r'\s(feat|ft|prod)\.?\s.*$', caseSensitive: false);
  static final _nonWord = RegExp(r'[^\p{L}\p{N}\s]', unicode: true);
  static final _spaces = RegExp(r'\s+');
  static final _artistSplit =
      RegExp(r'\s*(?:,|&|\bfeat\.?|\bft\.?|\bx\b|\band\b|\bи\b)\s*', caseSensitive: false);
  static final _variant = RegExp(
    r'\b(remix|rmx|live|acoustic|instrumental|karaoke|sped|slowed|nightcore|cover|edit|mashup|remaster(?:ed)?)\b',
    caseSensitive: false,
  );

  static String norm(String s) => s
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(_brackets, ' ')
      .replaceAll(_feat, ' ')
      .replaceAll(_nonWord, ' ')
      .replaceAll(_spaces, ' ')
      .trim();

  /// Spaces dropped and stylized digits read as letters ("madk1d" = "madkid").
  static String compact(String s) => norm(s)
      .replaceAll(' ', '')
      .replaceAll('0', 'o')
      .replaceAll('1', 'i')
      .replaceAll('3', 'e')
      .replaceAll('4', 'a');

  static Set<String> variants(String s) => {
        for (final m in _variant.allMatches(s))
          m.group(1)!.toLowerCase().replaceAll('remastered', 'remaster'),
      }..remove('remaster');

  static List<String> artistParts(String artist) => artist
      .split(_artistSplit)
      .map(compact)
      .where((p) => p.length >= 2)
      .toList();

  /// Returns a match score, or null when [title]/[artists] is not the track.
  static double? score({
    required String wantTitle,
    required String wantArtist,
    Duration? wantDuration,
    required String title,
    required List<String> artists,
    Duration? duration,
  }) {
    final wt = norm(wantTitle);
    final t = norm(title);
    if (wt.isEmpty || t.isEmpty) return null;

    double s;
    if (t == wt) {
      s = 3;
    } else if (' $t '.contains(' $wt ') || ' $wt '.contains(' $t ')) {
      s = 1.5;
    } else {
      return null;
    }

    // "Song (Live)" has different timings than "Song".
    if (variants(title).difference(variants(wantTitle)).isNotEmpty) {
      return null;
    }

    final want = artistParts(wantArtist);
    final got = artists.expand(artistParts).toList();
    final artistOk = want.any(
      (w) => got.any((g) => g == w || g.contains(w) || w.contains(g)),
    );
    if (artistOk) s += 2;

    final wantSec = wantDuration?.inSeconds ?? 0;
    final gotSec = duration?.inSeconds ?? 0;
    int? diff;
    if (wantSec > 0 && gotSec > 0) {
      diff = (wantSec - gotSec).abs();
      if (diff > 20) return null;
      if (diff <= 3) {
        s += 2;
      } else if (diff <= 8) {
        s += 1;
      }
    }

    // Without the artist, only an exact title with the same length counts.
    if (!artistOk && !(t == wt && diff != null && diff <= 3)) return null;
    return s;
  }
}
