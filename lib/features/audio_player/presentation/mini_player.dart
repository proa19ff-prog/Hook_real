import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'fullscreen_player.dart';
import 'player_state_provider.dart';

/// The player and navigation share one measured layout, including the device's
/// bottom safe area exactly once. Use as Scaffold.bottomNavigationBar so page
/// content cannot disappear under either control.
class PlaybackDock extends ConsumerWidget {
  const PlaybackDock({super.key, required this.theme, this.navigation});

  final HookTheme theme;
  final Widget? navigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrack = ref.watch(currentTrackProvider) != null;
    if (!hasTrack && navigation == null) return const SizedBox.shrink();
    return ColoredBox(
      color: theme.colors.background,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasTrack) MiniPlayer(theme: theme),
            if (navigation != null) navigation!,
          ],
        ),
      ),
    );
  }
}

class MiniPlayer extends ConsumerWidget {
  final HookTheme theme;
  const MiniPlayer({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final track = ref.watch(currentTrackProvider);
    if (track == null) return const SizedBox.shrink();
    final service = ref.watch(audioPlayerServiceProvider);
    final playing = ref.watch(isPlayingProvider);
    final loading = ref.watch(isTrackLoadingProvider);
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (_, __, ___) => FullscreenPlayer(theme: theme),
              transitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 300),
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 4, 10),
                child: Row(
                  children: [
                    Hero(
                      tag: 'current_artwork_${track.source.name}:${track.id}',
                      child: TrackArtwork(
                        url: track.artworkUrl,
                        size: 44,
                        borderRadius: BorderRadius.circular(8),
                        placeholderColor: colors.background,
                        iconColor: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            loading ? strings.loading : track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: loading
                          ? Padding(
                              padding: const EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.accent,
                                semanticsLabel: strings.loading,
                              ),
                            )
                          : IconButton(
                              tooltip: playing ? strings.pause : strings.play,
                              icon: Icon(
                                playing
                                    ? MingCuteIcons.mgc_pause_fill
                                    : MingCuteIcons.mgc_play_fill,
                                color: colors.textPrimary,
                                size: 28,
                              ),
                              onPressed: service.togglePlayPause,
                            ),
                    ),
                    IconButton(
                      tooltip: strings.next,
                      onPressed: service.next,
                      icon: Icon(
                        MingCuteIcons.mgc_skip_forward_fill,
                        color: colors.textPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              _MiniProgressBar(theme: theme),
            ],
          ),
        ),
      ),
    );
  }
}

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
      color: theme.colors.accent,
      backgroundColor: theme.colors.border,
    );
  }
}
