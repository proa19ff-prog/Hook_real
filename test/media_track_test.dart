import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';

void main() {
  test('MediaTrack round-trips JSON with a numeric id and duration', () {
    final track = MediaTrack(
      id: '123',
      title: 'Song',
      artist: 'Artist',
      duration: const Duration(minutes: 3, seconds: 12),
      artworkUrl: 'https://example.com/art.jpg',
      source: TrackSource.soundcloud,
    );

    final restored = MediaTrack.fromJson(track.toJson());

    expect(restored, track);
    expect(restored.duration, const Duration(minutes: 3, seconds: 12));
  });

  test('MediaTrack tolerates incomplete persisted data', () {
    final track = MediaTrack.fromJson(<String, dynamic>{
      'id': 42,
      'title': 'Legacy track',
      'artist': 'Legacy artist',
      'durationMs': 900,
    });

    expect(track.id, '42');
    expect(track.duration, const Duration(milliseconds: 900));
    expect(track.source, TrackSource.youtube);
  });
}
