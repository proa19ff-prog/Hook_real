import 'package:flutter/material.dart';

class HookColors {
  final Color background;
  final Color surface;
  final Color surfaceGlass;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;

  const HookColors({
    required this.background,
    required this.surface,
    required this.surfaceGlass,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
  });

  factory HookColors.fromJson(Map<String, dynamic> json) {
    Color parseHex(Object? value, Color fallback) {
      final clean = value is String ? value.trim().replaceAll('#', '') : '';
      if (clean.length != 6 && clean.length != 8) return fallback;
      try {
        return Color(
          int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16),
        );
      } on FormatException {
        return fallback;
      }
    }

    double contrastRatio(Color foreground, Color background) {
      final light = foreground.computeLuminance();
      final dark = background.computeLuminance();
      return (light > dark ? light + 0.05 : dark + 0.05) /
          (light > dark ? dark + 0.05 : light + 0.05);
    }

    final background = parseHex(json['background'], const Color(0xFF0D0E12));
    var surface = parseHex(json['surface'], const Color(0xFF16181F));
    var surfaceGlass =
        parseHex(json['surfaceGlass'], const Color(0x2416181F));
    var border = parseHex(json['border'], const Color(0xFF282B37));
    final primary = parseHex(json['primary'], const Color(0xFF6C5CE7));
    final secondary = parseHex(json['secondary'], const Color(0xFFA29BFE));
    final accent = parseHex(json['accent'], const Color(0xFF00CEC9));
    final textPrimary = parseHex(json['textPrimary'], const Color(0xFFFFFFFF));
    final textSecondary =
        parseHex(json['textSecondary'], const Color(0xFF8E92A4));
    final lightBackground = background.computeLuminance() > 0.45;
    final safePrimaryText =
        lightBackground ? const Color(0xFF141419) : const Color(0xFFFFFFFF);
    final safeSecondaryText =
        lightBackground ? const Color(0xFF4A4A5A) : const Color(0xFFB3B3B3);

    // Themes built from a light cover palette often keep dark surface colors
    // (or inherit dark fallbacks) — that painted the search field black on a
    // beige background and dialogs as dark boxes. Surfaces, glass and borders
    // must live in the same brightness family as the background; anything
    // else is rebuilt from the background's own hue.
    Color sameFamilyAsBackground(Color candidate, {required double offset}) {
      final isLightCandidate = candidate.computeLuminance() > 0.45;
      if (isLightCandidate == lightBackground) return candidate;
      final hsl = HSLColor.fromColor(background);
      return hsl
          .withLightness(
            (hsl.lightness + (lightBackground ? -offset : offset)).clamp(
              0.0,
              1.0,
            ),
          )
          .toColor();
    }

    surface = sameFamilyAsBackground(surface, offset: 0.05);

    // Glass is composited over the background, so judge the composite: a
    // glass that flips the brightness (dark glass over beige) becomes a
    // subtle on-hue tint instead.
    final glassOverBackground = Color.alphaBlend(surfaceGlass, background);
    if ((glassOverBackground.computeLuminance() > 0.45) != lightBackground) {
      surfaceGlass = lightBackground
          ? Colors.white.withValues(alpha: 0.55)
          : Colors.white.withValues(alpha: 0.07);
    }

    // A border indistinguishable from the background loses its job; nudge it
    // toward the text side of the palette. Judged by contrast ratio so the
    // legitimately subtle (barely lighter) borders of dark themes survive.
    double ratio(Color fg, Color bg) {
      final light = fg.computeLuminance();
      final dark = bg.computeLuminance();
      return (light > dark ? light + 0.05 : dark + 0.05) /
          (light > dark ? dark + 0.05 : light + 0.05);
    }

    if (ratio(border, background) < 1.25) {
      border = lightBackground
          ? Colors.black.withValues(alpha: 0.18)
          : Colors.white.withValues(alpha: 0.14);
    }

