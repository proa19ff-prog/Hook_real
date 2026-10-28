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

  void _scrollToActiveIndex(int index, int totalLines) {
    if (index == _lastActiveIndex || !mounted) return;
    _lastActiveIndex = index;

    // Approximate line height ~ 60px
    const itemHeight = 60.0;
    final targetOffset = (index * itemHeight) - 150.0;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 350),
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

    final position = positionAsync.value ?? Duration.zero;

    return lyricsAsync.when(
      loading: () => Center(
        child: CircularProgressIndicator(
          color: widget.theme.colors.primary,
        ),
      ),
      error: (_, __) => Center(
        child: Text(
          'Текст песни не найден',
          style: TextStyle(
            color: widget.theme.colors.textSecondary,
            fontSize: 16,
          ),
        ),
      ),
      data: (LyricsResult? result) {
        if (result == null || result.isEmpty) {
          return Center(
            child: Text(
              'Текст песни отсутствует',
              style: TextStyle(
                color: widget.theme.colors.textSecondary,
                fontSize: 16,
              ),
            ),
          );
        }

        // If only plain text is available
        if (!result.hasSynced) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Text(
              result.plainLyrics ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.theme.colors.textPrimary.withValues(alpha: 0.85),
                fontSize: 18,
                height: 1.8,
              ),
            ),
          );
        }

        final lines = result.lines;

        // Find active line index
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

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 200),
          itemCount: lines.length,
          itemBuilder: (context, index) {
            final line = lines[index];
            final isActive = index == activeIndex;
            final isPast = index < activeIndex;

            return InkWell(
              onTap: () {
                playerService.seek(line.startTime);
              },
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: line.hasWordTimings && isActive
                    ? _buildWordHighlightedLine(line, position)
                    : Text(
                        line.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isActive ? 24 : 18,
                          fontWeight:
                              isActive ? FontWeight.w800 : FontWeight.w500,
                          color: isActive
                              ? widget.theme.colors.textPrimary
                              : (isPast
                                  ? widget.theme.colors.textSecondary
                                      .withValues(alpha: 0.5)
                                  : widget.theme.colors.textSecondary
                                      .withValues(alpha: 0.8)),
                          height: 1.4,
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWordHighlightedLine(LyricLine line, Duration position) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: line.words.map((w) {
        final isWordActive = w.isActiveAt(position);
        final isWordPast = position >= w.endTime;

        return Text(
          w.text,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isWordActive
                ? widget.theme.colors.accent
                : (isWordPast
                    ? widget.theme.colors.textPrimary
                    : widget.theme.colors.textPrimary.withValues(alpha: 0.4)),
          ),
        );
      }).toList(),
    );
  }
}
