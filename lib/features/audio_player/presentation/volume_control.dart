import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/system_volume.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme_engine/domain/hook_theme.dart';
import 'equalizer_sheet.dart';
import 'player_state_provider.dart';

/// Material's `Icons.volume_*` only has three coarse states; Hook wanted the
/// icon to actually reflect the level, like the Windows taskbar does.
IconData _volumeIcon(double level, bool muted) {
  if (muted || level <= 0.001) return HookIcons.volumeOff;
  if (level < 0.34) return HookIcons.volumeMute;
  return HookIcons.volume;
}

/// Opens the mixer. A dialog on a desktop window, a sheet on a phone — the same
/// content, in the container the platform expects.
Future<void> showVolumeMixer(BuildContext context, {required HookTheme theme}) {
  if (HookBreakpoints.isDesktop(context)) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => Dialog(
        backgroundColor: theme.colors.raised,
        insetPadding: const EdgeInsets.all(40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HookRadius.lg),
          side: BorderSide(color: theme.colors.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: VolumeMixerPanel(theme: theme),
        ),
      ),
    );
  }
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => VolumeMixerPanel(theme: theme, asSheet: true),
  );
}

/// System volume and Hook's own level side by side, because on Windows the two
/// are different things: one moves every app, the other only this one.
class VolumeMixerPanel extends ConsumerWidget {
  const VolumeMixerPanel({
    super.key,
    required this.theme,
    this.asSheet = false,
  });

  final HookTheme theme;
  final bool asSheet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    final system = ref.watch(systemVolumeProvider);
    final player = ref.watch(audioPlayerServiceProvider);

    final body = ListenableBuilder(
      listenable: player.equalizer,
      builder: (context, _) {
        final appVolume = player.equalizer.volume;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!asSheet) _DialogHeader(theme: theme),
            if (asSheet) const SizedBox(height: HookSpace.sm),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HookSpace.xxl,
                0,
                HookSpace.xxl,
                HookSpace.sm,
              ),
              child: Text(
                strings.volumeMixer,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: HookType.title,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            if (system.supported)
              _VolumeRow(
                theme: theme,
                icon: _volumeIcon(system.volume, system.muted),
                title: strings.systemVolume,
                caption: strings.systemVolumeCaption,
                value: system.muted ? 0 : system.volume,
                display: system.muted
                    ? strings.mute
                    : '${(system.volume * 100).round()}%',
                onChanged: ref.read(systemVolumeProvider.notifier).setVolume,
                onMute: ref.read(systemVolumeProvider.notifier).toggleMute,
                muted: system.muted,
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  HookSpace.xxl,
                  HookSpace.sm,
                  HookSpace.xxl,
                  HookSpace.md,
                ),
                child: Row(
                  children: [
                    Icon(
                      HookIcons.volumeOff,
                      size: 18,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(width: HookSpace.md),
                    Expanded(
                      child: Text(
                        strings.volumeUnavailable,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: HookType.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _VolumeRow(
              theme: theme,
              icon: HookIcons.music,
              title: strings.appVolume,
              caption: strings.appVolumeCaption,
              value: appVolume,
              display: '${(appVolume * 100).round()}%',
              onChanged: (value) => player.setVolume(value),
              trailing: TextButton.icon(
                onPressed: () => showEqualizerSheet(
                  context,
                  theme: theme,
                  controller: player.equalizer,
                ),
                icon: const Icon(HookIcons.mixer, size: 18),
                label: Text(strings.equalizer),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HookSpace.xxl,
                HookSpace.md,
                HookSpace.xxl,
                HookSpace.xxl,
              ),
              child: Row(
                children: [
                  Icon(
                    HookIcons.keyboard,
                    size: 15,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(width: HookSpace.sm),
                  Expanded(
                    child: Text(
                      strings.volumeKeysHint,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: HookType.caption,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  if (asSheet)
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(strings.close),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );

    if (!asSheet) return body;
    return Container(
      decoration: BoxDecoration(
        color: colors.raised,
        borderRadius: HookRadius.sheet(theme.styling.borderRadius),
        border: Border.all(color: colors.border),
      ),
      child: SafeArea(top: false, child: body),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.theme});

  final HookTheme theme;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      HookSpace.md,
      HookSpace.md,
      HookSpace.md,
      0,
    ),
    child: Row(
      children: [
        const Spacer(),
        IconButton(
          tooltip: AppLocalizations.of(context).close,
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(HookIcons.close, size: 20),
        ),
      ],
    ),
  );
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({
    required this.theme,
    required this.icon,
    required this.title,
    required this.caption,
    required this.value,
    required this.display,
    required this.onChanged,
    this.onMute,
    this.muted = false,
    this.trailing,
  });

  final HookTheme theme;
  final IconData icon;
  final String title;
  final String caption;
  final double value;
  final String display;
  final ValueChanged<double> onChanged;
  final VoidCallback? onMute;
  final bool muted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        HookSpace.xxl,
        0,
        HookSpace.xxl,
        HookSpace.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 24,
                child: Icon(icon, size: 19, color: colors.textPrimary),
              ),
              const SizedBox(width: HookSpace.sm),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: HookType.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else
                Text(
                  display,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: HookType.label,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              if (onMute != null)
                IconButton(
                  tooltip: muted ? strings.unmute : strings.mute,
                  onPressed: onMute,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    muted ? HookIcons.volumeOff : HookIcons.volume,
                    size: 19,
                  ),
                  color: muted ? colors.textSecondary : colors.textPrimary,
                ),
            ],
          ),
          const SizedBox(height: HookSpace.hair),
          Text(
            caption,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: HookType.caption,
              height: 1.35,
            ),
          ),
          const SizedBox(height: HookSpace.xs),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Semantics(
              label: title,
              value: display,
              child: Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged),
            ),
          ),
        ],
      ),
    );
  }
}

