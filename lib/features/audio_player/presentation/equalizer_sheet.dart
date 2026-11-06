import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/equalizer_controller.dart';

Future<void> showEqualizerSheet(
  BuildContext context, {
  required HookTheme theme,
  required EqualizerController controller,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  backgroundColor: theme.colors.surface,
  constraints: const BoxConstraints(maxWidth: 640),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(theme.styling.borderRadius + 4),
    ),
  ),
  builder: (context) => EqualizerSheet(theme: theme, controller: controller),
);

/// A compact mixer, in Hook's existing type and surface colours. Real hardware
/// bands keep their own readable touch lanes instead of shrinking on phones.
class EqualizerSheet extends StatelessWidget {
  final HookTheme theme;
  final EqualizerController controller;
  const EqualizerSheet({
    super.key,
    required this.theme,
    required this.controller,
  });

  static String presetLabel(AppLocalizations strings, EqualizerPreset preset) =>
      switch (preset) {
        EqualizerPreset.flat => strings.equalizerFlat,
        EqualizerPreset.bass => strings.equalizerBass,
        EqualizerPreset.vocal => strings.equalizerVocal,
        EqualizerPreset.rock => strings.equalizerRock,
        EqualizerPreset.electronic => strings.equalizerElectronic,
        EqualizerPreset.soft => strings.equalizerSoft,
        EqualizerPreset.custom => strings.equalizerCustom,
      };

  static String frequencyLabel(double hz) => hz >= 1000
      ? '${(hz / 1000).toStringAsFixed(hz % 1000 == 0 ? 0 : 1)} kHz'
      : '${hz.round()} Hz';
  static String decibels(double db) =>
      '${db > 0 ? '+' : ''}${db.toStringAsFixed(1)} dB';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final settings = controller.settings;
        final hardware = controller.hardware;
        final ready = controller.status == EqualizerStatus.ready;
        final active = ready && settings.enabled;
        final gains = controller.bandGains;
        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.86,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                    surface: colors.surface,
                    onSurface: colors.textPrimary,
                    primary: colors.accent,
                    onSurfaceVariant: colors.textSecondary,
                  ),
                ),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.equalizer,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .closeButtonTooltip,
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.equalizerLive,
                        style: TextStyle(
                          color: colors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.equalizerEnabled),
                        value: settings.enabled && ready,
                        onChanged: ready ? controller.setEnabled : null,
                      ),
                      if (!ready) ...[
                        const SizedBox(height: 12),
                        Text(
                          switch (controller.status) {
                            EqualizerStatus.unsupported =>
                              strings.equalizerUnsupported,
                            EqualizerStatus.failed => strings.equalizerFailed,
                            _ => strings.equalizerWaiting,
                          },
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        if (controller.status == EqualizerStatus.failed)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: controller.retry,
                              child: Text(strings.equalizerRetry),
                            ),
                          ),
                      ] else ...[
                        const SizedBox(height: 16),
                        Text(
                          strings.equalizerPresets,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<EqualizerPreset>(
                          key: ValueKey(settings.preset),
                          initialValue: settings.preset,
                          isExpanded: true,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: colors.background,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: EqualizerPreset.values
                              .map(
                                (preset) => DropdownMenuItem(
                                  value: preset,
                                  child: Text(presetLabel(strings, preset)),
                                ),
                              )
                              .toList(),
                          onChanged: active
                              ? (value) {
                                  if (value != null) {
                                    controller.setPreset(value);
                                  }
                                }
                              : null,
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                strings.equalizerBands,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: active ? controller.reset : null,
                              child: Text(strings.reset),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // 5 × 56 = 280 px; extra bands scroll in their own mixer.
                            final count = hardware!.bands.length;
                            final textScale =
                                (MediaQuery.textScalerOf(context).scale(12) /
                                        12)
                                    .clamp(1.0, 3.0);
                            final laneWidth = (constraints.maxWidth / count)
                                .clamp(56.0 * textScale, 88.0 * textScale);
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var index = 0; index < count; index++)
                                    SizedBox(
                                      width: laneWidth,
                                      child: Column(
                                        children: [
                                          Text(
                                            decibels(gains[index]),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colors.textSecondary,
                                              fontFeatures: const [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 184,
                                            child: RotatedBox(
                                              quarterTurns: 3,
                                              child: Slider(
                                                value: gains[index],
                                                min: hardware.minDb,
                                                max: hardware.maxDb,
                                                divisions:
                                                    ((hardware.maxDb -
                                                                hardware
                                                                    .minDb) *
                                                            2)
                                                        .round()
                                                        .clamp(1, 120),
                                                label: decibels(gains[index]),
                                                semanticFormatterCallback: (
                                                  value,
                                                ) => '${frequencyLabel(hardware.bands[index].frequency)}, ${decibels(value)}',
                                                onChanged: active
                                                    ? (value) => controller
                                                          .setBand(index, value)
                                                    : null,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            frequencyLabel(
                                              hardware.bands[index].frequency,
                                            ),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        _ValueSlider(
                          label: strings.equalizerBassBoost,
                          formattedValue: '${(settings.bass * 100).round()}%',
                          value: settings.bass,
                          min: 0,
                          max: 1,
                          divisions: 20,
                          onChanged: active && hardware!.bassSupported
                              ? controller.setBass
                              : null,
                        ),
                        if (!hardware!.bassSupported)
                          Text(
                            strings.equalizerBassUnsupported,
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        const SizedBox(height: 16),
                        _ValueSlider(
                          label: strings.equalizerPreamp,
                          formattedValue: decibels(settings.preampDb),
                          value: settings.preampDb,
                          min: -12,
                          max: 0,
                          divisions: 24,
                          onChanged: active ? controller.setPreamp : null,
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(strings.equalizerHeadroom),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              strings.equalizerHeadroomDescription,
                              style: TextStyle(
                                color: colors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                          value: settings.autoHeadroom,
                          onChanged: active ? controller.setAutoHeadroom : null,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ValueSlider extends StatelessWidget {
  final String label;
  final String formattedValue;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double>? onChanged;
  const _ValueSlider({
    required this.label,
    required this.formattedValue,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formattedValue,
            style: const TextStyle(
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: formattedValue,
        semanticFormatterCallback: (value) =>
            '$label: ${max == 1 ? '${(value * 100).round()}%' : EqualizerSheet.decibels(value)}',
        onChanged: onChanged,
      ),
    ],
  );
}
