import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';

MediaTrack _track(String id, {TrackSource source = TrackSource.youtube}) {
  return MediaTrack(
    id: id,
    title: 'Track $id',
    artist: 'Artist',
    duration: const Duration(minutes: 3),
    artworkUrl: '',
    source: source,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioPlayerService queue', () {
    late AudioPlayerService service;

    setUp(() {
      service = AudioPlayerService();
    });

    tearDown(() async {
      await service.dispose();
    });

    test('adds tracks without changing the current index', () {
      final first = _track('first');
      final second = _track('second', source: TrackSource.soundcloud);

      service.addToQueue(first);
      service.addToQueue(second);

      expect(service.trackQueue, [first, second]);
      expect(service.currentIndex, -1);
      expect(service.currentTrack, isNull);
    });

    test('publishes tracks to the media session queue', () {
      final first = _track('first');
      final second = _track('second', source: TrackSource.soundcloud);

      service.addToQueue(first);
      service.addToQueue(second);

      expect(
        service.queue.value.map((item) => item.id).toList(),
        ['youtube:first', 'soundcloud:second'],
      );
    });

    test('reorders tracks and keeps the queue identity intact', () {
      final first = _track('first');
      final second = _track('second');
      final third = _track('third');
      service.addToQueue(first);
      service.addToQueue(second);
      service.addToQueue(third);

      service.reorderQueue(0, 3);

      expect(service.trackQueue, [second, third, first]);
      expect(service.currentIndex, -1);
    });

    test('ignores invalid queue indexes', () {
      final first = _track('first');
      service.addToQueue(first);

      service.removeFromQueue(-1);
      service.removeFromQueue(1);
      service.reorderQueue(1, 0);

      expect(service.trackQueue, [first]);
    });

    test('removing the last queued track resets the empty state', () {
      service.addToQueue(_track('only'));

      service.removeFromQueue(0);

      expect(service.trackQueue, isEmpty);
      expect(service.currentIndex, -1);
      expect(service.currentTrack, isNull);
    });

    test('loop mode cycles through all, one, and off', () {
      expect(service.loopMode, PlayerLoopMode.off);

      service.toggleLoopMode();
      expect(service.loopMode, PlayerLoopMode.all);
      service.toggleLoopMode();
      expect(service.loopMode, PlayerLoopMode.one);
      service.toggleLoopMode();
      expect(service.loopMode, PlayerLoopMode.off);
    });
  });
}
