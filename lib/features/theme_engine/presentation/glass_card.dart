import 'package:flutter/material.dart';

import '../domain/hook_theme.dart';

/// Shared surface used by the main app chrome and content cards.
/// Keeping this in one place makes the visual language consistent across
/// screens and lets themes control the rounding.
///
/// This used to wrap its content in a `BackdropFilter`. Real-time blur over
/// an animated background re-blurs the whole region every frame and was the
/// main cause of jank on phones, so the "glass" look is now a translucent
/// tinted fill, which costs a single draw call.
class HookGlassCard extends StatelessWidget {
  final HookTheme theme;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;

  const HookGlassCard({
    super.key,
    required this.theme,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(theme.styling.borderRadius.clamp(14, 24));

    // Theme glass colours are tuned for a blurred backdrop and are nearly
    // transparent. Without blur they need more opacity to stay readable.
    final fill = color ??
        Color.alphaBlend(
          theme.colors.surfaceGlass,
          theme.colors.surface.withValues(alpha: 0.86),
        );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: theme.colors.border.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: padding == null
              ? child
              : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
