import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/data/lyrics_client.dart';
import 'package:hook/features/lyrics/data/lyrics_translation_service.dart';
import 'package:hook/features/lyrics/domain/lyric_line.dart';
import 'package:hook/features/lyrics/presentation/lyrics_translation_panel.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';

const lyrics = LyricsResult(
  plainLyrics: 'The little boat waits.\nHello again.',
);
const channel = MethodChannel('hook/lyrics_translation');

class ControlledTranslation extends LyricsTranslationService {
  final calls = <({String id, String target, bool download})>[];
  final cancellations = <String>[];
  Future<Map<String, String>> Function(bool download)? action;
  @override
  Future<Map<String, String>> translate({
    required String id,
    required List<String> lines,
    required String target,
    bool allowDownload = false,
  }) async {
    calls.add((id: id, target: target, download: allowDownload));
    return action?.call(allowDownload) ??
        {'The little boat waits.': 'Маленькая лодка ждёт.'};
  }

  @override
  Future<void> cancel(String id) async {
    cancellations.add(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'translation sends unique lines and caches exact text and target only',
    () async {
      var calls = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls++;
            expect(call.method, 'translate');
            expect(call.arguments['lines'], ['Hello', 'World']);
            expect(call.arguments['allowDownload'], false);
            return ['Привет', 'Мир'];
          });
      final service = LyricsTranslationService();
      final first = await service.translate(
        id: service.newRequestId(),
        target: 'ru',
        lines: ['Hello', '', 'World', 'Hello'],
      );
      expect(first, {'Hello': 'Привет', 'World': 'Мир'});
      await service.translate(
        id: service.newRequestId(),
        target: 'ru',
        lines: ['Hello', 'World'],
      );
      expect(calls, 1);
      await service.translate(
        id: service.newRequestId(),
        target: 'en',
        lines: ['Hello', 'World'],
      );
      expect(calls, 2);
    },
  );

  test('oversized lyrics do not cross the platform channel', () async {
    await expectLater(
      LyricsTranslationService().translate(
        id: 'large',
        target: 'ru',
        lines: [List.filled(5001, 'x').join()],
      ),
      throwsA(
        isA<PlatformException>().having((e) => e.code, 'code', 'tooLarge'),
      ),
    );
  });

  test('incomplete native result is rejected and not cached', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => ['Only one']);
    await expectLater(
      LyricsTranslationService().translate(
        id: 'partial',
        target: 'ru',
        lines: ['Hello', 'World'],
      ),
      throwsA(isA<PlatformException>()),
    );
  });

  test('translation input includes independently timed backing vocals', () {
    const lead = LyricLine(
      startTime: Duration.zero,
      text: 'Lead',
      backingVocals: [
        LyricLine(
          startTime: Duration(seconds: 1),
          text: 'Backing',
          isBacking: true,
        ),
      ],
    );
    expect(translationLines(const LyricsResult(lines: [lead])), [
      'Lead',
      'Backing',
    ]);
    expect(translationLines(lyrics), [
      'The little boat waits.',
      'Hello again.',
    ]);
  });

  Future<void> mount(
    WidgetTester tester,
    ControlledTranslation service, {
    String identity = 'song',
  }) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          lyricsTranslationServiceProvider.overrideWithValue(service),
        ],
        child: MaterialApp(
          locale: const Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.8),
              disableAnimations: true,
            ),
            child: child!,
          ),
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: LyricsTranslationPanel(
                key: ValueKey(identity),
                lyrics: lyrics,
                theme: HookTheme.fromJson({}),
                caption: 'ТЕКСТ',
                builder: (translations) => ListView(
                  children: [
                    const Text('The little boat waits.'),
                    if (translations['The little boat waits.']
                        case final String translated)
                      Text(translated),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'button translates under original then hides without another request',
    (tester) async {
      final service = ControlledTranslation();
      await mount(tester, service);
      expect(service.calls, isEmpty);
      await tester.tap(find.byKey(const ValueKey('lyrics-translate-button')));
      await tester.pumpAndSettle();
      expect(find.text('The little boat waits.'), findsOneWidget);
      expect(find.text('Маленькая лодка ждёт.'), findsOneWidget);
      expect(
        find.text('Автоматический перевод: Google Translate'),
        findsOneWidget,
      );
      expect(service.calls.single.target, 'ru');
      await tester.tap(find.byTooltip('Скрыть перевод'));
      await tester.pumpAndSettle();
      expect(find.text('Маленькая лодка ждёт.'), findsNothing);
      await tester.tap(find.byTooltip('Перевести текст'));
      await tester.pumpAndSettle();
      expect(service.calls, hasLength(1));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'model download requires explicit confirmation and cancel keeps original',
    (tester) async {
      final service = ControlledTranslation()
        ..action = (_) async => throw PlatformException(code: 'modelRequired');
      await mount(tester, service);
      await tester.tap(find.byTooltip('Перевести текст'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Скачать языковую модель?'), findsOneWidget);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(service.calls.map((call) => call.download), [false]);
      expect(find.text('The little boat waits.'), findsOneWidget);
      expect(find.byTooltip('Перевести текст'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('confirmation enables model download only on second call', (
    tester,
  ) async {
    final service = ControlledTranslation()
      ..action = (download) async {
        if (!download) throw PlatformException(code: 'modelRequired');
        return {'The little boat waits.': 'Маленькая лодка ждёт.'};
      };
    await mount(tester, service);
    await tester.tap(find.byTooltip('Перевести текст'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Скачать и перевести'));
    await tester.pumpAndSettle();
    expect(service.calls.map((call) => call.download), [false, true]);
    expect(find.text('Маленькая лодка ждёт.'), findsOneWidget);
  });

  testWidgets('cancel discards a late result and restores usable original', (
    tester,
  ) async {
    final pending = Completer<Map<String, String>>();
    final service = ControlledTranslation()..action = (_) => pending.future;
    await mount(tester, service);
    await tester.tap(find.byTooltip('Перевести текст'));
    await tester.pump();
    await tester.tap(find.byTooltip('Отменить перевод'));
    await tester.pump();
    pending.complete({'The little boat waits.': 'Устаревший перевод'});
    await tester.pumpAndSettle();
    expect(service.cancellations, hasLength(1));
    expect(find.text('Устаревший перевод'), findsNothing);
    expect(find.text('The little boat waits.'), findsOneWidget);
  });

  testWidgets('switching song cancels request and ignores old completion', (
    tester,
  ) async {
    final pending = Completer<Map<String, String>>();
    final service = ControlledTranslation()..action = (_) => pending.future;
    await mount(tester, service);
    await tester.tap(find.byTooltip('Перевести текст'));
    await tester.pump();
    await mount(tester, service, identity: 'next-song');
    pending.complete({'The little boat waits.': 'Устаревший перевод'});
    await tester.pumpAndSettle();
    expect(service.cancellations, hasLength(1));
    expect(find.text('Устаревший перевод'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'download failure leaves original visible with a retryable control',
    (tester) async {
      final service = ControlledTranslation()
        ..action = (_) async => throw PlatformException(code: 'downloadFailed');
      await mount(tester, service);
      await tester.tap(find.byTooltip('Перевести текст'));
      await tester.pumpAndSettle();
      expect(find.text('The little boat waits.'), findsOneWidget);
      expect(find.byTooltip('Перевести текст'), findsOneWidget);
      expect(find.textContaining('Перевод не выполнен'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
