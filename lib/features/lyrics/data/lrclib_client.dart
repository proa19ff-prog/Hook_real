import 'package:dio/dio.dart';
import 'package:hook/core/constants/api_constants.dart';
import '../domain/lrc_parser.dart';
import '../domain/lyric_line.dart';

class LyricsResult {
  final String? plainLyrics;
  final String? syncedLyrics;
  final List<LyricLine> lines;

  const LyricsResult({
    this.plainLyrics,
    this.syncedLyrics,
    this.lines = const [],
  });

  bool get hasSynced => lines.isNotEmpty;
  bool get isEmpty =>
      !hasSynced && (plainLyrics == null || plainLyrics!.isEmpty);
}

class LrclibClient {
  final Dio _dio;
  final Map<String, LyricsResult> _memoryCache = {};

  LrclibClient({Dio? dio}) : _dio = dio ?? Dio();

  String _cacheKey(String track, String artist) =>
      '${track.trim().toLowerCase()}::${artist.trim().toLowerCase()}';

  static String cleanTrackTitle(String rawTitle, String rawArtist) {
    var title = rawTitle;

    // 1. If title starts with "Artist - ", strip it
    final artistPattern =
        RegExp('^${RegExp.escape(rawArtist)}\\s*-\\s*', caseSensitive: false);
    title = title.replaceAll(artistPattern, '');

    // 2. If title contains " - ", and first part matches artist
    if (title.contains(' - ')) {
      final parts = title.split(' - ');
      if (parts.length >= 2 &&
          parts[0].trim().toLowerCase() == rawArtist.trim().toLowerCase()) {
        title = parts.sublist(1).join(' - ');
      }
    }

    // 3. Strip common noise tags
    final noise = [
      RegExp(r'[\(\[]\s*official\s*(music)?\s*(video|audio|clip)?\s*[\)\]]',
          caseSensitive: false),
      RegExp(r'[\(\[]\s*lyrics?\s*(video)?\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*audio\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*video\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*ncs\s*(release)?\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*free\s*(download)?\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*out\s*now\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*hd\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*4k\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*feat(\.|\s+)?\s*.*?[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*ft(\.|\s+)?\s*.*?[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*prod(\.|\s+by)?\s*.*?[\)\]]', caseSensitive: false),
    ];

    for (final reg in noise) {
      title = title.replaceAll(reg, '');
    }

    return title.trim();
  }

  /// Fetches synchronized lyrics for a track, trying multiple matching strategies.
  Future<LyricsResult?> fetchLyrics({
    required String trackName,
    required String artistName,
    Duration? duration,
  }) async {
    final key = _cacheKey(trackName, artistName);
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    final cleanTitle = cleanTrackTitle(trackName, artistName);

    try {
      // 1. Try exact match with cleaned title
      var result = await _tryGet(
        trackName: cleanTitle.isNotEmpty ? cleanTitle : trackName,
        artistName: artistName,
        duration: duration,
      );
      if (result != null && !result.isEmpty) {
        _memoryCache[key] = result;
        return result;
      }

      // 2. Try exact match with original title if different
      if (cleanTitle != trackName) {
        result = await _tryGet(
          trackName: trackName,
          artistName: artistName,
          duration: duration,
        );
        if (result != null && !result.isEmpty) {
          _memoryCache[key] = result;
          return result;
        }
      }

      // 3. Fallback to fuzzy search endpoint with clean title
      result = await _trySearch(
        query: cleanTitle.isNotEmpty
            ? '$cleanTitle $artistName'
            : '$trackName $artistName',
      );
      if (result != null && !result.isEmpty) {
        _memoryCache[key] = result;
        return result;
      }

      // 4. Fallback to search with just the clean title
      if (cleanTitle.isNotEmpty && cleanTitle != trackName) {
        result = await _trySearch(query: cleanTitle);
        if (result != null && !result.isEmpty) {
          _memoryCache[key] = result;
          return result;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<LyricsResult?> _tryGet({
    required String trackName,
    required String artistName,
    Duration? duration,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'track_name': trackName,
        'artist_name': artistName,
      };
      if (duration != null && duration.inSeconds > 0) {
        queryParams['duration'] = duration.inSeconds;
      }

      final res = await _dio.get(
        '${ApiConstants.lrclibBaseUrl}/get',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'User-Agent': 'Hook-Music-Player/1.0 (https://github.com/hook)'
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (res.statusCode == 200 && res.data != null) {
        final synced = res.data['syncedLyrics'] as String?;
        final plain = res.data['plainLyrics'] as String?;
        final lines = synced != null && synced.isNotEmpty
            ? LrcParser.parse(synced)
            : (plain != null && plain.isNotEmpty
                ? LrcParser.synthesizeFromPlainText(
                    plain,
                    duration ?? const Duration(minutes: 3),
                  )
                : <LyricLine>[]);
        return LyricsResult(
          plainLyrics: plain,
          syncedLyrics: synced,
          lines: lines,
        );
      }
    } catch (_) {}
    return null;
  }

  Future<LyricsResult?> _trySearch({required String query}) async {
    try {
      final searchRes = await _dio.get(
        '${ApiConstants.lrclibBaseUrl}/search',
        queryParameters: {'q': query},
        options: Options(
          headers: {
            'User-Agent': 'Hook-Music-Player/1.0 (https://github.com/hook)'
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (searchRes.statusCode == 200 &&
          searchRes.data is List &&
          (searchRes.data as List).isNotEmpty) {
        // Prefer an item that has syncedLyrics
        final list = searchRes.data as List;
        Map<String, dynamic>? bestMatch;
        for (final item in list) {
          if (item is Map<String, dynamic> &&
              item['syncedLyrics'] != null &&
              (item['syncedLyrics'] as String).isNotEmpty) {
            bestMatch = item;
            break;
          }
        }
        bestMatch ??= list.first as Map<String, dynamic>;

        final synced = bestMatch['syncedLyrics'] as String?;
        final plain = bestMatch['plainLyrics'] as String?;
        final lines = synced != null && synced.isNotEmpty
            ? LrcParser.parse(synced)
            : (plain != null && plain.isNotEmpty
                ? LrcParser.synthesizeFromPlainText(
                    plain,
                    const Duration(minutes: 3),
                  )
                : <LyricLine>[]);
        return LyricsResult(
          plainLyrics: plain,
          syncedLyrics: synced,
          lines: lines,
        );
      }
    } catch (_) {}
    return null;
  }
}
