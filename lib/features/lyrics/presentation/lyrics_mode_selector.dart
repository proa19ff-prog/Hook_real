import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../theme_engine/domain/hook_theme.dart';
import '../domain/lyrics_display_mode.dart';
import 'lyrics_preferences_provider.dart';

class LyricsModeButton extends ConsumerWidget {
  final HookTheme theme;
  const LyricsModeButton({super.key, required this.theme});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(lyricsDisplayModeProvider);
    return TextButton.icon(
      key: const ValueKey('lyrics-mode-button'),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        backgroundColor: theme.colors.surface,
        builder: (_) => LyricsModeSelector(theme: theme),
      ),
      icon: const Icon(Icons.tune_rounded, size: 16),
      label: Text('Вид текста · ${mode.label}'),
      style: TextButton.styleFrom(
        foregroundColor: theme.colors.textSecondary,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return SafeArea(
        child: ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Ваш ритм чтения',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
              )),
          const SizedBox(height: 8),
          Text('Три способа быть ближе к песне.',
              style: TextStyle(color: colors.textSecondary, fontSize: 14)),
          const SizedBox(height: 22),
          for (final mode in LyricsDisplayMode.values) ...[
            Semantics(
              selected: selected == mode,
              button: true,
              label: '${mode.label}. ${mode.description}',
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
                        const SnackBar(
                            content: Text('Не удалось сохранить вид текста.')),
                      );
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(children: [
                    ExcludeSemantics(
                        child: RepaintBoundary(
                            child: ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(colors.textPrimary, BlendMode.srcIn),
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
                            child: Icon(mode == LyricsDisplayMode.focus
                                ? Icons.center_focus_strong_rounded
                                : Icons.lyrics_outlined)),
                      ),
                    ))),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(mode.label,
                              style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(mode.description,
                              style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                  height: 1.4)),
                        ])),
                    const SizedBox(width: 12),
                    Icon(
                        selected == mode
                            ? Icons.check_circle_rounded
                            : Icons.circle_outlined,
                        size: 22,
                        color: selected == mode
                            ? colors.textPrimary
                            : colors.textSecondary.withValues(alpha: 0.35)),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 12),
          Text(
              'Выбор сохранится для следующих песен. Точность караоке зависит от данных: '
              'без пословных меток подсветка слов приблизительная, без временных меток текст остаётся неподвижным.',
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 12, height: 1.5)),
        ]),
      ),
    ));
  }
}
