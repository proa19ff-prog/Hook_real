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

  /// Fetches synchronized lyrics for a track, first trying exact match,
  /// then falling back to fuzzy query search.
  Future<LyricsResult?> fetchLyrics({
    required String trackName,
    required String artistName,
    Duration? duration,
  }) async {
    final key = _cacheKey(trackName, artistName);
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key];
    }

    try {
      // 1. Try exact match API
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

        final lines = synced != null ? LrcParser.parse(synced) : <LyricLine>[];
        final result = LyricsResult(
          plainLyrics: plain,
          syncedLyrics: synced,
          lines: lines,
        );

        _memoryCache[key] = result;
        return result;
      }

      // 2. Fallback to search endpoint
      final searchRes = await _dio.get(
        '${ApiConstants.lrclibBaseUrl}/search',
        queryParameters: {'q': '$trackName $artistName'},
        options: Options(
          headers: {'User-Agent': 'Hook-Music-Player/1.0'},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (searchRes.statusCode == 200 &&
          searchRes.data is List &&
          (searchRes.data as List).isNotEmpty) {
        final firstMatch =
            (searchRes.data as List).first as Map<String, dynamic>;
        final synced = firstMatch['syncedLyrics'] as String?;
        final plain = firstMatch['plainLyrics'] as String?;

        final lines = synced != null ? LrcParser.parse(synced) : <LyricLine>[];
        final result = LyricsResult(
          plainLyrics: plain,
          syncedLyrics: synced,
          lines: lines,
        );

        _memoryCache[key] = result;
        return result;
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
