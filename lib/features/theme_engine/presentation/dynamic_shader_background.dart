import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:palette_generator/palette_generator.dart';
import '../domain/hook_theme.dart';
import 'track_artwork.dart';

/// Ambient theme data exposed to children inside [DynamicShaderBackground].
/// When dominant album art is white or light, automatically provides high-contrast dark text
/// and controls so content is never invisible on white backgrounds.
class AmbientThemeScope extends InheritedWidget {
  final bool isLight;
  final Color dominantColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color iconColor;
  final Color cardBackground;
  final Color cardBorder;

  const AmbientThemeScope({
    super.key,
    required this.isLight,
    required this.dominantColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.iconColor,
    required this.cardBackground,
    required this.cardBorder,
    required super.child,
  });

  static AmbientThemeScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AmbientThemeScope>();
  }

  @override
  bool updateShouldNotify(AmbientThemeScope oldWidget) {
    return isLight != oldWidget.isLight ||
        dominantColor != oldWidget.dominantColor ||
        textPrimary != oldWidget.textPrimary;
  }
}

class DynamicShaderBackground extends StatefulWidget {
  final HookTheme theme;
  final String? artworkUrl;
  final Widget child;

  const DynamicShaderBackground({
    super.key,
    required this.theme,
    this.artworkUrl,
    required this.child,
  });

  @override
  State<DynamicShaderBackground> createState() =>
      _DynamicShaderBackgroundState();
}

class _DynamicShaderBackgroundState extends State<DynamicShaderBackground>
    with SingleTickerProviderStateMixin {
  static const _frameInterval = Duration(
      milliseconds: 33); // ~30 fps for smooth, battery-friendly ambient flow

  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier(0);
  Duration _lastFrame = Duration.zero;
  ui.FragmentProgram? _program;
  bool _shaderLoadFailed = false;
  String? _paletteUrl;
  bool _isLightBackground = false;

  Color _c1 = const Color(0xFF6C5CE7);
  Color _c2 = const Color(0xFFA29BFE);
  Color _c3 = const Color(0xFF00CEC9);
  Color _c4 = const Color(0xFF0D0E12);

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    _loadShader();
    _updatePalette();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  void _updateMotion() {
    final animate = TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context) &&
        widget.theme.styling.shaderMeshEnabled;
    if (animate && !_ticker.isActive) {
      _lastFrame = Duration.zero;
      _ticker.start();
    } else if (!animate && _ticker.isActive) {
      _ticker.stop();
    }
  }

  void _onTick(Duration elapsed) {
    if (elapsed - _lastFrame < _frameInterval) return;
    _lastFrame = elapsed;
    _time.value = elapsed.inMilliseconds / 1000.0;
  }

  @override
  void didUpdateWidget(covariant DynamicShaderBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkUrl != widget.artworkUrl ||
        oldWidget.theme != widget.theme) {
      _updatePalette();
    }
    _updateMotion();
  }

  bool get _shaderActive =>
      widget.theme.styling.shaderMeshEnabled &&
      !_shaderLoadFailed &&
      _program != null;

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
          'assets/shaders/mesh_gradient.frag');
      if (!mounted) return;
      setState(() => _program = program);
    } catch (_) {
      if (!mounted) return;
      setState(() => _shaderLoadFailed = true);
    }
  }

  void _useThemeColors() {
    setState(() {
      final lightBg =
          widget.theme.colors.background.computeLuminance() > 0.58;
      // Dark themes keep their raw primary/secondary/accent as orb colors —
      // a near-white primary (OLED Monolith) used to flood the screen with a
      // light beige wash that white text and dark surfaces could not sit on.
      // Tame dark-theme orbs into the same calm range the cover palette uses.
      _c1 = lightBg
          ? widget.theme.colors.primary
          : _tame(
              widget.theme.colors.primary,
              maxSat: 0.55,
              minLight: 0.20,
              maxLight: 0.42,
            );
      _c2 = lightBg
          ? widget.theme.colors.secondary
          : _tame(
              widget.theme.colors.secondary,
              maxSat: 0.50,
              minLight: 0.16,
              maxLight: 0.36,
            );
      _c3 = lightBg
          ? widget.theme.colors.accent
          : _tame(
              widget.theme.colors.accent,
              maxSat: 0.45,
              minLight: 0.14,
              maxLight: 0.34,
            );
      _c4 = widget.theme.colors.background;
      _isLightBackground = lightBg;
    });
  }

  /// Clamps a palette color into a calm, dark range: capped saturation and
  /// lightness keep the background behind white text and controls.
  static Color _tame(
    Color c, {
    required double maxSat,
    required double minLight,
    required double maxLight,
  }) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withSaturation(hsl.saturation.clamp(0.0, maxSat))
        .withLightness(hsl.lightness.clamp(minLight, maxLight))
        .toColor();
  }

  Future<void> _updatePalette() async {
    final artUrl = TrackArtwork.getHighResUrl(widget.artworkUrl);
    _paletteUrl = artUrl;
    if (artUrl.isEmpty) {
      _useThemeColors();
      return;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(NetworkImage(artUrl), width: 48, height: 48),
        maximumColorCount: 6,
      );

      if (!mounted || _paletteUrl != artUrl) return;

      final dominant =
          palette.dominantColor?.color ?? widget.theme.colors.primary;
      // Muted swatches first: raw vibrant swatches are what made the mesh
      // garish (neon greens, hot pinks at full saturation).
      final second = palette.darkVibrantColor?.color ??
          palette.mutedColor?.color ??
          widget.theme.colors.secondary;
      final third = palette.mutedColor?.color ??
          palette.vibrantColor?.color ??
          widget.theme.colors.accent;
      final base =
          palette.darkMutedColor?.color ?? widget.theme.colors.background;

      setState(() {
        _c1 = _tame(dominant, maxSat: 0.55, minLight: 0.22, maxLight: 0.42);
        _c2 = _tame(second, maxSat: 0.50, minLight: 0.18, maxLight: 0.36);
        _c3 = _tame(third, maxSat: 0.45, minLight: 0.16, maxLight: 0.32);
        _c4 = _tame(base, maxSat: 0.35, minLight: 0.05, maxLight: 0.12);
        _isLightBackground = false;
      });
    } catch (_) {
      if (mounted && _paletteUrl == artUrl) _useThemeColors();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget background;
    if (_shaderActive) {
      background = CustomPaint(
        painter: _MeshShaderPainter(
          program: _program!,
          time: _time,
          c1: _c1,
          c2: _c2,
          c3: _c3,
          c4: _c4,
        ),
      );
    } else {
      background = CustomPaint(
        painter: _AuroraFlowPainter(
          time: _time,
          c1: _c1,
          c2: _c2,
          c3: _c3,
          bg: widget.theme.colors.background,
        ),
      );
    }

    final isLight = _isLightBackground;
    final textPrimary =
        isLight ? const Color(0xFF141419) : widget.theme.colors.textPrimary;
    final textSecondary =
        isLight ? const Color(0xFF4A4A5A) : widget.theme.colors.textSecondary;
    final iconColor =
        isLight ? const Color(0xFF1A1A22) : widget.theme.colors.textPrimary;
    final cardBg = isLight
        ? Colors.white.withValues(alpha: 0.65)
        : widget.theme.colors.surfaceGlass.withValues(alpha: 0.4);
    final cardBorder = isLight
        ? Colors.black.withValues(alpha: 0.18)
        : widget.theme.colors.border.withValues(alpha: 0.35);

    return AmbientThemeScope(
      isLight: isLight,
      dominantColor: _c1,
      textPrimary: textPrimary,
      textSecondary: textSecondary,
      iconColor: iconColor,
      cardBackground: cardBg,
      cardBorder: cardBorder,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(child: background),
          RepaintBoundary(child: widget.child),
        ],
      ),
    );
  }
}

