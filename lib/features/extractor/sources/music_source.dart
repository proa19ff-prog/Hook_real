import '../models/media_track.dart';
import '../models/resolved_stream.dart';

/// Independent source of public, full-length audio, not just catalog metadata.
abstract class MusicSource {
  TrackSource get source;
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20});
  Future<ResolvedStream?> resolveTrack(MediaTrack track);
  void close();
}
