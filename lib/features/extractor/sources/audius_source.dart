import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/media_track.dart';
import '../models/resolved_stream.dart';
import 'music_source.dart';

/// Audius' public discovery/stream API. Gated, paid and unstreamable records
/// are never treated as full public audio. This catalog is mostly independent
/// music, not a replacement for every major-label release.
class AudiusSource implements MusicSource {
  final Dio _dio;
  final String _baseUrl;

  AudiusSource({Dio? dio, String baseUrl = 'https://api.audius.co/v1'})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 6),
            )),
        _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  @override
  TrackSource get source => TrackSource.audius;

  static bool isPublicStream(Map<dynamic, dynamic> record) {
    final access = record['access'];
    final conditions = record['stream_conditions'];
    return record['is_streamable'] != false &&
        record['is_available'] != false &&
        record['is_delete'] != true &&
        record['is_stream_gated'] != true &&
        record['is_unlisted'] != true &&
        !(access is Map && access['stream'] == false) &&
        (conditions == null || (conditions is Map && conditions.isEmpty));
  }

  static MediaTrack? fromJson(Map<dynamic, dynamic> item) {
    if (!isPublicStream(item)) return null;
    final id = item['id']?.toString() ?? '';
    final title = item['title']?.toString().trim() ?? '';
    final user = item['user'];
    final artist = user is Map ? user['name']?.toString().trim() ?? '' : '';
    final seconds = item['duration'];
    if (id.isEmpty ||
        title.isEmpty ||
        artist.isEmpty ||
        seconds is! num ||
        !seconds.isFinite ||
        seconds <= 0) {
      return null;
    }
    final artwork = item['artwork'];
    return MediaTrack(
      id: id,
      title: title,
      artist: artist,
      duration: Duration(milliseconds: (seconds * 1000).round()),
      artworkUrl: artwork is Map
          ? (artwork['480x480'] ?? artwork['150x150'] ?? '').toString()
          : '',
      source: TrackSource.audius,
    );
  }

  Future<dynamic> _get(String path, [Map<String, dynamic>? params]) async {
    final token = CancelToken();
    final response = await _dio
        .get<dynamic>(
      '$_baseUrl$path',
      queryParameters: {'app_name': 'Hook', ...?params},
      cancelToken: token,
    )
        .timeout(const Duration(seconds: 7), onTimeout: () {
      token.cancel('Audius request timed out');
      throw TimeoutException('Audius request timed out');
    });
    return response.data is String ? jsonDecode(response.data) : response.data;
  }

  @override
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    if (query.trim().isEmpty || limit <= 0) return const [];
    final data = await _get('/tracks/search', {
      'query': query.trim(),
      'limit': limit.clamp(1, 50),
    });
    final records = data is Map ? data['data'] : null;
    if (records is! List) return const [];
    return records
        .whereType<Map>()
        .map(fromJson)
        .whereType<MediaTrack>()
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<ResolvedStream?> resolveTrack(MediaTrack track) async {
    if (track.source != source ||
        !RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(track.id)) {
      return null;
    }
    // Recheck access at playback time: a saved search result can become gated.
    final data = await _get('/tracks/${track.id}');
    final records = data is Map ? data['data'] : null;
    final record = records is List && records.isNotEmpty ? records.first : null;
    if (record is! Map) return null;
    final current = fromJson(record);
    if (current == null || current.id != track.id) return null;
    return ResolvedStream(
      Uri.parse('$_baseUrl/tracks/${track.id}/stream')
          .replace(queryParameters: {'app_name': 'Hook'}).toString(),
      source: source,
      duration: current.duration,
    );
  }

  @override
  void close() => _dio.close(force: true);
}
