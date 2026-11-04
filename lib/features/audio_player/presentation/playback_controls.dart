import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../data/audio_player_service.dart';
import 'player_state_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class PlaybackControls extends ConsumerWidget {
  final HookTheme theme;

  const PlaybackControls({super.key, required this.theme});

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSpeedPitchSheet(BuildContext context, AudioPlayerService service) {
    final strings = AppLocalizations.of(context);
    double speed = 1.0;
    double pitch = 1.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(theme.styling.borderRadius + 4),
        ),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colors.textSecondary.withValues(
                          alpha: 0.35,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.speedAndPitch,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.speedValue(speed.toStringAsFixed(2)),
                        style: TextStyle(color: theme.colors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => speed = 1.0);
                          service.setSpeed(1.0);
                        },
                        child: Text(strings.reset),
                      ),
                    ],
                  ),
                  Slider(
                    value: speed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 15,
                    activeColor: theme.colors.primary,
                    inactiveColor: theme.colors.border,
                    onChanged: (val) {
                      setModalState(() => speed = val);
                      service.setSpeed(val);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        strings.pitchValue(pitch.toStringAsFixed(2)),
                        style: TextStyle(color: theme.colors.textSecondary),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() => pitch = 1.0);
                          service.setPitch(1.0);
                        },
                        child: Text(strings.reset),
                      ),
                    ],
                  ),
                  Slider(
                    value: pitch,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    activeColor: theme.colors.accent,
                    inactiveColor: theme.colors.border,
                    onChanged: (val) {
                      setModalState(() => pitch = val);
                      service.setPitch(val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playerService = ref.watch(audioPlayerServiceProvider);
    final isPlaying = ref.watch(isPlayingProvider);
    final isLoading = ref.watch(isTrackLoadingProvider);
    final strings = AppLocalizations.of(context);

    final ambient = AmbientThemeScope.of(context);
    final isLight = ambient?.isLight ?? false;
    final textPrimary = ambient?.textPrimary ?? theme.colors.textPrimary;
    final textSecondary = ambient?.textSecondary ?? theme.colors.textSecondary;
    final playBtnBg = isLight
        ? const Color(0xFF141419)
        : theme.colors.textPrimary;
    final playBtnFg = isLight ? Colors.white : theme.colors.background;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SeekBar(theme: theme, formatDuration: _formatDuration),

        const SizedBox(height: 12),

        // Main Control Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // More options
            PopupMenuButton<String>(
              tooltip: strings.moreActions,
              icon: Icon(
                MingCuteIcons.mgc_more_1_line,
                color: textSecondary,
                size: 24,
              ),
              onSelected: (value) {
                if (value == 'speed_pitch') {
                  _showSpeedPitchSheet(context, playerService);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'speed_pitch',
                  child: Text(strings.speedAndPitch),
                ),
              ],
            ),

            // Previous
            _ControlButton(
              icon: MingCuteIcons.mgc_skip_previous_fill,
              size: 36,
              color: textPrimary,
              onTap: playerService.previous,
            ),

            // Play / Pause — Grand central button
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: playBtnBg,
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(22),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: playBtnFg,
                      ),
                    )
                  : IconButton(
                      tooltip: isPlaying ? strings.pause : strings.play,
                      iconSize: 42,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isPlaying
                              ? MingCuteIcons.mgc_pause_fill
                              : MingCuteIcons.mgc_play_fill,
                          key: ValueKey(isPlaying),
                          color: playBtnFg,
                          size: 42,
                        ),
                      ),
                      onPressed: playerService.togglePlayPause,
                    ),
            ),

            // Next
            _ControlButton(
              icon: MingCuteIcons.mgc_skip_forward_fill,
              size: 36,
              color: textPrimary,
              onTap: playerService.next,
            ),

            // Loop Toggle
            StatefulBuilder(
              builder: (context, setLocalState) {
                final mode = playerService.loopMode;
                return _ControlButton(
                  icon: mode == PlayerLoopMode.one
                      ? MingCuteIcons.mgc_repeat_one_fill
                      : MingCuteIcons.mgc_repeat_line,
                  size: 24,
                  color: mode != PlayerLoopMode.off
                      ? theme.colors.accent
                      : textSecondary,
                  onTap: () => setLocalState(playerService.toggleLoopMode),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Reusable circular control button with splash
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.size,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: color, size: size),
        ),
      ),
    );
  }
}

/// Timeline slider. While dragging, the thumb follows the finger locally
/// and a single seek is sent on release.
class _SeekBar extends ConsumerStatefulWidget {
  final HookTheme theme;
  final String Function(Duration?) formatDuration;

  const _SeekBar({required this.theme, required this.formatDuration});

  @override
  ConsumerState<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends ConsumerState<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
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

    final ambient = AmbientThemeScope.of(context);
    final textSecondary = ambient?.textSecondary ?? theme.colors.textSecondary;
    final inactiveTrack = ambient?.isLight == true
        ? Colors.black.withValues(alpha: 0.16)
        : theme.colors.border.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            activeTrackColor: theme.colors.accent,
            inactiveTrackColor: inactiveTrack,
            thumbColor: theme.colors.accent,
            overlayColor: theme.colors.accent.withValues(alpha: 0.15),
          ),
          child: Slider(
            value: sliderVal,
            min: 0.0,
            max: totalMs > 0 ? totalMs : 1.0,
            onChanged: totalMs > 0
                ? (val) => setState(() => _dragValue = val)
                : null,
            onChangeEnd: (val) {
              ref
                  .read(audioPlayerServiceProvider)
                  .seek(Duration(milliseconds: val.toInt()));
              setState(() => _dragValue = null);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.formatDuration(shownPosition),
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                widget.formatDuration(duration),
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
