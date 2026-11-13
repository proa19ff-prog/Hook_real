import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../extractor/models/media_track.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../../search/presentation/artist_screen.dart';
import '../data/audio_player_service.dart' show PlayerLoopMode;
import 'fullscreen_player.dart';
import 'player_state_provider.dart';
import 'volume_control.dart';

/// The bottom player bar for a wide window: track on the left, transport and a
/// seek line in the middle, output controls on the right.
///
/// On a phone the same track lives in [MiniPlayer]; this version exists because
/// a 1400px-wide window showing a 360px-wide bar with three buttons wastes the
/// space and hides the volume entirely.
class DesktopPlayerBar extends ConsumerStatefulWidget {
  const DesktopPlayerBar({super.key, required this.theme});

  final HookTheme theme;

  @override
  ConsumerState<DesktopPlayerBar> createState() => _DesktopPlayerBarState();
}

class _DesktopPlayerBarState extends ConsumerState<DesktopPlayerBar> {
  double? _dragValue;

  HookTheme get theme => widget.theme;

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    if (track == null) return const SizedBox.shrink();
    final service = ref.watch(audioPlayerServiceProvider);
    // Shuffle and loop live on the service, not in a provider of their own;
    // the queue stream is the change signal they already emit.
    ref.watch(queueChangesProvider);
    final playing = ref.watch(isPlayingProvider);
    final loading = ref.watch(isTrackLoadingProvider);
    final position =
        ref.watch(positionStreamProvider).valueOrNull ?? Duration.zero;
    final duration =
        ref.watch(durationStreamProvider).valueOrNull ?? Duration.zero;
    final buffered =
        ref.watch(bufferedPositionStreamProvider).valueOrNull ?? Duration.zero;
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;

    final totalMs = duration.inMilliseconds.toDouble();
    final positionMs = position.inMilliseconds.toDouble().clamp(0.0, totalMs);
    final value = _dragValue ?? (totalMs > 0 ? positionMs : 0.0);
    final shown = Duration(milliseconds: value.round());

