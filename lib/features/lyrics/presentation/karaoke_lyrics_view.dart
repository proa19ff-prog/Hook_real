import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../audio_player/presentation/player_state_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/lyrics_client.dart';
import '../domain/lyric_line.dart';

const _easeOut = Cubic(0.23, 1, 0.32, 1);

/// A pause between sung lines at least this long shows the break dots.
const _breakThreshold = Duration(seconds: 4);

/// One row of the lyrics list: a sung line, or an instrumental break.
class _Item {
  final LyricLine? line;
  final Duration start;
  final Duration end;

  const _Item.line(LyricLine this.line, this.start, this.end);
  const _Item.gap(this.start, this.end) : line = null;

  bool get isGap => line == null;
}

List<_Item> _buildItems(List<LyricLine> lines) {
  final items = <_Item>[];
  if (lines.isEmpty) return items;

  if (lines.first.startTime >= _breakThreshold) {
    items.add(_Item.gap(Duration.zero, lines.first.startTime));
  }
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final next = i + 1 < lines.length ? lines[i + 1] : null;
    if (next == null) {
      final end = line.endTime ?? line.vocalEnd + const Duration(seconds: 4);
      items.add(_Item.line(line, line.startTime, end));
      continue;
    }
    // The line stays lit briefly after its last word, then the break starts.
    var lineEnd = line.vocalEnd + const Duration(milliseconds: 700);
    if (next.startTime - lineEnd >= _breakThreshold) {
      if (lineEnd < line.startTime) lineEnd = line.startTime;
      items.add(_Item.line(line, line.startTime, lineEnd));
      items.add(_Item.gap(lineEnd, next.startTime));
    } else {
      items.add(_Item.line(line, line.startTime, next.startTime));
    }
  }
  return items;
}

class KaraokeLyricsView extends ConsumerStatefulWidget {
  final HookTheme theme;

  const KaraokeLyricsView({
    super.key,
    required this.theme,
  });

  @override
  ConsumerState<KaraokeLyricsView> createState() => _KaraokeLyricsViewState();
}