/// Fallback luxury Aurora Glow painter with smooth drifting radial gradients
class _AuroraFlowPainter extends CustomPainter {
  final ValueNotifier<double> time;
  final Color c1;
  final Color c2;
  final Color c3;
  final Color bg;

  _AuroraFlowPainter({
    required this.time,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.bg,
  }) : super(repaint: time);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Base dark canvas
    final basePaint = Paint()..color = bg;
    canvas.drawRect(Offset.zero & size, basePaint);

    final t = time.value * 0.45;
    final w = size.width;
    final h = size.height;

    // 2. First drifting glowing orb (Primary color)
    final o1X = w * (0.35 + 0.25 * math.sin(t));
    final o1Y = h * (0.25 + 0.15 * math.cos(t * 0.8));
    final r1 = math.max(w, h) * 0.75;
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          c1.withValues(alpha: 0.42),
          c1.withValues(alpha: 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o1X, o1Y), radius: r1));
    canvas.drawCircle(Offset(o1X, o1Y), r1, paint1);

    // 3. Second drifting glowing orb (Vibrant / Secondary color)
    final o2X = w * (0.68 + 0.22 * math.cos(t * 0.7));
    final o2Y = h * (0.55 + 0.20 * math.sin(t * 0.9));
    final r2 = math.max(w, h) * 0.65;
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          c2.withValues(alpha: 0.32),
          c2.withValues(alpha: 0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.48, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o2X, o2Y), radius: r2));
    canvas.drawCircle(Offset(o2X, o2Y), r2, paint2);

    // 4. Third subtle accent orb (Bottom ambient bounce)
    final o3X = w * (0.50 + 0.30 * math.sin(t * 0.6 + 1.5));
    final o3Y = h * (0.80 + 0.15 * math.cos(t * 0.5));
    final r3 = math.max(w, h) * 0.55;
    final paint3 = Paint()
      ..shader = RadialGradient(
        colors: [
          c3.withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(o3X, o3Y), radius: r3));
    canvas.drawCircle(Offset(o3X, o3Y), r3, paint3);

    // 5. Very subtle vignette overlay for contrast and focus
    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.15,
        colors: [
          Colors.transparent,
          bg.withValues(alpha: 0.5),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(_AuroraFlowPainter oldDelegate) =>
      oldDelegate.c1 != c1 || oldDelegate.c2 != c2 || oldDelegate.bg != bg;
}

class _MeshShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final ValueNotifier<double> time;
  final Color c1;
  final Color c2;
  final Color c3;
  final Color c4;
  final ui.FragmentShader _shader;

  _MeshShaderPainter({
    required this.program,
    required this.time,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
  })  : _shader = program.fragmentShader(),
        super(repaint: time);

  @override
  void paint(Canvas canvas, Size size) {
    _shader.setFloat(0, size.width);
    _shader.setFloat(1, size.height);
    _shader.setFloat(2, time.value);

    // The GLSL contract declares four vec4s, not RGB triples.
    final colors = [c1, c2, c3, c4];
    for (var i = 0; i < colors.length; i++) {
      final color = colors[i];
      final offset = 3 + i * 4;
      _shader.setFloat(offset, color.r);
      _shader.setFloat(offset + 1, color.g);
      _shader.setFloat(offset + 2, color.b);
      _shader.setFloat(offset + 3, color.a);
    }

    final paint = Paint()..shader = _shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_MeshShaderPainter oldDelegate) =>
      oldDelegate.c1 != c1 ||
      oldDelegate.c2 != c2 ||
      oldDelegate.c3 != c3 ||
      oldDelegate.c4 != c4;
}
