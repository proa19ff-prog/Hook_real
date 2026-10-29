import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:palette_generator/palette_generator.dart';
import '../domain/hook_theme.dart';

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
  /// The gradient moves slowly, so 20 fps looks the same as 60/120 fps
  /// while costing the GPU a fraction of the work.
  static const _frameInterval = Duration(milliseconds: 50);

  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier(0);
  Duration _lastFrame = Duration.zero;
  ui.FragmentProgram? _program;
  bool _shaderLoadFailed = false;
  String? _paletteUrl;

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

  void _onTick(Duration elapsed) {
    if (elapsed - _lastFrame < _frameInterval) return;
    _lastFrame = elapsed;
    _time.value = elapsed.inMilliseconds / 1000.0;
  }

  @override
  void didUpdateWidget(covariant DynamicShaderBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkUrl != widget.artworkUrl ||
        oldWidget.theme.id != widget.theme.id) {
      _updatePalette();
    }
    _syncTicker();
  }

  bool get _shaderActive =>
      widget.theme.styling.shaderMeshEnabled &&
      !_shaderLoadFailed &&
      _program != null;

  void _syncTicker() {
    if (_shaderActive && !_ticker.isActive) {
      _ticker.start();
    } else if (!_shaderActive && _ticker.isActive) {
      _ticker.stop();
    }
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
          'assets/shaders/mesh_gradient.frag');
      if (!mounted) return;
      setState(() => _program = program);
    } catch (e) {
      if (!mounted) return;
      setState(() => _shaderLoadFailed = true);
    }
    _syncTicker();
  }

  void _useThemeColors() {
    setState(() {
      _c1 = widget.theme.colors.primary;
      _c2 = widget.theme.colors.secondary;
      _c3 = widget.theme.colors.accent;
      _c4 = widget.theme.colors.background;
    });
  }

  Future<void> _updatePalette() async {
    final artUrl = widget.artworkUrl;
    _paletteUrl = artUrl;
    if (artUrl == null || artUrl.isEmpty) {
      _useThemeColors();
      return;
    }

    try {
      // A 48px thumbnail is plenty for picking four colours and keeps the
      // quantization work on the UI thread to a few milliseconds.
      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(NetworkImage(artUrl), width: 48, height: 48),
        maximumColorCount: 6,
      );

      // Ignore results for a track the user has already skipped past.
      if (!mounted || _paletteUrl != artUrl) return;
      setState(() {
        _c1 = palette.dominantColor?.color ?? widget.theme.colors.primary;
        _c2 = palette.vibrantColor?.color ?? widget.theme.colors.secondary;
        _c3 = palette.mutedColor?.color ?? widget.theme.colors.accent;
        _c4 = palette.darkMutedColor?.color ?? widget.theme.colors.background;
      });
    } catch (_) {
      // Fallback to theme colors if network fails
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
    if (!_shaderActive) {
      background = AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          color: widget.theme.colors.background,
          gradient: RadialGradient(
            center: const Alignment(0.0, -0.4),
            radius: 1.2,
            colors: [
              _c1.withValues(alpha: 0.35),
              _c2.withValues(alpha: 0.15),
              widget.theme.colors.background,
            ],
          ),
        ),
      );
    } else {
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
    }

    // Separate repaint boundaries keep the animated background from forcing
    // the whole UI on top of it to repaint on every shader frame.
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(child: background),
        RepaintBoundary(child: widget.child),
      ],
    );
  }
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
    final shader = _shader;

    // Uniform index 0, 1: resolution
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // Uniform index 2: time
    shader.setFloat(2, time.value);

    // Helper to set vec4 color
    void setColorUniform(int startIndex, Color c) {
      shader.setFloat(startIndex + 0, c.r);
      shader.setFloat(startIndex + 1, c.g);
      shader.setFloat(startIndex + 2, c.b);
      shader.setFloat(startIndex + 3, c.a);
    }

    // Color 1: index 3-6
    setColorUniform(3, c1);
    // Color 2: index 7-10
    setColorUniform(7, c2);
    // Color 3: index 11-14
    setColorUniform(11, c3);
    // Color 4: index 15-18
    setColorUniform(15, c4);

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _MeshShaderPainter oldDelegate) =>
      oldDelegate.program != program ||
      oldDelegate.c1 != c1 ||
      oldDelegate.c2 != c2 ||
      oldDelegate.c3 != c3 ||
      oldDelegate.c4 != c4;
}
