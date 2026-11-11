import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/app.dart';
import 'package:hook/core/platform/system_volume.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/desktop_player_bar.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _track = MediaTrack(
  id: 'track',
  title: 'Очень длинное название трека, которое не должно ломать строку',
  artist: 'Исполнитель с длинным именем',
  duration: Duration(minutes: 3, seconds: 21),
  artworkUrl: '',
  source: TrackSource.soundcloud,
);

final _selected = StateProvider<MediaTrack?>((ref) => _track);

class _Audio extends Fake implements AudioPlayerService {
  int seeks = 0;

  @override
  List<MediaTrack> get trackQueue => const [_track];
  @override
  Stream<int> get queueChanges => const Stream.empty();
  @override
  bool get isShuffle => false;
  @override
  PlayerLoopMode get loopMode => PlayerLoopMode.off;
  @override
  void prefetch(Iterable<MediaTrack> tracks, {int deep = 1}) {}
  @override
  void toggleShuffle() {}
  @override
  void toggleLoopMode() {}
  @override
  Future<void> togglePlayPause() async {}
  @override
  Future<void> next() async {}
  @override
  Future<void> skipToPrevious() async {}
  @override
  Future<void> seek(Duration position) async => seeks++;
}

class _Cache extends Fake implements AudioCacheManager {
  @override
  Future<List<CachedTrack>> getCachedTracks() async => const [];
}

/// A machine with a real endpoint, so the inline volume slider takes part in the
/// layout instead of being optimised away as on an unsupported platform.
class _EndpointService extends SystemVolumeService {
  @override
  Future<SystemVolumeState> read() async =>
      const SystemVolumeState(volume: 0.42, supported: true, step: 0.02);
  @override
  Stream<double>? watch() => null;
  @override
  Future<bool> setVolume(double value) async => true;
  @override
  Future<bool> setMuted(bool muted) async => true;
}

void main() {
  late ProviderContainer container;
  late HookTheme theme;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    theme = HookTheme.fromJson({});
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
        audioPlayerServiceProvider.overrideWithValue(_Audio()),
        audioCacheManagerProvider.overrideWithValue(_Cache()),
        currentTrackProvider.overrideWith((ref) => ref.watch(_selected)),
        playbackSourceProvider.overrideWithValue(null),
        isPlayingProvider.overrideWithValue(false),
        isTrackLoadingProvider.overrideWithValue(false),
        waveActiveProvider.overrideWithValue(false),
        playbackErrorProvider.overrideWith((ref) => const Stream.empty()),
        positionStreamProvider.overrideWith(
          (ref) => Stream.value(const Duration(seconds: 30)),
        ),
        durationStreamProvider.overrideWith(
          (ref) => Stream.value(_track.duration),
        ),
        youtubeAvailabilityProvider.overrideWith((ref) async => true),
        systemVolumeProvider.overrideWith(
          (ref) => SystemVolumeNotifier(service: _EndpointService()),
        ),
      ],
    );
  });

  tearDown(() => container.dispose());

  Future<void> mount(
    WidgetTester tester,
    Widget home, {
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme.toThemeData(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: const EdgeInsets.only(top: 24, bottom: 34),
              textScaler: const TextScaler.linear(2),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('player bar fits the narrowest desktop window', (tester) async {
    // 900px window minus the 232px rail is the tightest the bar ever gets.
    await mount(
      tester,
      Scaffold(bottomNavigationBar: DesktopPlayerBar(theme: theme)),
      size: const Size(668, 600),
    );
    expect(tester.takeException(), isNull);
    // Timecodes and the inline slider go before the transport ever overflows.
    expect(find.text('0:30'), findsNothing);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text(_track.title), findsOneWidget);
  });

  testWidgets('player bar restores timecodes and volume when there is room', (
    tester,
  ) async {
    await mount(
      tester,
      Scaffold(bottomNavigationBar: DesktopPlayerBar(theme: theme)),
      size: const Size(1200, 600),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('0:30'), findsOneWidget);
    expect(find.text('3:21'), findsOneWidget);
    // Seek line plus the system volume slider.
    expect(find.byType(Slider), findsNWidgets(2));
  });

  testWidgets('desktop shell swaps the bottom navigation for a rail', (
    tester,
  ) async {
    await mount(
      tester,
      const MainNavigationShell(),
      size: const Size(1280, 800),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(DesktopPlayerBar), findsOneWidget);
  });

  testWidgets('the rail switches screens without a bottom navigation', (
    tester,
  ) async {
    await mount(
      tester,
      const MainNavigationShell(),
      size: const Size(1280, 800),
    );
    await tester.tap(find.widgetWithText(InkWell, 'Поиск'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // The search screen is up and the player bar is still docked below it.
    expect(find.byType(TextField), findsWidgets);
    expect(find.byType(DesktopPlayerBar), findsOneWidget);
  });
}
