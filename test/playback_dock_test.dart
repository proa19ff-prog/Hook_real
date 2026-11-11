import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/app.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/mini_player.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/library/presentation/playlist_detail_screen.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _first = MediaTrack(
  id: 'first',
  title: 'Династия',
  artist: 'VILLIAN & madk1d',
  duration: Duration(minutes: 3),
  artworkUrl: '',
  source: TrackSource.soundcloud,
);
const _second = MediaTrack(
  id: 'second',
  title: 'Следующий трек с длинным названием',
  artist: 'Другой исполнитель',
  duration: Duration(minutes: 4),
  artworkUrl: '',
  source: TrackSource.soundcloud,
);
final _selected = StateProvider<MediaTrack?>((ref) => null);

class _Audio extends Fake implements AudioPlayerService {
  _Audio(this.select);
  final void Function(MediaTrack) select;
  int toggles = 0;
  List<MediaTrack> tracks = const [];
  @override
  List<MediaTrack> get trackQueue => tracks;
  @override
  Stream<int> get queueChanges => const Stream.empty();
  @override
  void prefetch(Iterable<MediaTrack> tracks, {int deep = 1}) {}
  @override
  Future<void> togglePlayPause() async {
    toggles++;
  }

  @override
  Future<void> next() async {
    select(_second);
  }

  @override
  Future<void> setQueue(List<MediaTrack> queue, {int startIndex = 0}) async {
    tracks = queue;
    select(queue[startIndex]);
  }
}

class _Cache extends Fake implements AudioCacheManager {
  @override
  Future<List<CachedTrack>> getCachedTracks() async => const [];
}

void main() {
  late ProviderContainer container;
  late _Audio audio;
  late HookTheme theme;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    theme = HookTheme.fromJson({});
    audio = _Audio((track) => container.read(_selected.notifier).state = track);
    container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
        audioPlayerServiceProvider.overrideWithValue(audio),
        audioCacheManagerProvider.overrideWithValue(_Cache()),
        currentTrackProvider.overrideWith((ref) => ref.watch(_selected)),
        playbackSourceProvider.overrideWithValue(null),
        isPlayingProvider.overrideWithValue(false),
        isTrackLoadingProvider.overrideWithValue(false),
        waveActiveProvider.overrideWithValue(false),
        playbackErrorProvider.overrideWith((ref) => const Stream.empty()),
        positionStreamProvider.overrideWith(
          (ref) => Stream.value(Duration.zero),
        ),
        durationStreamProvider.overrideWith(
          (ref) => Stream.value(_first.duration),
        ),
        youtubeAvailabilityProvider.overrideWith((ref) async => true),
      ],
    );
  });
  tearDown(() => container.dispose());

  Future<void> mount(WidgetTester tester, Widget home) async {
    tester.view.physicalSize = const Size(320, 800);
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
              textScaler: TextScaler.linear(2),
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

  testWidgets('main shell reserves player and navigation without overlap', (
    tester,
  ) async {
    container.read(_selected.notifier).state = _first;
    await mount(tester, const MainNavigationShell());
    final player = tester.getRect(find.byType(MiniPlayer));
    final navigation = tester.getRect(find.byType(NavigationBar));
    expect(player.bottom, lessThanOrEqualTo(navigation.top));
    expect(navigation.bottom, closeTo(800 - 34, 0.1));
    final body = tester.getRect(find.byType(IndexedStack));
    expect(body.bottom, lessThanOrEqualTo(player.top));
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Медиатека').last);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byType(MiniPlayer),
        matching: find.text(_first.title),
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'playlist starts playback and retains reachable current-track controls',
    (tester) async {
      await mount(
        tester,
        PlaylistDetailScreen(
          theme: theme,
          name: 'Мой плейлист',
          tracks: const [_first, _second],
        ),
      );
      expect(find.byType(MiniPlayer), findsNothing);
      await tester.ensureVisible(find.byTooltip('Слушать плейлист'));
      await tester.tap(find.byTooltip('Слушать плейлист'));
      await tester.pumpAndSettle();
      expect(find.byType(MiniPlayer), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(MiniPlayer),
          matching: find.text(_first.title),
        ),
        findsOneWidget,
      );
      expect(
        tester.getRect(find.byType(CustomScrollView)).bottom,
        lessThanOrEqualTo(tester.getRect(find.byType(MiniPlayer)).top),
      );
      await tester.tap(
        find.descendant(
          of: find.byType(MiniPlayer),
          matching: find.byTooltip('Играть'),
        ),
      );
      await tester.pump();
      expect(audio.toggles, 1);
      await tester.tap(find.byTooltip('Следующий'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(MiniPlayer),
          matching: find.text(_second.title),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty playlist reserves no invisible player space', (
    tester,
  ) async {
    await mount(
      tester,
      PlaylistDetailScreen(theme: theme, name: 'Пустой', tracks: const []),
    );
    expect(find.byType(MiniPlayer), findsNothing);
    expect(tester.getSize(find.byType(PlaybackDock)).height, 0);
    expect(tester.takeException(), isNull);
  });
}
