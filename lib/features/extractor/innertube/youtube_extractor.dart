import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/media_track.dart';

class YouTubeExtractor {
  final YoutubeExplode _yt;

  YouTubeExtractor({YoutubeExplode? yt}) : _yt = yt ?? YoutubeExplode();

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
            const Duration(seconds: 15),
          );
      final tracks = <MediaTrack>[];

      for (final video in searchList.take(limit)) {
        final cleanTitle = cleanTrackTitle(video.title);

        tracks.add(
          MediaTrack(
            id: video.id.value,
            title: cleanTitle,
            artist: video.author,
            duration: video.duration ?? Duration.zero,
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

  /// Resolves direct streamable audio URL (Opus or AAC/M4A) with highest bitrate.
  Future<String?> resolveAudioStreamUrl(String videoId) async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final manifest = await _yt.videos.streamsClient
            .getManifest(videoId)
            .timeout(const Duration(seconds: 20));

        // Prefer highest bitrate audio-only stream (Opus/WebM or M4A)
        final audioStreams = manifest.audioOnly.sortByBitrate();
        if (audioStreams.isNotEmpty) {
          return audioStreams.last.url.toString();
        }

        // Fallback to muxed stream if no audio-only stream exists
        final muxedStreams = manifest.muxed.sortByBitrate();
        if (muxedStreams.isNotEmpty) {
          return muxedStreams.last.url.toString();
        }

        return null;
      } catch (e) {
        lastError = e;
        if (attempt == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 250));
        }
      }
    }

    // Keep the UI message generic, but preserve the concrete resolver
    // failure for the playback error snackbar/logging.
    Error.throwWithStackTrace(
      StateError('YouTube stream resolve failed for $videoId: $lastError'),
      StackTrace.current,
    );
  }

  void close() {
    _yt.close();
  }
}
