import 'package:dio/dio.dart';
import 'package:hook/core/constants/api_constants.dart';
import '../models/media_track.dart';

class SoundCloudExtractor {
  final Dio _dio;
  String _clientId;
  bool _isRefreshingKey = false;

  /// Media info captured from search responses, so starting a found track
  /// skips the extra `/tracks/{id}` round-trip.
  final Map<String, Map<String, dynamic>> _mediaCache = {};
  final Map<String, int> _playCounts = {};

  /// Play count seen in the last search response (0 when unknown).
  int playbackCount(String trackId) => _playCounts[trackId] ?? 0;

  SoundCloudExtractor({Dio? dio, String? clientId})
      : _dio = dio ?? Dio(),
        _clientId = clientId ?? ApiConstants.soundCloudFallbackClientId;

  String get clientId => _clientId;

  void updateClientId(String newClientId) {
    _clientId = newClientId;
  }

  /// Automatically discovers and extracts an active client ID from soundcloud.com.
  /// This guarantees the player never breaks even if SoundCloud revokes the static ID.
  Future<String?> refreshClientId() async {
    if (_isRefreshingKey) return _clientId;
    _isRefreshingKey = true;
    try {
      final res = await _dio
          .get<String>(
            'https://soundcloud.com',
            options: Options(
              headers: {
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
              },
            ),
          )
          .timeout(const Duration(seconds: 10));

      final body = res.data ?? '';
      final scriptRegex = RegExp(r'<script[^>]+src="([^">]+\.js)"');
      final scriptUrls =
          scriptRegex.allMatches(body).map((m) => m.group(1)!).toList();

      // Check scripts starting from the end where app/vendor bundles typically live
      for (final scriptUrl in scriptUrls.reversed) {
        try {
          final sRes = await _dio
              .get<String>(
                scriptUrl,
                options: Options(responseType: ResponseType.plain),
              )
              .timeout(const Duration(seconds: 6));

          final sBody = sRes.data ?? '';
          final cidRegex = RegExp(r'client_id[=:][\s"]*([a-zA-Z0-9]{32})');
          final match = cidRegex.firstMatch(sBody);
          if (match != null) {
            final discoveredId = match.group(1)!;
            _clientId = discoveredId;
            return discoveredId;
          }
        } catch (_) {}
      }
    } catch (_) {
      // Keep existing client ID on failure
    } finally {
      _isRefreshingKey = false;
    }
    return _clientId;
  }

