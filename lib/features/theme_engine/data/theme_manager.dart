import 'dart:convert';
import 'package:flutter/services.dart';
import '../domain/hook_theme.dart';

class ThemeManager {
  static const List<String> builtinThemePaths = [
    'assets/themes/default_dark.json',
    'assets/themes/cyberpunk_neon.json',
    'assets/themes/minimal_oled.json',
  ];

  final Map<String, HookTheme> _loadedThemes = {};
  String _activeThemeId = 'default_dark';

  String get activeThemeId => _activeThemeId;
  List<HookTheme> get availableThemes => _loadedThemes.values.toList();
  HookTheme get currentTheme => _loadedThemes[_activeThemeId] ?? _fallbackTheme;

  static final HookTheme _fallbackTheme = HookTheme(
    id: 'default_dark',
    name: 'Hook Obsidian',
    author: 'Hook Core Team',
    version: '1.0.0',
    isDark: true,
    colors: const HookColors(
      background: Color(0xFF0D0E12),
      surface: Color(0xFF16181F),
      surfaceGlass: Color(0x2416181F),
      primary: Color(0xFF6C5CE7),
      secondary: Color(0xFFA29BFE),
      accent: Color(0xFF00CEC9),
      textPrimary: Color(0xFFFFFFFF),
      textSecondary: Color(0xFF8E92A4),
      border: Color(0xFF282B37),
    ),
    styling: const HookStyling(
      borderRadius: 16.0,
      cardBlur: 24.0,
      shaderMeshEnabled: true,
      shaderNoiseIntensity: 0.04,
      fontFamily: 'Inter',
    ),
  );

  /// Preloads built-in JSON themes from assets
  Future<void> initialize() async {
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
