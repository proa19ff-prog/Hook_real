import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../../extractor/models/media_track.dart';

class LyricsSearchHit {
  final MediaTrack track;
  final String snippet;
  const LyricsSearchHit({required this.track, required this.snippet});
}

/// NetEase's type=1006 searches lyric bodies. LRCLIB's `q` endpoint only
/// searches metadata and must not be presented as full-text lyrics search.
/// Results here are discovery metadata; audio still uses the normal resolver.
class LyricsSearchService {
  final Dio _dio;
  LyricsSearchService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 8),
              headers: {
                'Referer': 'https://music.163.com/',
                'User-Agent': 'Hook/0.1'
              },
            ));

  static String _normalize(String value) => value
      .toLowerCase()
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static String snippetFor(String lyrics, String phrase) {
    final plain = lyrics
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '');
    final lines = plain
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    final query = _normalize(phrase);
    final words = query.split(' ').where((word) => word.isNotEmpty).toSet();
    if (words.isEmpty) return '';
    var best = '';
    var bestScore = 0.0;
    for (var i = 0; i < lines.length; i++) {
      for (final line in [
        lines[i],
        if (i + 1 < lines.length) '${lines[i]} ${lines[i + 1]}'
      ]) {
        final normalized = _normalize(line);
        final tokens = normalized.split(' ').toSet();
        final coverage = words.intersection(tokens).length / words.length;
        final score = (normalized.contains(query) ? 2 : 0) + coverage;
        if (coverage >= 0.6 && score > bestScore) {
          best = line;
          bestScore = score;
        }
      }
    }
    if (best.length <= 180) return best;
    // Keep the match visible even on a provider's exceptionally long line.
    final firstWord = words.first;
    final match = best.toLowerCase().indexOf(firstWord);
    final start = match > 35 ? match - 35 : 0;
    final end = (start + 176).clamp(0, best.length);
    return '${start > 0 ? '…' : ''}${best.substring(start, end)}${end < best.length ? '…' : ''}';
  }

  Future<List<LyricsSearchHit>> search(String phrase, {int limit = 24}) async {
    final query = phrase.trim();
    if (query.isEmpty || limit <= 0) return const [];
    final token = CancelToken();
    final response = await _dio
        .get<dynamic>(
      'https://music.163.com/api/search/get',
      queryParameters: {
        's': query,
        'type': 1006,
        'limit': limit.clamp(1, 50),
        'offset': 0
      },
      cancelToken: token,
    )
        .timeout(const Duration(seconds: 9), onTimeout: () {
      token.cancel('Lyrics search timed out');
      throw TimeoutException('Lyrics search timed out');
    });
    final json =
        response.data is String ? jsonDecode(response.data) : response.data;
    if (json is! Map || json['code'] != 200) {
      throw StateError('Lyrics search is unavailable');
    }
    final result = json['result'];
    final songs = result is Map ? result['songs'] : null;
    if (songs is! List) return const [];
    final seen = <String>{};
    final hits = <LyricsSearchHit>[];
    for (final song in songs.whereType<Map>()) {
      final id = song['id']?.toString() ?? '';
      final title = song['name']?.toString().trim() ?? '';
      final artists = song['artists'];
      final artist = artists is List
          ? artists
              .whereType<Map>()
              .map((item) => item['name']?.toString() ?? '')
              .where((name) => name.isNotEmpty)
              .join(' & ')
          : '';
      final lyricData = song['lyrics'];
      final text = lyricData is Map ? lyricData['txt']?.toString() ?? '' : '';
      final snippet = snippetFor(text, query);
      if (id.isEmpty || title.isEmpty || artist.isEmpty || snippet.isEmpty) {
        continue;
      }
      final milliseconds = song['duration'];
      final seconds = milliseconds is num && milliseconds.isFinite
          ? (milliseconds / 1000).round()
          : 0;
      if (!seen.add('${_normalize(title)}|${_normalize(artist)}|$seconds')) {
        continue;
      }
      final album = song['album'];
      hits.add(LyricsSearchHit(
        track: MediaTrack(
          id: 'lyrics_netease_$id',
          title: title,
          artist: artist,
          album: album is Map ? album['name']?.toString() : null,
          duration: Duration(seconds: seconds),
          artworkUrl: album is Map ? album['picUrl']?.toString() ?? '' : '',
          source: TrackSource.spotify,
        ),
        snippet: snippet,
      ));
    }
    return List.unmodifiable(hits.take(limit));
  }

  void close() => _dio.close(force: true);
}
