import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/core/ui/hook_icons.dart';
import 'package:hook/core/ui/hook_tokens.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/home/presentation/home_screen.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/recommendations/recommendation_service.dart';
import 'package:hook/features/search/presentation/search_screen.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

MediaTrack _track(
  String id, {
  String artist = 'Artist A',
  String title = 'Song',
}) => MediaTrack(
  id: id,
  title: '$title $id',
  artist: artist,
  duration: const Duration(minutes: 3),
  artworkUrl: '',
  source: TrackSource.spotify,
);

class _TestAudioPlayerService extends AudioPlayerService {
  MediaTrack? lastWaveSeed;
  bool waveStarted = false;

  _TestAudioPlayerService({
    required super.resolver,
    required super.storageService,
    required super.cacheManager,
  });

  @override
  Future<void> startWave(MediaTrack seed) async {
    lastWaveSeed = seed;
    waveStarted = true;
  }
}

class _IdleAudioService extends Fake implements AudioPlayerService {
  @override
  bool get waveActive => false;

  @override
  List<MediaTrack> get trackQueue => const [];

  @override
  Stream<int> get queueChanges => const Stream.empty();

  @override
  void prefetch(Iterable<MediaTrack> tracks, {int deep = 1}) {}
}

class _EmptyCache extends Fake implements AudioCacheManager {
  @override
  Future<List<CachedTrack>> getCachedTracks() async => const [];
}

class _SearchResolver extends Fake implements StreamResolver {
  @override
  Future<List<MediaTrack>> search({
    required String query,
    bool includeSoundCloud = true,
    bool includeSpotify = true,
    Set<TrackSource>? sources,
  }) async => const [];
}

class _MockRecommendationService extends Fake implements RecommendationService {
  @override
  Future<List<MediaTrack>> getPersonalizedRecommendations({
    int limit = 25,
    DateTime? currentTime,
  }) async => const [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LocalStorageService storage;
  late HookTheme theme;
  late _SearchResolver resolver;
  late _MockRecommendationService recommendationService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    theme = HookTheme.fromJson({});
    resolver = _SearchResolver();
    recommendationService = _MockRecommendationService();
  });

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    List<Override> overrides = const [],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          audioPlayerServiceProvider.overrideWithValue(_IdleAudioService()),
          audioCacheManagerProvider.overrideWithValue(_EmptyCache()),
          currentTrackProvider.overrideWithValue(null),
          streamResolverProvider.overrideWithValue(resolver),
          recommendationServiceProvider.overrideWithValue(
            recommendationService,
          ),
          personalMixSeedProvider.overrideWith((ref) async => null),
          ...overrides,
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme.toThemeData(),
          home: screen,
        ),
      ),
    );
    await tester.pump();
  }

  group('Auto-recommendation & QueueNotifier', () {
    test('QueueNotifier.playRandom picks from favorites or history and starts wave', () async {
      final track1 = _track('1', title: 'Favorite');
      await storage.toggleFavorite(track1);

      final cache = AudioCacheManager();
      final service = _TestAudioPlayerService(
        resolver: resolver,
        storageService: storage,
        cacheManager: cache,
      );

      final container = ProviderContainer(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          audioPlayerServiceProvider.overrideWithValue(service),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(queueProvider.notifier);
      await notifier.playRandom();

      expect(service.waveStarted, isTrue);
      expect(service.lastWaveSeed?.id, '1');
    });
  });

  group('SearchScreen UI', () {
    testWidgets(
      'search field has rounded outline border matching design tokens',
      (tester) async {
        await pumpScreen(tester, SearchScreen(theme: theme, focusRequestId: 0));

        final textField = tester.widget<TextField>(
          find.byKey(const ValueKey('music-search-field')),
        );
        final decoration = textField.decoration!;
        expect(decoration.filled, isTrue);
        expect(decoration.border, isA<OutlineInputBorder>());
        final border = decoration.border! as OutlineInputBorder;
        expect(border.borderRadius, HookRadius.lgAll);
      },
    );

    testWidgets('search screen renders mode buttons in segmented container', (
      tester,
    ) async {
      await pumpScreen(tester, SearchScreen(theme: theme, focusRequestId: 0));

      expect(find.text('Музыка'), findsOneWidget);
      expect(find.text('По тексту'), findsOneWidget);
    });
  });

  group('HomeScreen Random Button UI', () {
    testWidgets('home screen displays shuffle random button next to search', (
      tester,
    ) async {
      await pumpScreen(tester, HomeScreen(theme: theme, onOpenSearch: () {}));

      // Verify the random shuffle icon exists in the search row
      expect(find.byIcon(HookIcons.shuffle), findsAtLeastNWidgets(1));
    });

    testWidgets(
      'home screen wave card offers random recommendation button when no seed exists',
      (tester) async {
        await pumpScreen(tester, HomeScreen(theme: theme, onOpenSearch: () {}));

        expect(find.text('Не знаете, что послушать?'), findsOneWidget);
        expect(find.byKey(const ValueKey('home-wave-button')), findsOneWidget);
      },
    );
  });
}
