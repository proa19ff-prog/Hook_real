import 'package:flutter/material.dart';

import '../../../core/ui/hook_tokens.dart';

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

  /// The visual weight a surface gets when it sits on top of `background`.
  Color get raised => Color.alphaBlend(
    textPrimary.withValues(alpha: 0.045),
    surface,
  );

  /// A faint wash for hover, selection and pressed states.
  Color get wash => textPrimary.withValues(alpha: 0.06);

  /// Text that is decorative rather than readable, e.g. a disabled icon.
  Color get textMuted => textSecondary.withValues(alpha: 0.6);

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

  /// Errors and destructive actions. Derived from the background's brightness
  /// rather than stored in the palette, so existing theme JSON keeps working
  /// while a beige theme does not get a pink that disappears into it.
  Color get danger => background.computeLuminance() > 0.45
      ? const Color(0xFFC0342E)
      : const Color(0xFFFF6B6B);

  /// Ink for text on [danger].
  Color get onDanger =>
      danger.computeLuminance() > 0.5
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

  /// The app-wide Material theme.
  ///
  /// Everything a screen needs is defined here — colour roles, the type scale,
  /// every control's shape, and motion. Screens should not need to construct a
  /// `TextStyle` or a `BorderRadius` of their own.
  ThemeData toThemeData() {
    final base = isDark
        ? ThemeData.dark(useMaterial3: true)
        : ThemeData.light(useMaterial3: true);

    final scheme = _colorScheme();
    final family = styling.fontFamily;
    final cardRadius = HookRadius.cardRadius(styling.borderRadius);

    TextStyle t({
      required double size,
      required FontWeight weight,
      double? spacing,
      double height = 1.3,
    }) => TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      leadingDistribution: TextLeadingDistribution.even,
    );

    final textTheme = TextTheme(
      displayLarge: t(size: 44, weight: FontWeight.w700, spacing: -1.2, height: 1.05),
      displayMedium: t(size: 36, weight: FontWeight.w700, spacing: -1.0, height: 1.08),
      displaySmall: t(size: HookType.display, weight: FontWeight.w700, spacing: -0.8, height: 1.1),
      headlineLarge: t(size: 26, weight: FontWeight.w700, spacing: -0.6, height: 1.12),
      headlineMedium: t(size: HookType.title, weight: FontWeight.w700, spacing: -0.4, height: 1.15),
      headlineSmall: t(size: 19, weight: FontWeight.w600, spacing: -0.2),
      titleLarge: t(size: HookType.heading, weight: FontWeight.w600, spacing: -0.15, height: 1.2),
      titleMedium: t(size: HookType.body, weight: FontWeight.w600),
      titleSmall: t(size: HookType.bodySmall, weight: FontWeight.w600),
      bodyLarge: t(size: HookType.body, weight: FontWeight.w400, height: 1.35),
      bodyMedium: t(size: HookType.bodySmall, weight: FontWeight.w400, height: 1.35),
      bodySmall: t(size: HookType.label, weight: FontWeight.w400, height: 1.35),
      labelLarge: t(size: HookType.bodySmall, weight: FontWeight.w600, spacing: 0.1, height: 1.15),
      labelMedium: t(size: HookType.label, weight: FontWeight.w500, spacing: 0.15, height: 1.2),
      labelSmall: t(size: HookType.caption, weight: FontWeight.w600, spacing: 0.35, height: 1.2),
    ).apply(
      bodyColor: colors.textPrimary,
      displayColor: colors.textPrimary,
      fontFamily: family,
    );

    final buttonText = t(
      size: HookType.bodySmall,
      weight: FontWeight.w600,
      height: 1.1,
      spacing: 0.1,
    );

    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      cardColor: colors.surface,
      primaryColor: colors.primary,
      colorScheme: scheme,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      dividerColor: colors.border,
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),
      // Press feedback: a quiet wash instead of Material's white 12% ripple
      // that made every dark-surface tap flash.
      splashFactory: InkSparkle.splashFactory,
      splashColor: colors.textPrimary.withValues(alpha: 0.06),
      highlightColor: colors.textPrimary.withValues(alpha: 0.04),
      hoverColor: colors.textPrimary.withValues(alpha: 0.05),
      focusColor: colors.primary.withValues(alpha: 0.12),
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,

      // ---- App chrome -----------------------------------------------------
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineMedium,
        iconTheme: IconThemeData(color: colors.textPrimary, size: 22),
        actionsIconTheme: IconThemeData(color: colors.textPrimary, size: 22),
      ),

      // ---- Navigation -----------------------------------------------------
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 23,
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textSecondary,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: colors.textPrimary.withValues(alpha: 0.10),
        selectedIconTheme: IconThemeData(color: colors.textPrimary, size: 22),
        unselectedIconTheme: IconThemeData(color: colors.textSecondary, size: 22),
        selectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: colors.textPrimary,
        ),
        unselectedLabelTextStyle: textTheme.labelLarge?.copyWith(
          color: colors.textSecondary,
        ),
        useIndicator: true,
        labelType: NavigationRailLabelType.none,
      ),
      tabBarTheme: TabBarThemeData(
        indicatorColor: colors.textPrimary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelColor: colors.textPrimary,
        unselectedLabelColor: colors.textSecondary,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        overlayColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.hovered)
              ? colors.textPrimary.withValues(alpha: 0.04)
              : Colors.transparent,
        ),
      ),

      // ---- Surfaces -------------------------------------------------------
      cardTheme: CardThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        shadowColor: Colors.black.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius + 4),
          side: BorderSide(color: colors.border),
        ),
        titleTextStyle: textTheme.headlineSmall,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.raised,
        modalBackgroundColor: colors.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 24,
        modalElevation: 24,
        showDragHandle: true,
        dragHandleColor: colors.textSecondary.withValues(alpha: 0.35),
        dragHandleSize: const Size(36, 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(cardRadius + 4),
          ),
        ),
        constraints: const BoxConstraints(maxWidth: 680),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.raised,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HookRadius.sm),
          side: BorderSide(color: colors.border),
        ),
        textStyle: textTheme.bodyMedium,
        labelTextStyle: WidgetStatePropertyAll(textTheme.bodyMedium),
      ),
      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.raised),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: const WidgetStatePropertyAll(16),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HookRadius.sm),
              side: BorderSide(color: colors.border),
            ),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          color: colors.textPrimary,
          borderRadius: HookRadius.xsAll,
        ),
        textStyle: textTheme.labelMedium?.copyWith(color: colors.background),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.textPrimary,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colors.background,
        ),
        actionTextColor: colors.primary,
        elevation: 8,
        insetPadding: const EdgeInsets.all(HookSpace.md),
        shape: RoundedRectangleBorder(borderRadius: HookRadius.smAll),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => colors.textSecondary.withValues(
            alpha: states.contains(WidgetState.dragged) ? 0.55 : 0.28,
          ),
        ),
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(999),
        crossAxisMargin: 2,
        mainAxisMargin: 2,
      ),

      // ---- Controls -------------------------------------------------------
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colors.textPrimary,
          foregroundColor: colors.background,
          disabledBackgroundColor: colors.textPrimary.withValues(alpha: 0.24),
          disabledForegroundColor: colors.background.withValues(alpha: 0.6),
          minimumSize: const Size(48, 44),
          padding: const EdgeInsets.symmetric(
            horizontal: HookSpace.xl,
            vertical: HookSpace.md,
          ),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: HookRadius.smAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(48, 44),
          side: BorderSide(color: colors.border),
          padding: const EdgeInsets.symmetric(
            horizontal: HookSpace.lg,
            vertical: HookSpace.md,
          ),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: HookRadius.smAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(40, 40),
          padding: const EdgeInsets.symmetric(
            horizontal: HookSpace.md,
            vertical: HookSpace.sm,
          ),
          textStyle: buttonText,
          shape: RoundedRectangleBorder(borderRadius: HookRadius.xsAll),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(44, 44),
          highlightColor: colors.textPrimary.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(borderRadius: HookRadius.xsAll),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.textPrimary.withValues(alpha: 0.06),
        selectedColor: colors.textPrimary,
        disabledColor: colors.textPrimary.withValues(alpha: 0.03),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: colors.textSecondary,
        ),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.background,
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: HookRadius.pillAll),
        showCheckmark: false,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.textPrimary,
        inactiveTrackColor: colors.textPrimary.withValues(alpha: 0.14),
        secondaryActiveTrackColor: colors.textPrimary.withValues(alpha: 0.35),
        disabledActiveTrackColor: colors.textPrimary.withValues(alpha: 0.3),
        disabledInactiveTrackColor: colors.textPrimary.withValues(alpha: 0.08),
        thumbColor: colors.textPrimary,
        overlayColor: colors.textPrimary.withValues(alpha: 0.10),
        trackHeight: 4,
        trackGap: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
        valueIndicatorColor: colors.textPrimary,
        valueIndicatorTextStyle: textTheme.labelMedium?.copyWith(
          color: colors.background,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.textPrimary,
        linearTrackColor: colors.textPrimary.withValues(alpha: 0.12),
        circularTrackColor: colors.textPrimary.withValues(alpha: 0.12),
        linearMinHeight: 3,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.background
              : colors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.textPrimary
              : colors.textPrimary.withValues(alpha: 0.16),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.textPrimary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(colors.background),
        side: BorderSide(color: colors.border, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        visualDensity: VisualDensity.compact,
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.textPrimary
              : colors.border,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.textSecondary,
        textColor: colors.textPrimary,
        titleTextStyle: textTheme.titleMedium,
        subtitleTextStyle: textTheme.bodySmall?.copyWith(
          color: colors.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HookSpace.lg,
          vertical: HookSpace.xs,
        ),
        shape: RoundedRectangleBorder(borderRadius: HookRadius.smAll),
        minVerticalPadding: HookSpace.md,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.textPrimary.withValues(alpha: 0.055),
        hintStyle: textTheme.bodyLarge?.copyWith(color: colors.textSecondary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colors.textSecondary),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: colors.textPrimary,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HookSpace.lg,
          vertical: HookSpace.md,
        ),
        border: OutlineInputBorder(
          borderRadius: HookRadius.smAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: HookRadius.smAll,
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: HookRadius.smAll,
          borderSide: BorderSide(color: colors.textPrimary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: HookRadius.smAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: HookRadius.smAll,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.textPrimary,
        foregroundColor: colors.background,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 4,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: HookRadius.smAll),
        extendedTextStyle: buttonText,
      ),

      // One transition for every push on every platform, instead of the
      // default Android zoom on Windows.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _HookPageTransitionsBuilder(),
          TargetPlatform.iOS: _HookPageTransitionsBuilder(),
          TargetPlatform.windows: _HookPageTransitionsBuilder(),
          TargetPlatform.linux: _HookPageTransitionsBuilder(),
          TargetPlatform.macOS: _HookPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _HookPageTransitionsBuilder(),
        },
      ),
    );
  }

  ColorScheme _colorScheme() {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    final surfaceLift = colors.textPrimary.withValues(
      alpha: isDark ? 0.06 : 0.04,
    );

    return ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: Color.alphaBlend(
        colors.primary.withValues(alpha: 0.22),
        colors.surface,
      ),
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.secondary,
      onSecondary: colors.onPrimary,
      secondaryContainer: Color.alphaBlend(
        colors.secondary.withValues(alpha: 0.20),
        colors.surface,
      ),
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.accent,
      onTertiary: colors.onAccent,
      tertiaryContainer: Color.alphaBlend(
        colors.accent.withValues(alpha: 0.20),
        colors.surface,
      ),
      onTertiaryContainer: colors.textPrimary,
      error: brightness == Brightness.dark
          ? const Color(0xFFFF6B6B)
          : const Color(0xFFB3261E),
      onError: brightness == Brightness.dark
          ? const Color(0xFF1A0505)
          : Colors.white,
      errorContainer: brightness == Brightness.dark
          ? const Color(0xFF4A1313)
          : const Color(0xFFF9DEDC),
      onErrorContainer: brightness == Brightness.dark
          ? const Color(0xFFFFD9D9)
          : const Color(0xFF410E0B),
      surface: colors.surface,
      onSurface: colors.textPrimary,
      surfaceContainerLowest: colors.background,
      surfaceContainerLow: Color.alphaBlend(
        surfaceLift.withValues(alpha: 0.5),
        colors.surface,
      ),
      surfaceContainer: colors.raised,
      surfaceContainerHigh: Color.alphaBlend(surfaceLift, colors.surface),
      surfaceContainerHighest: Color.alphaBlend(
        surfaceLift.withValues(alpha: 1.6),
        colors.surface,
      ),
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.textPrimary.withValues(alpha: 0.08),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.background,
      inversePrimary: colors.secondary,
      surfaceTint: Colors.transparent,
    );
  }
}

/// Fade + small lift. Short enough to stay out of the way, and consistent on
/// every platform so a Windows window does not jump like Android.
class _HookPageTransitionsBuilder extends PageTransitionsBuilder {
  const _HookPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (route.settings.name == null && animation.isCompleted) return child;
    final curved = CurvedAnimation(
      parent: animation,
      curve: HookMotion.enter,
      reverseCurve: HookMotion.exit,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.018),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
