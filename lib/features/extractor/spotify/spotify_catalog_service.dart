import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../core/diagnostics/playback_diagnostics.dart';
import '../models/media_track.dart';

class SpotifyCatalogService {
  final Dio _dio;
  final Map<String, List<MediaTrack>> _cache = {};

  SpotifyCatalogService({Dio? dio}) : _dio = dio ?? Dio();

  static final _cyrillic = RegExp(r'[а-яё]', caseSensitive: false);

  /// Searches tracks from the global streaming catalog (Spotify / Studio releases).
  /// Cyrillic queries go to the Russian storefront: the default US one is
  /// missing most Russian releases.
  Future<List<MediaTrack>> searchTracks(
    String query, {
    int limit = 25,
    String? country,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return const [];
    final storefront =
        country ?? (_cyrillic.hasMatch(cleanQuery) ? 'ru' : 'us');
    final cacheKey =
        '${storefront.toLowerCase()}|${cleanQuery.toLowerCase()}|$limit';
    final cached = _cache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);

    try {
      final res = await _dio
          .get<String>(
            'https://itunes.apple.com/search',
            queryParameters: {
              'term': cleanQuery,
              'entity': 'song',
              'limit': limit,
              'country': storefront,
            },
            options: Options(
              headers: {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              },
            ),
          )
          .timeout(const Duration(seconds: 7));

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

        if (trackId == null || trackName == null || artistName == null) {
          continue;
        }

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

      if (_cache.length >= 100) _cache.remove(_cache.keys.first);
      _cache[cacheKey] = tracks;
      return List.unmodifiable(tracks);
    } catch (error) {
      PlaybackDiagnostics.record(
        'catalog.api.failed',
        source: TrackSource.spotify.name,
        url: 'https://itunes.apple.com',
        error: error,
      );
      return const [];
    }
  }

  /// Canonical discography via the structured iTunes artist lookup:
  /// `search?entity=musicArtist` resolves the artist id, `lookup?entity=song`
  /// returns their studio releases — cleaner than text search, which scatters
  /// features and compilations across the results.
  Future<List<MediaTrack>> artistTopSongs(
    String artistName, {
    int limit = 50,
  }) async {
    final name = artistName.trim();
    if (name.isEmpty) return const [];
    final storefront = _cyrillic.hasMatch(name) ? 'ru' : 'us';
    final cacheKey = 'artist|$storefront|${name.toLowerCase()}|$limit';
    final cached = _cache[cacheKey];
    if (cached != null) return List.unmodifiable(cached);

    try {
      final wanted = name.toLowerCase();
      final artistSearch = await _dio
          .get<String>(
            'https://itunes.apple.com/search',
            queryParameters: {
              'term': name,
              'entity': 'musicArtist',
              'limit': 5,
              'country': storefront,
            },
            options: Options(
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              },
            ),
          )
          .timeout(const Duration(seconds: 7));
      final artistResults = _resultsOf(artistSearch.data);
      int? artistId;
      for (final item in artistResults) {
        final id = (item['artistId'] as num?)?.toInt();
        final got = (item['artistName'] as String?)?.toLowerCase() ?? '';
        if (id == null) continue;
        if (got == wanted || artistId == null) artistId = id;
        if (got == wanted) break;
      }
      if (artistId == null) return const [];

      final lookup = await _dio
          .get<String>(
            'https://itunes.apple.com/lookup',
            queryParameters: {
              'id': artistId,
              'entity': 'song',
              'limit': limit,
              'country': storefront,
            },
            options: Options(
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              },
            ),
          )
          .timeout(const Duration(seconds: 7));

      final seen = <String>{};
      final tracks = <MediaTrack>[];
      for (final item in _resultsOf(lookup.data)) {
        // The lookup response leads with the artist record itself.
        if (item['wrapperType'] != 'track' || item['kind'] != 'song') continue;
        final track = _trackFromItem(item);
        if (track == null) continue;
        // Same song surfaces once per album it appears on.
        final songKey =
            '${track.title.toLowerCase()}|${track.duration.inMilliseconds}';
        if (!seen.add(songKey)) continue;
        tracks.add(track);
      }
      if (_cache.length >= 100) _cache.remove(_cache.keys.first);
      _cache[cacheKey] = tracks;
      return List.unmodifiable(tracks);
    } catch (error) {
      PlaybackDiagnostics.record(
        'catalog.artist.failed',
        source: TrackSource.spotify.name,
        detail: name,
        error: error,
      );
      return const [];
    }
  }

  static List<Map<String, dynamic>> _resultsOf(String? body) {
    if (body == null || body.isEmpty) return const [];
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final results = data['results'] as List?;
      if (results == null) return const [];
      return [
        for (final item in results)
          if (item is Map<String, dynamic>) item,
      ];
    } catch (_) {
      return const [];
    }
  }

  MediaTrack? _trackFromItem(Map<String, dynamic> item) {
    final trackId = item['trackId']?.toString();
    final trackName = item['trackName'] as String?;
    final artistName = item['artistName'] as String?;
    if (trackId == null || trackName == null || artistName == null) return null;
    final rawArt = item['artworkUrl100'] as String? ?? '';
    return MediaTrack(
      id: 'sp_$trackId',
      title: trackName,
      artist: artistName,
      album: item['collectionName'] as String?,
      duration: Duration(milliseconds: (item['trackTimeMillis'] as num?)?.toInt() ?? 0),
      artworkUrl: rawArt.replaceAll('100x100bb', '600x600bb'),
      source: TrackSource.spotify,
    );
  }

  void close() {
    _dio.close(force: true);
  }
}
