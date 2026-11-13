import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../search/presentation/artist_screen.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'player_state_provider.dart';
import 'sleep_timer_provider.dart';
import 'track_downloads_provider.dart';

/// Spotify-inspired, reusable track row used by discovery, collections and the
/// play queue. One visual language also means a long press exposes the same
/// actions everywhere a track appears.
class SpotifyTrackTile extends ConsumerWidget {
  final HookTheme theme;
  final MediaTrack track;
  final VoidCallback? onTap;
  final VoidCallback? onFindArtist;
  final bool showDuration;
  final bool showArtwork;
  final bool showSource;
  final bool isCurrent;
  final EdgeInsetsGeometry padding;

  const SpotifyTrackTile({
    super.key,
    required this.theme,
    required this.track,
    this.onTap,
    this.onFindArtist,
    this.showDuration = true,
    this.showArtwork = true,
    this.showSource = false,
    this.isCurrent = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
  });

  static String formatDuration(Duration duration) {
    if (duration == Duration.zero) return '';
    final minutes = duration.inMinutes;
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final playing = ref.watch(currentTrackProvider);
    final isPlayingTrack =
        isCurrent ||
        (playing?.id == track.id && playing?.source == track.source);
    final isFavorite = ref.watch(
      favoritesProvider.select(
        (tracks) => tracks.any(
          (item) => item.id == track.id && item.source == track.source,
        ),
      ),
    );
    // A quiet "saved offline" hint once the track has been downloaded.
    final isDownloaded = ref.watch(
      trackDownloadsProvider.select(
        (downloads) =>
            downloads[TrackDownloadsNotifier.keyOf(track)]?.status ==
            TrackDownloadStatus.downloaded,
      ),
    );
    final duration = formatDuration(track.duration);

    return Semantics(
      button: true,
      label: strings.trackSemantics(track.title, track.artist),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: () => showSpotifyTrackActions(
          context,
          ref,
          theme: theme,
          track: track,
          onFindArtist: onFindArtist,
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isPlayingTrack
                ? colors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (showArtwork) ...[
                Stack(
                  children: [
                    TrackArtwork(
                      url: track.artworkUrl,
                      artist: track.artist,
                      title: track.title,
                      duration: track.duration,
                      size: 52,
                      borderRadius: BorderRadius.circular(4),
                      placeholderColor: colors.surface,
                      iconColor: colors.textSecondary,
                    ),
                    if (isPlayingTrack)
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.48),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Icon(
                              HookIcons.waveform,
                              size: 22,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isPlayingTrack
                            ? colors.primary
                            : colors.textPrimary,
                        fontSize: HookType.body,
                        height: 1.15,
                        fontWeight: isPlayingTrack
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    InteractiveArtistText(
                      artist: track.artist,
                      theme: theme,
                      rest: [
                        if (showSource)
                          track.source.labelFor(strings)
                        else if (track.album?.isNotEmpty == true)
                          track.album!,
                      ].where((part) => part.isNotEmpty).join(' • '),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: HookType.bodySmall,
                        height: 1.15,
                      ),
                      onArtistTap: onFindArtist != null
                          ? (_) => onFindArtist!()
                          : null,
                    ),
                  ],
                ),
              ),
              if (isDownloaded)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    HookIcons.downloadDone,
                    color: colors.primary,
                    size: 17,
                  ),
                ),
              if (isFavorite)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    HookIcons.heartFilled,
                    color: colors.primary,
                    size: 18,
                  ),
                ),
              if (showDuration && duration.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    duration,
                    style: TextStyle(color: colors.textSecondary, fontSize: HookType.label),
                  ),
                ),
              IconButton(
                tooltip: strings.trackActions,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  HookIcons.more,
                  color: colors.textSecondary,
                  size: 21,
                ),
                onPressed: () => showSpotifyTrackActions(
                  context,
                  ref,
                  theme: theme,
                  track: track,
                  onFindArtist: onFindArtist,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showSpotifyTrackActions(
  BuildContext context,
  WidgetRef ref, {
  required HookTheme theme,
  required MediaTrack track,
  VoidCallback? onFindArtist,
}) async {
  final colors = theme.colors;
  final strings = AppLocalizations.of(context);
  final isFavorite = ref
      .read(favoritesProvider)
      .any((item) => item.id == track.id && item.source == track.source);
  final isDisliked =
      ref.read(localStorageServiceProvider).isDislikedArtist(track.artist);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetContext) => Consumer(
      builder: (sheetContext, sheetRef, _) {
        final downloads = sheetRef.watch(trackDownloadsProvider);
        final dlState =
            downloads[TrackDownloadsNotifier.keyOf(track)] ??
            const TrackDownloadState();
        // First open of the sheet syncs the badge with what is on disk.
        if (dlState.status == TrackDownloadStatus.notDownloaded &&
            !downloads.containsKey(TrackDownloadsNotifier.keyOf(track))) {
          Future.microtask(
            () => sheetRef.read(trackDownloadsProvider.notifier).refresh(track),
          );
        }
        final isDownloading = dlState.status == TrackDownloadStatus.downloading;
        final isDownloaded =
            dlState.status == TrackDownloadStatus.downloaded;
        final isFailed = dlState.status == TrackDownloadStatus.failed;
        final String? subtitle;
        if (isDownloading) {
          subtitle = '${(dlState.progress * 100).round()}%';
        } else if (isDownloaded && dlState.bitrateKbps != null) {
          subtitle = '${dlState.bitrateKbps} kbps';
        } else {
          subtitle = null;
        }
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    TrackArtwork(
                      url: track.artworkUrl,
                      artist: track.artist,
                      title: track.title,
                      duration: track.duration,
                      size: 54,
                      borderRadius: BorderRadius.circular(4),
                      placeholderColor: colors.background,
                      iconColor: colors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: HookType.heading,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            track.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _TrackAction(
                  icon: isDownloaded
                      ? HookIcons.downloadDone
                      : HookIcons.download,
                  label: isDownloading
                      ? strings.downloading
                      : isDownloaded
                      ? strings.downloaded
                      : isFailed
                      ? strings.downloadFailed
                      : strings.download,
                  subtitle: subtitle,
                  color: isDownloaded
                      ? colors.primary
                      : isFailed
                      ? colors.danger
                      : null,
                  busy: isDownloading,
                  onTap: () {
                    final notifier = sheetRef.read(
                      trackDownloadsProvider.notifier,
                    );
                    if (isDownloading) return;
                    if (isDownloaded) {
                      notifier.remove(track);
                      Navigator.of(sheetContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.trackRemovedFromCache),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      notifier.download(track);
                    }
                  },
                ),
                _TrackAction(
                  icon: HookIcons.waveform,
                  label: strings.startWaveFromTrack,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    ref.read(queueProvider.notifier).startWave(track);
                  },
                ),
                _TrackAction(
                  icon: HookIcons.playlist,
                  label: strings.addToQueue,
                  onTap: () {
                    ref.read(queueProvider.notifier).addToQueue(track);
                    Navigator.of(sheetContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(strings.addedToQueue(track.title)),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                _TrackAction(
                  icon: isFavorite
                      ? HookIcons.heartFilled
                      : HookIcons.heart,
                  label: isFavorite
                      ? strings.removeFavorite
                      : strings.addFavorite,
                  color: isFavorite ? colors.primary : null,
                  onTap: () {
                    HookHaptics.tap();
                    ref.read(favoritesProvider.notifier).toggleFavorite(track);
                    Navigator.of(sheetContext).pop();
                  },
                ),
                _TrackAction(
                  icon: HookIcons.queue,
                  label: strings.addToPlaylist,
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _choosePlaylist(context, ref, theme, track);
                  },
                ),
                _TrackAction(
                  icon: HookIcons.social,
                  label: strings.goToArtist,
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    (onFindArtist ??
                            () => showArtistPickerOrOpen(
                                  context,
                                  theme,
                                  track.artist,
                                ))
                        .call();
                  },
                ),
                _TrackAction(
                  icon: HookIcons.dice,
                  label: strings.sleepTimer,
                  onTap: () => _showSleepTimerSheet(
                    context,
                    sheetContext,
                    strings,
                  ),
                ),
                _TrackAction(
                  icon: isDisliked
                      ? HookIcons.thumbDown
                      : HookIcons.thumbDown,
                  label: isDisliked
                      ? strings.dislikeRemove
                      : strings.dislike,
                  color: isDisliked ? colors.danger : null,
                  onTap: () {
                    ref
                        .read(localStorageServiceProvider)
                        .toggleDislikedArtist(track.artist);
                    Navigator.of(sheetContext).pop();
                    if (!isDisliked) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(strings.dislikeSaved(track.artist)),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

/// Sleep timer options in a compact modal: presets plus "until the track
/// ends", with the running countdown shown as the sheet's subtitle.
void _showSleepTimerSheet(
  BuildContext context,
  BuildContext sheetContext,
  AppLocalizations strings,
) {
  Navigator.of(sheetContext).pop();
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Consumer(
      builder: (context, ref, _) {
        final timer = ref.watch(sleepTimerProvider);
        final remaining = timer.remaining;
        final options = <Duration>[
          const Duration(minutes: 15),
          const Duration(minutes: 30),
          const Duration(minutes: 45),
          const Duration(hours: 1),
        ];
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remaining == null
                      ? strings.sleepTimer
                      : '${strings.sleepTimer} · '
                          '${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in options)
                      ActionChip(
                        label: Text(strings.sleepMinutes(
                          option.inMinutes >= 60
                              ? '${option.inHours} h'
                              : '${option.inMinutes} min',
                        )),
                        onPressed: () {
                          ref.read(sleepTimerProvider.notifier).start(option);
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                    ActionChip(
                      label: Text(strings.sleepUntilTrackEnd),
                      onPressed: () {
                        ref
                            .read(sleepTimerProvider.notifier)
                            .startUntilTrackEnd();
                        Navigator.of(sheetContext).pop();
                      },
                    ),
                    if (timer.active)
                      ActionChip(
                        label: Text(strings.sleepCancel),
                        onPressed: () {
                          ref.read(sleepTimerProvider.notifier).cancel();
                          Navigator.of(sheetContext).pop();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

Future<void> _choosePlaylist(
  BuildContext context,
  WidgetRef ref,
  HookTheme theme,
  MediaTrack track,
) async {
  final playlists = ref.read(playlistsProvider);
  final colors = theme.colors;
  final strings = AppLocalizations.of(context);
  if (playlists.isEmpty) {
    final nameController = TextEditingController(text: strings.myPlaylist);
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.surface,
        title: Text(
          strings.newPlaylist,
          style: TextStyle(color: colors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: TextStyle(color: colors.textPrimary),
          decoration: InputDecoration(hintText: strings.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(nameController.text),
            child: Text(strings.create),
          ),
        ],
      ),
    );
    nameController.dispose();
    if (name == null || name.trim().isEmpty) return;
    await ref.read(playlistsProvider.notifier).savePlaylist(name.trim(), [
      track,
    ]);
    return;
  }

  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              strings.addToPlaylist,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          for (final entry in playlists.entries)
            ListTile(
              leading: Icon(
                HookIcons.playlist,
                color: colors.primary,
              ),
              title: Text(
                entry.key,
                style: TextStyle(color: colors.textPrimary),
              ),
              subtitle: Text(
                strings.tracksCount(entry.value.length),
                style: TextStyle(color: colors.textSecondary),
              ),
              onTap: () async {
                final alreadyAdded = entry.value.any(
                  (item) => item.id == track.id && item.source == track.source,
                );
                if (!alreadyAdded) {
                  await ref.read(playlistsProvider.notifier).savePlaylist(
                    entry.key,
                    [...entry.value, track],
                  );
                }
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
        ],
      ),
    ),
  );
}

class _TrackAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color? color;
  final bool busy;
  final VoidCallback onTap;

  const _TrackAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.subtitle,
    this.color,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = color ?? Theme.of(context).colorScheme.onSurface;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: textColor, size: 22),
      title: Text(label, style: TextStyle(color: textColor, fontSize: HookType.body)),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.75),
                fontSize: HookType.label,
              ),
            ),
      trailing: busy
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: textColor,
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}