    return LayoutBuilder(
      builder: (context, constraints) {
        // The bar sits beside the rail, so a 900px window leaves it only ~667px.
        // At that width the fixed track block and the inline volume slider would
        // squeeze the transport into an overflow, so both give way first.
        final roomy = constraints.maxWidth >= 1000;
        return Container(
          decoration: BoxDecoration(
            color: colors.raised,
            border: Border(top: BorderSide(color: colors.border)),
          ),
          padding: const EdgeInsets.fromLTRB(
            HookSpace.lg,
            HookSpace.md,
            HookSpace.lg,
            HookSpace.md,
          ),
          child: Row(
            children: [
              // ---- Now playing -------------------------------------------
              _TrackBlock(
                theme: theme,
                track: track,
                loading: loading,
                width: roomy ? 260 : 176,
                onTap: () => _openPlayer(context),
              ),
              const SizedBox(width: HookSpace.lg),

              // ---- Transport ---------------------------------------------
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TransportIcon(
                          theme: theme,
                          tooltip: strings.shuffle,
                          icon: HookIcons.shuffle,
                          active: service.isShuffle,
                          onPressed: service.toggleShuffle,
                        ),
                        const SizedBox(width: HookSpace.sm),
                        _TransportIcon(
                          theme: theme,
                          tooltip: strings.previousTrack,
                          icon: HookIcons.previous,
                          size: 24,
                          onPressed: service.skipToPrevious,
                        ),
                        const SizedBox(width: HookSpace.xs),
                        _PlayButton(
                          theme: theme,
                          playing: playing,
                          loading: loading,
                          tooltip: playing ? strings.pause : strings.play,
                          onPressed: service.togglePlayPause,
                        ),
                        const SizedBox(width: HookSpace.xs),
                        _TransportIcon(
                          theme: theme,
                          tooltip: strings.next,
                          icon: HookIcons.next,
                          size: 24,
                          onPressed: service.next,
                        ),
                        const SizedBox(width: HookSpace.sm),
                        _TransportIcon(
                          theme: theme,
                          tooltip: strings.repeatPlayback,
                          icon: service.loopMode == PlayerLoopMode.one
                              ? HookIcons.repeatOne
                              : HookIcons.repeat,
                          active: service.loopMode != PlayerLoopMode.off,
                          onPressed: service.toggleLoopMode,
                        ),
                      ],
                    ),
                    const SizedBox(height: HookSpace.xs),
                    // A narrow bar keeps the seek line and drops the readable
                    // timecodes: scrubbing matters more than the clock.
                    Row(
                      children: [
                        if (roomy)
                          SizedBox(
                            width: 40,
                            child: Text(
                              _format(shown),
                              textAlign: TextAlign.right,
                              style: _timeStyle(colors),
                            ),
                          ),
                        if (roomy) const SizedBox(width: HookSpace.sm),
                        Expanded(
                          child: _SeekLine(
                            theme: theme,
                            value: value,
                            max: totalMs > 0 ? totalMs : 1.0,
                            buffered: buffered.inMilliseconds.toDouble(),
                            enabled: totalMs > 0,
                            onChanged: (next) =>
                                setState(() => _dragValue = next),
                            onChangeEnd: (next) {
                              service.seek(
                                Duration(milliseconds: next.round()),
                              );
                              setState(() => _dragValue = null);
                            },
                          ),
                        ),
                        if (roomy) const SizedBox(width: HookSpace.sm),
                        if (roomy)
                          SizedBox(
                            width: 40,
                            child: Text(
                              _format(duration),
                              style: _timeStyle(colors),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: HookSpace.lg),

              // ---- Output --------------------------------------------------
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VolumeCluster(theme: theme, sliderWidth: roomy ? 88 : 0),
                  _TransportIcon(
                    theme: theme,
                    tooltip: strings.volumeMixer,
                    icon: HookIcons.mixer,
                    onPressed: () => showVolumeMixer(context, theme: theme),
                  ),
                  _TransportIcon(
                    theme: theme,
                    tooltip: strings.karaokeLyrics,
                    icon: HookIcons.lyrics,
                    onPressed: () => _openPlayer(context, lyrics: true),
                  ),
                  _TransportIcon(
                    theme: theme,
                    tooltip: strings.openPlayer,
                    icon: HookIcons.expand,
                    onPressed: () => _openPlayer(context),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  TextStyle _timeStyle(HookColors colors) => TextStyle(
    color: colors.textSecondary,
    fontSize: HookType.caption,
    fontWeight: FontWeight.w500,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  String _format(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _openPlayer(BuildContext context, {bool lyrics = false}) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) =>
            FullscreenPlayer(theme: theme, initialLyrics: lyrics),
        transitionDuration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : HookMotion.base,
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: HookMotion.enter),
          child: child,
        ),
      ),
    );
  }
}

class _TrackBlock extends StatelessWidget {
  const _TrackBlock({
    required this.theme,
    required this.track,
    required this.loading,
    required this.width,
    required this.onTap,
  });

  final HookTheme theme;
  final MediaTrack track;
  final bool loading;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: HookRadius.smAll,
        child: Padding(
          padding: const EdgeInsets.all(HookSpace.xs),
          child: Row(
            children: [
              TrackArtwork(
                url: track.artworkUrl,
                artist: track.artist,
                title: track.title,
                duration: track.duration,
                size: 48,
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
                    const SizedBox(height: HookSpace.hair),
                    if (loading)
                      Text(
                        strings.loading,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: HookType.caption,
                        ),
                      )
                    else
                      InteractiveArtistText(
                        artist: track.artist,
                        rest: track.source.labelFor(strings),
                        theme: theme,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: HookType.caption,
                        ),
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

class _SeekLine extends StatelessWidget {
  const _SeekLine({
    required this.theme,
    required this.value,
    required this.max,
    required this.buffered,
    required this.enabled,
    required this.onChanged,
    required this.onChangeEnd,
  });

  final HookTheme theme;
  final double value;
  final double max;
  final double buffered;
  final bool enabled;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return SizedBox(
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Buffered range, so the line says how much is already downloaded.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: HookRadius.pillAll,
              child: SizedBox(
                height: 3,
                child: Stack(
                  children: [
                    Container(
                      color: colors.textPrimary.withValues(alpha: 0.12),
                    ),
                    FractionallySizedBox(
                      widthFactor: max > 0
                          ? (buffered / max).clamp(0.0, 1.0)
                          : 0.0,
                      child: Container(
                        color: colors.textPrimary.withValues(alpha: 0.26),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
              activeTrackColor: colors.textPrimary,
              inactiveTrackColor: Colors.transparent,
              thumbColor: colors.textPrimary,
              overlayColor: colors.textPrimary.withValues(alpha: 0.12),
            ),
            child: Slider(
              value: value.clamp(0.0, max),
              max: max,
              onChanged: enabled ? onChanged : null,
              onChangeEnd: enabled ? onChangeEnd : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransportIcon extends StatelessWidget {
  const _TransportIcon({
    required this.theme,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.size = 20,
    this.active = false,
  });

  final HookTheme theme;
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: size,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
      color: active ? colors.primary : colors.textSecondary,
      style: IconButton.styleFrom(
        minimumSize: const Size(36, 36),
        padding: const EdgeInsets.all(HookSpace.sm),
      ),
    );
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.theme,
    required this.playing,
    required this.loading,
    required this.tooltip,
    required this.onPressed,
  });

  final HookTheme theme;
  final bool playing;
  final bool loading;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return SizedBox(
      width: 44,
      height: 44,
      child: loading
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.accent,
              ),
            )
          : IconButton(
              tooltip: tooltip,
              onPressed: () {
                HookHaptics.impact();
                onPressed();
              },
              iconSize: 28,
              icon: Icon(playing ? HookIcons.pause : HookIcons.play),
              color: colors.textPrimary,
              style: IconButton.styleFrom(
                minimumSize: const Size(44, 44),
                padding: EdgeInsets.zero,
              ),
            ),
    );
  }
}