  /// Searches tracks on SoundCloud API v2
  Future<List<MediaTrack>> searchTracks(String query,
      {int limit = 25, bool isRetry = false}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.soundCloudApiBaseUrl}/search/tracks',
        queryParameters: {
          'q': query,
          'client_id': _clientId,
          'limit': limit,
        },
      ).timeout(const Duration(seconds: 12));

      final data = response.data;
      if (data == null || data['collection'] == null) {
        return [];
      }

      final collection = data['collection'] as List;
      final tracks = <MediaTrack>[];

      for (final item in collection) {
        if (item is! Map<String, dynamic>) continue;

        final id = (item['id'] ?? '').toString();
        final title = item['title'] as String? ?? 'Unknown Title';
        final user = item['user'] as Map<String, dynamic>?;
        // Label uploads carry the real performers in publisher metadata
        // (e.g. uploader "VILLIAN", artist "VILLIAN & madk1d").
        final publisherArtist =
            ((item['publisher_metadata'] as Map?)?['artist'] as String?)
                ?.trim();
        final artist = (publisherArtist != null && publisherArtist.isNotEmpty)
            ? publisherArtist
            : user?['username'] as String? ?? 'Unknown Artist';
        final durationMs = item['duration'] as int? ?? 0;
        final fullDurationMs = item['full_duration'] as int? ?? durationMs;
        final policy = (item['policy'] as String? ?? '').toUpperCase();
        final monetization =
            (item['monetization_model'] as String? ?? '').toUpperCase();

        // Filter out SoundCloud Go+ preview-only tracks (30s snippets)
        if (policy == 'SNIP' ||
            monetization == 'SUB_HIGH_TIER' ||
            (fullDurationMs > 45000 && durationMs <= 35000)) {
          continue;
        }

        var artworkUrl = item['artwork_url'] as String? ??
            user?['avatar_url'] as String? ??
            '';

        // Upscale thumbnail to 500x500 high resolution (never blurry)
        if (artworkUrl.contains('-large.')) {
          artworkUrl = artworkUrl.replaceAll('-large.', '-t500x500.');
        } else if (artworkUrl.contains('-t300x300.')) {
          artworkUrl = artworkUrl.replaceAll('-t300x300.', '-t500x500.');
        }

        final media = item['media'];
        if (media is Map &&
            (media['transcodings'] as List?)?.isNotEmpty == true) {
          if (_mediaCache.length > 500) _mediaCache.clear();
          _mediaCache[id] = {
            'media': media,
            'duration': item['duration'],
            'track_authorization': item['track_authorization'],
          };
        }
        _playCounts[id] = (item['playback_count'] as num?)?.toInt() ?? 0;

        tracks.add(
          MediaTrack(
            id: id,
            title: title,
            artist: artist,
            duration: Duration(
                milliseconds: fullDurationMs > 0 ? fullDurationMs : durationMs),
            artworkUrl: artworkUrl,
            source: TrackSource.soundcloud,
          ),
        );
      }

      return tracks;
    } on DioException catch (dioErr) {
      if (!isRetry && dioErr.response?.statusCode == 401) {
        final newKey = await refreshClientId();
        if (newKey != null && newKey.isNotEmpty) {
          return searchTracks(query, limit: limit, isRetry: true);
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Returns SoundCloud's related-track feed for a known track. The stations
  /// endpoint is not available on the current API, so this deliberately uses
  /// the track-specific related endpoint.
  Future<List<MediaTrack>> relatedTracks(String trackId,
      {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.soundCloudApiBaseUrl}/tracks/$trackId/related',
        queryParameters: {
          'client_id': _clientId,
          'limit': limit,
        },
      ).timeout(const Duration(seconds: 12));
      final collection = response.data is Map
          ? (response.data['collection'] as List? ?? const [])
          : const [];
      final tracks = <MediaTrack>[];
      for (final item in collection) {
        if (item is! Map<String, dynamic>) continue;
        final id = item['id']?.toString() ?? '';
        final title = item['title']?.toString() ?? '';
        if (id.isEmpty || title.isEmpty) continue;
        final user = item['user'] is Map ? item['user'] as Map : null;
        final publisher = item['publisher_metadata'] is Map
            ? item['publisher_metadata']['artist']?.toString()
            : null;
        final artist = publisher?.trim().isNotEmpty == true
            ? publisher!.trim()
            : user?['username']?.toString() ?? 'Unknown Artist';
        final duration = (item['full_duration'] as num?)?.toInt() ??
            (item['duration'] as num?)?.toInt() ??
            0;
        var artwork = item['artwork_url']?.toString() ??
            user?['avatar_url']?.toString() ??
            '';
        artwork = artwork.replaceAll('-large.', '-t500x500.');
        _playCounts[id] = (item['playback_count'] as num?)?.toInt() ?? 0;
        final media = item['media'];
        if (media is Map &&
            (media['transcodings'] as List?)?.isNotEmpty == true) {
          _mediaCache[id] = {
            'media': media,
            'duration': item['duration'],
            'track_authorization': item['track_authorization'],
          };
        }
        tracks.add(MediaTrack(
          id: id,
          title: title,
          artist: artist,
          duration: Duration(milliseconds: duration),
          artworkUrl: artwork,
          source: TrackSource.soundcloud,
        ));
      }
      return tracks;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        final key = await refreshClientId();
        if (key != null && key.isNotEmpty) {
          return relatedTracks(trackId, limit: limit);
        }
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  /// Resolves the actual streaming URL for a SoundCloud track by track ID.
  Future<String?> resolveAudioStreamUrl(String trackId,
      {bool isRetry = false}) async {
    // Fast path: transcodings from the search response, one request to start.
    final cached = isRetry ? null : _mediaCache[trackId];
    if (cached != null) {
      try {
        final url = await _resolveFromTrackData(cached);
        if (url != null && url.isNotEmpty) return url;
      } catch (_) {
        // Stale search data; fall through to the full track lookup.
      }
      _mediaCache.remove(trackId);
    }

    try {
      final trackDetailsRes = await _dio.get(
        '${ApiConstants.soundCloudApiBaseUrl}/tracks/$trackId',
        queryParameters: {'client_id': _clientId},
      ).timeout(const Duration(seconds: 10));

      final trackData = trackDetailsRes.data;
      if (trackData is! Map<String, dynamic>) return null;
      return await _resolveFromTrackData(trackData);
    } on DioException catch (dioErr) {
      if (!isRetry && dioErr.response?.statusCode == 401) {
        final newKey = await refreshClientId();
        if (newKey != null && newKey.isNotEmpty) {
          return resolveAudioStreamUrl(trackId, isRetry: true);
        }
      }
      Error.throwWithStackTrace(
        StateError('SoundCloud stream resolve failed for $trackId: $dioErr'),
        StackTrace.current,
      );
    } catch (e) {
      Error.throwWithStackTrace(
        StateError('SoundCloud stream resolve failed for $trackId: $e'),
        StackTrace.current,
      );
    }
  }

  /// Picks the fastest-starting playable transcoding and resolves its signed
  /// URL. Falls through to the next transcoding when one answers 404 (the
  /// `abr_sq` preset does on most tracks).
  Future<String?> _resolveFromTrackData(Map<String, dynamic> trackData) async {
    final media = trackData['media'];
    if (media is! Map) return null;
    final transcodings = media['transcodings'] as List?;
    if (transcodings == null || transcodings.isEmpty) return null;

    final trackDurationMs = (trackData['duration'] as num?) ?? 0;
    final playable = <Map<String, dynamic>>[];
    for (final t in transcodings) {
      if (t is! Map<String, dynamic>) continue;
      final format = t['format'] as Map<String, dynamic>?;
      final protocol = (format?['protocol'] as String? ?? '').toLowerCase();
      final mimeType = (format?['mime_type'] as String? ?? '').toLowerCase();
      // Encrypted/DRM streams can't be played by a standard player.
      if (protocol.contains('encrypted') ||
          protocol.contains('drm') ||
          mimeType.contains('encrypted')) {
        continue;
      }
      playable.add(t);
    }
    if (playable.isEmpty) return null;

    // Separate full tracks from 30s preview snippets (SoundCloud Go+ previews).
    bool isFull(Map<String, dynamic> t) {
      final url = (t['url'] as String? ?? '').toLowerCase();
      final tDur = (t['duration'] as num?) ?? 0;
      final isDurationSnippet =
          trackDurationMs > 40000 && tDur > 0 && tDur <= 35000;
      return t['snipped'] != true &&
          !url.contains('/preview') &&
          !isDurationSnippet;
    }

    final full = playable.where(isFull).toList();
    final candidates = full.isNotEmpty ? full : playable;

    // Progressive MP3 is one file, so the player starts after a single
    // request. Plain HLS needs a playlist fetch first. `abr_sq` presets
    // currently answer 404, so they go last.
    int rank(Map<String, dynamic> t) {
      final protocol = (t['format'] as Map?)?['protocol'];
      final preset = (t['preset'] as String? ?? '').toLowerCase();
      if (protocol == 'progressive') return 0;
      if (preset.startsWith('abr')) return 3;
      if (protocol == 'hls') return preset.contains('160') ? 1 : 2;
      return 4;
    }

    candidates.sort((a, b) => rank(a).compareTo(rank(b)));

    final auth = trackData['track_authorization'] as String?;
    Object? lastError;
    for (final t in candidates) {
      final streamInfoUrl = t['url'] as String?;
      if (streamInfoUrl == null) continue;
      try {
        final res = await _dio.get(
          streamInfoUrl,
          queryParameters: {
            'client_id': _clientId,
            if (auth != null && auth.isNotEmpty) 'track_authorization': auth,
          },
        ).timeout(const Duration(seconds: 8));
        final data = res.data;
        final url = data is Map ? data['url'] as String? : null;
        if (url != null && url.isNotEmpty) return url;
      } on DioException catch (e) {
        // A 401 means the client_id is stale; let the caller refresh it.
        if (e.response?.statusCode == 401) rethrow;
        lastError = e;
      } catch (e) {
        lastError = e;
      }
    }
    if (lastError != null) throw lastError;
    return null;
  }

  void close() {
    _dio.close(force: true);
  }
}
