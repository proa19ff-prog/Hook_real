import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/media_track.dart';

class SpotifyCatalogService {
  final Dio _dio;

  SpotifyCatalogService({Dio? dio}) : _dio = dio ?? Dio();

  static final _cyrillic = RegExp(r'[а-яё]', caseSensitive: false);

  /// Searches tracks from the global streaming catalog (Spotify / Studio releases).
  /// Cyrillic queries go to the Russian storefront: the default US one is
  /// missing most Russian releases.
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 25}) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const [];
    final country = _cyrillic.hasMatch(cleanQuery) ? 'ru' : 'us';

    try {
      final res = await _dio.get<String>(
        'https://itunes.apple.com/search',
        queryParameters: {
          'term': cleanQuery,
          'entity': 'song',
          'limit': limit,
          'country': country,
        },
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
        ),
      ).timeout(const Duration(seconds: 7));

      if (res.data == null || res.data!.isEmpty) return const [];

      final data = jsonDecode(res.data!) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results == null || results.isEmpty) return const [];

      final tracks = <MediaTrack>[];
      for (final item in results) {
        if (item is! Map<String, dynamic>) continue;
        final trackId = item['trackId']?.toString();
        final trackName = item['trackName'] as String?;
        final artistName = item['artistName'] as String?;
        final albumName = item['collectionName'] as String?;
        final durationMs = (item['trackTimeMillis'] as num?)?.toInt() ?? 0;
        final rawArt = item['artworkUrl100'] as String? ?? '';

        if (trackId == null || trackName == null || artistName == null) continue;

        // Upgrade 100x100 thumbnail to crystal clear 600x600 / 1000x1000 artwork
        final highResArt = rawArt.replaceAll('100x100bb', '600x600bb');

        tracks.add(
          MediaTrack(
            id: 'sp_$trackId',
            title: trackName,
            artist: artistName,
            album: albumName,
            duration: Duration(milliseconds: durationMs),
            artworkUrl: highResArt,
            source: TrackSource.spotify,
          ),
        );
      }

      return tracks;
    } catch (_) {
      return const [];
    }
  }

  void close() {
    _dio.close(force: true);
  }
}
