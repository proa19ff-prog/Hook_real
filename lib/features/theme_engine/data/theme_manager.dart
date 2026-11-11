import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/hook_theme.dart';

class ThemeManager {
  static const List<String> builtinThemePaths = [
    'assets/themes/default_dark.json',
    'assets/themes/cyberpunk_neon.json',
    'assets/themes/minimal_oled.json',
    'assets/themes/windows_11.json',
    'assets/themes/windows_11_light.json',
  ];

  final Map<String, HookTheme> _loadedThemes = {};
  static const String defaultThemeId = 'minimal_oled';

  String _activeThemeId = defaultThemeId;

  String get activeThemeId => _activeThemeId;
  List<HookTheme> get availableThemes => _loadedThemes.values.toList();
  HookTheme get currentTheme => _loadedThemes[_activeThemeId] ?? _fallbackTheme;

  /// Same values as assets/themes/minimal_oled.json, so the first frame
  /// (before the assets load) already looks like the default theme.
  static final HookTheme _fallbackTheme = HookTheme(
    id: defaultThemeId,
    name: 'OLED Monolith',
    author: 'Hook Core Team',
    version: '1.0.0',
    isDark: true,
    colors: const HookColors(
      background: Color(0xFF000000),
      surface: Color(0xFF121212),
      surfaceGlass: Color(0xE6121212),
      primary: Color(0xFFF4F2ED),
      secondary: Color(0xFFB8B5AF),
      accent: Color(0xFFF0B35A),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFFB3B3B3),
      border: Color(0xFF2A2A2A),
    ),
    styling: const HookStyling(
      borderRadius: 20.0,
      cardBlur: 0.0,
      shaderMeshEnabled: false,
      shaderNoiseIntensity: 0.0,
      fontFamily: 'Inter',
    ),
  );

  /// Preloads built-in JSON themes from assets, restoring saved theme if available
  Future<void> initialize(
      {String? savedThemeId, String? savedCustomJson}) async {
    _loadedThemes[_fallbackTheme.id] = _fallbackTheme;

    for (final path in builtinThemePaths) {
      try {
        final content = await rootBundle.loadString(path);
        final map = jsonDecode(content) as Map<String, dynamic>;
        final theme = HookTheme.fromJson(map);
        _loadedThemes[theme.id] = theme;
      } catch (e) {
        // Fallback already exists
      }
    }

    if (savedCustomJson != null && savedCustomJson.isNotEmpty) {
      importThemeFromJson(savedCustomJson);
    }
    if (savedThemeId != null && _loadedThemes.containsKey(savedThemeId)) {
      _activeThemeId = savedThemeId;
    }
  }

  void setActiveTheme(String id) {
    if (_loadedThemes.containsKey(id)) {
      _activeThemeId = id;
    }
  }

  /// Imports a custom theme from raw JSON string (e.g. shared by another user)
  HookTheme? importThemeFromJson(String jsonString) {
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      final theme = HookTheme.fromJson(map);
      _loadedThemes[theme.id] = theme;
      _activeThemeId = theme.id;
      return theme;
    } catch (e) {
      return null;
    }
  }
}
