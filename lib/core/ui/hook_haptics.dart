import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Haptics, in one place, fired only where a tap changes something.
///
/// Mobile had none at all — every transport button, favorite toggle and
/// navigation switch felt like a picture of a button. Desktop has no haptic
/// hardware, so nothing is attempted there and no platform channel is touched
/// in tests.
abstract final class HookHaptics {
  /// Master switch, mirrored from the settings toggle. Defaults to on, which
  /// is the behaviour every existing screen already expects.
  static bool enabled = true;

  static bool get _available =>
      enabled && !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// A control that acts immediately: play, next, mute.
  static void tap() {
    if (_available) HapticFeedback.selectionClick();
  }

  /// A control that acts immediately and matters: favourite, download.
  static void impact() {
    if (_available) HapticFeedback.lightImpact();
  }

  /// A destructive or irreversible action, right before it runs.
  static void warn() {
    if (_available) HapticFeedback.mediumImpact();
  }
}
