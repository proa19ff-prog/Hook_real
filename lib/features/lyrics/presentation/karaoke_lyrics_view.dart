import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../l10n/generated/app_localizations.dart';

import '../../audio_player/presentation/player_state_provider.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/lyrics_client.dart';
import '../domain/lyric_line.dart';
import '../domain/lyrics_display_mode.dart';
import 'lyrics_preferences_provider.dart';
import 'lyrics_chrome.dart';
import 'lyrics_translation_panel.dart';

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
  var singingUntil = Duration.zero;
  for (var i = 0; i < lines.length; i++) {
    final line = lines[i];
    final next = i + 1 < lines.length ? lines[i + 1] : null;
    var vocalEnd = line.vocalEnd;
    for (final backing in line.backingVocals) {
      if (backing.vocalEnd > vocalEnd) vocalEnd = backing.vocalEnd;
    }
    if (vocalEnd > singingUntil) singingUntil = vocalEnd;
    final gapStart = singingUntil + const Duration(milliseconds: 700);
    items.add(_Item.line(line, line.startTime, line.groupEnd));
    if (next != null && next.startTime - gapStart >= _breakThreshold) {
      items.add(_Item.gap(gapStart, next.startTime));
    }
  }
  return items;
}

class KaraokeLyricsView extends ConsumerStatefulWidget {
  final HookTheme theme;

