import 'package:flutter/services.dart';

const _channel = MethodChannel('hook/updater');

/// Opens Android's package installer for the downloaded APK.
/// Returns the native verdict: 'started' | 'permission_needed' |
/// 'no_installer' | 'failed'.
Future<String> installUpdateApk(String apkPath) async {
  try {
    return await _channel.invokeMethod<String>(
          'installApk',
          {'path': apkPath},
        ) ??
        'failed';
  } on PlatformException {
    return 'failed';
  } on MissingPluginException {
    return 'failed';
  }
}
