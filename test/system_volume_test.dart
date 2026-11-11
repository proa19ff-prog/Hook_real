import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/platform/system_volume.dart';

class _FakeService extends SystemVolumeService {
  _FakeService();

  double level = 0.5;
  bool muted = false;
  final List<double> writes = [];
  final List<bool> muteWrites = [];
  final _controller = StreamController<double>.broadcast();

  @override
  Future<SystemVolumeState> read() async => SystemVolumeState(
    volume: level,
    muted: muted,
    supported: true,
    step: 0.02,
  );

  @override
  Stream<double>? watch() => _controller.stream;

  @override
  Future<bool> setVolume(double value) async {
    writes.add(value);
    level = value;
    muted = false;
    return true;
  }

  @override
  Future<bool> setMuted(bool value) async {
    muteWrites.add(value);
    muted = value;
    return true;
  }

  void emit(double value) => _controller.add(value);

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeService service;
  late SystemVolumeNotifier notifier;

  setUp(() {
    service = _FakeService();
    notifier = SystemVolumeNotifier(service: service);
  });

  tearDown(() => notifier.dispose());

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('bootstraps from the OS endpoint', () async {
    await settle();
    expect(notifier.state.supported, isTrue);
    expect(notifier.state.volume, closeTo(0.5, 1e-9));
  });

  test('the slider unmutes an endpoint muted elsewhere', () async {
    await settle();
    service.emit(0);
    await settle();
    expect(notifier.state.muted, isTrue);

    notifier.setVolume(0.42);
    await settle();

    expect(service.writes.last, closeTo(0.42, 1e-9));
    expect(service.muteWrites.last, isFalse);
    expect(notifier.state.muted, isFalse);
  });

  test('mute round-trips back to the previous level', () async {
    await settle();
    notifier.setVolume(0.7);
    await settle();

    notifier.toggleMute();
    await settle();
    expect(notifier.state.muted, isTrue);
    expect(service.muteWrites.last, isTrue);

    notifier.toggleMute();
    await settle();
    expect(notifier.state.muted, isFalse);
    expect(notifier.state.volume, closeTo(0.7, 1e-9));
    expect(service.muteWrites.last, isFalse);
  });

  test(
    'volume-down on a muted endpoint stays muted, volume-up restores',
    () async {
      await settle();
      notifier.toggleMute();
      await settle();
      final mutedLevel = notifier.state.volume;

      notifier.nudge(-1);
      await settle();
      expect(notifier.state.muted, isTrue);
      expect(notifier.state.volume, closeTo(mutedLevel, 1e-9));

      notifier.nudge(1);
      await settle();
      expect(notifier.state.muted, isFalse);
    },
  );

  test('nudges land on whole OS steps', () async {
    await settle();
    notifier.setVolume(0.5);
    await settle();
    notifier.nudge(1);
    await settle();
    expect(service.writes.last, closeTo(0.52, 1e-9));
    notifier.nudge(-2);
    await settle();
    expect(service.writes.last, closeTo(0.48, 1e-9));
  });
}