/// Speaker button for a player bar. Click mutes, right-click (or long-press)
/// opens the full mixer so both volumes stay one gesture away.
class VolumeIconButton extends ConsumerWidget {
  const VolumeIconButton({super.key, required this.theme, this.size = 20});

  final HookTheme theme;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final system = ref.watch(systemVolumeProvider);
    final strings = AppLocalizations.of(context);
    final level = system.supported ? system.volume : 1.0;
    final muted = system.supported && system.muted;

    return GestureDetector(
      onSecondaryTapDown: (_) => showVolumeMixer(context, theme: theme),
      onLongPress: () => showVolumeMixer(context, theme: theme),
      child: IconButton(
        // Without an OS endpoint the button cannot mute anything, so it opens
        // the mixer instead of promising an action it cannot perform.
        tooltip: !system.supported
            ? strings.volumeMixer
            : muted
            ? strings.unmute
            : strings.mute,
        iconSize: size,
        visualDensity: VisualDensity.compact,
        onPressed: system.supported
            ? () {
                HookHaptics.tap();
                ref.read(systemVolumeProvider.notifier).toggleMute();
              }
            : () => showVolumeMixer(context, theme: theme),
        icon: Icon(_volumeIcon(level, muted)),
      ),
    );
  }
}

/// Mute button + slider + readout, sized for a player bar. The readout is a
/// button so the exact number can be typed/clicked into the mixer.
class VolumeCluster extends ConsumerWidget {
  const VolumeCluster({super.key, required this.theme, this.sliderWidth = 84});

  final HookTheme theme;
  final double sliderWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final system = ref.watch(systemVolumeProvider);
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    final level = system.muted ? 0.0 : system.volume;

    // No endpoint (tests, Linux, web): a permanently dead slider at 100% would
    // be a lie, so the bar keeps only the button that opens the mixer.
    if (!system.supported) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [VolumeIconButton(theme: theme, size: 19)],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        VolumeIconButton(theme: theme, size: 19),
        // A narrow bar keeps the button and the mixer dialog; a slider squeezed
        // into a few pixels is worse than no slider at all.
        if (sliderWidth > 0)
          SizedBox(
            width: sliderWidth,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: colors.textPrimary,
                inactiveTrackColor: colors.textPrimary.withValues(alpha: 0.16),
                thumbColor: colors.textPrimary,
                overlayColor: colors.textPrimary.withValues(alpha: 0.12),
              ),
              child: Semantics(
                label: strings.volume,
                value: '${(system.volume * 100).round()}%',
                child: Slider(
                  value: level.clamp(0.0, 1.0),
                  onChangeEnd: (_) => HookHaptics.tap(),
                  onChanged: ref.read(systemVolumeProvider.notifier).setVolume,
                ),
              ),
            ),
          ),
        if (sliderWidth > 0) ...[
          SizedBox(
            width: 34,
            child: Text(
              '${(level * 100).round()}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: HookType.caption,
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: HookSpace.xs),
        ],
      ],
    );
  }
}

/// Human-readable percentage for an arbitrary 0..1 level.
String volumePercent(double value) => '${(value.clamp(0, 1) * 100).round()}%';
