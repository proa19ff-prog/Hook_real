import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/fullscreen_player.dart';
import 'package:hook/features/audio_player/presentation/lyrics_focus_frame.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/home/presentation/home_screen.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/lyrics/data/lyrics_result.dart';
import 'package:hook/features/lyrics/presentation/karaoke_lyrics_view.dart';
import 'package:hook/features/settings/presentation/settings_provider.dart';
import 'package:hook/features/settings/presentation/settings_screen.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hook/features/lyrics/domain/lyric_line.dart';
import 'package:hook/features/lyrics/presentation/lyrics_translation_panel.dart';

class _FrameHarness extends StatefulWidget {
  const _FrameHarness({super.key});
  @override
  State<_FrameHarness> createState() => _FrameHarnessState();
}

class _FrameHarnessState extends State<_FrameHarness> {
  bool active = true;
  bool enabled = true;
  int track = 0;

  void configure({bool? active, bool? enabled, bool nextTrack = false}) {
    setState(() {
      if (active != null) this.active = active;
      if (enabled != null) this.enabled = enabled;
      if (nextTrack) track++;
    });
  }

  @override
  Widget build(BuildContext context) => LyricsFocusFrame(
    active: active,
    enabled: enabled,
    trackKey: track,
    builder: (context, hidden, restore) => Column(
      children: [
        LyricsChrome(
          key: const ValueKey('top'),
          hidden: hidden,
          slideUp: true,
          child: const SizedBox(height: 64, child: Text('Header')),
        ),
        const Expanded(child: Center(child: Text('Lyrics'))),
        if (hidden)
          IconButton(
            key: const ValueKey('restore'),
            tooltip: 'Restore',
            onPressed: restore,
            icon: const Icon(Icons.unfold_more),
          ),
        LyricsChrome(
          key: const ValueKey('bottom'),
          hidden: hidden,
          slideUp: false,
          child: const SizedBox(height: 80, child: Text('Controls')),
        ),
      ],
    ),
  );
}

class _RawAudio extends Fake implements AudioPlayer {
  @override
  Duration get position => Duration.zero;
}

class _Audio extends Fake implements AudioPlayerService {
  @override
  AudioPlayer get rawPlayer => _RawAudio();
  @override
  int get currentIndex => 0;
  @override
  List<MediaTrack> get trackQueue => [_track];
  @override
  PlayerLoopMode get loopMode => PlayerLoopMode.off;
}

const _track = MediaTrack(
  id: 'focus-song',
  title: 'Песня для просмотра текста',
  artist: 'Исполнитель',
  duration: Duration(minutes: 3),
  artworkUrl: '',
  source: TrackSource.soundcloud,
);
const _lyrics = LyricsResult(plainLyrics: 'Первая строка\nВторая строка');

