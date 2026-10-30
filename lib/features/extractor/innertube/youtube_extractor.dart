import 'dart:io';
import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../../core/constants/api_constants.dart';
import '../models/media_track.dart';

class YouTubeExtractor {
  final YoutubeExplode _yt;
  final Dio _dio;

  YouTubeExtractor({YoutubeExplode? yt, Dio? dio})
      : _yt = yt ?? YoutubeExplode(),
        _dio = dio ?? Dio();

  static final List<List<YoutubeApiClient>> _clientChain = [
    [YoutubeApiClient.ios],
    [YoutubeApiClient.android],
    [YoutubeApiClient.androidVr],
    [YoutubeApiClient.tv],
  ];

  static String cleanTrackTitle(String rawTitle) {
    var title = rawTitle;
    final regexes = [
      RegExp(r'[\(\[]\s*official\s*(music)?\s*video\s*[\)\]]',
          caseSensitive: false),
      RegExp(r'[\(\[]\s*official\s*audio\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*lyrics?\s*(video)?\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*4k\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*hd\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*remaster(ed)?\s*[\)\]]', caseSensitive: false),
      RegExp(r'[\(\[]\s*visualizer\s*[\)\]]', caseSensitive: false),
    ];

    for (final reg in regexes) {
      title = title.replaceAll(reg, '');
    }

    return title.trim();
  }

  /// Searches tracks on YouTube / YouTube Music.
  /// Seamlessly falls back to Invidious if YouTube DNS/domain is blocked.
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    // 1. Attempt native YouTubeExplode
    try {
      final searchList = await _yt.search
          .search(query)
          .timeout(const Duration(seconds: 7));

      final tracks = <MediaTrack>[];
      for (final video in searchList) {
        if (tracks.length >= limit) break;
        if (video.isLive || video.duration == null) continue;

        tracks.add(
          MediaTrack(
            id: video.id.value,
            title: cleanTrackTitle(video.title),
            artist: video.author,
            duration: video.duration!,
            artworkUrl: video.thumbnails.highResUrl,
            source: TrackSource.youtube,
          ),
        );
      }

      if (tracks.isNotEmpty) return tracks;
    } on SocketException {
      // Direct DNS / network block; immediately skip to Invidious without waiting
    } catch (_) {
      // Timeout or other network error; proceed to Invidious
    }

