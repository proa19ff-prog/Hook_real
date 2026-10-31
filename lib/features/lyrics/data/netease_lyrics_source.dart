import 'dart:convert';

import 'package:dio/dio.dart';

import 'lyrics_match.dart';

class NeteaseLyrics {
  /// Line-synced LRC.
  final String? lrc;

  /// Word-synced lyrics: `[lineStart,lineDur](wordStart,wordDur,0)word`.
  final String? yrc;

  const NeteaseLyrics({this.lrc, this.yrc});
}

/// NetEase Cloud Music has word-level timing (YRC) for many international
/// songs and line-synced lyrics for a large share of Russian ones.
class NeteaseLyricsSource {
  static const _base = 'https://music.163.com/api';

  final Dio _dio;

  NeteaseLyricsSource({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
                'Referer': 'https://music.163.com/',
              },
            ));

  /// The API answers JSON with a `text/plain` content type.
  static dynamic _json(dynamic data) => data is String ? jsonDecode(data) : data;

  Future<NeteaseLyrics?> fetch({
    required String title,
    required String artist,
    Duration? duration,
  }) async {
    final queries = <String>{'$title $artist'.trim(), title.trim()};
    for (final query in queries) {
      final id = await _findSong(query, title, artist, duration);
      if (id == null) continue;
      final lyrics = await _lyrics(id);
      if (lyrics != null) return lyrics;
    }
    return null;
  }

  Future<int?> _findSong(
    String query,
    String title,
    String artist,
    Duration? duration,
  ) async {
    try {
      final res = await _dio.get(
        '$_base/search/get',
        queryParameters: {'s': query, 'type': 1, 'limit': 12},
      );
      final songs = (_json(res.data) as Map?)?['result']?['songs'];
      if (songs is! List) return null;

      int? bestId;
      var bestScore = double.negativeInfinity;
      for (final song in songs) {
        if (song is! Map) continue;
        final artists = [
          for (final a in (song['artists'] as List? ?? const []))
            if (a is Map && a['name'] is String) a['name'] as String,
        ];
        final ms = (song['duration'] as num?)?.toInt() ?? 0;
        final s = LyricsMatch.score(
          wantTitle: title,
          wantArtist: artist,
          wantDuration: duration,
          title: song['name'] as String? ?? '',
          artists: artists,
          duration: Duration(milliseconds: ms),
        );
        if (s != null && s > bestScore) {
          bestScore = s;
          bestId = (song['id'] as num?)?.toInt();
        }
      }
      return bestId;
    } catch (_) {
      return null;
    }
  }

  Future<NeteaseLyrics?> _lyrics(int id) async {
    try {
      final res = await _dio.get(
        '$_base/song/lyric/v1',
        queryParameters: {'id': id, 'lv': -1, 'kv': -1, 'tv': -1, 'yv': -1},
      );
      final data = _json(res.data);
      if (data is! Map) return null;
      final lrc = (data['lrc'] as Map?)?['lyric'] as String?;
      final yrc = (data['yrc'] as Map?)?['lyric'] as String?;
      if ((lrc == null || lrc.trim().isEmpty) &&
          (yrc == null || yrc.trim().isEmpty)) {
        return null;
      }
      return NeteaseLyrics(lrc: lrc, yrc: yrc);
    } catch (_) {
      return null;
    }
  }

  void close() => _dio.close(force: true);
}
