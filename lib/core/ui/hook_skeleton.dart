import 'package:flutter/material.dart';

import 'hook_tokens.dart';

/// Placeholder shapes shown while real content loads.
///
/// A centred spinner tells the listener that something is happening but not
/// what will appear, so the page jumps when it does. A skeleton with the shape
/// of the result set keeps the layout still and makes the wait feel shorter.
class HookSkeleton extends StatefulWidget {
  const HookSkeleton({
    super.key,
    required this.child,
    this.label,
    this.reduceMotion,
  });

  final Widget child;

  /// Announced by screen readers instead of leaving the region silent.
  final String? label;

  /// Read from `MediaQuery.disableAnimationsOf` by the caller; a shimmer is
  /// exactly the kind of motion a reduce-motion preference is asking to stop.
  final bool? reduceMotion;

  @override
  State<HookSkeleton> createState() => _HookSkeletonState();
}

class _HookSkeletonState extends State<HookSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void initState() {
    super.initState();
    if (!(widget.reduceMotion ??
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations)) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce =
        widget.reduceMotion ?? MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      return Semantics(
        label: widget.label,
        container: widget.label != null,
        child: widget.child,
      );
    }
    return Semantics(
      label: widget.label,
      container: widget.label != null,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              Color(0x00FFFFFF),
              Color(0x22FFFFFF),
              Color(0x00FFFFFF),
            ],
            stops: const [0.25, 0.5, 0.75],
            transform: _SlidingGradient(_controller.value),
          ).createShader(bounds),
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}

class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.progress);

  final double progress;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (progress * 2 - 1), 0, 0);
}

/// One grey block. Sized by the caller so a skeleton always has the exact
/// footprint of the widget it stands in for.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius});

  final double? width;
  final double height;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
        borderRadius: radius ?? HookRadius.smAll,
      ),
    );
  }
}

/// The shape of a track row: artwork, two text lines, a trailing control.
class SkeletonTrackRow extends StatelessWidget {
  const SkeletonTrackRow({super.key, this.height = 56});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: HookSpace.md,
        vertical: HookSpace.sm,
      ),
      child: Row(
        children: [
          SkeletonBox(width: height - 16, height: height - 16),
          const SizedBox(width: HookSpace.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SkeletonBox(height: 12),
                SizedBox(height: HookSpace.sm),
                FractionallySizedBox(
                  widthFactor: 0.55,
                  child: SkeletonBox(height: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: HookSpace.md),
          const SkeletonBox(width: 20, height: 20),
        ],
      ),
    );
  }
}

/// A short list of [SkeletonTrackRow]s, wrapped in one shimmer.
class SkeletonTrackList extends StatelessWidget {
  const SkeletonTrackList({super.key, this.count = 6, this.label});

  final int count;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return HookSkeleton(
      label: label,
      child: Column(
        children: [
          for (var index = 0; index < count; index++) const SkeletonTrackRow(),
        ],
      ),
    );
  }
}
