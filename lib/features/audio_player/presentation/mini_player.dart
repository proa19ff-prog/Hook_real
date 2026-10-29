import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/glass_card.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'fullscreen_player.dart';
import 'player_state_provider.dart';

class MiniPlayer extends ConsumerWidget {
  final HookTheme theme;

  const MiniPlayer({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);
    if (track == null) return const SizedBox.shrink();

    final playerService = ref.watch(audioPlayerServiceProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isLoading = ref.watch(isTrackLoadingProvider);

    return HookGlassCard(
      theme: theme,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullscreenPlayer(theme: theme),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 62,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: Row(
                children: [
                  Hero(
                    tag: 'current_artwork',
                    child: TrackArtwork(
                      url: track.artworkUrl,
                      size: 46,
                      placeholderColor: theme.colors.surface,
                      iconColor: theme.colors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isLoading ? 'Загрузка…' : track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 48,
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: theme.colors.textPrimary,
                            ),
                          )
                        : IconButton(
                            tooltip: isPlaying ? 'Пауза' : 'Играть',
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: theme.colors.textPrimary,
                              size: 30,
                            ),
                            onPressed: playerService.togglePlayPause,
                          ),
                  ),
                  IconButton(
                    tooltip: 'Следующий',
                    icon: Icon(
                      Icons.skip_next_rounded,
                      color: theme.colors.textSecondary,
                      size: 28,
                    ),
                    onPressed: playerService.next,
                  ),
                ],
              ),
            ),
          ),
          _MiniProgressBar(theme: theme),
        ],
      ),
    );
  }
}

/// Separate widget so position ticks (several per second) rebuild only this
/// 2px bar, not the whole mini player.
class _MiniProgressBar extends ConsumerWidget {
  final HookTheme theme;

  const _MiniProgressBar({required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final position = ref.watch(positionStreamProvider).valueOrNull;
    final duration = ref.watch(durationStreamProvider).valueOrNull;
    final total = duration?.inMilliseconds ?? 0;
    final value = total > 0 && position != null
        ? (position.inMilliseconds / total).clamp(0.0, 1.0)
        : 0.0;

    return LinearProgressIndicator(
      value: value,
      minHeight: 2,
      color: theme.colors.primary,
      backgroundColor: theme.colors.border.withValues(alpha: 0.4),
    );
  }
}
