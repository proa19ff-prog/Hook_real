import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/fullscreen_player.dart';
import 'package:hook/features/audio_player/presentation/playback_controls.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/audio_player/presentation/swipe_track_transition.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _DeckHarness extends StatefulWidget {
  final bool reduceMotion;
  final bool delayedPlayback;
  final bool wrap;
  const _DeckHarness({
    super.key,
    this.reduceMotion = false,
    this.delayedPlayback = false,
    this.wrap = false,
  });
  @override
  State<_DeckHarness> createState() => _DeckHarnessState();
}

class _DeckHarnessState extends State<_DeckHarness> {
  final deck = GlobalKey<SwipeTrackTransitionState>();
  final pending = <Completer<void>>[];
  int index = 0;
  int nextCalls = 0;
  int previousCalls = 0;

  Future<void> next() {
    nextCalls++;
    if (index < 2 || widget.wrap) setState(() => index = (index + 1) % 3);
    if (!widget.delayedPlayback) return Future.value();
    final request = Completer<void>();
    pending.add(request);
    return request.future;
  }

  Future<void> previous() async {
    previousCalls++;
    if (index > 0 || widget.wrap) setState(() => index = (index + 2) % 3);
  }

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(disableAnimations: widget.reduceMotion),
    child: Column(
      children: [
        SwipeTrackTransition(
          key: deck,
          trackKey: index,
          queueIndex: index,
          onNext: next,
          onPrevious: previous,
          child: SizedBox(
            width: double.infinity,
            height: 360,
            child: ColoredBox(
              color: [Colors.teal, Colors.blueGrey, Colors.brown][index],
              child: Center(
                child: Text('Track $index', key: ValueKey('track-$index')),
              ),
            ),
          ),
        ),
        const SizedBox(
          key: ValueKey('stationary-controls'),
          height: 80,
          child: Center(child: Text('Play / pause')),
        ),
      ],
    ),
  );
  @override
  void dispose() {
    for (final request in pending) {
      if (!request.isCompleted) request.complete();
    }
    super.dispose();
  }
}

const _tracks = [
  MediaTrack(
    id: 'first',
    title: 'Первый трек с длинным названием',
    artist: 'Первый исполнитель',
    duration: Duration(minutes: 3),
    artworkUrl: '',
    source: TrackSource.soundcloud,
  ),
  MediaTrack(
    id: 'second',
    title: 'Второй трек',
    artist: 'Второй исполнитель',
    duration: Duration(minutes: 3),
    artworkUrl: '',
    source: TrackSource.soundcloud,
  ),
];
final _selection = StateProvider<MediaTrack>((ref) => _tracks.first);

class _Audio extends Fake implements AudioPlayerService {
  final void Function(MediaTrack) select;
  int index = 0;
  _Audio(this.select);
  @override
  int get currentIndex => index;
  @override
  List<MediaTrack> get trackQueue => _tracks;
  @override
  PlayerLoopMode get loopMode => PlayerLoopMode.off;
  @override
  Future<void> next() async {
    index = 1;
    select(_tracks[1]);
  }

  @override
  Future<void> previousTrack() async {
    index = 0;
    select(_tracks[0]);
  }

  @override
  Future<void> previous() => previousTrack();
}

