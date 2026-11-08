import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/updates/update_provider.dart';
import 'package:hook/features/updates/update_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppUpdate _update() => const AppUpdate(
      version: '0.4.0',
      notes: 'notes',
      apkUrl: 'https://example/hook.apk',
      apkBytes: 2048,
    );

class _FakeService extends UpdateService {
  _FakeService(this.update);

  final AppUpdate? update;

  @override
  Future<AppUpdate?> check({bool force = true}) async => update;
}

class _ApkAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = Uint8List(2048);
    bytes.setRange(4, 8, 'ftyp'.codeUnits);
    return ResponseBody.fromBytes(
      bytes,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/vnd.android.package-archive'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Future<ProviderContainer> _container(
  String installerResult,
  List<String> calls,
  Directory dir,
) async {
  final container = ProviderContainer(overrides: [
    updateServiceProvider.overrideWithValue(_FakeService(_update())),
    updateProvider.overrideWith((ref) => UpdateNotifier(
          service: ref.watch(updateServiceProvider),
          installer: (path) async {
            calls.add(path);
            return installerResult;
          },
          dio: Dio()..httpClientAdapter = _ApkAdapter(),
          directoryResolver: () async => dir,
        )),
  ]);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // path_provider is bypassed via directoryResolver; stub the plugin
    // anyway so nothing else touches the missing channels.
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async => temp.path);
    temp = await Directory.systemTemp.createTemp('hook_updates_');
  });

  tearDown(() async {
    await temp.delete(recursive: true);
  });

  test('check reflects an available update', () async {
    final calls = <String>[];
    final container = await _container('started', calls, temp);
    addTearDown(container.dispose);

    await container.read(updateProvider.notifier).check();
    expect(container.read(updateProvider).stage, UpdateStage.available);
    expect(container.read(updateProvider).update!.version, '0.4.0');
  });

  test('download writes the apk, then hands off to the installer',
      () async {
    final calls = <String>[];
    final container = await _container('started', calls, temp);
    addTearDown(container.dispose);

    final notifier = container.read(updateProvider.notifier);
    await notifier.check();
    await notifier.downloadAndInstall();

    final state = container.read(updateProvider);
    expect(state.stage, UpdateStage.downloaded);
    expect(state.progress, 1);
    expect(calls, hasLength(1));
    expect(File(calls.single).existsSync(), isTrue);
  });

  test('permission_needed returns to downloaded with the flag set',
      () async {
    final calls = <String>[];
    final container = await _container('permission_needed', calls, temp);
    addTearDown(container.dispose);

    final notifier = container.read(updateProvider.notifier);
    await notifier.check();
    await notifier.downloadAndInstall();

    final state = container.read(updateProvider);
    expect(state.stage, UpdateStage.downloaded);
    expect(state.permissionNeeded, isTrue);
  });

  test('an installer failure lands in failed with the reason', () async {
    final calls = <String>[];
    final container = await _container('no_installer', calls, temp);
    addTearDown(container.dispose);

    final notifier = container.read(updateProvider.notifier);
    await notifier.check();
    await notifier.downloadAndInstall();

    final state = container.read(updateProvider);
    expect(state.stage, UpdateStage.failed);
    expect(state.failure, 'install');
  });
}
