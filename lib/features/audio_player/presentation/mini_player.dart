import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
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
      elevation: 1.2,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => FullscreenPlayer(theme: theme),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 68,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 6),
              child: Row(
                children: [
                  Hero(
                    tag: 'current_artwork',
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colors.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TrackArtwork(
                        url: track.artworkUrl,
                        size: 48,
                        placeholderColor: theme.colors.surface,
                        iconColor: theme.colors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
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
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isLoading ? 'Загрузка…' : track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isLoading
                                ? theme.colors.accent
                                : theme.colors.textSecondary,
                            fontWeight: isLoading ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Play / Pause button
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: isLoading
                        ? Padding(
                            padding: const EdgeInsets.all(12),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: theme.colors.accent,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colors.primary,
                                  theme.colors.primary.withValues(alpha: 0.8),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colors.primary.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: IconButton(
                              tooltip: isPlaying ? 'Пауза' : 'Играть',
                              iconSize: 22,
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isPlaying
                                    ? MingCuteIcons.mgc_pause_fill
                                    : MingCuteIcons.mgc_play_fill,
                                color: Colors.white,
                              ),
                              onPressed: playerService.togglePlayPause,
                            ),
                          ),
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    tooltip: 'Следующий',
                    icon: Icon(
                      MingCuteIcons.mgc_skip_forward_fill,
                      color: theme.colors.textSecondary,
                      size: 26,
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

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 2.5,
        color: theme.colors.accent,
        backgroundColor: theme.colors.border.withValues(alpha: 0.3),
      ),
    );
  }
}
