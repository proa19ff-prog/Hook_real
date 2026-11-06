import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/audio_player/data/audio_player_service.dart';
import 'package:hook/features/audio_player/data/equalizer_controller.dart';
import 'package:hook/features/audio_player/presentation/equalizer_sheet.dart';
import 'package:hook/features/audio_player/presentation/playback_controls.dart';
import 'package:hook/features/audio_player/presentation/player_state_provider.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';
import 'package:hook/l10n/generated/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Backend implements EqualizerBackend {
  bool available = true;
  bool failApply = false;
  final sessions = <int>[];
  List<double> gains = [];
  bool enabled = false;
  double bass = 0;
  int released = 0;
  @override
  bool get supported => available;
  @override
  Future<EqualizerHardware> attach(int id) async {
    sessions.add(id);
    return const EqualizerHardware(
      bands: [
        EqualizerBand(60),
        EqualizerBand(230),
        EqualizerBand(910),
        EqualizerBand(3600),
        EqualizerBand(14000),
      ],
      minDb: -15,
      maxDb: 15,
      bassSupported: true,
    );
  }

  @override
  Future<void> apply({
    required bool enabled,
    required List<double> gains,
    required double bass,
  }) async {
    if (failApply) throw StateError('No audio effect control');
    this.enabled = enabled;
    this.gains = gains;
    this.bass = bass;
  }

  @override
  Future<void> release() async {
    released++;
    enabled = false;
  }
}