  const KaraokeLyricsView({super.key, required this.theme});

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
  String? _offsetTrackKey;
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
    for (var i = lo; i >= 0; i--) {
      final item = _items[i];
      if (pos < item.end && item.line?.isBacking != true) return i;
    }
    for (var i = lo; i >= 0; i--) {
      if (pos < _items[i].end) return i;
    }
    return lo == _items.length - 1 ? _items.length : lo;
  }

  void _setLines(List<LyricLine> lines) {
    _source = lines;
    _items = _buildItems(lines);
    _keys = List.generate(_items.length, (_) => GlobalKey());
    _clock.value = _position();
    _active = _indexAt(_clock.value);
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
      final ctx = mounted && index < _keys.length
          ? _keys[index].currentContext
          : null;
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
    final mode = ref.watch(lyricsDisplayModeProvider);
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final track = ref.watch(currentTrackProvider);
    final offsetKey = track == null
        ? null
        : '${track.source.name}:${track.id}:${track.duration.inMilliseconds}';
    if (_offsetTrackKey != offsetKey) {
      _offsetTrackKey = offsetKey;
      _syncOffsetSeconds = offsetKey == null
          ? 0
          : ref.read(localStorageServiceProvider).getLyricsOffset(offsetKey);
      _showOffsetControls = false;
      _source = null;
      _items = const [];
      _keys = const [];
      _active = -1;
    }

    return lyricsAsync.when(
      loading: () =>
          Center(child: CircularProgressIndicator(color: colors.primary)),
      error: (_, __) => _buildMessage(
        colors,
        MingCuteIcons.mgc_forbid_circle_line,
        strings.lyricsNotFound,
      ),
      data: (LyricsResult? result) {
        if (result == null || result.isEmpty) {
          return _buildMessage(
            colors,
            MingCuteIcons.mgc_mic_line,
            strings.karaokeUnavailable,
          );
        }

        if (result.isRealSync && !identical(result.lines, _source)) {
          _setLines(result.lines);
        }
        return LyricsTranslationPanel(
          key: ValueKey((
            offsetKey,
            result,
            Localizations.localeOf(context).languageCode,
          )),
          lyrics: result,
          theme: widget.theme,
          caption: !result.isRealSync
              ? strings.unsyncedLyrics
              : result.hasWordSync
              ? strings.wordSyncUpper
              : strings.lineSyncUpper,
          builder: (translations) => result.isRealSync
              ? _buildSynced(colors, mode, translations)
              : _buildStatic(result, colors, translations),
        );
      },
    );
  }

  Widget _buildMessage(HookColors colors, IconData icon, String text) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: colors.textSecondary.withValues(alpha: 0.5),
          ),
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

  Widget _buildStatic(
    LyricsResult result,
    HookColors colors,
    Map<String, String> translations,
  ) {
    final lines = result.lines.isNotEmpty
        ? result.lines.map((line) => line.text).toList()
        : (result.plainLyrics ?? '').split('\n');
    return _edgeFade(
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 48),
        itemCount: lines.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  lines[index],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                    color: colors.textPrimary.withValues(alpha: 0.78),
                  ),
                ),
                if (translations[lines[index]] case final String translation)
                  _TranslationText(
                    text: translation,
                    color: colors.textSecondary,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSynced(
    HookColors colors,
    LyricsDisplayMode mode,
    Map<String, String> translations,
  ) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final strings = AppLocalizations.of(context);

    return Stack(
      children: [
        if (mode == LyricsDisplayMode.focus)
          _buildFocus(colors, reduceMotion, translations)
        else
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
                      final distance = _active < 0
                          ? index + 1
                          : (index - _active).abs();
                      return KeyedSubtree(
                        key: _keys[index],
                        child: VocalLyricGroup(
                          line: item.line!,
                          distance: distance,
                          clock: _clock,
                          colors: colors,
                          reduceMotion: reduceMotion,
                          wordSweep: mode == LyricsDisplayMode.karaoke,
                          onSeek: _seekTo,
                          translations: translations,
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        if (_source?.isNotEmpty ?? false)
          Positioned(
            bottom: 12,
            left: 16,
            right: 16,
            child: LyricsChrome(
              key: const ValueKey('lyrics-sync-chrome'),
              hidden: LyricsControlsScope.hiddenOf(context),
              slideUp: false,
              child: Align(
                alignment: _showOffsetControls
                    ? Alignment.center
                    : Alignment.centerRight,
                child: _showOffsetControls
                    ? _buildOffsetBar(colors)
                    : IconButton(
                        tooltip: strings.adjustLyricsSync,
                        style: IconButton.styleFrom(
                          backgroundColor: colors.surface.withValues(
                            alpha: 0.88,
                          ),
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
          ),
      ],
    );
  }

  Widget _buildFocus(
    HookColors colors,
    bool reduceMotion,
    Map<String, String> translations,
  ) {
    final strings = AppLocalizations.of(context);
    final current = _active >= 0 && _active < _items.length
        ? _items[_active]
        : null;
    final position = _clock.value;
    final overlapping = _items
        .where(
          (item) =>
              item.line != null &&
              position >= item.start &&
              position < item.end,
        )
        .toList();
    LyricLine? next;
    for (var i = math.max(0, _active + 1); i < _items.length; i++) {
      if (_items[i].line != null) {
        next = _items[i].line;
        break;
      }
    }
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 44, 28, 84),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedSwitcher(
                  duration: reduceMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 320),
                  child: Align(
                    key: ValueKey('focus:$_active'),
                    alignment: Alignment.centerLeft,
                    child: current?.line != null
                        ? Column(
                            children: [
                              for (final item
                                  in overlapping.isEmpty
                                      ? [current!]
                                      : overlapping)
                                VocalLyricGroup(
                                  line: item.line!,
                                  distance: 0,
                                  clock: _clock,
                                  colors: colors,
                                  reduceMotion: reduceMotion,
                                  onSeek: _seekTo,
                                  translations: translations,
                                ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (current?.isGap == true)
                                _BreakDots(
                                  item: current!,
                                  active: true,
                                  clock: _clock,
                                  color: colors.textPrimary,
                                  reduceMotion: reduceMotion,
                                ),
                              Text(
                                _active < 0
                                    ? strings.startsSoon
                                    : strings.musicContinues,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 24,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 28),
                  Text(
                    next.text,
                    style: TextStyle(
                      color: colors.textSecondary.withValues(alpha: 0.65),
                      fontSize: 18,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOffsetBar(HookColors colors) {
    final strings = AppLocalizations.of(context);
    final offset =
        '${_syncOffsetSeconds > 0 ? '+' : ''}${_syncOffsetSeconds.toStringAsFixed(1)}';
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          IconButton(
            tooltip: strings.decreaseLyricsOffset,
            onPressed: () => _shiftOffset(-0.1),
            icon: Icon(Icons.remove_rounded, color: colors.textPrimary),
          ),
          TextButton(
            onPressed: () => _setOffset(0),
            child: Text(
              strings.lyricsOffset(offset),
              style: TextStyle(color: colors.textPrimary, fontSize: 12),
            ),
          ),
          IconButton(
            tooltip: strings.increaseLyricsOffset,
            onPressed: () => _shiftOffset(0.1),
            icon: Icon(Icons.add_rounded, color: colors.textPrimary),
          ),
          IconButton(
            tooltip: strings.hideSetting,
            onPressed: () => setState(() => _showOffsetControls = false),
            icon: Icon(
              Icons.close_rounded,
              color: colors.textSecondary,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _shiftOffset(double delta) => _setOffset(_syncOffsetSeconds + delta);

  void _setOffset(double value) {
    setState(
      () => _syncOffsetSeconds = double.parse(
        value.clamp(-15.0, 15.0).toStringAsFixed(1),
      ),
    );
    final key = _offsetTrackKey;
    if (key == null) return;
    unawaited(
      ref
          .read(localStorageServiceProvider)
          .saveLyricsOffset(key, _syncOffsetSeconds)
          .catchError((Object error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    AppLocalizations.of(context).lyricsOffsetSaveFailed,
                  ),
                ),
              );
            }
          }),
    );
  }
}

const _lineStyle = TextStyle(
  fontSize: 27,
  fontWeight: FontWeight.w700,
  height: 1.22,
  letterSpacing: -0.4,
);

/// Translation follows its original line; it has no invented word timings.
class _TranslationText extends StatelessWidget {
  const _TranslationText({
    required this.text,
    required this.color,
    this.alignment = TextAlign.left,
  });
  final String text;
  final Color color;
  final TextAlign alignment;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      textAlign: alignment,
      style: TextStyle(
        color: color,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

class VocalLyricGroup extends StatelessWidget {
  final LyricLine line;
  final int distance;
  final ValueListenable<Duration> clock;
  final HookColors colors;
  final bool reduceMotion;
  final bool wordSweep;
  final ValueChanged<LyricLine> onSeek;
  final Map<String, String> translations;

  const VocalLyricGroup({
    super.key,
    required this.line,
    required this.distance,
    required this.clock,
    required this.colors,
    required this.reduceMotion,
    required this.onSeek,
    this.translations = const {},
    this.wordSweep = true,
  });

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Duration>(
    valueListenable: clock,
    builder: (context, position, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final part in [line, ...line.backingVocals])
          _LineTile(
            line: part,
            translation: translations[part.text],
            isActive:
                part.isActiveAt(position) &&
                (part.hasRealWordTimings ||
                    position <
                        part.vocalEnd + const Duration(milliseconds: 700)),
            isPast: position >= (part.endTime ?? part.vocalEnd),
            distance: distance,
            clock: clock,
            colors: colors,
            reduceMotion: reduceMotion,
            wordSweep: wordSweep,
            onTap: () => onSeek(part),
          ),
      ],
    ),
  );
}

Alignment _lineAlignment(LyricLine line) => switch (line.placement) {
  LyricPlacement.left => Alignment.centerLeft,
  LyricPlacement.right => Alignment.centerRight,
  LyricPlacement.center => Alignment.center,
};

class _LineTile extends StatelessWidget {
  final LyricLine line;
  final String? translation;
  final bool isActive;
  final bool isPast;
  final int distance;
  final ValueListenable<Duration> clock;
  final HookColors colors;
  final bool reduceMotion;
  final bool wordSweep;
  final VoidCallback onTap;

  const _LineTile({
    required this.line,
    this.translation,
    required this.isActive,
    required this.isPast,
    required this.distance,
    required this.clock,
    required this.colors,
    required this.reduceMotion,
    required this.onTap,
    this.wordSweep = true,
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
    final opacity = isActive || distance <= 1 ? 1.0 : 0.85;
    final animate = !reduceMotion;
    final alignment = _lineAlignment(line);
    final style = _lineStyle.copyWith(
      fontSize: line.isBacking ? 18 : 27,
      fontWeight: line.isBacking ? FontWeight.w500 : FontWeight.w700,
      height: line.isBacking ? 1.35 : 1.22,
    );

    final body = !wordSweep
        ? Text(
            line.text,
            textAlign: switch (line.placement) {
              LyricPlacement.left => TextAlign.left,
              LyricPlacement.right => TextAlign.right,
              LyricPlacement.center => TextAlign.center,
            },
            style: style.copyWith(
              color: isActive ? colors.textPrimary : colors.textSecondary,
            ),
          )
        : TweenAnimationBuilder<double>(
            tween: Tween(end: isActive ? 1.0 : 0.0),
            duration: animate
                ? const Duration(milliseconds: 420)
                : Duration.zero,
            curve: _easeOut,
            builder: (context, emphasis, _) {
              Widget wrap(Duration? pos) => _WordsWrap(
                words: words,
                style: style,
                placement: line.placement,
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

    return Semantics(
      key: ValueKey('vocal:${line.startTime.inMicroseconds}:${line.text}'),
      label:
          '${line.singer == null ? line.text : '${line.singer}: ${line.text}'}${translation == null ? '' : '\n$translation'}',
      selected: isActive,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: line.isBacking ? 0 : 12, bottom: 12),
          child: Align(
            alignment: alignment,
            child: FractionallySizedBox(
              widthFactor: line.isBacking
                  ? 0.78
                  : (line.singer == null ? 1 : 0.9),
              child: AnimatedOpacity(
                opacity: opacity,
                duration: animate
                    ? const Duration(milliseconds: 350)
                    : Duration.zero,
                curve: _easeOut,
                child: AnimatedScale(
                  scale: isActive || !animate ? 1.0 : 0.96,
                  alignment: alignment,
                  duration: animate
                      ? const Duration(milliseconds: 450)
                      : Duration.zero,
                  curve: _easeOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      body,
                      if (translation != null)
                        _TranslationText(
                          text: translation!,
                          color: colors.textSecondary,
                          alignment: switch (line.placement) {
                            LyricPlacement.left => TextAlign.left,
                            LyricPlacement.right => TextAlign.right,
                            LyricPlacement.center => TextAlign.center,
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WordsWrap extends StatelessWidget {
  final List<LyricWord> words;
  final TextStyle style;
  final LyricPlacement placement;
  final double Function(LyricWord) progressOf;

  /// 1 while the line is the current one, easing to 0 as it ends.
  final double emphasis;
  final bool realTimings;
  final HookColors colors;
  final bool reduceMotion;

  const _WordsWrap({
    required this.words,
    required this.style,
    required this.placement,
    required this.progressOf,
    required this.emphasis,
    required this.realTimings,
    required this.colors,
    required this.reduceMotion,
  });

  @override
  Widget build(BuildContext context) {
    final dim = colors.textSecondary;
    final sung = Color.lerp(dim, colors.textPrimary, emphasis)!;
    final spaceWidth = (style.fontSize ?? 27) * 0.27;

    return Wrap(
      alignment: switch (placement) {
        LyricPlacement.left => WrapAlignment.start,
        LyricPlacement.right => WrapAlignment.end,
        LyricPlacement.center => WrapAlignment.center,
      },
      runSpacing: 2,
      children: [
        for (var i = 0; i < words.length; i++)
          () {
            final w = words[i];
            final text = w.text.trim();
            final spaced =
                w.text.endsWith(' ') ||
                (i + 1 < words.length && words[i + 1].text.startsWith(' '));
            final p = progressOf(w);
            final longNote =
                realTimings &&
                w.endTime - w.startTime >= const Duration(milliseconds: 900);
            return Padding(
              padding: EdgeInsets.only(right: spaced ? spaceWidth : 0),
              child: _SweepWord(
                text: text,
                style: style,
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
  final TextStyle style;
  final double progress;
  final Color sung;
  final Color dim;

  /// Width of the soft edge in logical pixels.
  final double feather;
  final double lift;
  final double glow;

  const _SweepWord({
    required this.text,
    required this.style,
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
      painted = Text(text, style: style.copyWith(color: dim));
    } else if (progress >= 1 && glow <= 0) {
      painted = Text(text, style: style.copyWith(color: sung));
    } else {
      painted = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (rect) {
          final f = rect.width <= 0
              ? 0.2
              : (feather / rect.width).clamp(0.02, 0.45);
          final edge = -f + progress * (1 + 2 * f);
          return LinearGradient(
            colors: [sung, dim],
            stops: [(edge - f).clamp(0.0, 1.0), (edge + f).clamp(0.0, 1.0)],
          ).createShader(rect);
        },
        child: Text(
          text,
          style: style.copyWith(
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
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 300),
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
                      : ((pos - item.start).inMilliseconds / totalMs).clamp(
                          0.0,
                          1.0,
                        );
                  final remainingMs = (item.end - pos).inMilliseconds;
                  final exit = _easeOut.transform(
                    (remainingMs / 450).clamp(0.0, 1.0),
                  );
                  final breathe = reduceMotion
                      ? 1.0
                      : 1.0 +
                            0.08 *
                                math.sin(
                                  pos.inMilliseconds / 2400 * 2 * math.pi,
                                );
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
                                    alpha:
                                        0.25 +
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
