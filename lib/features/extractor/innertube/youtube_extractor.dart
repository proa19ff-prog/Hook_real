import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/media_track.dart';

class YouTubeExtractor {
  final YoutubeExplode _yt;

  YouTubeExtractor({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

  /// Clients whose stream URLs play in ExoPlayer/AVPlayer without extra
  /// headers or signature deciphering. Asking a single client at a time and
  /// skipping the watch page keeps resolving to one or two HTTP requests.
  static final List<List<YoutubeApiClient>> _clientChain = [
    [YoutubeApiClient.androidVr],
    [YoutubeApiClient.ios],
    [YoutubeApiClient.tv],
  ];

  /// Cleans track title by stripping common junk like "(Official Video)", "[4K]", etc.
  /// This ensures optimal matching with LRCLIB for lyrics and clean UI display.
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

  /// Searches tracks on YouTube / YouTube Music without any external backend.
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    try {
      final searchList = await _yt.search.search(query).timeout(
            const Duration(seconds: 10),
          );
      final tracks = <MediaTrack>[];

      for (final video in searchList) {
        if (tracks.length >= limit) break;
        // Live streams and premieres have no fixed duration and cannot be
        // played as a regular audio file.
        if (video.isLive || video.duration == null) continue;

        tracks.add(
          MediaTrack(
            id: video.id.value,
            title: cleanTrackTitle(video.title),
            artist: video.author,
            duration: video.duration!,
            // Search rows display a 48px tile.  Avoid downloading the
            // high-resolution thumbnail for every result.
            artworkUrl: video.thumbnails.mediumResUrl,
            source: TrackSource.youtube,
          ),
        );
      }

      return tracks;
    } catch (e) {
      return [];
    }
  }

  /// Resolves a direct audio URL. AAC/M4A is preferred because it plays on
  /// every platform and matches the `.m4a` extension used by the disk cache.
  Future<String?> resolveAudioStreamUrl(String videoId) async {
    Object? lastError;
    for (final clients in _clientChain) {
      try {
        final manifest = await _yt.videos.streamsClient
            .getManifest(videoId, ytClients: clients, requireWatchPage: false)
            .timeout(const Duration(seconds: 10));

        final audio = manifest.audioOnly.toList();
        if (audio.isNotEmpty) {
          final mp4 =
              audio.where((s) => s.container == StreamContainer.mp4).toList();
          // sortByBitrate() sorts in descending order.
          final best = (mp4.isNotEmpty ? mp4 : audio).sortByBitrate().first;
          return best.url.toString();
        }

        final muxed = manifest.muxed.sortByBitrate();
        if (muxed.isNotEmpty) return muxed.first.url.toString();
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
  }
}