class _Audio extends Fake implements AudioPlayerService {
  @override
  final EqualizerController equalizer;
  _Audio(this.equalizer);
  @override
  PlayerLoopMode get loopMode => PlayerLoopMode.off;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Backend backend;
  late EqualizerController controller;
  late List<double> volumes;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = _Backend();
    controller = EqualizerController(backend: backend);
    volumes = [];
  });
  tearDown(() => controller.dispose());

  Future<void> bind({int? session = 17}) => controller.bind(
    sessionIds: const Stream.empty(),
    initialSessionId: session,
    writeVolume: (value) async {
      volumes.add(value);
    },
  );

  test('presets interpolate in log-frequency and settings survive JSON', () {
    final settings = const EqualizerSettings(enabled: true)
        .withPreset(EqualizerPreset.bass);
    expect(settings.gainAt(60), 6);
    expect(settings.gainAt(math.sqrt(60 * 230)), closeTo(4.5, 0.001));
    final restored = EqualizerSettings.fromJson(
      jsonDecode(jsonEncode(settings.toJson())),
    );
    expect(restored.enabled, isTrue);
    expect(restored.preset, EqualizerPreset.bass);
    expect(restored.gainAt(230), 3);
  });

  test('invalid stored gains and nonfinite values are sanitized', () {
    final settings = EqualizerSettings.fromJson({
      'gains': {'0': 8, 'NaN': 2, '60': 999, '230': double.nan},
      'bass': double.infinity,
      'preampDb': -99,
      'preset': 'unknown',
    });
    expect(settings.gains, {60.0: 15.0, 230.0: 0.0});
    expect(settings.bass, 0);
    expect(settings.preampDb, -12);
    expect(settings.preset, EqualizerPreset.custom);
  });

  test('real effects, bass, headroom and user volume are applied', () async {
    await bind();
    controller.setEnabled(true);
    controller.setPreset(EqualizerPreset.bass);
    controller.setBass(0.5);
    controller.setPreamp(-2);
    await controller.setVolume(0.8);
    await controller.flush();
    expect(backend.enabled, isTrue);
    expect(backend.gains.first, 6);
    expect(backend.bass, 0.5);
    expect(controller.attenuationDb, -11);
    expect(volumes.last, closeTo(0.8 * math.pow(10, -11 / 20), 0.00001));
    controller.setEnabled(false);
    await controller.flush();
    expect(backend.enabled, isFalse);
    expect(volumes.last, 0.8);
  });

  test(
    'band edits clamp to hardware range and persist across controllers',
    () async {
      await bind();
      controller.setEnabled(true);
      controller.setBand(0, 99);
      controller.setBand(99, 5);
      controller.setBass(double.nan);
      await controller.flush();
      expect(backend.gains.first, 15);
      expect(controller.settings.preset, EqualizerPreset.custom);
      final restored = EqualizerController(backend: _Backend());
      await restored.bind(
        sessionIds: const Stream.empty(),
        initialSessionId: 18,
        writeVolume: (_) async {},
      );
      expect(restored.settings.enabled, isTrue);
      expect(restored.bandGains.first, 15);
      restored.dispose();
    },
  );

  test(
    'session replacement reapplies saved curve and failure restores volume',
    () async {
      await bind();
      controller.setEnabled(true);
      controller.setPreset(EqualizerPreset.rock);
      await controller.flush();
      await controller.connect(22);
      expect(backend.sessions, [17, 22]);
      expect(backend.gains.first, 4);
      backend.failApply = true;
      controller.setBass(0.5);
      await controller.flush();
      expect(controller.status, EqualizerStatus.failed);
      expect(backend.enabled, isFalse);
      expect(volumes.last, 1);
      backend.failApply = false;
      await controller.retry();
      expect(controller.status, EqualizerStatus.ready);
    },
  );

  test('unsupported platform and missing session do not stop audio', () async {
    backend.available = false;
    await bind(session: null);
    expect(controller.status, EqualizerStatus.unsupported);
    await controller.setVolume(0.4);
    expect(volumes.last, 0.4);
    expect(backend.sessions, isEmpty);
  });

  test(
    'native channel sends actual dB without millibel scaling in Dart',
    () async {
      const channel = MethodChannel('hook/equalizer');
      MethodCall? sent;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            sent = call;
            if (call.method == 'attach') {
              return {
                'frequencies': [60.0, 230.0],
                'minDb': -15.0,
                'maxDb': 15.0,
                'bassSupported': true,
              };
            }
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final native = AndroidEqualizerBackend();
      final hardware = await native.attach(8);
      expect(hardware.maxDb, 15);
      expect(hardware.bands.first.frequency, 60);
      await native.apply(enabled: true, gains: [6, -2], bass: 0.5);
      expect(sent!.method, 'apply');
      expect(sent!.arguments, {
        'enabled': true,
        'gains': [6.0, -2.0],
        'bass': 0.5,
      });
    },
  );

  Future<void> mount(
    WidgetTester tester,
    Widget child, {
    double width = 390,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.runAsync(() async {
      final font = FontLoader('Inter')
        ..addFont(
          rootBundle.load('assets/fonts/inter-regular/Inter-Regular.ttf'),
        );
      await font.load();
    });
    final theme = HookTheme.fromJson({
      'colors': {
        'background': '#000000',
        'surface': '#151515',
        'accent': '#00CEC9',
      },
    });
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: theme.toThemeData(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(backgroundColor: theme.colors.background, body: child),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('three-dot playback menu opens equalizer alongside speed/pitch', (
    tester,
  ) async {
    controller.dispose();
    controller = EqualizerController(backend: backend);
    await bind();
    final theme = HookTheme.fromJson({});
    await mount(
      tester,
      ProviderScope(
        overrides: [
          audioPlayerServiceProvider.overrideWithValue(_Audio(controller)),
          isPlayingProvider.overrideWithValue(false),
          isTrackLoadingProvider.overrideWithValue(false),
          positionStreamProvider.overrideWith(
            (ref) => Stream.value(Duration.zero),
          ),
          durationStreamProvider.overrideWith(
            (ref) => Stream.value(const Duration(minutes: 3)),
          ),
        ],
        child: PlaybackControls(theme: theme),
      ),
    );
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    expect(find.text('Эквалайзер'), findsOneWidget);
    expect(find.text('Скорость и тональность'), findsOneWidget);
    await tester.tap(find.text('Эквалайзер'));
    await tester.pumpAndSettle();
    expect(find.byType(EqualizerSheet), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await controller.flush();
    await tester.pumpAndSettle();
    expect(controller.settings.enabled, isTrue);
    expect(backend.enabled, isTrue);
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 768.0]) {
    testWidgets(
      'mixer fits $width px and large text, controls reach native backend',
      (tester) async {
        controller.dispose();
        controller = EqualizerController(backend: backend);
        await bind();
        controller.setEnabled(true);
        controller.setPreset(EqualizerPreset.bass);
        await controller.flush();
        final theme = HookTheme.fromJson({
          'colors': {
            'background': '#000000',
            'surface': '#151515',
            'accent': '#00CEC9',
          },
        });
        final key = GlobalKey();
        await mount(
          tester,
          RepaintBoundary(
            key: key,
            child: EqualizerSheet(theme: theme, controller: controller),
          ),
          width: width,
          scale: width == 320 ? 2 : 1,
        );
        expect(find.text('Эквалайзер'), findsOneWidget);
        expect(find.byType(Slider), findsNWidgets(7));
        expect(tester.takeException(), isNull);
        if (const bool.fromEnvironment('EQ_SCREENSHOTS')) {
          await tester.runAsync(() async {
            final boundary =
                key.currentContext!.findRenderObject() as RenderRepaintBoundary;
            final image = await boundary.toImage(pixelRatio: 1);
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await Directory('build/equalizer-preview').create(recursive: true);
            await File('build/equalizer-preview/eq-${width.toInt()}.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
        await tester.drag(
          find.byType(SingleChildScrollView).first,
          const Offset(0, -500),
        );
        await tester.pumpAndSettle();
        expect(find.text('Автоматический запас'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