    // 2. Resilient Invidious fallback
    return _searchInvidiousFallback(query, limit: limit);
  }

  Future<List<MediaTrack>> _searchInvidiousFallback(String query,
      {int limit = 20}) async {
    for (final instance in ApiConstants.invidiousInstances) {
      try {
        final res = await _dio.get(
          '$instance/api/v1/search',
          queryParameters: {
            'q': query,
            'type': 'video',
          },
          options: Options(responseType: ResponseType.json),
        ).timeout(const Duration(seconds: 5));

        if (res.statusCode == 200 && res.data is List) {
          final list = res.data as List;
          final tracks = <MediaTrack>[];

          for (final item in list) {
            if (tracks.length >= limit) break;
            if (item is! Map<String, dynamic>) continue;

            final videoId = item['videoId'] as String?;
            final title = item['title'] as String? ?? 'Unknown Title';
            final author = item['author'] as String? ?? 'YouTube';
            final lengthSec = item['lengthSeconds'] as int? ?? 0;
            if (videoId == null || lengthSec <= 0) continue;

            String thumb = '';
            final thumbs = item['videoThumbnails'] as List?;
            if (thumbs != null && thumbs.isNotEmpty) {
              final high = thumbs.firstWhere(
                (t) =>
                    t['quality'] == 'maxres' ||
                    t['quality'] == 'high' ||
                    t['quality'] == 'sd',
                orElse: () => thumbs.first,
              );
              thumb = high['url'] as String? ?? '';
            }
            if (thumb.isEmpty) {
              thumb = 'https://i.ytimg.com/vi/$videoId/maxresdefault.jpg';
            }

            tracks.add(
              MediaTrack(
                id: videoId,
                title: cleanTrackTitle(title),
                artist: author,
                duration: Duration(seconds: lengthSec),
                artworkUrl: thumb,
                source: TrackSource.youtube,
              ),
            );
          }

          if (tracks.isNotEmpty) return tracks;
        }
      } catch (_) {
        continue;
      }
    }
    return [];
  }

  /// Resolves direct audio stream URL with fast Invidious fallback when direct connection is blocked.
  /// When falling back to Invidious, the stream URL is proxied through the Invidious instance
  /// to bypass both IP signature mismatches (403 Forbidden) and ISP censorship/throttling of googlevideo.com.
  Future<String?> resolveAudioStreamUrl(String videoId) async {
    Object? lastError;

    // 1. Try native YouTube Explode with clients that work best on mobile
    for (final clients in _clientChain) {
      try {
        final manifest = await _yt.videos.streamsClient
            .getManifest(videoId, ytClients: clients, requireWatchPage: false)
            .timeout(const Duration(seconds: 8));

        final audio = manifest.audioOnly.toList();
        if (audio.isNotEmpty) {
          final mp4 =
              audio.where((s) => s.container == StreamContainer.mp4).toList();
          final best = (mp4.isNotEmpty ? mp4 : audio).sortByBitrate().first;
          return best.url.toString();
        }

        final muxed = manifest.muxed.sortByBitrate();
        if (muxed.isNotEmpty) return muxed.first.url.toString();
      } on SocketException catch (e) {
        lastError = e;
        break; // Host lookup failed, all clients will fail identically; break immediately to Invidious
      } catch (e) {
        lastError = e;
      }
    }

    // 2. Invidious fallback with stream proxying
    for (final instance in ApiConstants.invidiousInstances) {
      try {
        final res = await _dio.get(
          '$instance/api/v1/videos/$videoId',
          options: Options(responseType: ResponseType.json),
        ).timeout(const Duration(seconds: 8));

        if (res.statusCode == 200 && res.data is Map<String, dynamic>) {
          final data = res.data as Map<String, dynamic>;
          final adaptiveFormats = data['adaptiveFormats'] as List?;
          if (adaptiveFormats != null && adaptiveFormats.isNotEmpty) {
            final audioFormats = adaptiveFormats.where((f) {
              final type = (f['type'] as String? ?? '').toLowerCase();
              final url = f['url'] as String? ?? '';
              return type.startsWith('audio/') && !url.contains('sabr-segment');
            }).toList();

            if (audioFormats.isNotEmpty) {
              // Prefer AAC (m4a/mp4) for 100% Android codec compatibility, then highest bitrate
              audioFormats.sort((a, b) {
                final isAacA = (a['type'] as String? ?? '').contains('mp4a');
                final isAacB = (b['type'] as String? ?? '').contains('mp4a');
                if (isAacA && !isAacB) return -1;
                if (!isAacA && isAacB) return 1;

                final bitA = (a['bitrate'] as num?) ?? 0;
                final bitB = (b['bitrate'] as num?) ?? 0;
                return bitB.compareTo(bitA);
              });

              final rawUrl = audioFormats.first['url'] as String?;
              if (rawUrl != null && rawUrl.isNotEmpty) {
                final uri = Uri.tryParse(rawUrl);
                if (uri != null && uri.host.contains('googlevideo.com')) {
                  final instanceUri = Uri.parse(instance);
                  final proxyUri = uri.replace(
                    scheme: instanceUri.scheme,
                    host: instanceUri.host,
                    port: instanceUri.hasPort ? instanceUri.port : null,
                  );
                  return proxyUri.toString();
                }
                return rawUrl;
              }
            }
          }
        }
      } catch (e) {
        lastError = e;
      }
    }

    Error.throwWithStackTrace(
      StateError('YouTube stream resolve failed for $videoId: $lastError'),
      StackTrace.current,
    );
  }

  void close() {
    _yt.close();
    _dio.close(force: true);
  }
}
