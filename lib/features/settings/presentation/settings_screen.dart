import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../core/ui/hook_tokens.dart';
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
import '../../../core/ui/hook_icons.dart';

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
                    strings.settingsCaption,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: HookType.body,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: HookSpace.xxl),
                  _heading(strings.playerSettings, colors),
                  const SizedBox(height: HookSpace.sm),
                  Material(
                    color: colors.surface,
                    borderRadius: HookRadius.smAll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile.adaptive(
                          key: const ValueKey('lyrics-auto-hide-setting'),
                          contentPadding: const EdgeInsets.fromLTRB(
                            HookSpace.lg,
                            HookSpace.sm,
                            HookSpace.lg,
                            0,
                          ),
                          title: Text(
                            strings.lyricsAutoHide,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: HookType.heading,
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
                          padding: const EdgeInsets.fromLTRB(
                            HookSpace.lg,
                            HookSpace.sm,
                            HookSpace.lg,
                            HookSpace.lg,
                          ),
                          child: Text(
                            strings.lyricsAutoHideDescription,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: HookType.body,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: HookSpace.xxl),
                  _heading(strings.language, colors),
                  const SizedBox(height: HookSpace.sm),
                  Text(
                    strings.languageCaption,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: HookType.body,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: HookSpace.md),
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
                            fontSize: HookType.body,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: HookSpace.xxl),
                  ListTile(
                    key: const ValueKey('appearance-settings-link'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(HookIcons.palette, color: colors.textPrimary),
                    title: Text(strings.themeSettings),
                    subtitle: Text(strings.themesSubtitle),
                    trailing: const Icon(HookIcons.chevron),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ThemeSettingsScreen(theme: theme),
                      ),
                    ),
                  ),
                  const SizedBox(height: HookSpace.md),
                  ListTile(
                    key: const ValueKey('youtube-account-general-settings'),
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
                  const SizedBox(height: HookSpace.md),
                  ListTile(
                    key: const ValueKey('remote-resolver-setting'),
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(HookIcons.server, color: colors.textPrimary),
                    title: Text(strings.serverResolver),
                    subtitle: Text(
                      _resolverSubtitle(ref, strings),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(HookIcons.chevron),
                    onTap: () => _editRemoteResolver(context, ref, colors),
                  ),
                  if (!kIsWeb &&
                      defaultTargetPlatform == TargetPlatform.windows)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: colors.surface,
                        borderRadius: HookRadius.smAll,
                        child: SwitchListTile.adaptive(
                          secondary: Icon(
                            HookIcons.pip,
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
                  const SizedBox(height: HookSpace.xxl),
                  _heading(strings.keyboardShortcuts, colors),
                  const SizedBox(height: HookSpace.sm),
                  Text(
                    strings.shortcutsCaption,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: HookType.bodySmall,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: HookSpace.md),
                  _ShortcutList(theme: theme),
                  const SizedBox(height: HookSpace.xxl),
                  const AccountSection(),
                  const SizedBox(height: HookSpace.md),
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
      fontSize: HookType.heading,
      fontWeight: FontWeight.w600,
    ),
  );

  String _resolverSubtitle(WidgetRef ref, AppLocalizations strings) {
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
                  fontSize: HookType.bodySmall,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: HookSpace.md),
              TextField(
                key: const ValueKey('remote-resolver-input'),
                controller: controller,
                keyboardType: TextInputType.url,
                autocorrect: false,
                enableSuggestions: false,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: HookType.body,
                ),
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

/// Reference sheet for the global shortcuts bound in `app.dart`.
///
/// The bindings live above the navigator, so a user cannot discover them from
/// the UI alone; this list is the only place they are documented in the app.
class _ShortcutList extends StatelessWidget {
  const _ShortcutList({required this.theme});

  final HookTheme theme;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final rows = <(String, String)>[
      ('Space', strings.playPauseShortcut),
      ('←  →', strings.shortcutsSeek),
      ('Ctrl + ←  →', '${strings.previousTrack} / ${strings.next}'),
      ('Ctrl + ↑  ↓', strings.volume),
      ('M', strings.mute),
    ];

    // A key cap is as wide as the shortcut printed on it, so at accessibility
    // text sizes the row runs out of room for the label. Above ~1.3x the keys
    // move onto their own line instead of squeezing the description to nothing.
    final stacked =
        MediaQuery.textScalerOf(context).scale(HookType.label) >
        HookType.label * 1.3;

    return Material(
      color: colors.surface,
      borderRadius: HookRadius.smAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: HookSpace.lg,
          vertical: HookSpace.sm,
        ),
        child: Column(
          children: [
            for (final (keys, label) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: HookSpace.sm),
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _KeyCaps(theme: theme, text: keys),
                          const SizedBox(height: HookSpace.xs),
                          Text(
                            label,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: HookType.bodySmall,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          _KeyCaps(theme: theme, text: keys),
                          const SizedBox(width: HookSpace.md),
                          Expanded(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: HookType.bodySmall,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _KeyCaps extends StatelessWidget {
  const _KeyCaps({required this.theme, required this.text});

  final HookTheme theme;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 92),
      padding: const EdgeInsets.symmetric(
        horizontal: HookSpace.sm,
        vertical: HookSpace.xs,
      ),
      decoration: BoxDecoration(
        color: colors.raised,
        borderRadius: HookRadius.xsAll,
        border: Border.all(color: colors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: HookType.label,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
