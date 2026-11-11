import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/supported_languages.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../youtube_account/presentation/youtube_account_screen.dart';
import '../domain/hook_theme.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  final HookTheme theme;

  const ThemeSettingsScreen({super.key, required this.theme});

  @override
  ConsumerState<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  final _jsonInputController = TextEditingController();

  @override
  void dispose() {
    _jsonInputController.dispose();
    super.dispose();
  }

  void _showImportJsonDialog() {
    final theme = ref.read(themeProvider);
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    String? error;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.surface,
          scrollable: true,
          title: Text(strings.importThemeTitle),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.pasteThemeJson,
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _jsonInputController,
                  minLines: 4,
                  maxLines: 8,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: HookType.bodySmall,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    labelText: 'JSON',
                    errorText: error,
                    errorMaxLines: 4,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                final input = _jsonInputController.text.trim();
                try {
                  final data = jsonDecode(input);
                  if (data is! Map<String, dynamic>) {
                    throw const FormatException();
                  }
                  HookTheme.fromJson(data);
                  ref.read(themeProvider.notifier).importJson(input);
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(
                    this.context,
                  ).showSnackBar(SnackBar(content: Text(strings.themeApplied)));
                } catch (_) {
                  setDialogState(() => error = strings.invalidThemeJson);
                }
              },
              child: Text(strings.apply),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportJsonDialog(HookTheme theme) {
    final json = const JsonEncoder.withIndent('  ').convert(theme.toJson());
    final strings = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colors.surface,
        scrollable: true,
        title: Text(strings.exportThemeTitle),
        content: SizedBox(
          width: 420,
          child: SelectableText(
            json,
            style: const TextStyle(fontSize: HookType.bodySmall, fontFamily: 'monospace'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(strings.close),
          ),
          FilledButton.icon(
            icon: const Icon(HookIcons.copy, size: 20),
            label: Text(strings.copyJson),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: json));
              if (!mounted || !dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(strings.jsonCopied)));
            },
          ),
        ],
      ),
    );
  }

  void _updateStyling(HookTheme theme, HookStyling styling) {
    ref
        .read(themeProvider.notifier)
        .importJson(jsonEncode(theme.copyWith(styling: styling).toJson()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Theme(
      data: theme.toThemeData(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          foregroundColor: colors.textPrimary,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              tooltip: strings.exportJson,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(HookIcons.importFile),
              onPressed: () => _showExportJsonDialog(theme),
            ),
            IconButton(
              tooltip: strings.importJson,
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              icon: const Icon(HookIcons.downloadFile),
              onPressed: _showImportJsonDialog,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: HookBreakpoints.readingMax,
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  HookSpace.xl,
                  HookSpace.sm,
                  HookSpace.xl,
                  HookSpace.xxxl,
                ),
                children: [
                  Text(
                    strings.themesAndShaders,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: HookType.display,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: HookSpace.sm),
                  Text(
                    strings.themesSubtitle,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: HookType.body,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ListTile(
                    key: const ValueKey('youtube-account-settings'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      HookIcons.accountCircle,
                      color: colors.textPrimary,
                    ),
                    title: Text(strings.youtubeAccount),
                    subtitle: Text(strings.youtubeAccountSubtitle),
                    trailing: const Icon(HookIcons.chevron),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => YouTubeAccountScreen(theme: theme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle(strings.language, colors),
                  const SizedBox(height: 8),
                  Text(
                    strings.languageCaption,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: HookType.bodySmall,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _languageChip(
                        'system',
                        strings.systemLanguage,
                        locale == null,
                        colors,
                      ),
                      for (final (code, name) in supportedLanguages)
                        _languageChip(
                          code,
                          name,
                          locale?.languageCode == code,
                          colors,
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _sectionTitle(strings.readyThemes, colors),
                  const SizedBox(height: 12),
                  for (final preset in themeNotifier.availableThemes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: colors.surface,
                        borderRadius: HookRadius.smAll,
                        child: InkWell(
                          borderRadius: HookRadius.smAll,
                          onTap: () {
                            HookHaptics.tap();
                            themeNotifier.setTheme(preset.id);
                          },
                          child: Semantics(
                            selected: preset.id == theme.id,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: ClipRRect(
                                      borderRadius: HookRadius.xsAll,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ColoredBox(
                                              color: preset.colors.background,
                                              child: const SizedBox.expand(),
                                            ),
                                          ),
                                          Expanded(
                                            child: ColoredBox(
                                              color: preset.colors.primary,
                                              child: const SizedBox.expand(),
                                            ),
                                          ),
                                          Expanded(
                                            child: ColoredBox(
                                              color: preset.colors.accent,
                                              child: const SizedBox.expand(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          preset.name,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: HookType.body,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          preset.author,
                                          style: TextStyle(
                                            color: colors.textSecondary,
                                            fontSize: HookType.label,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  if (preset.id == theme.id)
                                    Icon(
                                      HookIcons.check,
                                      color: colors.textPrimary,
                                      size: 22,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  _sectionTitle(strings.gpuShaders, colors),
                  const SizedBox(height: 12),
                  Material(
                    color: colors.surface,
                    borderRadius: HookRadius.smAll,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SwitchListTile.adaptive(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              strings.meshGradient,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: HookType.body,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            value: theme.styling.shaderMeshEnabled,
                            onChanged: (value) => _updateStyling(
                              theme,
                              theme.styling.copyWith(shaderMeshEnabled: value),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _settingSlider(
                            label: strings.vinylNoise,
                            valueLabel:
                                '${(theme.styling.shaderNoiseIntensity * 100).round()}%',
                            value: theme.styling.shaderNoiseIntensity.clamp(
                              0,
                              0.15,
                            ),
                            max: 0.15,
                            colors: colors,
                            onChanged: (value) => _updateStyling(
                              theme,
                              theme.styling.copyWith(
                                shaderNoiseIntensity: value,
                              ),
                            ),
                          ),
                          _settingSlider(
                            label: strings.glassBlur,
                            valueLabel: '${theme.styling.cardBlur.round()} px',
                            value: theme.styling.cardBlur.clamp(0, 50),
                            max: 50,
                            colors: colors,
                            onChanged: (value) => _updateStyling(
                              theme,
                              theme.styling.copyWith(cardBlur: value),
                            ),
                          ),
                          _settingSlider(
                            label: strings.cornerRadius,
                            valueLabel:
                                '${theme.styling.borderRadius.round()} px',
                            value: theme.styling.borderRadius.clamp(0, 32),
                            max: 32,
                            colors: colors,
                            onChanged: (value) => _updateStyling(
                              theme,
                              theme.styling.copyWith(borderRadius: value),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String label, HookColors colors) => Text(
    label,
    style: TextStyle(
      color: colors.textPrimary,
      fontSize: HookType.heading,
      fontWeight: FontWeight.w600,
    ),
  );

  Widget _settingSlider({
    required String label,
    required String valueLabel,
    required double value,
    required double max,
    required HookColors colors,
    required ValueChanged<double> onChanged,
  }) => Column(
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: colors.textPrimary, fontSize: HookType.body),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            valueLabel,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: HookType.bodySmall,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
      Slider(
        label: valueLabel,
        semanticFormatterCallback: (_) => valueLabel,
        value: value,
        max: max,
        activeColor: colors.textPrimary,
        inactiveColor: colors.border,
        onChanged: onChanged,
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _languageChip(
    String code,
    String label,
    bool selected,
    HookColors colors,
  ) => ChoiceChip(
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    materialTapTargetSize: MaterialTapTargetSize.padded,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    onSelected: (_) => ref.read(localeProvider.notifier).select(code),
    selectedColor: colors.textPrimary,
    backgroundColor: colors.surface,
    side: BorderSide.none,
    labelStyle: TextStyle(
      color: selected ? colors.background : colors.textPrimary,
      fontSize: HookType.body,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
    ),
  );
}
