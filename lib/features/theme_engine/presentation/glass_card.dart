import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/hook_theme.dart';

/// Shared surface used by the main app chrome and content cards.
/// Keeping this in one place makes the visual language consistent across
/// screens and lets themes control the amount of blur and rounding.
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

    final card = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: theme.styling.cardBlur,
          sigmaY: theme.styling.cardBlur,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: color ?? theme.colors.surfaceGlass,
            borderRadius: radius,
            border: Border.all(
              color: theme.colors.border.withValues(alpha: 0.72),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );

    final interactive = onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap,
              child: card,
            ),
          );

    return margin == null
        ? interactive
        : Padding(padding: margin!, child: interactive);
  }
}
