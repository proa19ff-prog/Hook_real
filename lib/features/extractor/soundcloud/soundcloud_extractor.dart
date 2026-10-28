import 'package:dio/dio.dart';
import 'package:hook/core/constants/api_constants.dart';
import '../models/media_track.dart';

class SoundCloudExtractor {
  final Dio _dio;
  String _clientId;

  SoundCloudExtractor({Dio? dio, String? clientId})
      : _dio = dio ?? Dio(),
        _clientId = clientId ?? ApiConstants.soundCloudFallbackClientId;

  void updateClientId(String newClientId) {
    _clientId = newClientId;
  }

  /// Searches tracks on SoundCloud API v2
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.soundCloudApiBaseUrl}/search/tracks',
        queryParameters: {
          'q': query,
          'client_id': _clientId,
          'limit': limit,
        },
      ).timeout(const Duration(seconds: 15));

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

        // Keep SoundCloud's small artwork URL for result rows.  Upscaling
        // every search result to t500x500 causes avoidable network and image
        // decode work on mobile.
        var artworkUrl = item['artwork_url'] as String? ??
            user?['avatar_url'] as String? ??
            '';

        tracks.add(
          MediaTrack(
            id: id,
            title: title,
            artist: artist,
            duration: Duration(milliseconds: durationMs),
            artworkUrl: artworkUrl,
            source: TrackSource.soundcloud,
          ),
        );
      }

      return tracks;
    } catch (e) {
      return [];
    }
  }

  /// Resolves the actual streaming URL for a SoundCloud track by track ID.
  Future<String?> resolveAudioStreamUrl(String trackId) async {
    try {
      final trackDetailsRes = await _dio.get(
        '${ApiConstants.soundCloudApiBaseUrl}/tracks/$trackId',
        queryParameters: {'client_id': _clientId},
      );

      final trackData = trackDetailsRes.data;
      if (trackData == null || trackData['media'] == null) return null;

      final transcodings = trackData['media']['transcodings'] as List?;
      if (transcodings == null || transcodings.isEmpty) return null;

      // 1. Try finding progressive MP3 stream first (cleanest seeking and playback)
      Map<String, dynamic>? targetTranscoding;
      for (final t in transcodings) {
        final format = t['format'] as Map<String, dynamic>?;
        if (format?['protocol'] == 'progressive') {
          targetTranscoding = t;
          break;
        }
      }

      // 2. Fallback to HLS stream if progressive is unavailable
      targetTranscoding ??= transcodings.first as Map<String, dynamic>?;

      if (targetTranscoding == null) return null;

      final streamInfoUrl = targetTranscoding['url'] as String;
      final streamResolveRes = await _dio.get(
        streamInfoUrl,
        queryParameters: {'client_id': _clientId},
      );

      final streamUrl = streamResolveRes.data?['url'] as String?;
      return streamUrl;
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
