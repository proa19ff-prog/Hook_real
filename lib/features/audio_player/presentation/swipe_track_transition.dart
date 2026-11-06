import 'dart:async';

import 'package:flutter/material.dart';

enum TrackSwipeDirection { next, previous }

/// One moving track panel (artwork + metadata). Playback controls stay anchored.
/// Motion is independent of URL resolution: slow audio must not lock gestures.
class SwipeTrackTransition extends StatefulWidget {
  final Object trackKey;
  final Widget child;
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final int queueIndex;
  final bool enabled;

  const SwipeTrackTransition({
    super.key,
    required this.trackKey,
    required this.child,
    required this.onNext,
    required this.onPrevious,
    this.queueIndex = -1,
    this.enabled = true,
  });

  @override
  State<SwipeTrackTransition> createState() => SwipeTrackTransitionState();
}

class SwipeTrackTransitionState extends State<SwipeTrackTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;
  Widget? _outgoing;
  double _width = 0;
  double _drag = 0;
  double _gestureDistance = 0;
  double _incomingFrom = 0;
  double _outgoingFrom = 0;
  double _outgoingTo = 0;
  double _snapFrom = 0;
  bool _snapping = false;
  bool _reduceMotion = false;
  bool _gestureCancelled = false;
  TrackSwipeDirection? _requestedDirection;
  int _request = 0;

  double get _progress => Curves.easeOutCubic.transform(_motion.value);
  double get _currentOffset => _outgoing != null
      ? _incomingFrom * (1 - _progress)
      : _snapping
      ? _snapFrom * (1 - _progress)
      : _drag;

  @override
  void initState() {
    super.initState();
    _motion =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 360),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed && mounted) {
            setState(() {
              _outgoing = null;
              _snapping = false;
              _drag = 0;
            });
          }
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _motion.stop();
      _outgoing = null;
      _snapping = false;
      _drag = 0;
    }
  }

  @override
  void didUpdateWidget(SwipeTrackTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackKey == widget.trackKey) return;
    final offset = _currentOffset;
    final direction =
        _requestedDirection ??
        (widget.queueIndex >= 0 &&
                oldWidget.queueIndex >= 0 &&
                widget.queueIndex < oldWidget.queueIndex
            ? TrackSwipeDirection.previous
            : TrackSwipeDirection.next);
    _requestedDirection = null;
    _motion.stop();
    _gestureDistance = 0;
    _drag = 0;
    _snapping = false;
    // Empty/error states do not fly in as though they were another recording.
    if (_reduceMotion || !widget.enabled || !oldWidget.enabled || _width <= 0) {
      _outgoing = null;
      return;
    }
    // At most one outgoing panel. Rapid changes cannot accumulate stale cards.
    _outgoing = oldWidget.child;
    _outgoingFrom = offset;
    _incomingFrom = direction == TrackSwipeDirection.next ? _width : -_width;
    _outgoingTo = -_incomingFrom;
    _motion.duration = const Duration(milliseconds: 360);
    _motion.forward(from: 0);
  }

  void _snapBack() {
    final offset = _currentOffset;
    _motion.stop();
    if (_reduceMotion || offset.abs() < 0.5) {
      setState(() {
        _outgoing = null;
        _drag = 0;
        _snapping = false;
      });
      return;
    }
    setState(() {
      _outgoing = null;
      _snapFrom = offset;
      _snapping = true;
      _drag = 0;
    });
    _motion.duration = const Duration(milliseconds: 220);
    _motion.forward(from: 0);
  }

  /// Also used by the next/previous buttons, keeping both navigation paths in
  /// the same direction. A button can keep its usual "restart after 3s" action.
  void navigate(
    TrackSwipeDirection direction, {
    Future<void> Function()? action,
  }) {
    if (!widget.enabled) return;
    _requestedDirection = direction;
    final request = ++_request;
    final oldKey = widget.trackKey;
    _snapBack();
    unawaited(() async {
      try {
        await (action ??
            (direction == TrackSwipeDirection.next
                ? widget.onNext
                : widget.onPrevious))();
      } catch (error, stack) {
        if (mounted && request == _request) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stack,
              library: 'Hook player',
              context: ErrorDescription('while changing the current track'),
            ),
          );
        }
      } finally {
        if (mounted && request == _request && widget.trackKey == oldKey) {
          // A synchronous selection can reach Riverpod before the next widget
          // rebuild. Keep the direction hint until that frame has been painted.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && request == _request && widget.trackKey == oldKey) {
              _requestedDirection = null;
            }
          });
          WidgetsBinding.instance.ensureVisualUpdate();
        }
      }
    }());
  }

  void _dragStart(DragStartDetails details) {
    _gestureCancelled = false;
    final offset = _currentOffset;
    _motion.stop();
    setState(() {
      _outgoing = null;
      _snapping = false;
      _gestureDistance = 0;
      _drag = _reduceMotion ? 0 : offset;
    });
  }

  void _dragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta ?? 0;
    _gestureDistance += delta;
    if (_reduceMotion) return;
    setState(
      () => _drag = (_drag + delta).clamp(-_width * 0.72, _width * 0.72),
    );
  }

  void _dragEnd(DragEndDetails details) {
    if (_gestureCancelled) {
      _gestureDistance = 0;
      _snapBack();
      return;
    }
    final velocity = details.primaryVelocity ?? 0;
    final distance = _gestureDistance;
    _gestureDistance = 0;
    if (velocity.abs() >= 520) {
      navigate(
        velocity < 0 ? TrackSwipeDirection.next : TrackSwipeDirection.previous,
      );
    } else if (distance.abs() >= 56) {
      navigate(
        distance < 0 ? TrackSwipeDirection.next : TrackSwipeDirection.previous,
      );
    } else {
      _snapBack();
    }
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      _width = bounds.maxWidth;
      return Listener(
        onPointerCancel: (_) => _gestureCancelled = true,
        child: GestureDetector(
          key: const ValueKey('player-track-swipe-area'),
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: widget.enabled ? _dragStart : null,
          onHorizontalDragUpdate: widget.enabled ? _dragUpdate : null,
          onHorizontalDragEnd: widget.enabled ? _dragEnd : null,
          onHorizontalDragCancel: widget.enabled ? _snapBack : null,
          child: ClipRect(
            child: AnimatedBuilder(
              animation: _motion,
              builder: (context, _) {
                final progress = _progress;
                return Stack(
                  children: [
                    if (_outgoing != null)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: ExcludeSemantics(
                            child: Transform.translate(
                              key: const ValueKey('player-outgoing-track'),
                              offset: Offset(
                                _outgoingFrom +
                                    (_outgoingTo - _outgoingFrom) * progress,
                                0,
                              ),
                              child: Opacity(
                                opacity: 1 - progress * 0.35,
                                child: _outgoing,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Transform.translate(
                      key: const ValueKey('player-current-track'),
                      offset: Offset(_currentOffset, 0),
                      child: Opacity(
                        opacity: _outgoing == null ? 1 : 0.8 + progress * 0.2,
                        child: widget.child,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
    },
  );

  @override
  void dispose() {
    _request++;
    _motion.dispose();
    super.dispose();
  }
}
