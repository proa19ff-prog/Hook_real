import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/audio_cache_manager.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/stream_resolver.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/library/presentation/library_screen.dart';
import 'package:hook/features/library/presentation/playlist_detail_screen.dart';
import 'package:hook/features/search/presentation/search_screen.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/features/theme_engine/presentation/theme_settings_screen.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _IdleAudioService extends Fake implements AudioPlayerService {
  @override
  List<MediaTrack> get trackQueue => const [];

  @override
  Stream<int> get queueChanges => const Stream.empty();

  @override
  void prefetch(Iterable<MediaTrack> tracks) {}
}

class _SearchResolver extends Fake implements StreamResolver {
  late final result = Completer<List<MediaTrack>>();

  @override
  Future<List<MediaTrack>> search({
    required String query,
    bool includeSoundCloud = true,
    bool includeSpotify = true,
    Set<TrackSource>? sources,
  }) => result.future;
}

class _EmptyCache extends Fake implements AudioCacheManager {
  @override
  Future<List<CachedTrack>> getCachedTracks() async => const [];
}

const _track = MediaTrack(
  id: 'layout-test',
  title: 'Длинное название любимого трека',
  artist: 'Исполнитель и второй исполнитель',
  duration: Duration(minutes: 3),
  artworkUrl: '',
  source: TrackSource.spotify,
);

void main() {
  late LocalStorageService storage;
  late HookTheme theme;
  late _SearchResolver resolver;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = LocalStorageService(await SharedPreferences.getInstance());
    theme = HookTheme.fromJson({});
    resolver = _SearchResolver();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          audioPlayerServiceProvider.overrideWithValue(_IdleAudioService()),
          audioCacheManagerProvider.overrideWithValue(_EmptyCache()),
          currentTrackProvider.overrideWithValue(null),
          streamResolverProvider.overrideWithValue(resolver),
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: theme.toThemeData(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.5),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: screen,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('library tabs and empty states fit narrow large-text screens', (
    tester,
  ) async {
    await pumpScreen(tester, LibraryScreen(theme: theme));
    expect(tester.takeException(), isNull);
    expect(
      tester.getSize(find.byKey(const ValueKey('library-import'))).height,
      greaterThanOrEqualTo(48),
    );
    final tabs = tester.widget<TabBar>(find.byType(TabBar));
    expect(tabs.isScrollable, isTrue);
    await tester.ensureVisible(find.text('Плейлисты'));
    await tester.tap(find.text('Плейлисты'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Офлайн'));
    await tester.tap(find.text('Офлайн'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('library populated playlists keep names and menu accessible', (
    tester,
  ) async {
    await storage.savePlaylist('Ночной плейлист с длинным названием', [_track]);
    await storage.toggleFavorite(_track);
    await pumpScreen(tester, LibraryScreen(theme: theme));
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('Плейлисты'));
    await tester.tap(find.text('Плейлисты'));
    await tester.pumpAndSettle();
    expect(find.text('Ночной плейлист с длинным названием'), findsOneWidget);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('playlist detail empty state and artwork fit large text', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      PlaylistDetailScreen(
        theme: theme,
        name: 'Мой плейлист с длинным названием',
        tracks: const [],
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(IconButton), findsNWidgets(3));
  });

  testWidgets('search modes remain scrollable with the keyboard open', (
    tester,
  ) async {
    await pumpScreen(tester, SearchScreen(theme: theme, focusRequestId: 0));
    expect(tester.takeException(), isNull);
    await tester.showKeyboard(find.byKey(const ValueKey('music-search-field')));
    tester.view.viewInsets = const FakeViewPadding(bottom: 340);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('По тексту'));
    await tester.tap(find.text('По тексту'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('search loading and results fit above the keyboard', (
    tester,
  ) async {
    await pumpScreen(tester, SearchScreen(theme: theme, focusRequestId: 0));
    await tester.enterText(
      find.byKey(const ValueKey('music-search-field')),
      'Ночной трек',
    );
    tester.view.viewInsets = const FakeViewPadding(bottom: 340);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.takeException(), isNull);
    resolver.result.complete([_track]);
    await tester.pumpAndSettle();
    expect(find.text(_track.title), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('theme import explains invalid JSON without dismissing input', (
    tester,
  ) async {
    await pumpScreen(tester, ThemeSettingsScreen(theme: theme));
    await tester.tap(find.byTooltip('Импорт JSON'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '{broken');
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(
      find.text(
        'Не удалось прочитать тему. Проверьте формат JSON и значения полей.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settings scroll and shader controls fit narrow large-text screens',
    (tester) async {
      await pumpScreen(tester, ThemeSettingsScreen(theme: theme));
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(find.byType(SwitchListTile), 240);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(Slider), findsNWidgets(3));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
