import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../library/presentation/library_provider.dart';
import 'update_install.dart';
import 'update_service.dart';

enum UpdateStage { idle, checking, upToDate, available, downloading, downloaded, failed }

class UpdateState {
  final UpdateStage stage;
  final AppUpdate? update;

  /// 0..1 while [UpdateStage.downloading].
  final double progress;

  /// Human-readable failure reason for the current stage.
  final String? failure;

  /// Whether the last failure was the missing "install unknown apps" grant
  /// (the settings screen opened; a second tap proceeds with the install).
  final bool permissionNeeded;

  const UpdateState({
    this.stage = UpdateStage.idle,
    this.update,
    this.progress = 0,
    this.failure,
    this.permissionNeeded = false,
  });
}

/// Drives the full OTA cycle: check → download → hand to the system
/// installer. Android always confirms the install itself; this class only
/// gets the APK to disk and opens the right screen.
class UpdateNotifier extends StateNotifier<UpdateState> {
  UpdateNotifier({
    required this.service,
    required this.installer,
    Dio? dio,
    Future<Directory> Function()? directoryResolver,
  }) : _dio = dio ?? Dio(),
       _directoryResolver =
           directoryResolver ?? _defaultDirectory,
       super(const UpdateState());

  final UpdateService service;

  /// Native hook that opens the package installer for a local APK file.
  final Future<String> Function(String apkPath) installer;

  final Dio _dio;
  final Future<Directory> Function() _directoryResolver;

  File? _apkFile;

  /// App-specific external storage keeps the APK readable by the system
  /// installer through the FileProvider mapping in file_paths.xml. Desktop
  /// builds have no external storage; their support directory is used as is.
  static Future<Directory> _defaultDirectory() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return getApplicationSupportDirectory();
    }
    return await getExternalStorageDirectory() ??
        await getApplicationSupportDirectory();
  }

  /// Manual check from the settings screen. [force] bypasses the 6-hour
  /// gate used by the silent startup check.
  Future<void> check({bool force = true}) async {
    if (state.stage == UpdateStage.checking ||
        state.stage == UpdateStage.downloading) {
      return;
    }
    state = const UpdateState(stage: UpdateStage.checking);
    try {
      final update = await service.check(force: force);
      if (!mounted) return;
      state = update == null
          ? const UpdateState(stage: UpdateStage.upToDate)
          : UpdateState(stage: UpdateStage.available, update: update);
    } catch (_) {
      if (!mounted) return;
      state = const UpdateState(
        stage: UpdateStage.failed,
        failure: 'check',
      );
    }
  }

  /// Downloads the APK with progress, then opens the system installer. When
  /// Android reports the missing unknown-sources grant, the stage returns to
  /// [UpdateStage.available] and the next tap retries the install directly.
  Future<void> downloadAndInstall() async {
    final update = state.update;
    if (update == null || state.stage == UpdateStage.downloading) return;
    state = UpdateState(stage: UpdateStage.downloading, update: update);
    try {
      final dir = await _directoryResolver();
      final updatesDir = Directory(
        '${dir.path}${Platform.pathSeparator}updates',
      );
      if (!await updatesDir.exists()) await updatesDir.create(recursive: true);
      final extension =
          defaultTargetPlatform == TargetPlatform.android ? 'apk' : 'zip';
      _apkFile = File(
        '${updatesDir.path}${Platform.pathSeparator}hook-${update.version}.$extension',
      );
      await _dio.download(
        update.apkUrl,
        _apkFile!.path,
        options: Options(
          headers: {'User-Agent': 'Hook-Music-Player/1.0'},
        ),
        onReceiveProgress: (received, total) {
          if (!mounted || total <= 0) return;
          state = UpdateState(
            stage: UpdateStage.downloading,
            update: update,
            progress: (received / total).clamp(0.0, 1.0),
          );
        },
      );
      if (!mounted) return;
      state = UpdateState(
        stage: UpdateStage.downloaded,
        update: update,
        progress: 1,
      );
      await openInstaller();
    } catch (error) {
      if (!mounted) return;
      state = UpdateState(
        stage: UpdateStage.failed,
        update: update,
        failure: 'download',
      );
    }
  }

  /// Opens the system installer for the APK already on disk. Desktop builds
  /// have no in-place self-update (a running exe cannot replace itself), so
  /// they hand off to the GitHub releases page instead.
  Future<void> openInstaller() async {
    if (defaultTargetPlatform != TargetPlatform.android) {
      try {
        await launchUrl(
          Uri.parse(UpdateService.releasesPageUrl),
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {
        if (mounted) {
          state = UpdateState(
            stage: UpdateStage.failed,
            update: state.update,
            failure: 'install',
          );
        }
      }
      return;
    }
    final path = _apkFile?.path;
    if (path == null) return;
    String result;
    try {
      result = await installer(path);
    } catch (_) {
      result = 'failed';
    }
    if (!mounted) return;
    switch (result) {
      case 'started':
        break; // Android's own install flow takes over from here.
      case 'permission_needed':
        state = UpdateState(
          stage: UpdateStage.downloaded,
          update: state.update,
          progress: 1,
          permissionNeeded: true,
        );
      default:
        state = UpdateState(
          stage: UpdateStage.failed,
          update: state.update,
          failure: 'install',
        );
    }
  }
}

/// The installed app's own version, for the settings caption.
final appVersionProvider = FutureProvider<String>((_) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(storage: ref.watch(localStorageServiceProvider));
});

final updateProvider =
    StateNotifierProvider<UpdateNotifier, UpdateState>((ref) {
  return UpdateNotifier(
    service: ref.watch(updateServiceProvider),
    installer: installUpdateApk,
  );
});
