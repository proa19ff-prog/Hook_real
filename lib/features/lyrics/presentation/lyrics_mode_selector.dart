import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/ui/hook_tokens.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../domain/lyrics_display_mode.dart';
import 'lyrics_preferences_provider.dart';
import '../../../core/ui/hook_icons.dart';

class LyricsModeButton extends ConsumerWidget {
  final HookTheme theme;
  const LyricsModeButton({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(lyricsDisplayModeProvider);
    final strings = AppLocalizations.of(context);
    return TextButton.icon(
      key: const ValueKey('lyrics-mode-button'),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: theme.colors.surface,
        builder: (_) => LyricsModeSelector(theme: theme),
      ),
      icon: const Icon(HookIcons.mixer, size: 16),
      label: Text(strings.lyricsView(mode.labelFor(strings))),
      style: TextButton.styleFrom(
        foregroundColor: theme.colors.textSecondary,
        textStyle: const TextStyle(fontSize: HookType.label, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class LyricsModeSelector extends ConsumerWidget {
  final HookTheme theme;
  const LyricsModeSelector({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(lyricsDisplayModeProvider);
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.lyricsReadingRhythm,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.lyricsModeSubtitle,
                style: TextStyle(color: colors.textSecondary, fontSize: HookType.body),
              ),
              const SizedBox(height: 22),
              for (final mode in LyricsDisplayMode.values) ...[
                Semantics(
                  selected: selected == mode,
                  button: true,
                  label:
                      '${mode.labelFor(strings)}. ${mode.descriptionFor(strings)}',
                  child: InkWell(
                    key: ValueKey('lyrics-mode-${mode.name}'),
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      try {
                        await ref
                            .read(lyricsDisplayModeProvider.notifier)
                            .select(mode);
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.lyricsModeSaveFailed),
                            ),
                          );
                        }
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          ExcludeSemantics(
                            child: RepaintBoundary(
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  colors.textPrimary,
                                  BlendMode.srcIn,
                                ),
                                child: Lottie.asset(
                                  mode.assetPath,
                                  width: 88,
                                  height: 64,
                                  animate: !reduceMotion && selected == mode,
                                  controller: reduceMotion || selected != mode
                                      ? const AlwaysStoppedAnimation(0.45)
                                      : null,
                                  frameRate: const FrameRate(30),
                                  errorBuilder: (_, __, ___) => SizedBox(
                                    width: 88,
                                    height: 64,
                                    child: Icon(
                                      mode == LyricsDisplayMode.focus
                                          ? HookIcons.lyricsFocus
                                          : HookIcons.lyrics,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mode.labelFor(strings),
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mode.descriptionFor(strings),
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: HookType.label,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            selected == mode
                                ? HookIcons.checkCircle
                                : HookIcons.circle,
                            size: 22,
                            color: selected == mode
                                ? colors.textPrimary
                                : colors.textSecondary.withValues(alpha: 0.35),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 12),
              Text(
                strings.lyricsModeFootnote,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: HookType.label,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
