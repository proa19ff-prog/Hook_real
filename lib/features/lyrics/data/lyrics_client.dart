import 'dart:async';

import '../domain/lrc_parser.dart';
import '../domain/lyric_line.dart';
import 'lrclib_client.dart';
import 'netease_lyrics_source.dart';

class LyricsResult {
  final String? plainLyrics;
  final List<LyricLine> lines;

  /// True when [lines] carry real timestamps from a synced source. False when
  /// lines were synthesized from plain text; those timings are guesses and
  /// must not drive karaoke highlighting or auto-scroll.
  final bool isRealSync;

  /// True when every word has its own timestamp from the source.
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
}

/// Finds lyrics in this order: word-synced (NetEase YRC), line-synced
/// (LRCLIB, then NetEase LRC; words are timed by estimate), plain text.
/// Both providers are queried in parallel; either may be unreachable.
class LyricsClient {
  final NeteaseLyricsSource _netease;
  final LrclibSource _lrclib;
  final Map<String, LyricsResult?> _cache = {};

  LyricsClient({NeteaseLyricsSource? netease, LrclibSource? lrclib})
      : _netease = netease ?? NeteaseLyricsSource(),
        _lrclib = lrclib ?? LrclibSource();

  static final _noise = [
    RegExp(
        r'[\(\[]\s*(official\s*)?(music\s*)?(video|audio|clip|visualizer)\s*[\)\]]',
        caseSensitive: false),
    RegExp(r'[\(\[]\s*(lyrics?|lyric video|текст)\s*[\)\]]',
        caseSensitive: false),
    RegExp(
        r'[\(\[]\s*(hd|hq|4k|ncs( release)?|free (dl|download)|out now)\s*[\)\]]',
        caseSensitive: false),
    RegExp(r'[\(\[]\s*(feat|ft|prod)\b.*?[\)\]]', caseSensitive: false),
    RegExp(r'\s(feat|ft)\.?\s.*$', caseSensitive: false),
  ];

  /// Strips "Artist - " prefixes and upload noise from SoundCloud-style titles.
  static String cleanTrackTitle(String rawTitle, String rawArtist) {
    var title =
        rawTitle.replaceAll('"', '').replaceAll('«', '').replaceAll('»', '');
    final artist = rawArtist.trim().toLowerCase();

    if (title.contains(' - ') || title.contains(' – ')) {
      final parts = title.split(RegExp(r'\s[-–]\s'));
      final first = parts.first.trim().toLowerCase();
      if (parts.length >= 2 &&
          (first == artist ||
              artist.contains(first) ||
              first.contains(artist.split(RegExp(r'[,&]')).first.trim()))) {
        title = parts.sublist(1).join(' - ');
      }
    }

    for (final reg in _noise) {
      title = title.replaceAll(reg, '');
    }
    return title.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  Future<LyricsResult?> fetchLyrics({
    required String trackName,
    required String artistName,
    Duration? duration,
  }) async {
    final key =
        '${trackName.trim().toLowerCase()}::${artistName.trim().toLowerCase()}::${duration?.inMilliseconds ?? 0}';
    if (_cache.containsKey(key)) return _cache[key];
    if (_cache.length >= 100) _cache.remove(_cache.keys.first);

    final cleaned = cleanTrackTitle(trackName, artistName);
    final title = cleaned.isNotEmpty ? cleaned : trackName;
    final known =
        duration != null && duration > Duration.zero ? duration : null;

    final neteaseFuture = _netease
        .fetch(title: title, artist: artistName, duration: known)
        .timeout(const Duration(seconds: 12), onTimeout: () => null)
        .catchError((Object _) => null);
    final lrclibFuture = _lrclib
        .fetch(title: title, artist: artistName, duration: known)
        .timeout(const Duration(seconds: 12), onTimeout: () => null)
        .catchError((Object _) => null);

    final netease = await neteaseFuture;
    final yrc = netease?.yrc;
    if (yrc != null && yrc.trim().isNotEmpty) {
      final lines = LrcParser.parseYrc(yrc);
      if (lines.length >= 3) {
        return _cache[key] = LyricsResult(
          lines: lines,
          isRealSync: true,
          hasWordSync: true,
        );
      }
    }

    final lrclib = await lrclibFuture;
    for (final synced in [lrclib?.synced, netease?.lrc]) {
      if (synced == null || synced.trim().isEmpty) continue;
      final lines = LrcParser.parse(synced);
      if (lines.isEmpty || LrcParser.looksUnsynced(lines)) continue;
      return _cache[key] = LyricsResult(
        plainLyrics: lrclib?.plain,
        lines: lines,
        isRealSync: true,
        hasWordSync: lines.every((l) => l.hasRealWordTimings),
      );
    }

    final plain = lrclib?.plain ?? _plainFromLrc(netease?.lrc);
    if (plain != null && plain.trim().isNotEmpty) {
      return _cache[key] = LyricsResult(
        plainLyrics: plain,
        lines: LrcParser.synthesizeFromPlainText(
            plain, known ?? const Duration(minutes: 3)),
      );
    }

    // Not cached: a provider may simply have been unreachable this time.
    return null;
  }

  static String? _plainFromLrc(String? lrc) {
    if (lrc == null) return null;
    final text = lrc
        .split('\n')
        .map((l) => l.replaceAll(RegExp(r'\[[^\]]*\]'), '').trim())
        .where((l) => l.isNotEmpty && !l.startsWith('{'))
        .join('\n');
    return text.isEmpty ? null : text;
  }

  void close() {
    _netease.close();
    _lrclib.close();
  }
}