class _KaraokeLyricsViewState extends ConsumerState<KaraokeLyricsView>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  /// Playback position, refreshed every frame. just_audio extrapolates its
  /// position between platform updates, so the sweep moves smoothly instead
  /// of in 200 ms steps.
  final ValueNotifier<Duration> _clock = ValueNotifier(Duration.zero);
  late final Ticker _ticker;

  List<LyricLine>? _source;
  List<_Item> _items = const [];
  List<GlobalKey> _keys = const [];
  int _active = -1;
  double _syncOffsetSeconds = 0.0;
  bool _showOffsetControls = false;

  DateTime _userScrollUntil = DateTime.fromMillisecondsSinceEpoch(0);
  Timer? _resumeTimer;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _resumeTimer?.cancel();
    _clock.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Duration _position() {
    final player = ref.read(audioPlayerServiceProvider).rawPlayer;
    return player.position +
        Duration(milliseconds: (_syncOffsetSeconds * 1000).round());
  }

  void _onTick(Duration _) {
    if (_items.isEmpty) return;
    final pos = _position();
    _clock.value = pos;
    final index = _indexAt(pos);
    if (index != _active) {
      setState(() => _active = index);
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollTo(_active));
    }
  }

  /// Index of the item playing at [pos]; -1 before the first one and
  /// `_items.length` after the last one ends.
  int _indexAt(Duration pos) {
    if (_items.isEmpty || pos < _items.first.start) return -1;
    var lo = 0;
    var hi = _items.length - 1;
    while (lo < hi) {
      final mid = (lo + hi + 1) >> 1;
      if (_items[mid].start <= pos) {
        lo = mid;
      } else {
        hi = mid - 1;
      }
    }
    if (lo == _items.length - 1 && pos >= _items[lo].end) return _items.length;
    return lo;
  }

  void _setLines(List<LyricLine> lines) {
    _source = lines;
    _items = _buildItems(lines);
    _keys = List.generate(_items.length, (_) => GlobalKey());
    _active = _indexAt(_position());
    _userScrollUntil = DateTime.fromMillisecondsSinceEpoch(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_active < 0 && _scrollController.hasClients) {
        _scrollController.jumpTo(0);
      } else {
        _scrollTo(_active, animate: false);
      }
    });
  }

  void _scrollTo(int index, {bool animate = true}) {
    if (!mounted || index < 0 || index >= _items.length) return;
    if (DateTime.now().isBefore(_userScrollUntil)) return;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = animate && !reduceMotion
        ? const Duration(milliseconds: 650)
        : Duration.zero;

    final itemContext = _keys[index].currentContext;
    if (itemContext != null) {
      Scrollable.ensureVisible(
        itemContext,
        alignment: 0.3,
        duration: duration,
        curve: _easeOut,
      );
      return;
    }
    if (!_scrollController.hasClients) return;

    // The item is not laid out yet (a seek far ahead): jump near it, then
    // align precisely once it is built.
    final position = _scrollController.position;
    final estimate = (index * 72.0).clamp(0.0, position.maxScrollExtent);
    _scrollController.jumpTo(estimate);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = mounted ? _keys[index].currentContext : null;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 0.3, duration: Duration.zero);
      }
    });
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is UserScrollNotification &&
        notification.direction != ScrollDirection.idle) {
      // The user is reading ahead or back: stop following for a moment.
      _userScrollUntil = DateTime.now().add(const Duration(seconds: 3));
      _resumeTimer?.cancel();
      _resumeTimer = Timer(const Duration(milliseconds: 3100), () {
        _scrollTo(_active);
      });
    }
    return false;
  }

  void _seekTo(LyricLine line) {
    final offset = Duration(milliseconds: (_syncOffsetSeconds * 1000).round());
    final target = line.startTime - offset;
    ref
        .read(audioPlayerServiceProvider)
        .seek(target < Duration.zero ? Duration.zero : target);
    _userScrollUntil = DateTime.fromMillisecondsSinceEpoch(0);
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(trackLyricsProvider);
    final colors = widget.theme.colors;

    return lyricsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.primary),
      ),
      error: (_, __) => _buildMessage(
        colors,
        MingCuteIcons.mgc_forbid_circle_line,
        'Текст песни не найден',
      ),
      data: (LyricsResult? result) {
        if (result == null || result.isEmpty) {
          return _buildMessage(
            colors,
            MingCuteIcons.mgc_mic_line,
            'Текст караоке отсутствует для этого трека',
          );
        }

        // Unsynced lyrics have invented timings that never match the audio,
        // so they are shown as calm static text.
        if (!result.isRealSync) return _buildStatic(result, colors);

        if (!identical(result.lines, _source)) _setLines(result.lines);
        return _buildSynced(colors);
      },
    );
  }

  Widget _buildMessage(HookColors colors, IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _edgeFade({required Widget child}) {
    return ShaderMask(
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0.0, 0.1, 0.86, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }

  Widget _buildStatic(LyricsResult result, HookColors colors) {
    final lines = result.lines;
    return _edgeFade(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
        itemCount: lines.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Текст без синхронизации',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: colors.textSecondary,
                ),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              lines[index - 1].text,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: colors.textPrimary.withValues(alpha: 0.78),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSynced(HookColors colors) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            return NotificationListener<ScrollNotification>(
              onNotification: _onScrollNotification,
              child: _edgeFade(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(24, h * 0.28, 24, h * 0.62),
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final isActive = index == _active;
                    if (item.isGap) {
                      return KeyedSubtree(
                        key: _keys[index],
                        child: _BreakDots(
                          item: item,
                          active: isActive,
                          clock: _clock,
                          color: colors.textPrimary,
                          reduceMotion: reduceMotion,
                        ),
                      );
                    }
                    final distance =
                        _active < 0 ? index + 1 : (index - _active).abs();
                    return KeyedSubtree(
                      key: _keys[index],
                      child: _LineTile(
                        line: item.line!,
                        isActive: isActive,
                        isPast: _active >= 0 && index < _active,
                        distance: distance,
                        clock: _clock,
                        colors: colors,
                        reduceMotion: reduceMotion,
                        onTap: () => _seekTo(item.line!),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        if (_source?.any((line) => line.hasRealWordTimings) ?? false)
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: Align(
              alignment: _showOffsetControls
                  ? Alignment.center
                  : Alignment.centerRight,
              child: _showOffsetControls
                  ? _buildOffsetBar(colors)
                  : IconButton(
                      tooltip: 'Настроить синхронизацию текста',
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: 0.88),
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(
                          color: colors.border.withValues(alpha: 0.45),
                        ),
                      ),
                      icon: const Icon(MingCuteIcons.mgc_settings_3_line),
                      onPressed: () {
                        setState(() => _showOffsetControls = true);
                      },
                    ),
            ),
          ),
      ],
    );
  }

  Widget _buildOffsetBar(HookColors colors) {
    final offsetStr = _syncOffsetSeconds == 0.0
        ? 'Сдвиг: 0.0с'
        : 'Сдвиг: ${_syncOffsetSeconds > 0 ? "+" : ""}${_syncOffsetSeconds.toStringAsFixed(1)}с';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildOffsetBtn('-0.5s', () => _shiftOffset(-0.5)),
          _buildOffsetBtn('-0.1s', () => _shiftOffset(-0.1)),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _syncOffsetSeconds = 0.0),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                offsetStr,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _syncOffsetSeconds == 0.0
                      ? colors.textSecondary
                      : colors.accent,
                ),
              ),
            ),
          ),
          _buildOffsetBtn('+0.1s', () => _shiftOffset(0.1)),
          _buildOffsetBtn('+0.5s', () => _shiftOffset(0.5)),
          IconButton(
            tooltip: 'Скрыть настройку',
            constraints: const BoxConstraints.tightFor(width: 28, height: 28),
            padding: EdgeInsets.zero,
            iconSize: 16,
            icon: Icon(
              MingCuteIcons.mgc_close_line,
              color: colors.textSecondary,
            ),
            onPressed: () => setState(() => _showOffsetControls = false),
          ),
        ],
      ),
    );
  }

  void _shiftOffset(double delta) {
    setState(() {
      _syncOffsetSeconds =
          double.parse((_syncOffsetSeconds + delta).toStringAsFixed(1));
    });
  }

  Widget _buildOffsetBtn(String label, VoidCallback onTap) {
    final colors = widget.theme.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: colors.textPrimary,
          ),
        ),
      ),
    );
  }
}