    return HookColors(
      background: background,
      surface: surface,
      surfaceGlass: surfaceGlass,
      primary: primary,
      secondary: secondary,
      accent: accent,
      textPrimary: contrastRatio(textPrimary, background) >= 4.5
          ? textPrimary
          : safePrimaryText,
      textSecondary: contrastRatio(textSecondary, background) >= 3
          ? textSecondary
          : safeSecondaryText,
      border: border,
    );
  }

  /// Foreground for content drawn on [primary]-colored fills. Beige/light
  /// primaries need dark ink — hardcoded white turned unreadable on them.
  Color get onPrimary =>
      primary.computeLuminance() > 0.6
      ? const Color(0xFF141419)
      : Colors.white;

  /// Foreground for content drawn on [accent]-colored fills (chips, buttons).
  Color get onAccent =>
      accent.computeLuminance() > 0.6
      ? const Color(0xFF141419)
      : Colors.white;

  Map<String, dynamic> toJson() {
    String toHex(Color c) =>
        '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    return {
      'background': toHex(background),
      'surface': toHex(surface),
      'surfaceGlass': toHex(surfaceGlass),
      'primary': toHex(primary),
      'secondary': toHex(secondary),
      'accent': toHex(accent),
      'textPrimary': toHex(textPrimary),
      'textSecondary': toHex(textSecondary),
      'border': toHex(border),
    };
  }

  HookColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceGlass,
    Color? primary,
    Color? secondary,
    Color? accent,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
  }) {
    return HookColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceGlass: surfaceGlass ?? this.surfaceGlass,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      accent: accent ?? this.accent,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
    );
  }
}

class HookStyling {
  final double borderRadius;
  final double cardBlur;
  final bool shaderMeshEnabled;
  final double shaderNoiseIntensity;
  final String fontFamily;

  const HookStyling({
    required this.borderRadius,
    required this.cardBlur,
    required this.shaderMeshEnabled,
    required this.shaderNoiseIntensity,
    required this.fontFamily,
  });

  factory HookStyling.fromJson(Map<String, dynamic> json) {
    return HookStyling(
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 16.0,
      cardBlur: (json['cardBlur'] as num?)?.toDouble() ?? 24.0,
      shaderMeshEnabled: json['shaderMeshEnabled'] as bool? ?? true,
      shaderNoiseIntensity:
          (json['shaderNoiseIntensity'] as num?)?.toDouble() ?? 0.04,
      fontFamily: json['fontFamily'] as String? ?? 'Inter',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'borderRadius': borderRadius,
      'cardBlur': cardBlur,
      'shaderMeshEnabled': shaderMeshEnabled,
      'shaderNoiseIntensity': shaderNoiseIntensity,
      'fontFamily': fontFamily,
    };
  }

  HookStyling copyWith({
    double? borderRadius,
    double? cardBlur,
    bool? shaderMeshEnabled,
    double? shaderNoiseIntensity,
    String? fontFamily,
  }) {
    return HookStyling(
      borderRadius: borderRadius ?? this.borderRadius,
      cardBlur: cardBlur ?? this.cardBlur,
      shaderMeshEnabled: shaderMeshEnabled ?? this.shaderMeshEnabled,
      shaderNoiseIntensity: shaderNoiseIntensity ?? this.shaderNoiseIntensity,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }
}

class HookTheme {
  final String id;
  final String name;
  final String author;
  final String version;
  final bool isDark;
  final HookColors colors;
  final HookStyling styling;

  const HookTheme({
    required this.id,
    required this.name,
    required this.author,
    required this.version,
    required this.isDark,
    required this.colors,
    required this.styling,
  });

  factory HookTheme.fromJson(Map<String, dynamic> json) {
    return HookTheme(
      id: json['id'] as String? ?? 'custom',
      name: json['name'] as String? ?? 'Custom Theme',
      author: json['author'] as String? ?? 'User',
      version: json['version'] as String? ?? '1.0.0',
      isDark: json['isDark'] as bool? ?? true,
      colors:
          HookColors.fromJson(json['colors'] as Map<String, dynamic>? ?? {}),
      styling:
          HookStyling.fromJson(json['styling'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'author': author,
      'version': version,
      'isDark': isDark,
      'colors': colors.toJson(),
      'styling': styling.toJson(),
    };
  }

  HookTheme copyWith({
    String? id,
    String? name,
    String? author,
    String? version,
    bool? isDark,
    HookColors? colors,
    HookStyling? styling,
  }) {
    return HookTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      author: author ?? this.author,
      version: version ?? this.version,
      isDark: isDark ?? this.isDark,
      colors: colors ?? this.colors,
      styling: styling ?? this.styling,
    );
  }

  ThemeData toThemeData() {
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      cardColor: colors.surface,
      primaryColor: colors.primary,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.textPrimary,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        error: Colors.redAccent,
        onError: Colors.white,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: styling.fontFamily,
        bodyColor: colors.textPrimary,
        displayColor: colors.textPrimary,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: colors.background,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(48, 48),
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48), foregroundColor: colors.textPrimary),
      ),
      dividerColor: colors.border,
      splashFactory: InkRipple.splashFactory,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceGlass,
        hintStyle: TextStyle(color: colors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(styling.borderRadius),
          borderSide: BorderSide(color: colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(styling.borderRadius),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(styling.borderRadius),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}
