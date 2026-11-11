import 'package:flutter/widgets.dart';

/// Guards for the app-wide keyboard shortcuts.
///
/// `CallbackShortcuts` fires whenever the focused node does not consume the
/// key itself, and a `TextField` only consumes the keys it needs. A bare `M`
/// therefore reaches the app while the user is typing "m" into the search box:
/// the character is swallowed *and* the machine is muted. Every bare-key
/// shortcut has to check [isTyping] first.
abstract final class HookShortcuts {
  /// True while an editable text field owns the keyboard focus.
  static bool isTyping() {
    final focus = FocusManager.instance.primaryFocus;
    if (focus == null) return false;
    final context = focus.context;
    if (context == null) return false;
    var editable = false;
    // `EditableText` is the widget that actually receives characters, so it is
    // the only reliable signal; a `TextField` without focus is not typing.
    context.visitAncestorElements((element) {
      if (element.widget is EditableText) {
        editable = true;
        return false;
      }
      return true;
    });
    return editable;
  }

  /// Wraps [action] so it does nothing while a text field is focused.
  static VoidCallback whenNotTyping(VoidCallback action) => () {
    if (isTyping()) return;
    action();
  };
}
