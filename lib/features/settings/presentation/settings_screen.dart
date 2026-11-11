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
import '../../import/import_file_picker.dart';
import '../../import/music_import_service.dart';
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
                  _heading(strings.playbackSettings, colors),
                  const SizedBox(height: HookSpace.sm),
                  Material(
                    color: colors.surface,
                    borderRadius: HookRadius.smAll,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _toggle(
                          key: 'haptics-setting',
                          title: strings.haptics,
                          description: strings.hapticsDescription,
                          value: ref.watch(hapticsEnabledProvider),
                          colors: colors,
                          onChanged: (value) => ref
                              .read(hapticsEnabledProvider.notifier)
                              .setEnabled(value),
                        ),
                        _divider(colors),
                        _toggle(
                          key: 'background-prefetch-setting',
                          title: strings.backgroundPrefetch,
                          description: strings.backgroundPrefetchDescription,
                          value: ref.watch(backgroundPrefetchProvider),
                          colors: colors,
                          onChanged: (value) => ref
                              .read(backgroundPrefetchProvider.notifier)
                              .setEnabled(value),
                        ),
                        _divider(colors),
                        _toggle(
                          key: 'reduce-motion-setting',
                          title: strings.reduceMotion,
                          description: strings.reduceMotionDescription,
                          value: ref.watch(reduceMotionProvider),
                          colors: colors,
                          onChanged: (value) => ref
                              .read(reduceMotionProvider.notifier)
                              .setEnabled(value),
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
                  if (RemoteResolverSource.enabled)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: _CookieStatusRow(theme: theme),
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

  Widget _divider(HookColors colors) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: HookSpace.lg),
    child: Container(height: 1, color: colors.textSecondary.withValues(alpha: 0.12)),
  );

  /// One switch plus its explanation, in the card the player section uses.
  Widget _toggle({
    required String key,
    required String title,
    required String description,
    required bool value,
    required HookColors colors,
    required ValueChanged<bool> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SwitchListTile.adaptive(
        key: ValueKey(key),
        contentPadding: const EdgeInsets.fromLTRB(
          HookSpace.lg,
          HookSpace.sm,
          HookSpace.lg,
          0,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: HookType.heading,
            fontWeight: FontWeight.w600,
          ),
        ),
        activeTrackColor: colors.textPrimary,
        value: value,
        onChanged: onChanged,
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(
          HookSpace.lg,
          HookSpace.sm,
          HookSpace.lg,
          HookSpace.md,
        ),
        child: Text(
          description,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: HookType.body,
            height: 1.5,
          ),
        ),
      ),
    ],
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

/// The server's YouTube cookie state, with an on-demand live check.
///
/// Deliberately manual: `/cookies/verify` makes a real request to YouTube, so
/// running it on every settings visit would be both slow and wasteful. The row
/// explains itself without a tap, and the button answers "is it still true?".
class _CookieStatusRow extends ConsumerStatefulWidget {
  const _CookieStatusRow({required this.theme});

  final HookTheme theme;

  @override
  ConsumerState<_CookieStatusRow> createState() => _CookieStatusRowState();
}

class _CookieStatusRowState extends ConsumerState<_CookieStatusRow> {
  CookieJarHealth? _health;
  bool _checking = false;
  bool _uploading = false;

  /// The last upload's outcome, shown until the next check or upload. Kept
  /// separate from [_health] because a rejection is not a jar state: the old
  /// jar is still in place and still answering.
  String? _uploadMessage;
  bool _uploadMessageIsError = false;

  Future<void> _check() async {
    if (_checking || _uploading) return;
    setState(() {
      _checking = true;
      _uploadMessage = null;
    });
    final health = await ref.read(cookieHealthProvider.future);
    if (!mounted) return;
    setState(() {
      _health = health;
      _checking = false;
    });
  }