const _lineStyle = TextStyle(
  fontSize: 27,
  fontWeight: FontWeight.w800,
  height: 1.22,
  letterSpacing: -0.4,
);

class _LineTile extends StatelessWidget {
  final LyricLine line;
  final bool isActive;
  final bool isPast;
  final int distance;
  final ValueListenable<Duration> clock;
  final HookColors colors;
  final bool reduceMotion;
  final VoidCallback onTap;

  const _LineTile({
    required this.line,
    required this.isActive,
    required this.isPast,
    required this.distance,
    required this.clock,
    required this.colors,
    required this.reduceMotion,
    required this.onTap,
  });

  static double _progress(LyricWord w, Duration pos) {
    if (pos <= w.startTime) return 0.0;
    if (pos >= w.endTime) return 1.0;
    final total = (w.endTime - w.startTime).inMicroseconds;
    if (total <= 0) return 1.0;
    return (pos - w.startTime).inMicroseconds / total;
  }

  @override
  Widget build(BuildContext context) {
    final words = line.words.isNotEmpty
        ? line.words
        : [
            LyricWord(
              text: line.text,
              startTime: line.startTime,
              endTime: line.endTime ?? line.startTime,
            ),
          ];
    final opacity = isActive
        ? 1.0
        : switch (distance) {
            1 => 0.85,
            2 => 0.65,
            _ => 0.45,
          };
    final animate = !reduceMotion;

    final body = TweenAnimationBuilder<double>(
      tween: Tween(end: isActive ? 1.0 : 0.0),
      duration: animate ? const Duration(milliseconds: 420) : Duration.zero,
      curve: _easeOut,
      builder: (context, emphasis, _) {
        Widget wrap(Duration? pos) => _WordsWrap(
              words: words,
              progressOf: (w) =>
                  pos == null ? (isPast ? 1.0 : 0.0) : _progress(w, pos),
              emphasis: emphasis,
              realTimings: line.hasRealWordTimings,
              colors: colors,
              reduceMotion: reduceMotion,
            );
        if (!isActive) return wrap(null);
        return ValueListenableBuilder<Duration>(
          valueListenable: clock,
          builder: (context, pos, _) => wrap(pos),
        );
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: AnimatedOpacity(
          opacity: opacity,
          duration: animate ? const Duration(milliseconds: 350) : Duration.zero,
          curve: _easeOut,
          child: AnimatedScale(
            scale: isActive || !animate ? 1.0 : 0.94,
            alignment: Alignment.centerLeft,
            duration:
                animate ? const Duration(milliseconds: 450) : Duration.zero,
            curve: _easeOut,
            child: body,
          ),
        ),
      ),
    );
  }
}

class _WordsWrap extends StatelessWidget {
  final List<LyricWord> words;
  final double Function(LyricWord) progressOf;

  /// 1 while the line is the current one, easing to 0 as it ends.
  final double emphasis;
  final bool realTimings;
  final HookColors colors;
  final bool reduceMotion;

