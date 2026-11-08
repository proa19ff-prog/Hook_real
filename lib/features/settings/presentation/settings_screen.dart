import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:window_manager/window_manager.dart';
import 'updates_section.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/supported_languages.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/sources/remote_resolver_source.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/theme_settings_screen.dart';
import '../../youtube_account/presentation/youtube_account_screen.dart';
import 'account_section.dart';
import '../../library/presentation/library_provider.dart';
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
                        ...supportedLanguages,
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
                  const SizedBox(height: 12),
                  ListTile(
                    key: const ValueKey('remote-resolver-setting'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.dns_outlined,
                      color: colors.textPrimary,
                    ),
                    title: Text(strings.serverResolver),
                    subtitle: Text(_resolverSubtitle(ref, strings),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _editRemoteResolver(context, ref, colors),
                  ),
                  if (!kIsWeb &&
                      defaultTargetPlatform == TargetPlatform.windows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12),
                        child: SwitchListTile.adaptive(
                          secondary: Icon(
                            Icons.picture_in_picture_alt_rounded,
                            color: colors.textPrimary,
                          ),
                          title: Text(
                            strings.alwaysOnTop,
                            style: TextStyle(color: colors.textPrimary),
                          ),
                          value: ref
                              .watch(localStorageServiceProvider)
                              .getWindowOnTop(),
                          onChanged: (value) async {
                            await ref
                                .read(localStorageServiceProvider)
                                .saveWindowOnTop(value);
                            await windowManager.setAlwaysOnTop(value);
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  const AccountSection(),
                  const SizedBox(height: 12),
                  const UpdatesSection(),
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

  String _resolverSubtitle(
    WidgetRef ref,
    AppLocalizations strings,
  ) {
    final stored = ref.watch(remoteResolverProvider);
    if (stored == null) return RemoteResolverSource.defaultEndpoint;
    if (stored.trim().isEmpty) return strings.serverResolverDisabled;
    return stored;
  }

  void _editRemoteResolver(
    BuildContext context,
    WidgetRef ref,
    HookColors colors,
  ) {
    final strings = AppLocalizations.of(context);
    final stored = ref.read(remoteResolverProvider);
    final controller = TextEditingController(
      text: stored ?? RemoteResolverSource.defaultEndpoint,
    );
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(strings.serverResolver),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.serverResolverCaption,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const ValueKey('remote-resolver-input'),
                controller: controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: strings.serverResolverHint,
                  hintStyle: TextStyle(color: colors.textSecondary),
                  isDense: true,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Empty string, not null: null means "never configured",
                // which keeps the built-in default endpoint active.
                ref.read(remoteResolverProvider.notifier).setEndpoint('');
                Navigator.of(dialogContext).pop();
              },
              child: Text(strings.serverDisable),
            ),
            TextButton(
              key: const ValueKey('remote-resolver-save'),
              onPressed: () {
                ref
                    .read(remoteResolverProvider.notifier)
                    .setEndpoint(controller.text.trim());
                Navigator.of(dialogContext).pop();
              },
              child: Text(strings.serverSave),
            ),
          ],
        );
      },
    );
  }
}
