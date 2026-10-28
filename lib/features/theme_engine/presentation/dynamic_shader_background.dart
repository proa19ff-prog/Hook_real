import 'dart:ui' as ui;
import 'package:flutter/material.dart';
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
  late final AnimationController _animController;
  ui.FragmentProgram? _program;
  bool _shaderLoadFailed = false;

  Color _c1 = const Color(0xFF6C5CE7);
  Color _c2 = const Color(0xFFA29BFE);
  Color _c3 = const Color(0xFF00CEC9);
  Color _c4 = const Color(0xFF0D0E12);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _loadShader();
    _updatePalette();
  }

  @override
  void didUpdateWidget(covariant DynamicShaderBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.artworkUrl != widget.artworkUrl) {
      _updatePalette();
    }
  }

  Future<void> _loadShader() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
          'assets/shaders/mesh_gradient.frag');
      if (mounted) {
        setState(() {
          _program = program;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _shaderLoadFailed = true;
        });
      }
    }
  }

  Future<void> _updatePalette() async {
    final artUrl = widget.artworkUrl;
    if (artUrl == null || artUrl.isEmpty) {
      setState(() {
        _c1 = widget.theme.colors.primary;
        _c2 = widget.theme.colors.secondary;
        _c3 = widget.theme.colors.accent;
        _c4 = widget.theme.colors.background;
      });
      return;
    }

    try {
      final palette = await PaletteGenerator.fromImageProvider(
        ResizeImage(
          NetworkImage(artUrl),
          width: 128,
          height: 128,
        ),
        maximumColorCount: 8,
      );

      if (mounted) {
        setState(() {
          _c1 = palette.dominantColor?.color ?? widget.theme.colors.primary;
          _c2 = palette.vibrantColor?.color ?? widget.theme.colors.secondary;
          _c3 = palette.mutedColor?.color ?? widget.theme.colors.accent;
          _c4 = palette.darkMutedColor?.color ?? widget.theme.colors.background;
        });
      }
    } catch (_) {
      // Fallback to theme colors if network fails
      setState(() {
        _c1 = widget.theme.colors.primary;
        _c2 = widget.theme.colors.secondary;
        _c3 = widget.theme.colors.accent;
        _c4 = widget.theme.colors.background;
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meshEnabled = widget.theme.styling.shaderMeshEnabled;

    if (!meshEnabled || _shaderLoadFailed || _program == null) {
      // Fallback animated radial gradient
      return AnimatedContainer(
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
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return CustomPaint(
          painter: _MeshShaderPainter(
            program: _program!,
            time: _animController.value * 20.0,
            c1: _c1,
            c2: _c2,
            c3: _c3,
            c4: _c4,
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _MeshShaderPainter extends CustomPainter {
  final ui.FragmentProgram program;
  final double time;
  final Color c1;
  final Color c2;
  final Color c3;
  final Color c4;

  _MeshShaderPainter({
    required this.program,
    required this.time,
    required this.c1,
    required this.c2,
    required this.c3,
    required this.c4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shader = program.fragmentShader();

    // Uniform index 0, 1: resolution
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);

    // Uniform index 2: time
    shader.setFloat(2, time);

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
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _MeshShaderPainter oldDelegate) => true;
}
