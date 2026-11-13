import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/fullscreen_lyrics_bottom_bar.dart';
import 'package:hook/features/audio_player/presentation/fullscreen_player.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/lyrics/data/lyrics_result.dart';
import 'package:hook/features/lyrics/presentation/karaoke_lyrics_view.dart';
import 'package:hook/features/search/presentation/artist_screen.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAudioPlayer extends Fake implements AudioPlayer {
  @override
  Duration get position => const Duration(seconds: 45);
}

class _FakeAudioPlayerService extends Fake implements AudioPlayerService {
  @override
  AudioPlayer get rawPlayer => _FakeAudioPlayer();

  @override
  int get currentIndex => 0;

  @override
  List<MediaTrack> get trackQueue => [_testTrack];

  @override
  PlayerLoopMode get loopMode => PlayerLoopMode.off;

  bool playPauseToggled = false;
  bool nextCalled = false;
  bool previousCalled = false;
  Duration? seekTarget;

  @override
  Future<void> togglePlayPause() async => playPauseToggled = true;

  @override
  Future<void> next() async => nextCalled = true;

  @override
  Future<void> previous() async => previousCalled = true;

  @override
  Future<void> seek(Duration position) async {
    seekTarget = position;
  }
}

const _testTrack = MediaTrack(
  id: 'lyr-123',
  title: 'Sunflower (Spider-Man)',
  artist: 'Post Malone и Swae Lee',
  duration: Duration(minutes: 3, seconds: 12),
  artworkUrl: '',
  source: TrackSource.remote,
);

const _testLyrics = LyricsResult(
  plainLyrics: "Ayy, ayy, ayy, ayy (ooh)\nNeedless to say, I keep in check\nShe was a bad-bad, nevertheless",
);

void main() {
  group('FullscreenLyricsBottomBar', () {
    testWidgets('renders preview artwork, title, multi-artist, and timeline', (
      tester,
    ) async {
      final fakePlayer = _FakeAudioPlayerService();
      var collapsed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            audioPlayerServiceProvider.overrideWithValue(fakePlayer),
            isPlayingProvider.overrideWithValue(true),
            isTrackLoadingProvider.overrideWithValue(false),
            positionStreamProvider.overrideWith(
              (ref) => Stream.value(const Duration(seconds: 45)),
            ),
            durationStreamProvider.overrideWith(
              (ref) => Stream.value(const Duration(minutes: 3, seconds: 12)),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: FullscreenLyricsBottomBar(
                theme: HookTheme.fromJson({}),
                track: _testTrack,
                onCollapse: () => collapsed = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and artist text
      expect(find.text('Sunflower (Spider-Man)'), findsOneWidget);
      expect(find.byType(InteractiveArtistText), findsOneWidget);

      // Check timeline timecodes (0:45 and 3:12)
      expect(find.text('0:45'), findsOneWidget);
      expect(find.text('3:12'), findsOneWidget);

      // Check playback toggle button
      await tester.tap(find.byTooltip('Пауза'));
      expect(fakePlayer.playPauseToggled, isTrue);

      // Check collapse button
      final collapseBtn = find.byKey(
        const ValueKey('player-lyrics-bottom-collapse'),
      );
      expect(collapseBtn, findsOneWidget);
      await tester.tap(collapseBtn);
      expect(collapsed, isTrue);
    });
  });

  group('FullscreenPlayer lyrics expansion', () {
    testWidgets(
      'expands to fullscreen lyrics and collapses back via bottom bar',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        final storage = LocalStorageService(
          await SharedPreferences.getInstance(),
        );
        final fakePlayer = _FakeAudioPlayerService();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              localStorageServiceProvider.overrideWithValue(storage),
              audioPlayerServiceProvider.overrideWithValue(fakePlayer),
              currentTrackProvider.overrideWithValue(_testTrack),
              playbackSourceProvider.overrideWithValue(TrackSource.remote),
              isPlayingProvider.overrideWithValue(false),
              isTrackLoadingProvider.overrideWithValue(false),
              waveActiveProvider.overrideWithValue(false),
              positionStreamProvider.overrideWith(
                (ref) => Stream.value(const Duration(seconds: 30)),
              ),
              durationStreamProvider.overrideWith(
                (ref) => Stream.value(const Duration(minutes: 3, seconds: 12)),
              ),
              trackLyricsProvider.overrideWith((ref) async => _testLyrics),
            ],
            child: MaterialApp(
              locale: const Locale('ru'),
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              theme: HookTheme.fromJson({}).toThemeData(),
              home: FullscreenPlayer(
                theme: HookTheme.fromJson({}),
                initialLyrics: true,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        // In initialLyrics mode, the expand button is present
        final expandBtn = find.byKey(
          const ValueKey('player-lyrics-fullscreen-expand'),
        );
        expect(expandBtn, findsOneWidget);

        // Tap expand to enter fullscreen lyrics
        await tester.tap(expandBtn);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Now fullscreen lyrics bottom bar is present
        expect(find.byType(FullscreenLyricsBottomBar), findsOneWidget);
        expect(find.byType(KaraokeLyricsView), findsOneWidget);

        // Tap bottom collapse button to return to standard view
        final bottomCollapse = find.byKey(
          const ValueKey('player-lyrics-bottom-collapse'),
        );
        await tester.tap(bottomCollapse);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // Standard view is restored, bottom bar is gone
        expect(find.byType(FullscreenLyricsBottomBar), findsNothing);

        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}
