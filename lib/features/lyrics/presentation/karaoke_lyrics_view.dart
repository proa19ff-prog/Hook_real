import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int _lastActiveIndex = -1;
  double _syncOffsetSeconds = 0.0;

  void _scrollToActiveIndex(int index, int totalLines) {
    if (index == _lastActiveIndex || !mounted || !_scrollController.hasClients) return;
    _lastActiveIndex = index;

    // Line height ~ 60px; keep active line in the upper third for comfortable reading
    const itemHeight = 60.0;
    final targetOffset = (index * itemHeight) - 32.0;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
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
            Icon(Icons.subtitles_off_rounded,
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
                Icon(Icons.lyrics_outlined,
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

        // Find active line index using offset-adjusted position
        int activeIndex = -1;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].isActiveAt(position)) {
            activeIndex = i;
            break;
          }
        }

        // Auto-scroll when active line changes
        if (activeIndex >= 0 && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToActiveIndex(activeIndex, lines.length);
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
                    onTap: () => playerService.seek(line.startTime),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: line.hasWordTimings && isActive
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
            child: Text(w.text),
          ),
        );
      }).toList(),
    );
  }
}
