import 'package:dio/dio.dart';
import 'package:hook/core/constants/api_constants.dart';

import 'lyrics_match.dart';

class LrclibLyrics {
  final String? synced;
  final String? plain;

  const LrclibLyrics({this.synced, this.plain});

  bool get hasSynced => synced != null && synced!.trim().isNotEmpty;
  bool get isEmpty => !hasSynced && (plain == null || plain!.trim().isEmpty);
}

/// LRCLIB: community line-synced lyrics.
class LrclibSource {
  final Dio _dio;

  LrclibSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                'User-Agent': 'Hook-Music-Player/1.0 (https://github.com/hook)',
              },
            ));

  Future<LrclibLyrics?> fetch({
    required String title,
    required String artist,
    Duration? duration,
  }) async {
    // The /get endpoint fuzzy-matches server-side and happily returns a
    // different song with the same title — score its metadata locally
    // before trusting it.
    final exact = _scored(
      await _getRecord(title, artist, duration),
      wantTitle: title,
      wantArtist: artist,
      wantDuration: duration,
    );
    if (exact != null && exact.hasSynced) return exact;

    final searched = await _search(title, artist, duration);
    if (searched != null && (searched.hasSynced || exact == null)) {
      return searched;
    }
    return exact;
  }

  static LrclibLyrics? _scored(
    Map? record, {
    required String wantTitle,
    required String wantArtist,
    Duration? wantDuration,
  }) {
    if (record == null) return null;
    final score = LyricsMatch.score(
      wantTitle: wantTitle,
      wantArtist: wantArtist,
      wantDuration: wantDuration,
      title: record['trackName'] as String? ?? '',
      artists: [record['artistName'] as String? ?? ''],
      duration: Duration(
          seconds: (record['duration'] as num?)?.round() ?? 0),
    );
    if (score == null) return null;
    final lyrics = _fromRecord(record);
    return lyrics.isEmpty ? null : lyrics;
  }

  Future<Map?> _getRecord(
      String title, String artist, Duration? duration) async {
    try {
      final res = await _dio.get(
        '${ApiConstants.lrclibBaseUrl}/get',
        queryParameters: {
          'track_name': title,
          'artist_name': artist,
          if (duration != null && duration.inSeconds > 0)
            'duration': duration.inSeconds,
        },
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (res.statusCode != 200 || res.data is! Map) return null;
      return res.data as Map;
    } catch (_) {
      return null;
    }
  }

  Future<LrclibLyrics?> _search(
      String title, String artist, Duration? duration) async {
    try {
      final res = await _dio.get(
        '${ApiConstants.lrclibBaseUrl}/search',
        queryParameters: {'track_name': title, 'artist_name': artist},
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
      if (res.statusCode != 200 || res.data is! List) return null;

      LrclibLyrics? best;
      var bestScore = double.negativeInfinity;
      for (final item in res.data as List) {
        if (item is! Map) continue;
        var s = LyricsMatch.score(
          wantTitle: title,
          wantArtist: artist,
          wantDuration: duration,
          title: item['trackName'] as String? ?? '',
          artists: [item['artistName'] as String? ?? ''],
          duration: Duration(
              seconds: (item['duration'] as num?)?.round() ?? 0),
        );
        if (s == null) continue;
        final lyrics = _fromRecord(item);
        if (lyrics.isEmpty) continue;
        if (lyrics.hasSynced) s += 1;
        if (s > bestScore) {
          bestScore = s;
          best = lyrics;
        }
      }
      return best;
    } catch (_) {
      return null;
    }
  }

  static LrclibLyrics _fromRecord(Map record) => LrclibLyrics(
        synced: record['syncedLyrics'] as String?,
        plain: record['plainLyrics'] as String?,
      );

  void close() => _dio.close(force: true);
}
