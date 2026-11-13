import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../extractor/models/media_track.dart';
import '../../search/presentation/artist_screen.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'player_state_provider.dart';

/// Persistent compact player bar shown at the bottom of the screen during
/// fullscreen lyrics mode.
///
/// Displays:
/// - Interactive track timeline scrubber showing current time and total duration.
/// - Album artwork preview thumbnail.
/// - Track title and author(s) via [InteractiveArtistText] for individual collaborator navigation.
/// - Playback controls (Previous, Play/Pause, Next) and exit fullscreen button.
class FullscreenLyricsBottomBar extends ConsumerStatefulWidget {
  final HookTheme theme;
  final MediaTrack? track;
  final VoidCallback onCollapse;
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const FullscreenLyricsBottomBar({
    super.key,
    required this.theme,
    required this.track,
    required this.onCollapse,
    this.onNext,
    this.onPrevious,
  });

  @override
  ConsumerState<FullscreenLyricsBottomBar> createState() =>
      _FullscreenLyricsBottomBarState();
}

class _FullscreenLyricsBottomBarState
    extends ConsumerState<FullscreenLyricsBottomBar> {
  double? _dragValue;
  bool _showRemaining = false;

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = widget.theme;
    final colors = theme.colors;
    final track = widget.track;
    final playerService = ref.watch(audioPlayerServiceProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isLoading = ref.watch(isTrackLoadingProvider);

    final position =
        ref.watch(positionStreamProvider).valueOrNull ?? Duration.zero;
    final duration =
        ref.watch(durationStreamProvider).valueOrNull ?? Duration.zero;

    final totalMs = duration.inMilliseconds.toDouble();
    final sliderVal =
        _dragValue ??
        (totalMs > 0
            ? position.inMilliseconds.toDouble().clamp(0.0, totalMs)
            : 0.0);
    final shownPosition = Duration(milliseconds: sliderVal.toInt());
    final remaining = duration - shownPosition;

    final ambient = AmbientThemeScope.of(context);
    final textPrimary = ambient?.textPrimary ?? colors.textPrimary;
    final textSecondary = ambient?.textSecondary ?? colors.textSecondary;
    final isLight = ambient?.isLight ?? false;
    final playBtnBg = isLight ? const Color(0xFF141419) : colors.textPrimary;
    final playBtnFg = isLight ? Colors.white : colors.background;

    final inactiveTrack = isLight
        ? Colors.black.withValues(alpha: 0.16)
        : colors.border.withValues(alpha: 0.5);

    final timeStyle = TextStyle(
      color: textSecondary,
      fontSize: HookType.label,
      fontWeight: FontWeight.w500,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timeline scrubber (progress bar & duration timecodes)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _showRemaining = !_showRemaining),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: HookSpace.xs,
                        ),
                        child: Text(
                          _showRemaining
                              ? '-${_formatDuration(remaining)}'
                              : _formatDuration(shownPosition),
                          style: timeStyle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 3.5,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14,
                          ),
                          activeTrackColor: colors.accent,
                          inactiveTrackColor: inactiveTrack,
                          thumbColor: colors.accent,
                          overlayColor: colors.accent.withValues(alpha: 0.15),
                        ),
                        child: Slider(
                          value: sliderVal,
                          min: 0.0,
                          max: totalMs > 0 ? totalMs : 1.0,
                          onChanged: totalMs > 0
                              ? (val) => setState(() => _dragValue = val)
                              : null,
                          onChangeEnd: (val) {
                            HookHaptics.tap();
                            ref
                                .read(audioPlayerServiceProvider)
                                .seek(Duration(milliseconds: val.toInt()));
                            setState(() => _dragValue = null);
                          },
                        ),
                      ),
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () =>
                          setState(() => _showRemaining = !_showRemaining),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: HookSpace.xs,
                        ),
                        child: Text(
                          _formatDuration(duration),
                          style: timeStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Main track info and playback controls row
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0.0;
                  if (velocity < -250) {
                    (widget.onNext ?? playerService.next)();
                  } else if (velocity > 250) {
                    (widget.onPrevious ?? playerService.previous)();
                  }
                },
                child: Row(
                  children: [
                    // Preview artwork thumbnail
                    GestureDetector(
                      onTap: () {
                        HookHaptics.tap();
                        widget.onCollapse();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: colors.border.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: TrackArtwork(
                            url: track?.artworkUrl ?? '',
                            artist: track?.artist,
                            title: track?.title,
                            duration: track?.duration,
                            size: 44,
                            borderRadius: BorderRadius.circular(7),
                            placeholderColor: colors.surface,
                            iconColor: colors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Title & Artist(s)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HookHaptics.tap();
                              widget.onCollapse();
                            },
                            child: Text(
                              track?.title ?? strings.queueEmpty,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (track != null)
                            InteractiveArtistText(
                              artist: track.artist,
                              theme: theme,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          else
                            Text(
                              strings.findMusicStart,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: textSecondary,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Previous track button
                    IconButton(
                      tooltip: strings.previousTrack,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        HookIcons.previous,
                        size: 22,
                        color: textPrimary,
                      ),
                      onPressed: widget.onPrevious ?? playerService.previous,
                    ),

                    const SizedBox(width: 2),

                    // Play / Pause prominent button
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: playBtnBg,
                      ),
                      child: isLoading
                          ? Padding(
                              padding: const EdgeInsets.all(11),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: playBtnFg,
                              ),
                            )
                          : IconButton(
                              tooltip: isPlaying ? strings.pause : strings.play,
                              constraints: const BoxConstraints.tightFor(
                                width: 42,
                                height: 42,
                              ),
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                isPlaying ? HookIcons.pause : HookIcons.play,
                                color: playBtnFg,
                                size: 22,
                              ),
                              onPressed: () {
                                HookHaptics.impact();
                                playerService.togglePlayPause();
                              },
                            ),
                    ),

                    const SizedBox(width: 2),

                    // Next track button
                    IconButton(
                      tooltip: strings.next,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(HookIcons.next, size: 22, color: textPrimary),
                      onPressed: widget.onNext ?? playerService.next,
                    ),

                    const SizedBox(width: 2),

                    // Collapse fullscreen lyrics button
                    IconButton(
                      key: const ValueKey('player-lyrics-bottom-collapse'),
                      tooltip: strings.exitFullscreenLyrics,
                      constraints: const BoxConstraints.tightFor(
                        width: 36,
                        height: 36,
                      ),
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        HookIcons.fullscreenExit,
                        size: 20,
                        color: textSecondary,
                      ),
                      onPressed: () {
                        HookHaptics.tap();
                        widget.onCollapse();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
