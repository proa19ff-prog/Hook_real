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
    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final isPlaying = playerStateAsync.value?.playing ?? false;

    return HookGlassCard(
      theme: theme,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => FullscreenPlayer(theme: theme),
          ),
        );
      },
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            // Artwork thumbnail
            Hero(
              tag: 'current_artwork',
              child: TrackArtwork(
                url: track.artworkUrl,
                size: 48,
                placeholderColor: theme.colors.surface,
                iconColor: theme.colors.textSecondary,
              ),
            ),

            const SizedBox(width: 12),

            // Title and Artist
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
                  Text(
                    track.artist,
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

            // Play / Pause Button
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: theme.colors.textPrimary,
                size: 28,
              ),
              onPressed: () {
                if (isPlaying) {
                  playerService.pause();
                } else {
                  playerService.play();
                }
              },
            ),

            // Next Button
            IconButton(
              icon: Icon(
                Icons.skip_next_rounded,
                color: theme.colors.textSecondary,
                size: 28,
              ),
              onPressed: () => playerService.next(),
            ),
          ],
        ),
      ),
    );
  }
}