void main() {
  Future<_DeckHarnessState> mount(
    WidgetTester tester, {
    bool reduce = false,
    bool delayed = false,
    bool wrap = false,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey<_DeckHarnessState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _DeckHarness(
            key: key,
            reduceMotion: reduce,
            delayedPlayback: delayed,
            wrap: wrap,
          ),
        ),
      ),
    );
    return key.currentState!;
  }

  double currentX(WidgetTester tester) => tester
      .widget<Transform>(find.byKey(const ValueKey('player-current-track')))
      .transform
      .storage[12];
  double outgoingX(WidgetTester tester) => tester
      .widget<Transform>(find.byKey(const ValueKey('player-outgoing-track')))
      .transform
      .storage[12];

  Future<void> slowDrag(WidgetTester tester, double distance) =>
      tester.timedDragFrom(
        const Offset(195, 160),
        Offset(distance, 0),
        const Duration(milliseconds: 600),
      );

  testWidgets(
    'track follows the finger, then old/new panels slide in the swipe direction',
    (tester) async {
      final state = await mount(tester);
      final controls = tester.getRect(
        find.byKey(const ValueKey('stationary-controls')),
      );
      final gesture = await tester.startGesture(const Offset(195, 160));
      await gesture.moveBy(const Offset(-90, 0));
      await tester.pump(const Duration(milliseconds: 150));
      expect(currentX(tester), lessThan(-40));
      await gesture.up();
      await tester.pump();
      expect(state.index, 1);
      expect(find.text('Track 0'), findsOneWidget);
      expect(find.text('Track 1'), findsOneWidget);
      expect(currentX(tester), greaterThan(0));
      expect(outgoingX(tester), lessThan(0));
      await tester.pump(const Duration(milliseconds: 120));
      expect(currentX(tester), inExclusiveRange(0, 390));
      expect(outgoingX(tester), lessThan(-90));
      expect(
        tester.getRect(find.byKey(const ValueKey('stationary-controls'))),
        controls,
      );
      await tester.pumpAndSettle();
      expect(currentX(tester), 0);
      expect(find.text('Track 0'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('right swipe and loop wrap keep the correct direction', (
    tester,
  ) async {
    final state = await mount(tester, wrap: true);
    await slowDrag(tester, 90);
    await tester.pump();
    expect(state.index, 2);
    expect(currentX(tester), lessThan(0));
    await tester.pumpAndSettle();
    state.deck.currentState!.navigate(TrackSwipeDirection.next);
    await tester.pump();
    expect(state.index, 0);
    expect(currentX(tester), greaterThan(0));
    await tester.pumpAndSettle();
    expect(state.previousCalls, 1);
    expect(state.nextCalls, 1);
  });

  testWidgets(
    'short/cancelled drag and queue edge settle without changing tracks',
    (tester) async {
      final state = await mount(tester);
      await slowDrag(tester, -32);
      await tester.pumpAndSettle();
      expect(state.nextCalls, 0);
      expect(currentX(tester), 0);
      final gesture = await tester.startGesture(const Offset(195, 160));
      await gesture.moveBy(const Offset(-70, 0));
      await tester.pump();
      await gesture.cancel();
      await tester.pumpAndSettle();
      expect(state.nextCalls, 0);
      await slowDrag(tester, 90);
      await tester.pumpAndSettle();
      expect(state.previousCalls, 1);
      expect(state.index, 0);
      expect(currentX(tester), 0);
      expect(find.byKey(const ValueKey('player-outgoing-track')), findsNothing);
    },
  );

  testWidgets(
    'fast repeated navigation never waits for audio or piles up outgoing panels',
    (tester) async {
      final state = await mount(tester, delayed: true);
      state.deck.currentState!.navigate(TrackSwipeDirection.next);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      final offset = currentX(tester);
      state.deck.currentState!.navigate(TrackSwipeDirection.next);
      await tester.pump();
      expect(state.index, 2);
      expect(state.pending, hasLength(2));
      expect(
        find.byKey(const ValueKey('player-outgoing-track')),
        findsOneWidget,
      );
      expect(outgoingX(tester), closeTo(offset, 1));
      expect(find.text('Track 0'), findsNothing);
      await tester.pumpAndSettle();
      state.pending.first.complete();
      await tester.pump();
      expect(state.index, 2);
      expect(find.text('Track 2'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('vertical scrolling does not select another track', (
    tester,
  ) async {
    final state = await mount(tester);
    await tester.drag(find.text('Track 0'), const Offset(0, -160));
    await tester.pumpAndSettle();
    expect(state.index, 0);
    expect(state.nextCalls + state.previousCalls, 0);
  });

  testWidgets(
    'reduced motion still navigates without moving or retaining old artwork',
    (tester) async {
      final state = await mount(tester, reduce: true);
      await slowDrag(tester, -90);
      await tester.pump();
      expect(state.index, 1);
      expect(currentX(tester), 0);
      expect(find.text('Track 0'), findsNothing);
      expect(find.byKey(const ValueKey('player-outgoing-track')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  for (final (width, height, scale) in [
    (320.0, 844.0, 1.0),
    (390.0, 844.0, 1.0),
    (320.0, 600.0, 2.0),
  ]) {
    testWidgets(
      'fullscreen cover and metadata move together at $width x $height, text $scale; controls stay fixed',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final storage = LocalStorageService(
          await SharedPreferences.getInstance(),
        );
        late ProviderContainer container;
        final audio = _Audio(
          (track) => container.read(_selection.notifier).state = track,
        );
        container = ProviderContainer(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
            audioPlayerServiceProvider.overrideWithValue(audio),
            currentTrackProvider.overrideWith((ref) => ref.watch(_selection)),
            playbackSourceProvider.overrideWithValue(TrackSource.soundcloud),
            isPlayingProvider.overrideWithValue(false),
            isTrackLoadingProvider.overrideWithValue(false),
            positionStreamProvider.overrideWith(
              (ref) => Stream.value(Duration.zero),
            ),
            durationStreamProvider.overrideWith(
              (ref) => Stream.value(const Duration(minutes: 3)),
            ),
          ],
        );
        addTearDown(container.dispose);
        tester.view.physicalSize = Size(width, height);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final theme = HookTheme.fromJson({});
        final screenshotKey = GlobalKey();
        final frames = <ui.Image>[];
        final capture =
            const bool.fromEnvironment('SWIPE_SCREENSHOTS') && width == 390;
        if (capture) {
          await tester.runAsync(() async {
            final font = FontLoader('Inter')
              ..addFont(
                rootBundle.load('assets/fonts/inter-regular/Inter-Regular.ttf'),
              )
              ..addFont(
                rootBundle.load('assets/fonts/inter-bold/Inter-Bold.ttf'),
              );
            await font.load();
          });
        }
        Future<void> captureFrame() async {
          if (!capture) return;
          await tester.runAsync(() async {
            final boundary =
                screenshotKey.currentContext!.findRenderObject()
                    as RenderRepaintBoundary;
            frames.add(await boundary.toImage(pixelRatio: 0.6));
          });
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              locale: const Locale('ru'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: theme.toThemeData(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: RepaintBoundary(
                key: screenshotKey,
                child: FullscreenPlayer(theme: theme),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 30));
        await captureFrame();
        final controls = tester.getRect(find.byType(PlaybackControls));
        await tester.drag(
          find.byKey(const ValueKey('player-track-swipe-area')),
          const Offset(-120, 0),
        );
        await tester.pump();
        expect(container.read(currentTrackProvider), _tracks[1]);
        expect(find.text(_tracks[0].title), findsOneWidget);
        expect(find.text(_tracks[1].title), findsOneWidget);
        expect(find.text(_tracks[0].artist), findsOneWidget);
        expect(find.text(_tracks[1].artist), findsOneWidget);
        await tester.pump(const Duration(milliseconds: 120));
        await captureFrame();
        expect(tester.getRect(find.byType(PlaybackControls)), controls);
        await tester.pump(const Duration(milliseconds: 400));
        await captureFrame();
        expect(find.text(_tracks[0].title), findsNothing);
        expect(tester.takeException(), isNull);
        if (capture) {
          await tester.runAsync(() async {
            final recorder = ui.PictureRecorder();
            final canvas = Canvas(recorder);
            for (var i = 0; i < frames.length; i++) {
              canvas.drawImage(
                frames[i],
                Offset((frames.first.width * i).toDouble(), 0),
                Paint(),
              );
            }
            final picture = recorder.endRecording();
            final image = await picture.toImage(
              frames.first.width * frames.length,
              frames.first.height,
            );
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('build/swipe-preview').create(recursive: true);
            await File('build/swipe-preview/transition.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            for (final frame in frames) {
              frame.dispose();
            }
            image.dispose();
            picture.dispose();
          });
        }
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