void main() {
  Future<_FrameHarnessState> mount(
    WidgetTester tester, {
    bool reduce = false,
  }) async {
    final key = GlobalKey<_FrameHarnessState>();
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: reduce),
          child: child!,
        ),
        home: Scaffold(body: _FrameHarness(key: key)),
      ),
    );
    return key.currentState!;
  }

  double size(WidgetTester tester, String key) =>
      tester.getSize(find.byKey(ValueKey(key))).height;

  Future<void> hide(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 10));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets(
    'ten seconds hides both panels; restore starts another interval',
    (tester) async {
      await mount(tester);
      await tester.pump(const Duration(seconds: 9));
      expect(size(tester, 'top'), 64);
      expect(size(tester, 'bottom'), 80);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 160));
      expect(size(tester, 'top'), inExclusiveRange(0, 64));
      await tester.pump(const Duration(milliseconds: 200));
      expect(size(tester, 'top'), 0);
      expect(size(tester, 'bottom'), 0);
      expect(find.byTooltip('Restore'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('restore')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(size(tester, 'top'), 64);
      await tester.pump(const Duration(seconds: 9));
      expect(find.byKey(const ValueKey('restore')), findsNothing);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byKey(const ValueKey('restore')), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('cover mode and disabled preference never auto hide', (
    tester,
  ) async {
    final state = await mount(tester);
    state.configure(active: false);
    await tester.pump();
    await hide(tester);
    expect(size(tester, 'top'), 64);
    state.configure(active: true, enabled: false);
    await tester.pump();
    await hide(tester);
    expect(size(tester, 'bottom'), 80);
    expect(find.byTooltip('Restore'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('new track and disabling the preference restore hidden panels', (
    tester,
  ) async {
    final state = await mount(tester);
    await hide(tester);
    state.configure(nextTrack: true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(size(tester, 'top'), 64);
    await hide(tester);
    state.configure(enabled: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(size(tester, 'bottom'), 80);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'holding a pointer pauses countdown; release and cancel rearm it',
    (tester) async {
      await mount(tester);
      await tester.pump(const Duration(seconds: 8));
      final gesture = await tester.startGesture(const Offset(200, 200));
      await tester.pump(const Duration(seconds: 20));
      expect(find.byTooltip('Restore'), findsNothing);
      await gesture.cancel();
      await tester.pump(const Duration(seconds: 9));
      expect(size(tester, 'top'), 64);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 400));
      expect(size(tester, 'top'), 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('background and a covering route do not consume reading time', (
    tester,
  ) async {
    await mount(tester);
    await tester.pump(const Duration(seconds: 8));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 30));
    expect(size(tester, 'top'), 64);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 9));
    expect(find.byTooltip('Restore'), findsNothing);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('Another screen')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 20));
    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byTooltip('Restore'), findsNothing);
    await tester.pump(const Duration(seconds: 9));
    expect(size(tester, 'top'), 64);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(size(tester, 'top'), 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'reduced motion hides immediately and excludes hidden semantics',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await mount(tester, reduce: true);
      await tester.pump(const Duration(seconds: 10));
      expect(size(tester, 'top'), 0);
      expect(size(tester, 'bottom'), 0);
      final semanticsTree = tester
          .getSemantics(find.byType(Scaffold))
          .toStringDeep();
      expect(semanticsTree, isNot(contains('Header')));
      expect(semanticsTree, isNot(contains('Controls')));
      expect(find.byTooltip('Restore'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );

  test('auto-hide enabled default and persisted choice survive provider recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final container = ProviderContainer(
      overrides: [localStorageServiceProvider.overrideWithValue(storage)],
    );
    expect(container.read(lyricsAutoHideProvider), isTrue);
    await container.read(lyricsAutoHideProvider.notifier).setEnabled(false);
    container.dispose();
    final restored = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(
          LocalStorageService(prefs),
        ),
      ],
    );
    expect(restored.read(lyricsAutoHideProvider), isFalse);
    restored.dispose();
  });

  Future<ProviderContainer> mountApp(
    WidgetTester tester,
    Widget home, {
    double width = 390,
    double height = 844,
    double scale = 1,
    LyricsResult? lyrics = _lyrics,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final container = ProviderContainer(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storage),
        audioPlayerServiceProvider.overrideWithValue(_Audio()),
        currentTrackProvider.overrideWithValue(_track),
        playbackSourceProvider.overrideWithValue(TrackSource.soundcloud),
        isPlayingProvider.overrideWithValue(false),
        waveActiveProvider.overrideWithValue(false),
        isTrackLoadingProvider.overrideWithValue(false),
        positionStreamProvider.overrideWith(
          (ref) => Stream.value(Duration.zero),
        ),
        durationStreamProvider.overrideWith(
          (ref) => Stream.value(const Duration(minutes: 3)),
        ),
        trackLyricsProvider.overrideWith((ref) async => lyrics),
      ],
    );
    addTearDown(container.dispose);
    tester.view.physicalSize = Size(width, height);
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
          theme: HookTheme.fromJson({}).toThemeData(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: home,
        ),
      ),
    );
    await tester.pump();
    return container;
  }

  for (final (width, height, scale) in [
    (390.0, 844.0, 1.0),
    (320.0, 600.0, 2.0),
  ]) {
    testWidgets(
      'fullscreen lyrics keeps view mounted and restores at $width, $scale',
      (tester) async {
        final container = await mountApp(
          tester,
          FullscreenPlayer(theme: HookTheme.fromJson({})),
          width: width,
          height: height,
          scale: scale,
        );
        final toggle = find.byKey(const ValueKey('player-lyrics-toggle'));
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        final state = tester.state(find.byType(KaraokeLyricsView));
        final translationState = tester.state(
          find.byType(LyricsTranslationPanel),
        );
        expect(size(tester, 'lyrics-translation-chrome'), greaterThan(0));
        final target = find.byKey(const ValueKey('translation-target'));
        final dropdown = tester.widget<DropdownButton<String>>(target);
        dropdown.onChanged!('en');
        await tester.pump();
        await hide(tester);
        expect(
          find.byKey(const ValueKey('player-restore-controls')),
          findsOneWidget,
        );
        expect(size(tester, 'player-top-chrome'), 0);
        expect(size(tester, 'player-bottom-chrome'), 0);
        expect(size(tester, 'lyrics-translation-chrome'), 0);
        expect(tester.state(find.byType(KaraokeLyricsView)), same(state));
        expect(
          tester.state(find.byType(LyricsTranslationPanel)),
          same(translationState),
        );
        await tester.tap(find.byKey(const ValueKey('player-restore-controls')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(size(tester, 'player-top-chrome'), greaterThan(0));
        expect(size(tester, 'lyrics-translation-chrome'), greaterThan(0));
        expect(tester.widget<DropdownButton<String>>(target).value, 'en');
        expect(
          find.byKey(const ValueKey('player-restore-controls')),
          findsNothing,
        );
        await container.read(lyricsAutoHideProvider.notifier).setEnabled(false);
        await tester.pump();
        await hide(tester);
        expect(size(tester, 'player-top-chrome'), greaterThan(0));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  testWidgets(
    'immersive synced lyrics hides offset tools and preserves their state',
    (tester) async {
      await mountApp(
        tester,
        FullscreenPlayer(theme: HookTheme.fromJson({})),
        lyrics: const LyricsResult(
          isRealSync: true,
          lines: [
            LyricLine(
              text: 'Первая строка',
              startTime: Duration.zero,
              endTime: Duration(seconds: 30),
            ),
            LyricLine(
              text: 'Вторая строка',
              startTime: Duration(seconds: 30),
              endTime: Duration(seconds: 60),
            ),
          ],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('player-lyrics-toggle')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final strings = AppLocalizations.of(
        tester.element(find.byType(KaraokeLyricsView)),
      );
      await tester.tap(find.byTooltip(strings.adjustLyricsSync));
      await tester.pump();
      expect(find.byTooltip(strings.increaseLyricsOffset), findsOneWidget);
      await tester.tap(find.byTooltip(strings.increaseLyricsOffset));
      await tester.pump();
      await hide(tester);
      expect(size(tester, 'lyrics-sync-chrome'), 0);
      expect(size(tester, 'lyrics-translation-chrome'), 0);
      await tester.tap(find.byKey(const ValueKey('player-restore-controls')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(size(tester, 'lyrics-sync-chrome'), greaterThan(0));
      expect(find.byTooltip(strings.increaseLyricsOffset), findsOneWidget);
      expect(find.text(strings.lyricsOffset('+0.1')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('missing lyrics never hides recovery controls', (tester) async {
    await mountApp(
      tester,
      FullscreenPlayer(theme: HookTheme.fromJson({})),
      lyrics: null,
    );
    await tester.tap(find.byKey(const ValueKey('player-lyrics-toggle')));
    await tester.pump();
    await hide(tester);
    expect(find.byKey(const ValueKey('player-restore-controls')), findsNothing);
    expect(size(tester, 'player-top-chrome'), greaterThan(0));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'home gear opens general settings and switch works at large text',
    (tester) async {
      final container = await mountApp(
        tester,
        HomeScreen(theme: HookTheme.fromJson({}), onOpenSearch: () {}),
        width: 320,
        height: 600,
        scale: 2,
      );
      await tester.tap(find.byKey(const ValueKey('home-settings-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(SettingsScreen), findsOneWidget);
      final toggle = find.byKey(const ValueKey('lyrics-auto-hide-setting'));
      await tester.ensureVisible(toggle);
      await tester.pump();
      await tester.tap(toggle);
      await tester.pump();
      expect(container.read(lyricsAutoHideProvider), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
