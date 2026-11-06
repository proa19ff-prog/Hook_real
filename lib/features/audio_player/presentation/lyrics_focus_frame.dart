import 'dart:async';

import 'package:flutter/material.dart';

import '../../lyrics/presentation/lyrics_chrome.dart';
export '../../lyrics/presentation/lyrics_chrome.dart' show LyricsChrome;

/// Keeps the lyrics view mounted while the surrounding controls disappear.
/// Time spent off-screen, in the background, or holding a pointer never counts.
class LyricsFocusFrame extends StatefulWidget {
  const LyricsFocusFrame({
    super.key,
    required this.active,
    required this.enabled,
    required this.trackKey,
    required this.builder,
  });

  final bool active;
  final bool enabled;
  final Object trackKey;
  final Widget Function(BuildContext, bool hidden, VoidCallback restore)
  builder;

  @override
  State<LyricsFocusFrame> createState() => _LyricsFocusFrameState();
}

class _LyricsFocusFrameState extends State<LyricsFocusFrame>
    with WidgetsBindingObserver {
  static const _delay = Duration(seconds: 10);
  Timer? _timer;
  bool _hidden = false;
  bool _foreground = true;
  bool _routeCurrent = true;
  final _pointers = <int>{};

  bool get _canHide =>
      widget.active && widget.enabled && _foreground && _routeCurrent;

  @override
  void initState() {
    super.initState();
    _foreground =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.of(context)?.isCurrent ?? true;
    final changed = current != _routeCurrent;
    _routeCurrent = current;
    if (changed || _timer == null && !_hidden) _restart();
  }

  @override
  void didUpdateWidget(covariant LyricsFocusFrame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active ||
        oldWidget.enabled != widget.enabled ||
        oldWidget.trackKey != widget.trackKey) {
      _hidden = false;
      _restart();
    }
  }

  void _restart() {
    _timer?.cancel();
    _timer = null;
    if (!_canHide) {
      _hidden = false;
      return;
    }
    if (_hidden || _pointers.isNotEmpty) return;
    _timer = Timer(_delay, () {
      _timer = null;
      if (mounted && _canHide && _pointers.isEmpty) {
        setState(() => _hidden = true);
      }
    });
  }

  void _restore() {
    setState(() => _hidden = false);
    _restart();
  }

  void _pointerDown(PointerDownEvent event) {
    _pointers.add(event.pointer);
    _timer?.cancel();
    _timer = null;
  }

  void _pointerEnd(PointerEvent event) {
    _pointers.remove(event.pointer);
    if (_pointers.isEmpty) _restart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (foreground == _foreground) return;
    setState(() {
      _foreground = foreground;
      _hidden = false;
      _pointers.clear();
      _restart();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Listener(
    behavior: HitTestBehavior.translucent,
    onPointerDown: _pointerDown,
    onPointerUp: _pointerEnd,
    onPointerCancel: _pointerEnd,
    child: LyricsControlsScope(
      hidden: _hidden,
      child: widget.builder(context, _hidden, _restore),
    ),
  );
}
