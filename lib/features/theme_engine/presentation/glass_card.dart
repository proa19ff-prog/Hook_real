import 'package:flutter/material.dart';
import '../domain/hook_theme.dart';

/// Shared luxury glass surface used by the main app chrome and content cards.
class HookGlassCard extends StatelessWidget {
  final HookTheme theme;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final Color? color;
  final VoidCallback? onTap;
  final double elevation;

  const HookGlassCard({
    super.key,
    required this.theme,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.onTap,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(theme.styling.borderRadius.clamp(14, 24));

    final baseFill = color ??
        Color.alphaBlend(
          theme.colors.surfaceGlass.withValues(alpha: 0.28),
          theme.colors.surface.withValues(alpha: 0.88),
        );

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 18 * elevation,
                    spreadRadius: 1,
                    offset: Offset(0, 8 * elevation),
                  ),
                  BoxShadow(
                    color: theme.colors.primary.withValues(alpha: 0.04 * elevation),
                    blurRadius: 24 * elevation,
                    spreadRadius: 2,
                    offset: Offset(0, 4 * elevation),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Material(
          color: baseFill,
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(
              color: theme.colors.border.withValues(alpha: 0.55),
              width: 1.0,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.colors.primary.withValues(alpha: 0.12),
            highlightColor: theme.colors.primary.withValues(alpha: 0.06),
            child: padding == null
                ? child
                : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}
