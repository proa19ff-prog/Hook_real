import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/theme_settings_screen.dart';
import '../../youtube_account/presentation/youtube_account_screen.dart';
import 'settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final autoHide = ref.watch(lyricsAutoHideProvider);

    return Theme(
      data: theme.toThemeData(),
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          title: Text(strings.settings),
          backgroundColor: colors.background,
          foregroundColor: colors.textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Text(
                    strings.settingsCaption,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _heading(strings.playerSettings, colors),
                  const SizedBox(height: 8),
                  Material(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile.adaptive(
                          key: const ValueKey('lyrics-auto-hide-setting'),
                          contentPadding: const EdgeInsets.fromLTRB(
                            16,
                            8,
                            16,
                            0,
                          ),
                          title: Text(
                            strings.lyricsAutoHide,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          activeTrackColor: colors.textPrimary,
                          value: autoHide,
                          onChanged: (value) => ref
                              .read(lyricsAutoHideProvider.notifier)
                              .setEnabled(value),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Text(
                            strings.lyricsAutoHideDescription,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _heading(strings.language, colors),
                  const SizedBox(height: 8),
                  Text(
                    strings.languageCaption,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (code, label) in [
                        ('system', strings.systemLanguage),
                        ('ru', strings.russian),
                        ('en', strings.english),
                      ])
                        ChoiceChip(
                          label: Text(label),
                          selected: code == 'system'
                              ? locale == null
                              : locale?.languageCode == code,
                          showCheckmark: false,
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          onSelected: (_) =>
                              ref.read(localeProvider.notifier).select(code),
                          selectedColor: colors.textPrimary,
                          backgroundColor: colors.surface,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                            color:
                                (code == 'system'
                                    ? locale == null
                                    : locale?.languageCode == code)
                                ? colors.background
                                : colors.textPrimary,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  ListTile(
                    key: const ValueKey('appearance-settings-link'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      MingCuteIcons.mgc_palette_line,
                      color: colors.textPrimary,
                    ),
                    title: Text(strings.themeSettings),
                    subtitle: Text(strings.themesSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ThemeSettingsScreen(theme: theme),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    key: const ValueKey('youtube-account-general-settings'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.account_circle_outlined,
                      color: colors.textPrimary,
                    ),
                    title: Text(strings.youtubeAccount),
                    subtitle: Text(strings.youtubeAccountSubtitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => YouTubeAccountScreen(theme: theme),
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

  Widget _heading(String title, HookColors colors) => Text(
    title,
    style: TextStyle(
      color: colors.textPrimary,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );
}
