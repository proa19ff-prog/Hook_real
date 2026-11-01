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

  test('getSearchQueries adds catalog-friendly digit aliases', () {
    final queries = resolver.getSearchQueries('madkid rise');
    expect(queries, contains('madk1d rise'));

    final reverse = resolver.getSearchQueries('madk1d rise');
    expect(reverse, contains('madkid rise'));
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

    final originalScore =
        StreamResolver.scoreTrack(original, 'alan walker faded');
    final slowedScore =
        StreamResolver.scoreTrack(slowedReverb, 'alan walker faded');
    final loopScore = StreamResolver.scoreTrack(loop1Hour, 'alan walker faded');

    expect(originalScore, greaterThan(slowedScore));
    expect(originalScore, greaterThan(loopScore));
  });

  MediaTrack track(String title, String artist, {int sec = 220}) => MediaTrack(
        id: '$artist-$title',
        title: title,
        artist: artist,
        artworkUrl: '',
        duration: Duration(seconds: sec),
        source: TrackSource.spotify,
      );

  test('scoreTrack matches Cyrillic titles', () {
    final right = track('ДИНАСТИЯ', 'VILLIAN & madk1d');
    final wrong = track('Движуха', 'Пал Лаич');
    expect(
      StreamResolver.scoreTrack(right, 'династия madkid'),
      greaterThan(StreamResolver.scoreTrack(wrong, 'династия madkid') + 200),
    );
  });

  test('scoreCandidate prefers the original upload over a remix', () {
    final target = track('Sweater Weather', 'The Neighbourhood', sec: 240);
    MediaTrack sc(String title, String artist, int sec) => MediaTrack(
          id: title,
          title: title,
          artist: artist,
          artworkUrl: '',
          duration: Duration(seconds: sec),
          source: TrackSource.soundcloud,
        );
    final original = sc('"Sweater Weather"', 'theneighbourhood', 240);
    final remix = sc('The Neighbourhood - Sweater Weather (Marcus Melt Remix)',
        'Marcus Melt, The Neighbourhood', 201);
    final slowed =
        sc('sweater weather - the neighbourhood (slowed)', 'oleariia', 295);

    final o = StreamResolver.scoreCandidate(target, original, plays: 99000000);
    expect(o,
        greaterThan(StreamResolver.scoreCandidate(target, remix, plays: 2000)));
    expect(
        o,
        greaterThan(
            StreamResolver.scoreCandidate(target, slowed, plays: 50000)));
  });

  test('isPlayableMatch rejects alternate SoundCloud uploads', () {
    final target = MediaTrack(
      id: 'catalog',
      title: 'Sunflower',
      artist: 'Post Malone',
      artworkUrl: '',
      duration: const Duration(minutes: 2, seconds: 38),
      source: TrackSource.spotify,
    );
    MediaTrack soundCloud(
            String id, String title, String artist, int seconds) =>
        MediaTrack(
          id: id,
          title: title,
          artist: artist,
          artworkUrl: '',
          duration: Duration(seconds: seconds),
          source: TrackSource.soundcloud,
        );

    final original = soundCloud(
      'original',
      'Post Malone - Sunflower',
      'Post Malone',
      158,
    );
    final remix = soundCloud(
      'remix',
      'Sunflower (Remix)',
      'Post Malone',
      158,
    );
    final cover = soundCloud('cover', 'Sunflower', 'Acoustic Collective', 158);
    final wrongDuration = soundCloud(
      'extended',
      'Sunflower',
      'Post Malone',
      220,
    );

    expect(StreamResolver.isPlayableMatch(target, original), isTrue);
    expect(StreamResolver.isPlayableMatch(target, remix), isFalse);
    expect(StreamResolver.isPlayableMatch(target, cover), isFalse);
    expect(StreamResolver.isPlayableMatch(target, wrongDuration), isFalse);
  });

  test('scoreTrack finds a title by its first word', () {
    final full = track('Sweater Weather', 'The Neighbourhood');
    final other = track('Summer Rain', 'Someone');
    expect(
      StreamResolver.scoreTrack(full, 'sweater'),
      greaterThan(StreamResolver.scoreTrack(other, 'sweater') + 200),
    );
    expect(
      StreamResolver.scoreTrack(full, 'sweat'),
      greaterThan(StreamResolver.scoreTrack(other, 'sweat')),
    );
  });

  test('scoreTrack tolerates a small title typo and bracketed subtitle', () {
    final original = track(
      'Sunflower (Spider-Man: Into the Spider-Verse)',
      'Post Malone & Swae Lee',
    );
    final cover = track(
      'Sunflower - Spider-Man: Into the Spider-Verse',
      'Acoustic Heartstrings',
    );

    expect(
      StreamResolver.scoreTrack(original, 'sunflowee spider man'),
      greaterThan(StreamResolver.scoreTrack(cover, 'sunflowee spider man')),
    );
  });
}
