import 'package:flutter/material.dart';

/// Propagates immersive mode without recreating lyrics or translation state.
/// Lyrics screens outside the fullscreen player keep their controls visible.
class LyricsControlsScope extends InheritedWidget {
  const LyricsControlsScope({
    super.key,
    required this.hidden,
    required super.child,
  });

  final bool hidden;

  static bool hiddenOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LyricsControlsScope>()
          ?.hidden ??
      false;

  @override
  bool updateShouldNotify(LyricsControlsScope oldWidget) =>
      hidden != oldWidget.hidden;
}

/// Slides chrome out, clips it, and releases its space to the lyrics.
/// Hidden controls keep their state but cannot receive input or accessibility
/// focus; reduced motion changes the layout immediately.
class LyricsChrome extends StatefulWidget {
  const LyricsChrome({
    super.key,
    required this.hidden,
    required this.slideUp,
    required this.child,
  });

  final bool hidden;
  final bool slideUp;
  final Widget child;

  @override
  State<LyricsChrome> createState() => _LyricsChromeState();
}

class _LyricsChromeState extends State<LyricsChrome>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
    value: widget.hidden ? 0 : 1,
  );
  late final _visibility = CurvedAnimation(
    parent: _motion,
    curve: Curves.easeInOutCubic,
  );

  void _updateMotion() {
    final target = widget.hidden ? 0.0 : 1.0;
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.value = target;
    } else {
      _motion.animateTo(target);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(covariant LyricsChrome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hidden != widget.hidden) _updateMotion();
  }

  @override
  void dispose() {
    _visibility.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    ignoring: widget.hidden,
    child: ExcludeSemantics(
      excluding: widget.hidden,
      child: SizeTransition(
        sizeFactor: _visibility,
        alignment: widget.slideUp
            ? Alignment.topCenter
            : Alignment.bottomCenter,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0, widget.slideUp ? -1 : 1),
            end: Offset.zero,
          ).animate(_visibility),
          child: FadeTransition(opacity: _visibility, child: widget.child),
        ),
      ),
    ),
  );
}
