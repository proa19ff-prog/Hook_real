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
    final playerStateAsync = ref.watch(playerStateStreamProvider);
    final positionAsync = ref.watch(positionStreamProvider);
    final durationAsync = ref.watch(durationStreamProvider);

    final isPlaying = playerStateAsync.value?.playing ?? false;
    final position = positionAsync.value ?? Duration.zero;
    final duration = durationAsync.value ?? Duration.zero;

    final posMs = position.inMilliseconds.toDouble();
    final totalMs = duration.inMilliseconds.toDouble();
    final sliderVal = totalMs > 0 ? posMs.clamp(0.0, totalMs) : 0.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Timeline Slider
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: theme.colors.primary,
            inactiveTrackColor: theme.colors.border,
            thumbColor: theme.colors.textPrimary,
          ),
          child: Slider(
            value: sliderVal,
            min: 0.0,
            max: totalMs > 0 ? totalMs : 1.0,
            onChanged: (val) {
              playerService.seek(Duration(milliseconds: val.toInt()));
            },
          ),
        ),

        // Position & Duration labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: TextStyle(
                  color: theme.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                _formatDuration(duration),
                style: TextStyle(
                  color: theme.colors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),

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
              icon: Icon(Icons.skip_previous_rounded,
                  color: theme.colors.textPrimary, size: 36),
              onPressed: () => playerService.previous(),
            ),

            // Play / Pause FAB
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.colors.primary, theme.colors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                iconSize: 42,
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (isPlaying) {
                    playerService.pause();
                  } else {
                    playerService.play();
                  }
                },
              ),
            ),

            // Next
            IconButton(
              icon: Icon(Icons.skip_next_rounded,
                  color: theme.colors.textPrimary, size: 36),
              onPressed: () => playerService.next(),
            ),

            // Loop Toggle
            IconButton(
              icon: Icon(
                playerService.loopMode == PlayerLoopMode.one
                    ? Icons.repeat_one_rounded
                    : (playerService.loopMode == PlayerLoopMode.all
                        ? Icons.repeat_rounded
                        : Icons.repeat_rounded),
                color: playerService.loopMode != PlayerLoopMode.off
                    ? theme.colors.primary
                    : theme.colors.textSecondary,
              ),
              onPressed: () {
                playerService.toggleLoopMode();
              },
            ),
          ],
        ),
      ],
    );
  }
}
