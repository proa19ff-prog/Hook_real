import 'dart:async';

import '../domain/lrc_parser.dart';
import 'lrclib_client.dart';
import 'netease_lyrics_source.dart';
import 'lyrics_disk_cache.dart';
import 'lyrics_result.dart';

export 'lyrics_result.dart';

/// Finds lyrics in this order: word-synced (NetEase YRC), line-synced
/// (LRCLIB, then NetEase LRC; words are timed by estimate), plain text.
/// Both providers are queried in parallel; either may be unreachable.
class LyricsClient {
  final NeteaseLyricsSource _netease;
  final LrclibSource _lrclib;
  final Map<String, LyricsResult?> _cache = {};
  final LyricsDiskCache _diskCache;

  LyricsClient({
    NeteaseLyricsSource? netease,
    LrclibSource? lrclib,
    LyricsDiskCache? diskCache,
  }) : _netease = netease ?? NeteaseLyricsSource(),
       _lrclib = lrclib ?? LrclibSource(),
       _diskCache = diskCache ?? LyricsDiskCache();

  static final _noise = [
    RegExp(
      r'[\(\[]\s*(official\s*)?(music\s*)?(video|audio|clip|visualizer)\s*[\)\]]',
      caseSensitive: false,
    ),
    RegExp(
      r'[\(\[]\s*(lyrics?|lyric video|текст)\s*[\)\]]',
      caseSensitive: false,
    ),
    RegExp(
      r'[\(\[]\s*(hd|hq|4k|ncs( release)?|free (dl|download)|out now)\s*[\)\]]',
      caseSensitive: false,
    ),
    RegExp(r'[\(\[]\s*(feat|ft|prod)\b.*?[\)\]]', caseSensitive: false),
    RegExp(r'\s(feat|ft)\.?\s.*$', caseSensitive: false),
  ];

  /// Strips "Artist - " prefixes and upload noise from SoundCloud-style titles.
  static String cleanTrackTitle(String rawTitle, String rawArtist) {
    var title = rawTitle
        .replaceAll('"', '')
        .replaceAll('«', '')
        .replaceAll('»', '');
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
    String? trackKey,
  }) async {
    final metadataKey =
        '${trackName.trim().toLowerCase()}::${artistName.trim().toLowerCase()}::${duration?.inMilliseconds ?? 0}';
    final key = trackKey == null ? metadataKey : '$trackKey::$metadataKey';
    if (_cache.containsKey(key)) return _cache[key];
    if (_cache.length >= 100) _cache.remove(_cache.keys.first);
    final saved = await _diskCache.read(key);
    if (saved != null) return _cache[key] = saved;

    Future<LyricsResult> remember(LyricsResult result) async {
      _cache[key] = result;
      await _diskCache.write(key, result);
      return result;
    }

    final cleaned = cleanTrackTitle(trackName, artistName);
    final title = cleaned.isNotEmpty ? cleaned : trackName;
    final known = duration != null && duration > Duration.zero
        ? duration
        : null;

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
      if (lines.isNotEmpty && !LrcParser.looksUnsynced(lines)) {
        return remember(
          LyricsResult(lines: lines, isRealSync: true, hasWordSync: true),
        );
      }
    }

    final lrclib = await lrclibFuture;
    for (final synced in [lrclib?.synced, netease?.lrc]) {
      if (synced == null || synced.trim().isEmpty) continue;
      final lines = LrcParser.parse(synced);
      if (lines.isEmpty || LrcParser.looksUnsynced(lines)) continue;
      return remember(
        LyricsResult(
          plainLyrics: lrclib?.plain,
          lines: lines,
          isRealSync: true,
          hasWordSync: lines.every(
            (line) =>
                line.hasRealWordTimings &&
                line.backingVocals.every(
                  (backing) => backing.hasRealWordTimings,
                ),
          ),
        ),
      );
    }

    final plain = lrclib?.plain ?? _plainFromLrc(netease?.lrc);
    if (plain != null && plain.trim().isNotEmpty) {
      return remember(
        LyricsResult(
          plainLyrics: plain,
          lines: LrcParser.synthesizeFromPlainText(
            plain,
            known ?? const Duration(minutes: 3),
          ),
        ),
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
