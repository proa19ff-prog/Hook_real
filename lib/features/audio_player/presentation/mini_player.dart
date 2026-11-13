import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'desktop_player_bar.dart';
import 'fullscreen_player.dart';
import 'player_state_provider.dart';

/// The player and navigation share one measured layout, including the device's
/// bottom safe area exactly once. Use as Scaffold.bottomNavigationBar so page
/// content cannot disappear under either control.
///
/// On a wide window the dock is replaced by [DesktopPlayerBar]: a three-zone
/// bar with inline volume, because a 320px-wide mini player in a 1400px window
/// hides every control that makes a desktop music app usable.
class PlaybackDock extends ConsumerWidget {
  const PlaybackDock({super.key, required this.theme, this.navigation});

  final HookTheme theme;
  final Widget? navigation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTrack = ref.watch(currentTrackProvider) != null;
    final desktop = HookBreakpoints.isDesktop(context);
    if (!hasTrack && navigation == null) return const SizedBox.shrink();
    if (desktop) {
      return ColoredBox(
        color: theme.colors.background,
        child: DesktopPlayerBar(theme: theme),
      );
    }
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

/// The phone-sized player. Kept deliberately spare: artwork, title, play and
/// next. Everything else is one tap away in the full-screen player.
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
      padding: const EdgeInsets.fromLTRB(
        HookSpace.md,
        0,
        HookSpace.md,
        HookSpace.sm,
      ),
      child: Material(
        color: colors.surface,
        borderRadius: HookRadius.mdAll,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            PageRouteBuilder<void>(
              pageBuilder: (_, __, ___) => FullscreenPlayer(theme: theme),
              transitionDuration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : HookMotion.slow,
              transitionsBuilder: (_, animation, __, child) => SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: HookMotion.enter,
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
                padding: const EdgeInsets.fromLTRB(
                  HookSpace.md,
                  HookSpace.sm,
                  HookSpace.xs,
                  HookSpace.sm,
                ),
                child: Row(
                  children: [
                    TrackArtwork(
                      url: track.artworkUrl,
                      artist: track.artist,
                      title: track.title,
                      duration: track.duration,
                      size: 44,
                      borderRadius: HookRadius.xsAll,
                      placeholderColor: colors.background,
                      iconColor: colors.textSecondary,
                    ),
                    const SizedBox(width: HookSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: HookType.bodySmall,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: HookSpace.xs),
                          Text(
                            loading ? strings.loading : track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: HookType.label,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: HookSpace.xs),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: loading
                          ? Padding(
                              padding: const EdgeInsets.all(HookSpace.md),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.accent,
                                semanticsLabel: strings.loading,
                              ),
                            )
                          : IconButton(
                              tooltip: playing ? strings.pause : strings.play,
                              icon: Icon(
                                playing ? HookIcons.pause : HookIcons.play,
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
                        HookIcons.next,
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