  const _WordsWrap({
    required this.words,
    required this.progressOf,
    required this.emphasis,
    required this.realTimings,
    required this.colors,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final dim = colors.textPrimary.withValues(alpha: 0.32);
    final sung = Color.lerp(dim, colors.textPrimary, emphasis)!;
    const spaceWidth = 27 * 0.27;

    return Wrap(
      runSpacing: 2,
      children: [
        for (var i = 0; i < words.length; i++)
          () {
            final w = words[i];
            final text = w.text.trim();
            final spaced = w.text.endsWith(' ') ||
                (i + 1 < words.length && words[i + 1].text.startsWith(' '));
            final p = progressOf(w);
            final longNote = realTimings &&
                w.endTime - w.startTime >= const Duration(milliseconds: 900);
            return Padding(
              padding: EdgeInsets.only(right: spaced ? spaceWidth : 0),
              child: _SweepWord(
                text: text,
                progress: p,
                sung: sung,
                dim: dim,
                feather: realTimings ? 10 : 22,
                lift: reduceMotion ? 0 : 2.0 * emphasis * _easeOut.transform(p),
                glow: longNote ? emphasis * math.sin(p * math.pi) : 0,
              ),
            );
          }(),
      ],
    );
  }
}

/// A word filled left to right as it is sung, with a soft leading edge.
class _SweepWord extends StatelessWidget {
  final String text;
  final double progress;
  final Color sung;
  final Color dim;

  /// Width of the soft edge in logical pixels.
  final double feather;
  final double lift;
  final double glow;

  const _SweepWord({
    required this.text,
    required this.progress,
    required this.sung,
    required this.dim,
    required this.feather,
    required this.lift,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    Widget painted;
    if (progress <= 0) {
      painted = Text(text, style: _lineStyle.copyWith(color: dim));
    } else if (progress >= 1 && glow <= 0) {
      painted = Text(text, style: _lineStyle.copyWith(color: sung));
    } else {
      painted = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (rect) {
          final f =
              rect.width <= 0 ? 0.2 : (feather / rect.width).clamp(0.02, 0.45);
          final edge = -f + progress * (1 + 2 * f);
          return LinearGradient(
            colors: [sung, dim],
            stops: [
              (edge - f).clamp(0.0, 1.0),
              (edge + f).clamp(0.0, 1.0),
            ],
          ).createShader(rect);
        },
        child: Text(
          text,
          style: _lineStyle.copyWith(
            color: Colors.white,
            shadows: glow > 0.01
                ? [
                    Shadow(
                      color: Colors.white.withValues(alpha: 0.6 * glow),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
        ),
      );
    }
    if (lift > 0.01) {
      painted = Transform.translate(offset: Offset(0, -lift), child: painted);
    }
    return painted;
  }
}

/// Three dots that fill over an instrumental break and breathe while it
/// plays, then shrink away just before the next line.
class _BreakDots extends StatelessWidget {
  final _Item item;
  final bool active;
  final ValueListenable<Duration> clock;
  final Color color;
  final bool reduceMotion;

  const _BreakDots({
    required this.item,
    required this.active,
    required this.clock,
    required this.color,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration:
          reduceMotion ? Duration.zero : const Duration(milliseconds: 300),
      curve: _easeOut,
      alignment: Alignment.topLeft,
      child: !active
          ? const SizedBox(width: double.infinity, height: 0)
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: ValueListenableBuilder<Duration>(
                valueListenable: clock,
                builder: (context, pos, _) {
                  final totalMs = (item.end - item.start).inMilliseconds;
                  final p = totalMs <= 0
                      ? 1.0
                      : ((pos - item.start).inMilliseconds / totalMs)
                          .clamp(0.0, 1.0);
                  final remainingMs = (item.end - pos).inMilliseconds;
                  final exit =
                      _easeOut.transform((remainingMs / 450).clamp(0.0, 1.0));
                  final breathe = reduceMotion
                      ? 1.0
                      : 1.0 +
                          0.08 *
                              math.sin(pos.inMilliseconds / 2400 * 2 * math.pi);
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Opacity(
                      opacity: exit,
                      child: Transform.scale(
                        scale: breathe * (0.7 + 0.3 * exit),
                        alignment: Alignment.centerLeft,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < 3; i++)
                              Container(
                                width: 11,
                                height: 11,
                                margin: const EdgeInsets.only(right: 9),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: color.withValues(
                                    alpha: 0.25 +
                                        0.75 * (p * 3 - i).clamp(0.0, 1.0),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
