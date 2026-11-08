import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';

MediaTrack _track(String id, {String source = 'spotify'}) => MediaTrack(
      id: id,
      title: 'T$id',
      artist: 'A$id',
      duration: const Duration(minutes: 3),
      artworkUrl: '',
      source: TrackSource.values.firstWhere((s) => s.name == source),
    );

void main() {
  group('pickRandomTrack', () {
    test('returns null on an empty pool', () {
      expect(pickRandomTrack(const []), isNull);
    });

    test('never picks the currently playing track', () {
      final pool = [_track('a'), _track('b'), _track('c')];
      final random = Random(7);
      for (var i = 0; i < 30; i++) {
        final picked = pickRandomTrack(
          pool,
          current: _track('b'),
          random: random,
        );
        expect(picked!.id, isNot('b'));
      }
    });

    test('respects the avoid set from previous rolls', () {
      final pool = [_track('a'), _track('b'), _track('c')];
      final random = Random(3);
      for (var i = 0; i < 30; i++) {
        final picked = pickRandomTrack(
          pool,
          avoidKeys: {'spotify:a', 'spotify:b'},
          random: random,
        );
        expect(picked!.id, 'c');
      }
    });

    test('falls back to the plain pool when everything is excluded', () {
      final pool = [_track('a')];
      final picked = pickRandomTrack(
        pool,
        current: _track('a'),
        avoidKeys: {'spotify:a'},
        random: Random(1),
      );
      // Dead-ending is worse than a repeat.
      expect(picked!.id, 'a');
    });

    test('keys are source-scoped: same id on another source stays eligible',
        () {
      final pool = [_track('a', source: 'youtubeMusic')];
      final picked = pickRandomTrack(
        pool,
        current: _track('a', source: 'spotify'),
        random: Random(2),
      );
      expect(picked!.source.name, 'youtubeMusic');
    });

    test('deterministic with a seeded dice, varied across the pool', () {
      final pool = [_track('a'), _track('b'), _track('c'), _track('d')];
      final seen = <String>{
        for (var i = 0; i < 40; i++)
          pickRandomTrack(pool, random: Random(i))!.id,
      };
      expect(seen.length, greaterThan(1));
    });
  });
}
