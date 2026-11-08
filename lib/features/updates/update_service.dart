import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/storage/local_storage_service.dart';

/// One installable update, as published in the repository's Releases.
class AppUpdate {
  final String version;
  final String notes;
  final DateTime? publishedAt;
  final String apkUrl;
  final int apkBytes;

  const AppUpdate({
    required this.version,
    required this.notes,
    required this.apkUrl,
    required this.apkBytes,
    this.publishedAt,
  });
}

/// Checks GitHub Releases for a newer build. The API is public, so nothing
/// here needs auth; results are cached in prefs so an app start does not
/// hammer the endpoint more often than once per [checkInterval].
class UpdateService {
  UpdateService({
    Dio? dio,
    this._storage,
  }) : _dio = dio ?? Dio();

  static const releasesPageUrl =
      'https://github.com/proa19ff-prog/Hook_real/releases/latest';

  static const repoApiUrl =
      'https://api.github.com/repos/proa19ff-prog/Hook_real/releases/latest';
  static const checkInterval = Duration(hours: 6);

  final Dio _dio;
  final LocalStorageService? _storage;

  /// Test seam pinning the installed version for [check].
  @visibleForTesting
  static Future<PackageInfo>? infoOverride;

  /// True when enough time has passed since the last automatic check.
  bool shouldAutoCheck({DateTime? now}) {
    final last = _storage?.lastUpdateCheck;
    if (last == null) return true;
    return (now ?? DateTime.now()).difference(last) >= checkInterval;
  }

  Future<void> _rememberCheck() =>
      _storage?.markUpdateChecked() ?? Future.value();

  Future<PackageInfo> _packageInfo() =>
      infoOverride ?? PackageInfo.fromPlatform();

  /// [force] skips the interval gate (the manual "check" button).
  Future<AppUpdate?> check({bool force = true}) async {
    if (!force && !shouldAutoCheck()) return null;
    try {
      final response = await _dio
          .get<Map<String, dynamic>>(
            repoApiUrl,
            options: Options(
              validateStatus: (status) => status != null && status < 500,
              headers: {
                'Accept': 'application/vnd.github+json',
                'User-Agent': 'Hook-Music-Player/1.0',
              },
            ),
          )
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200 || response.data == null) return null;
      final update = parseRelease(response.data!);
      await _rememberCheck();
      if (update == null) return null;
      final info = await _packageInfo();
      if (isNewerVersion(update.version, info.version)) return update;
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Picks the release payload: tag becomes the version, the APK asset for
  /// this device's ABI wins (universal is the fallback). Windows takes the
  /// `windows-x64` zip.
  @visibleForTesting
  static AppUpdate? parseRelease(Map<String, dynamic> release) {
    final tag = (release['tag_name'] as String? ?? '').trim();
    if (tag.isEmpty) return null;
    final version = tag.replaceFirst(RegExp(r'^[vV]'), '');
    final draft = release['draft'] == true;
    if (draft) return null;

    final wantedExtension =
        defaultTargetPlatform == TargetPlatform.android ? '.apk' : '.zip';
    final assets = (release['assets'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((asset) => (
              name: (asset['name'] as String? ?? '').toLowerCase(),
              url: asset['browser_download_url']?.toString() ?? '',
              bytes: (asset['size'] as num?)?.toInt() ?? 0,
            ))
        .where(
          (asset) =>
              asset.url.isNotEmpty && asset.name.endsWith(wantedExtension),
        )
        .toList();
    if (assets.isEmpty) return null;

    final abi = currentAbi();
    (String, int)? picked = assets
        .where((asset) => asset.name.contains('-$abi.'))
        .map((asset) => (asset.url, asset.bytes))
        .firstOrNull;
    picked ??= assets
        .where((asset) => asset.name.contains('-universal.'))
        .map((asset) => (asset.url, asset.bytes))
        .firstOrNull;
    picked ??= (assets.first.url, assets.first.bytes);

    return AppUpdate(
      version: version,
      notes: release['body']?.toString() ?? '',
      publishedAt: DateTime.tryParse(release['published_at']?.toString() ?? ''),
      apkUrl: picked.$1,
      apkBytes: picked.$2,
    );
  }

  /// Which release-asset ABI this device runs, from the Dart VM banner
  /// ("android_arm64", "android_armv7", "android_x64"). No native channel
  /// needed for a choice the release names already encode. Windows builds
  /// track the `windows-x64` zip asset instead of an APK.
  @visibleForTesting
  static String currentAbi() {
    if (defaultTargetPlatform != TargetPlatform.android) return 'windows-x64';
    final banner = Platform.version.toLowerCase();
    if (banner.contains('x86_64') || banner.contains('android_x64')) {
      return 'x86_64';
    }
    if (banner.contains('armv7') || banner.contains('android_arm32')) {
      return 'armeabi-v7a';
    }
    return 'arm64';
  }

  /// True when [candidate] is strictly newer than [current]. Both are
  /// "major.minor.patch(+build)"; non-numeric tails are ignored.
  @visibleForTesting
  static bool isNewerVersion(String candidate, String current) {
    final a = _versionParts(candidate);
    final b = _versionParts(current);
    for (var i = 0; i < 3; i++) {
      if (a[i] != b[i]) return a[i] > b[i];
    }
    return false;
  }

  static List<int> _versionParts(String value) {
    final core =
        value.trim().split(RegExp(r'[+~-]')).first.replaceAll(RegExp(r'^[^\d]+'), '');
    final parts = core.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }
}
