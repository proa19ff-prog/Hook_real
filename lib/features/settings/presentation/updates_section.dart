import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ui/hook_tokens.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../updates/update_provider.dart';
import '../../../core/ui/hook_icons.dart';

/// The OTA section in settings: current version, an automatic check on
/// open (gated to once per six hours), and the full download-and-install
/// flow with progress.
class UpdatesSection extends ConsumerStatefulWidget {
  const UpdatesSection({super.key});

  @override
  ConsumerState<UpdatesSection> createState() => _UpdatesSectionState();
}

class _UpdatesSectionState extends ConsumerState<UpdatesSection> {
  bool _autoCheckStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _autoCheckStarted) return;
      _autoCheckStarted = true;
      ref.read(updateProvider.notifier).check(force: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final state = ref.watch(updateProvider);
    final version = ref.watch(appVersionProvider).valueOrNull ?? '';

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(HookIcons.download, size: 20, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.updatesTitle,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: HookType.heading,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    strings.currentVersion(version),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: HookType.label,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...switch (state.stage) {
              UpdateStage.checking => [
                Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        strings.checkingForUpdates,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: HookType.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              UpdateStage.upToDate => [
                Row(
                  children: [
                    Icon(
                      HookIcons.checkCircle,
                      size: 17,
                      color: colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.upToDate,
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: HookType.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              UpdateStage.available ||
              UpdateStage.downloading ||
              UpdateStage.downloaded => _buildUpdateFlow(context, state),
              UpdateStage.failed => [
                Text(
                  strings.updateCheckFailed,
                  style: TextStyle(
                    color: colors.error,
                    fontSize: HookType.bodySmall,
                  ),
                ),
              ],
              UpdateStage.idle => const [],
            },
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const ValueKey('updates-check-button'),
                onPressed:
                    state.stage == UpdateStage.checking ||
                        state.stage == UpdateStage.downloading
                    ? null
                    : () => ref.read(updateProvider.notifier).check(),
                child: Text(strings.checkForUpdates),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildUpdateFlow(BuildContext context, UpdateState state) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final update = state.update!;

    if (state.stage == UpdateStage.downloading) {
      return [
        Text(
          strings.downloadingUpdate,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: HookType.bodySmall,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: state.progress,
          color: colors.primary,
          backgroundColor: colors.onSurface.withValues(alpha: 0.12),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(state.progress * 100).round()}%',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: HookType.caption,
            ),
          ),
        ),
      ];
    }

    return [
      Text(
        strings.updateAvailable(update.version),
        style: TextStyle(
          color: colors.onSurface,
          fontSize: HookType.body,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (update.notes.trim().isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          update.notes.trim(),
          maxLines: 8,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: HookType.label,
            height: 1.4,
          ),
        ),
      ],
      if (state.permissionNeeded) ...[
        const SizedBox(height: 8),
        Text(
          strings.installPermissionNeeded,
          style: TextStyle(color: colors.error, fontSize: HookType.label),
        ),
      ],
      const SizedBox(height: 12),
      SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const ValueKey('updates-install-button'),
          onPressed: state.stage == UpdateStage.downloaded
              ? ref.read(updateProvider.notifier).openInstaller
              : ref.read(updateProvider.notifier).downloadAndInstall,
          icon: const Icon(HookIcons.downloadDone, size: 18),
          label: Text(strings.installUpdate),
        ),
      ),
    ];
  }
}
