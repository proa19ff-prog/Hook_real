import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/theme_engine/data/theme_manager.dart';

double _contrast(Color a, Color b) {
  final light = a.computeLuminance();
  final dark = b.computeLuminance();
  return (light > dark ? light + 0.05 : dark + 0.05) /
      (light > dark ? dark + 0.05 : light + 0.05);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('both Windows presets ship with the app', () async {
    final manager = ThemeManager();
    await manager.initialize();
    final ids = manager.availableThemes.map((theme) => theme.id).toList();

    expect(ids, contains('windows_11'));
    expect(ids, contains('windows_11_light'));
  });

  test('the default theme is unchanged by the Windows presets', () async {
    final manager = ThemeManager();
    await manager.initialize();

    expect(manager.activeThemeId, ThemeManager.defaultThemeId);
  });

  for (final id in const ['windows_11', 'windows_11_light']) {
    test('$id stays readable', () async {
      final manager = ThemeManager();
      await manager.initialize();
      final theme = manager.availableThemes.firstWhere(
        (theme) => theme.id == id,
      );
      final colors = theme.colors;

      expect(_contrast(colors.textPrimary, colors.background), greaterThan(7));
      expect(
        _contrast(colors.textSecondary, colors.background),
        greaterThan(3),
      );
      // The rail, the player bar and the dialogs paint on `raised`.
      expect(_contrast(colors.textPrimary, colors.raised), greaterThan(4.5));
      expect(
        colors.onPrimary.computeLuminance(),
        anyOf(lessThan(0.1), greaterThan(0.9)),
      );
      // Windows' own corner radius is 8, not the app's 20.
      expect(theme.styling.borderRadius, 8);
      expect(theme.styling.fontFamily, 'Segoe UI');
    });
  }
}