  /// Picks a Netscape export and posts it to the resolver.
  ///
  /// The file is never touched locally: it goes straight to the server, which
  /// validates it before swapping, so a bad pick cannot break playback.
  Future<void> _upload() async {
    if (_checking || _uploading) return;
    final source = RemoteResolverSource();
    ImportTextFile? file;
    try {
      file = await ImportFilePicker.pick();
    } on MusicImportFileException catch (error) {
      if (!mounted) return;
      setState(() {
        _uploadMessage = _pickError(
          strings: AppLocalizations.of(context),
          error: error,
        );
        _uploadMessageIsError = true;
      });
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _uploadMessage = AppLocalizations.of(
          context,
        ).cookieUploadRejected('file picker is unavailable');
        _uploadMessageIsError = true;
      });
      return;
    }
    if (file == null) return; // Dialog dismissed.
    if (!mounted) return;
    setState(() {
      _uploading = true;
      _uploadMessage = null;
    });
    final result = await source.uploadCookies(file.text);
    if (!mounted) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _uploading = false;
      _uploadMessageIsError = result.isError || !result.ready;
      if (result.isError) {
        _uploadMessage = strings.cookieUploadRejected(result.error!);
      } else if (result.ready) {
        _uploadMessage = strings.cookieUploadAccepted(result.cookies);
        _health = const CookieJarHealth(
          configured: true,
          healthy: true,
          signedIn: true,
          ageRestrictedReady: true,
          detail: '',
        );
      } else {
        // Accepted but still a visitor jar: say so plainly instead of leaving
        // the user with a track that silently refuses to play.
        _uploadMessage = strings.cookieUploadApology;
      }
    });
  }

  static String _pickError({
    required AppLocalizations strings,
    required MusicImportFileException error,
  }) {
    final reason = switch (error.kind) {
      ImportFileError.tooLarge => 'file too large',
      ImportFileError.unsupported => 'choose a .txt file',
      ImportFileError.invalidEncoding => 'not UTF-8 text',
      // Any other kind is a CSV import problem; it cannot come from a
      // cookies.txt pick, so it only needs a truthful generic answer.
      _ => 'not a cookie export',
    };
    return strings.cookieUploadRejected(reason);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final health = _health;
    final ready = health?.ageRestrictedReady ?? false;
    final busy = _checking || _uploading;
    final subtitle = _checking
        ? strings.cookieStatusChecking
        : _uploading
        ? strings.cookieStatusUploading
        : health == null
        ? strings.cookieStatusUnknown
        : ready
        ? strings.cookieStatusReady
        : strings.cookieStatusVisitor;

    return Padding(
      padding: const EdgeInsets.only(left: HookSpace.xl, bottom: HookSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  ready ? HookIcons.check : HookIcons.warning,
                  size: 16,
                  color: ready ? colors.textPrimary : colors.danger,
                ),
              ),
              const SizedBox(width: HookSpace.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.cookieStatus,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: HookType.body,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      key: const ValueKey('cookie-status-subtitle'),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: HookType.bodySmall,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Both actions under the text, not beside it: at 320 px with 2× text
          // two labels and the title cannot share a row without clipping.
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Wrap(
              spacing: HookSpace.xs,
              runSpacing: HookSpace.xs,
              children: [
                TextButton(
                  key: const ValueKey('cookie-status-check'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: busy ? null : _check,
                  child: Text(
                    strings.cookieStatusCheck,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
                TextButton(
                  key: const ValueKey('cookie-status-upload'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 40),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  // Only Android and Windows have a text-file picker wired up;
                  // elsewhere the other platforms would only produce an error.
                  onPressed: busy || !ImportFilePicker.isSupported
                      ? null
                      : _upload,
                  child: Text(
                    strings.cookieStatusUpload,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
          if (_uploadMessage != null)
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: HookSpace.sm,
                top: 2,
              ),
              child: Text(
                _uploadMessage!,
                key: const ValueKey('cookie-status-message'),
                style: TextStyle(
                  color: _uploadMessageIsError
                      ? colors.danger
                      : colors.textSecondary,
                  fontSize: HookType.bodySmall,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
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
