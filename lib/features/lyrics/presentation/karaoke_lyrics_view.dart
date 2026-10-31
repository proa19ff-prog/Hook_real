import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/lrclib_client.dart';
import '../domain/lyric_line.dart';

class KaraokeLyricsView extends ConsumerStatefulWidget {
  final HookTheme theme;

  const KaraokeLyricsView({
    super.key,
    required this.theme,
  });

  @override
  ConsumerState<KaraokeLyricsView> createState() => _KaraokeLyricsViewState();
}

class _KaraokeLyricsViewState extends ConsumerState<KaraokeLyricsView> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _itemKeys = {};
  int _lastActiveIndex = -1;
  double _syncOffsetSeconds = 0.0;

  GlobalKey _keyForIndex(int index) =>
      _itemKeys.putIfAbsent(index, () => GlobalKey());

  void _scrollToActiveIndex(int index) {
    if (index == _lastActiveIndex || !mounted) return;
    _lastActiveIndex = index;

    final keyContext = _itemKeys[index]?.currentContext;
    if (keyContext != null) {
      // Element is already built: glide it to the upper third (0.3) of the
      // viewport without jumping.
      Scrollable.ensureVisible(
        keyContext,
        alignment: 0.3,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else if (_scrollController.hasClients) {
      // Fallback: the user seeked far ahead and the widget is not laid out yet.
      const estimatedItemHeight = 60.0;
      final targetOffset = (index * estimatedItemHeight) - 80.0;
      _scrollController.animateTo(
        targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lyricsAsync = ref.watch(trackLyricsProvider);
    final positionAsync = ref.watch(positionStreamProvider);
    final playerService = ref.watch(audioPlayerServiceProvider);
    final colors = widget.theme.colors;

    final rawPosition = positionAsync.value ?? Duration.zero;
    final offsetMillis = (_syncOffsetSeconds * 1000).round();
    final position = rawPosition + Duration(milliseconds: offsetMillis);

    return lyricsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(color: colors.primary),
      ),
      error: (_, __) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(MingCuteIcons.mgc_forbid_circle_line,
                size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 12),
            Text(
              'Текст песни не найден',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      data: (LyricsResult? result) {
        if (result == null || result.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(MingCuteIcons.mgc_mic_line,
                    size: 48, color: colors.textSecondary.withValues(alpha: 0.5)),
                const SizedBox(height: 12),
                Text(
                  'Текст караоке отсутствует для этого трека',
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

        final lines = result.lines;

        // Unsynced lyrics (synthesized from plain text) have invented timings
        // that never match the actual audio — show them as calm static text
        // instead of a karaoke highlight that runs ahead of / behind the song.
        if (!result.isRealSync) {
          return Stack(
            children: [
              ShaderMask(
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Colors.transparent,
                    Colors.white,
                    Colors.white,
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.06, 0.92, 1.0],
                ).createShader(rect),
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                  itemCount: lines.length,
                  itemBuilder: (context, index) {
                    final line = lines[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 8),
                      child: Text(
                        line.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }

        // Find active line index using offset-adjusted position
        int activeIndex = -1;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].isActiveAt(position)) {
            activeIndex = i;
            break;
          }
        }

        // Drop stale keys when the track changed and the line count shrank.
        if (_itemKeys.length > lines.length) {
          _itemKeys.clear();
          _lastActiveIndex = -1;
        }

        // Auto-scroll when active line changes
        if (activeIndex >= 0 && activeIndex != _lastActiveIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _scrollToActiveIndex(activeIndex);
          });
        }

        return Stack(
          children: [
            ShaderMask(
              shaderCallback: (rect) => LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: const [
                  Colors.transparent,
                  Colors.white,
                  Colors.white,
                  Colors.transparent,
                ],
                stops: const [0.0, 0.06, 0.92, 1.0],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                itemCount: lines.length,
                itemBuilder: (context, index) {
                  final line = lines[index];
                  final isActive = index == activeIndex;
                  final isPast = activeIndex != -1 && index < activeIndex;

                  return InkWell(
                    key: _keyForIndex(index),
                    onTap: () {
                      // Respect the user timing offset when seeking by tap.
                      final adjustedTarget =
                          line.startTime - Duration(milliseconds: offsetMillis);
                      playerService.seek(
                        adjustedTarget < Duration.zero
                            ? Duration.zero
                            : adjustedTarget,
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: line.hasRealWordTimings && isActive
                          ? _buildWordHighlightedLine(line, position, colors)
                          : Text(
                              line.text,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: isActive ? 22 : 16,
                                fontWeight:
                                    isActive ? FontWeight.w800 : FontWeight.w500,
                                color: isActive
                                    ? colors.accent
                                    : (isPast
                                        ? colors.textSecondary
                                            .withValues(alpha: 0.45)
                                        : colors.textPrimary
                                            .withValues(alpha: 0.75)),
                                height: 1.4,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),

            // Floating Timing Offset Adjustment Bar
            _buildOffsetBar(colors),
          ],
        );
      },
    );
  }

  Widget _buildOffsetBar(HookColors colors) {
    final offsetStr = _syncOffsetSeconds == 0.0
        ? 'Сдвиг: 0.0с'
        : 'Сдвиг: ${_syncOffsetSeconds > 0 ? "+" : ""}${_syncOffsetSeconds.toStringAsFixed(1)}с';

    return Positioned(
      bottom: 12,
      left: 16,
      right: 16,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.45),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOffsetBtn('-0.5s', () => setState(() => _syncOffsetSeconds -= 0.5)),
              _buildOffsetBtn('-0.1s', () => setState(() => _syncOffsetSeconds -= 0.1)),
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
              _buildOffsetBtn('+0.1s', () => setState(() => _syncOffsetSeconds += 0.1)),
              _buildOffsetBtn('+0.5s', () => setState(() => _syncOffsetSeconds += 0.5)),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildWordHighlightedLine(
      LyricLine line, Duration position, HookColors colors) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6.0, // gap between words
      runSpacing: 4.0, // gap between wrapped lines
      children: line.words.map((w) {
        final isWordActive = w.isActiveAt(position);
        final isWordPast = position >= w.endTime;

        return AnimatedScale(
          scale: isWordActive ? 1.06 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 160),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: isWordActive
                  ? colors.accent
                  : (isWordPast
                      ? colors.textPrimary
                      : colors.textPrimary.withValues(alpha: 0.38)),
              shadows: isWordActive
                  ? [
                      Shadow(
                        color: colors.accent.withValues(alpha: 0.75),
                        blurRadius: 18,
                      ),
                    ]
                  : null,
            ),
            child: Text(w.text.trim()),
          ),
        );
      }).toList(),
    );
  }
}
