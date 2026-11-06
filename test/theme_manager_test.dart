import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/theme_engine/data/theme_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ThemeManager', () {
    test('starts with the fallback default theme before assets load', () {
      final manager = ThemeManager();
      expect(manager.currentTheme.id, ThemeManager.defaultThemeId);
      expect(manager.currentTheme.colors.background.toARGB32(), 0xFF000000);
    });

    test('imports a valid custom theme and activates it', () {
      final manager = ThemeManager();
      final json = jsonEncode({
        'id': 'custom_sunrise',
        'name': 'Sunrise',
        'author': 'tester',
        'version': '1.0.0',
        'isDark': false,
        'colors': {
          'background': '#FFF8F0E7',
          'surface': '#FFFFFFFF',
          'primary': '#FF222222',
          'secondary': '#FF666666',
          'accent': '#FFD96A4B',
          'textPrimary': '#FF222222',
          'textSecondary': '#FF777777',
        },
        'styling': {'borderRadius': 16.0, 'fontFamily': 'Inter'},
      });

      final theme = manager.importThemeFromJson(json);
      expect(theme, isNotNull);
      expect(theme!.id, 'custom_sunrise');
      expect(manager.activeThemeId, 'custom_sunrise');
      expect(manager.currentTheme.id, 'custom_sunrise');
      expect(manager.availableThemes.map((t) => t.id),
          contains('custom_sunrise'));
    });

    test('rejects malformed theme JSON and keeps the previous theme', () {
      final manager = ThemeManager();
      expect(manager.importThemeFromJson('not json at all {'), isNull);
      expect(manager.importThemeFromJson('{"colors": "wrong shape"}'), isNull);
      expect(manager.activeThemeId, ThemeManager.defaultThemeId);
    });

    test('imported theme with missing id does not crash or activate', () {
      final manager = ThemeManager();
      final json = jsonEncode({
        'name': 'No id theme',
        'colors': {
          'background': '#FF000000',
          'surface': '#FF111111',
          'primary': '#FFFFFFFF',
          'secondary': '#FF888888',
          'accent': '#FFFFC107',
          'textPrimary': '#FFFFFFFF',
          'textSecondary': '#FF999999',
        },
      });
      final theme = manager.importThemeFromJson(json);
      // Either rejected outright or registered under a generated id; the
      // important part is that the manager stays consistent either way.
      if (theme != null) {
        expect(theme.id, isNotEmpty);
      }
      expect(manager.currentTheme.id, isNotEmpty);
    });

    test('initialize restores the saved theme id among built-ins', () async {
      // Serve minimal built-in theme assets so initialize() can parse them.
      final contents = <String, String>{
        for (final path in ThemeManager.builtinThemePaths)
          path: jsonEncode({
            'id': path.split('/').last.replaceAll('.json', ''),
            'name': path,
            'colors': {
              'background': '#FF000000',
              'surface': '#FF111111',
              'primary': '#FFFFFFFF',
              'secondary': '#FF888888',
              'accent': '#FFFFC107',
              'textPrimary': '#FFFFFFFF',
              'textSecondary': '#FF999999',
            },
            'styling': {'borderRadius': 20.0, 'fontFamily': 'Inter'},
          }),
      };
      TestingWidgetsBindingHandler.installAssetHandler(contents);

      final manager = ThemeManager();
      final cyberpunkId =
          ThemeManager.builtinThemePaths[1].split('/').last.replaceAll('.json', '');
      await manager.initialize(savedThemeId: cyberpunkId);
      expect(manager.activeThemeId, cyberpunkId);

      // A saved id that no longer exists falls back to the default (fresh
      // instance: initialize() never resets an already-activated manager).
      final fresh = ThemeManager();
      await fresh.initialize(savedThemeId: 'gone_theme');
      expect(fresh.activeThemeId, ThemeManager.defaultThemeId);
    });
  });
}

/// Minimal asset bridge: fills the asset bundle with the given contents so
/// theme JSON files can be loaded in tests without real files.
class TestingWidgetsBindingHandler {
  static void installAssetHandler(Map<String, String> contents) {
    final channel = const OptionalMethodChannel('flutter/assets');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler(channel.name, (message) async {
      final key = const StringCodec().decodeMessage(message as ByteData);
      if (contents.containsKey(key)) {
        return const StringCodec().encodeMessage(contents[key]!);
      }
      return null;
    });
  }
}
