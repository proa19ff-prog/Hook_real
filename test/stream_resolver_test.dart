import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/stream_resolver.dart';

void main() {
  late StreamResolver resolver;

  setUp(() {
    resolver = StreamResolver();
  });

  tearDown(() {
    resolver.dispose();
  });

  test('fixKeyboardLayout converts English layout slip to Russian', () {
    expect(StreamResolver.fixKeyboardLayout('fkfy djkrth'), 'алан волкер');
    expect(StreamResolver.fixKeyboardLayout('vbzub'), 'мияги');
  });

  test('getSearchQueries expands phonetic queries', () {
    final queries = resolver.getSearchQueries('алан волкер');
    expect(queries.any((q) => q.toLowerCase().contains('alan walker')), isTrue);

    final phonkQueries = resolver.getSearchQueries('фонк');
    expect(phonkQueries.any((q) => q.toLowerCase().contains('phonk')), isTrue);
  });

  test('scoreTrack prioritizes original songs over bootleg edits', () {
    final original = MediaTrack(
      id: '1',
      title: 'Faded',
      artist: 'Alan Walker',
      artworkUrl: 'https://example.com/art.jpg',
      duration: const Duration(minutes: 3, seconds: 32),
      source: TrackSource.soundcloud,
    );

    final slowedReverb = MediaTrack(
      id: '2',
      title: 'Faded (Slowed + Reverb)',
      artist: 'Alan Walker',
      artworkUrl: 'https://example.com/art.jpg',
      duration: const Duration(minutes: 4, seconds: 20),
      source: TrackSource.soundcloud,
    );

    final loop1Hour = MediaTrack(
      id: '3',
      title: 'Alan Walker - Faded (1 hour loop)',
      artist: 'Various',
      artworkUrl: 'https://example.com/art.jpg',
      duration: const Duration(hours: 1),
      source: TrackSource.soundcloud,
    );

    final originalScore = StreamResolver.scoreTrack(original, 'alan walker faded');
    final slowedScore = StreamResolver.scoreTrack(slowedReverb, 'alan walker faded');
    final loopScore = StreamResolver.scoreTrack(loop1Hour, 'alan walker faded');

    expect(originalScore, greaterThan(slowedScore));
    expect(originalScore, greaterThan(loopScore));
  });
}
