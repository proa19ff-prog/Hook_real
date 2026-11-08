import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/core/storage/local_storage_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/import/import_file_picker.dart';
import 'package:hook/features/import/music_import_service.dart';
import 'package:hook/features/import/presentation/import_bottom_sheet.dart';
import 'package:hook/features/library/presentation/library_provider.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestImportService extends MusicImportService {
  @override
  Future<ImportedCollection> importFromCsv(String csv, {String? title}) async {
    return ImportedCollection(
      title: title ?? 'Exportify',
      author: 'CSV',
      artworkUrl: '',
      tracks: MusicImportService.parseCsv(csv),
      platform: ImportPlatform.csv,
    );
  }
}

class _GatedStorage extends LocalStorageService {
  _GatedStorage(super.prefs);

  Completer<void>? gate;
  int saveCalls = 0;

  @override
  Future<void> savePlaylist(String name, List<MediaTrack> tracks) async {
    saveCalls++;
    await gate?.future;
    await super.savePlaylist(name, tracks);
  }
}

void testOnPlatform(
  String description,
  WidgetTesterCallback callback, {
  TargetPlatform platform = TargetPlatform.android,
}) {
  testWidgets(
    description,
    callback,
    variant: TargetPlatformVariant.only(platform),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _GatedStorage storage;
  late _TestImportService service;
  const csv =
      'Track URI,Track Name,Artist Name(s),Duration (ms)\n'
      'spotify:track:abc123,Sunflower,Post Malone; Swae Lee,158000';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = _GatedStorage(await SharedPreferences.getInstance());
    service = _TestImportService();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ImportFilePicker.channel, null);
    service.close();
  });

  Future<void> openSheet(WidgetTester tester, {bool largeText = false}) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final theme = HookTheme.fromJson({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localStorageServiceProvider.overrideWithValue(storage),
          musicImportServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          theme: theme.toThemeData(),
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(largeText ? 1.6 : 1)),
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => ImportBottomSheet.show(context, theme),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, String key) async {
    final target = find.byKey(ValueKey(key));
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  void mockFile({String text = csv, String name = 'Night mix.CSV'}) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ImportFilePicker.channel, (call) async {
          expect(call.method, 'pickTextFile');
          return {'name': name, 'bytes': Uint8List.fromList(utf8.encode(text))};
        });
  }

  testOnPlatform('selects CSV, previews metadata, renames and saves locally', (
    tester,
  ) async {
    mockFile();
    await openSheet(tester, largeText: true);
    await tapVisible(tester, 'import-mode-file');
    await tapVisible(tester, 'import-choose-file');
    expect(find.text('Импортировано из CSV'), findsOneWidget);
    expect(find.text('Sunflower'), findsOneWidget);
    expect(find.text('Post Malone, Swae Lee'), findsOneWidget);
    expect(find.text('Night mix.CSV'), findsOneWidget);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    final name = find.byKey(const ValueKey('import-playlist-name'));
    await tester.ensureVisible(name);
    await tester.enterText(name, 'Моя коллекция');
    await tapVisible(tester, 'import-save');
    final saved = storage.getPlaylists()['Моя коллекция']!;
    expect(saved.single.id, 'sp_abc123');
    expect(saved.single.duration, const Duration(milliseconds: 158000));
    expect(find.byType(ImportBottomSheet), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testOnPlatform('cancelling picker leaves file selection available', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ImportFilePicker.channel, (_) async => null);
    await openSheet(tester);
    await tapVisible(tester, 'import-mode-file');
    await tapVisible(tester, 'import-choose-file');
    expect(find.byKey(const ValueKey('import-error')), findsNothing);
    expect(find.byKey(const ValueKey('import-save')), findsNothing);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('import-choose-file')),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
  });

  testOnPlatform('malformed CSV stays in input state with a useful error', (
    tester,
  ) async {
    mockFile(text: 'Title,Artist\n"Unclosed,Artist');
    await openSheet(tester);
    await tapVisible(tester, 'import-mode-file');
    await tapVisible(tester, 'import-choose-file');
    expect(find.textContaining('CSV повреждён'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-save')), findsNothing);
    expect(storage.getPlaylists(), isEmpty);
    expect(tester.takeException(), isNull);
  });

  testOnPlatform('native byte-limit errors are localized and recoverable', (
    tester,
  ) async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(ImportFilePicker.channel, (_) async {
          throw PlatformException(code: 'tooLarge');
        });
    await openSheet(tester);
    await tapVisible(tester, 'import-mode-file');
    await tapVisible(tester, 'import-choose-file');
    expect(find.textContaining('Файл больше 10 МБ'), findsOneWidget);
    mockFile();
    await tapVisible(tester, 'import-choose-file');
    expect(find.text('Sunflower'), findsOneWidget);
    expect(find.byKey(const ValueKey('import-error')), findsNothing);
  });

  testOnPlatform('pasted CSV is not mistaken for a Spotify link', (
    tester,
  ) async {
    await openSheet(tester);
    await tapVisible(tester, 'import-mode-text');
    await tester.enterText(find.byKey(const ValueKey('import-input')), csv);
    await tapVisible(tester, 'import-preview');
    expect(find.text('Импортировано из CSV'), findsOneWidget);
    expect(find.text('Sunflower'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testOnPlatform(
    'saving disables repeat actions and preserves existing playlists',
    (tester) async {
      await storage.savePlaylist('Night mix', const []);
      storage.saveCalls = 0;
      mockFile();
      await openSheet(tester);
      await tapVisible(tester, 'import-mode-file');
      await tapVisible(tester, 'import-choose-file');
      await tapVisible(tester, 'import-save');
      expect(
        find.textContaining('Плейлист с таким именем уже есть'),
        findsOneWidget,
      );
      expect(storage.saveCalls, 0);
      final name = find.byKey(const ValueKey('import-playlist-name'));
      await tester.ensureVisible(name);
      await tester.enterText(name, 'Night mix 2');
      storage.gate = Completer<void>();
      final save = find.byKey(const ValueKey('import-save'));
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pump();
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
      expect(storage.saveCalls, 1);
      storage.gate!.complete();
      await tester.pumpAndSettle();
      expect(storage.getPlaylists()['Night mix'], isEmpty);
      expect(storage.getPlaylists()['Night mix 2'], hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testOnPlatform(
    'late file selection after closing does not update disposed state',
    (tester) async {
      final selection = Completer<Map<String, dynamic>?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            ImportFilePicker.channel,
            (_) => selection.future,
          );
      await openSheet(tester);
      await tapVisible(tester, 'import-mode-file');
      final choose = find.byKey(const ValueKey('import-choose-file'));
      await tester.ensureVisible(choose);
      await tester.tap(choose);
      await tester.pump();
      final close = find.byTooltip('Закрыть');
      await tester.ensureVisible(close);
      await tester.tap(close);
      await tester.pumpAndSettle();
      selection.complete({
        'name': 'mix.csv',
        'bytes': Uint8List.fromList(utf8.encode(csv)),
      });
      await tester.pumpAndSettle();
      expect(find.byType(ImportBottomSheet), findsNothing);
      expect(storage.getPlaylists(), isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testOnPlatform(
    'windows offers the native file picker like Android',
    (tester) async {
      await openSheet(tester);
      expect(find.byKey(const ValueKey('import-mode-file')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    platform: TargetPlatform.windows,
  );

  testOnPlatform(
    'macOS still falls back to pasted CSV without a dead file button',
    (tester) async {
      await openSheet(tester);
      expect(find.byKey(const ValueKey('import-mode-file')), findsNothing);
      expect(
        find.textContaining('Выбор файла доступен'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
    platform: TargetPlatform.macOS,
  );
}
