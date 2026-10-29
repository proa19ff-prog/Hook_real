import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/audio_player_service.dart';
import 'player_state_provider.dart';

class PlaybackControls extends ConsumerWidget {
  final HookTheme theme;

  const PlaybackControls({
    super.key,
    required this.theme,
  });

  String _formatDuration(Duration? d) {
    if (d == null) return '0:00';
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSpeedPitchSheet(BuildContext context, AudioPlayerService service) {
    double speed = 1.0;
    double pitch = 1.0;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(theme.styling.borderRadius)),
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
                  Text(
                    'Скорость и тональность',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Скорость: ${speed.toStringAsFixed(2)}x',
                          style: TextStyle(color: theme.colors.textSecondary)),
                      TextButton(
                        onPressed: () {
                          setModalState(() => speed = 1.0);
                          service.setSpeed(1.0);
                        },
                        child: const Text('Сброс'),
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
                      Text('Высота тона (Pitch): ${pitch.toStringAsFixed(2)}x',
                          style: TextStyle(color: theme.colors.textSecondary)),
                      TextButton(
                        onPressed: () {
                          setModalState(() => pitch = 1.0);
                          service.setPitch(1.0);
                        },
                        child: const Text('Сброс'),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SeekBar(theme: theme, formatDuration: _formatDuration),

        const SizedBox(height: 8),

        // Main Control Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Secondary playback actions stay behind the overflow menu.
            PopupMenuButton<String>(
              tooltip: 'Дополнительные действия',
              icon: Icon(Icons.more_vert, color: theme.colors.textSecondary),
              onSelected: (value) {
                if (value == 'speed_pitch') {
                  _showSpeedPitchSheet(context, playerService);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'speed_pitch',
                  child: Text('Скорость и тональность'),
                ),
              ],
            ),

            // Previous
            IconButton(
              tooltip: 'Предыдущий',
              icon: Icon(Icons.skip_previous_rounded,
                  color: theme.colors.textPrimary, size: 38),
              onPressed: playerService.previous,
            ),

            // Play / Pause
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colors.textPrimary,
              ),
              child: isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(22),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: theme.colors.background,
                      ),
                    )
                  : IconButton(
                      tooltip: isPlaying ? 'Пауза' : 'Играть',
                      iconSize: 40,
                      icon: Icon(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: theme.colors.background,
                      ),
                      onPressed: playerService.togglePlayPause,
                    ),
            ),

            // Next
            IconButton(
              tooltip: 'Следующий',
              icon: Icon(Icons.skip_next_rounded,
                  color: theme.colors.textPrimary, size: 38),
              onPressed: playerService.next,
            ),

            // Loop Toggle. Loop mode lives in the service and has no stream,
            // so this button keeps its own rebuild trigger.
            StatefulBuilder(
              builder: (context, setLocalState) {
                final mode = playerService.loopMode;
                return IconButton(
                  tooltip: 'Повтор',
                  icon: Icon(
                    mode == PlayerLoopMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    color: mode != PlayerLoopMode.off
                        ? theme.colors.primary
                        : theme.colors.textSecondary,
                  ),
                  onPressed: () =>
                      setLocalState(playerService.toggleLoopMode),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

/// Timeline slider. Kept separate so position updates rebuild only the
/// slider and labels. While dragging, the thumb follows the finger locally
/// and a single seek is sent on release instead of one per pixel.
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
    final sliderVal = _dragValue ??
        (totalMs > 0
            ? position.inMilliseconds.toDouble().clamp(0.0, totalMs)
            : 0.0);
    final shownPosition = Duration(milliseconds: sliderVal.toInt());

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: theme.colors.textPrimary,
            inactiveTrackColor: theme.colors.border,
            thumbColor: theme.colors.textPrimary,
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
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.formatDuration(shownPosition),
                style: TextStyle(
                  color: theme.colors.textSecondary,
                  fontSize: 12,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                widget.formatDuration(duration),
                style: TextStyle(
                  color: theme.colors.textSecondary,
                  fontSize: 12,
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
