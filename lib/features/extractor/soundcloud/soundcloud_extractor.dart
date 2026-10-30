import 'package:dio/dio.dart';
import 'package:hook/core/constants/api_constants.dart';
import '../models/media_track.dart';

class SoundCloudExtractor {
  final Dio _dio;
  String _clientId;
  bool _isRefreshingKey = false;

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
      final res = await _dio.get<String>(
        'https://soundcloud.com',
        options: Options(
          headers: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          },
        ),
      ).timeout(const Duration(seconds: 10));

      final body = res.data ?? '';
      final scriptRegex = RegExp(r'<script[^>]+src="([^">]+\.js)"');
      final scriptUrls = scriptRegex.allMatches(body).map((m) => m.group(1)!).toList();

      // Check scripts starting from the end where app/vendor bundles typically live
      for (final scriptUrl in scriptUrls.reversed) {
        try {
          final sRes = await _dio.get<String>(
            scriptUrl,
            options: Options(responseType: ResponseType.plain),
          ).timeout(const Duration(seconds: 6));

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
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 25, bool isRetry = false}) async {
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
        final artist = user?['username'] as String? ?? 'Unknown Artist';
        final durationMs = item['duration'] as int? ?? 0;
        final fullDurationMs = item['full_duration'] as int? ?? durationMs;
        final policy = (item['policy'] as String? ?? '').toUpperCase();
        final monetization = (item['monetization_model'] as String? ?? '').toUpperCase();

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

        tracks.add(
          MediaTrack(
            id: id,
            title: title,
            artist: artist,
            duration: Duration(milliseconds: fullDurationMs > 0 ? fullDurationMs : durationMs),
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

  /// Resolves the actual streaming URL for a SoundCloud track by track ID.
  Future<String?> resolveAudioStreamUrl(String trackId, {bool isRetry = false}) async {
    try {
      final trackDetailsRes = await _dio.get(
        '${ApiConstants.soundCloudApiBaseUrl}/tracks/$trackId',
        queryParameters: {'client_id': _clientId},
      ).timeout(const Duration(seconds: 10));

      final trackData = trackDetailsRes.data;
      if (trackData == null || trackData['media'] == null) return null;

      final transcodings = trackData['media']['transcodings'] as List?;
      if (transcodings == null || transcodings.isEmpty) return null;

      // Filter out any encrypted/DRM transcodings that standard players cannot play
      final playableTranscodings = transcodings.where((t) {
        if (t is! Map<String, dynamic>) return false;
        final format = t['format'] as Map<String, dynamic>?;
        final protocol = (format?['protocol'] as String? ?? '').toLowerCase();
        final mimeType = (format?['mime_type'] as String? ?? '').toLowerCase();
        final isEncrypted = protocol.contains('encrypted') ||
            protocol.contains('drm') ||
            mimeType.contains('encrypted');
        return !isEncrypted;
      }).toList();

      // Separate full tracks from 30s preview snippets (SoundCloud Go+ previews)
      final trackDurationMs = (trackData['duration'] as num?) ?? 0;
      final fullTranscodings = playableTranscodings.where((t) {
        final isSnipped = t['snipped'] == true;
        final url = (t['url'] as String? ?? '').toLowerCase();
        final isPreviewUrl = url.contains('/preview');
        final tDur = (t['duration'] as num?) ?? 0;
        final isDurationSnippet = trackDurationMs > 40000 && tDur > 0 && tDur <= 35000;
        return !isSnipped && !isPreviewUrl && !isDurationSnippet;
      }).toList();

      // Prefer full non-snipped transcodings
      final candidateTranscodings = fullTranscodings.isNotEmpty
          ? fullTranscodings
          : playableTranscodings;

      Map<String, dynamic>? targetTranscoding;

      // 1. If full transcodings exist, prioritize full progressive or full HLS
      for (final t in candidateTranscodings) {
        final format = t['format'] as Map<String, dynamic>?;
        if (format?['protocol'] == 'progressive' && t['snipped'] != true) {
          targetTranscoding = t;
          break;
        }
      }

      // 2. Prioritize clean HLS streams
      if (targetTranscoding == null) {
        for (final t in candidateTranscodings) {
          final format = t['format'] as Map<String, dynamic>?;
          if (format?['protocol'] == 'hls') {
            targetTranscoding = t;
            break;
          }
        }
      }

      // 3. Fallback to any remaining candidate
      targetTranscoding ??= candidateTranscodings.isNotEmpty
          ? (candidateTranscodings.first as Map<String, dynamic>?)
          : (transcodings.first as Map<String, dynamic>?);

      if (targetTranscoding == null) return null;

      final streamInfoUrl = targetTranscoding['url'] as String;
      final streamResolveRes = await _dio.get(
        streamInfoUrl,
        queryParameters: {'client_id': _clientId},
      ).timeout(const Duration(seconds: 10));

      final streamUrl = streamResolveRes.data?['url'] as String?;
      return streamUrl;
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

  void close() {
    _dio.close(force: true);
  }
}
