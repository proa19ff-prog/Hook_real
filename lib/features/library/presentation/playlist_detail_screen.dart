import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/hook_tokens.dart';

import '../../audio_player/presentation/mini_player.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../audio_player/presentation/playlist_downloads_provider.dart';
import 'playlist_export.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/playlist_artwork.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/ui/hook_icons.dart';

class PlaylistDetailScreen extends ConsumerWidget {
  final HookTheme theme;
  final String name;
  final List<MediaTrack> tracks;

  const PlaylistDetailScreen({
    super.key,
    required this.theme,
    required this.name,
    required this.tracks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final playlistDownloads = ref.watch(playlistDownloadsProvider);
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: PlaybackDock(theme: theme),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: strings.back,
                      icon: Icon(
                        HookIcons.back,
                        color: colors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.playlists,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: HookType.body,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: PlaylistArtwork(
                        urls: tracks.map((track) => track.artworkUrl),
                        tracks: tracks,
                        size: 190,
                        borderRadius: BorderRadius.circular(12),
                        placeholderColor: colors.surface,
                        iconColor: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 28,
                        height: 1.15,
                        letterSpacing: -0.7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hook • ${strings.tracksCount(tracks.length)}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconButton(
                          tooltip: strings.shuffle,
                          icon: Icon(
                            HookIcons.shuffle,
                            color: colors.primary,
                          ),
                          onPressed: tracks.isEmpty
                              ? null
                              : () {
                                  final shuffled = [...tracks]..shuffle();
                                  ref
                                      .read(queueProvider.notifier)
                                      .playQueue(shuffled);
                                },
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: strings.exportPlaylist,
                          icon: Icon(
                            HookIcons.share,
                            color: colors.textPrimary,
                          ),
                          onPressed: tracks.isEmpty
                              ? null
                              : () async {
                                  try {
                                    await PlaylistExport.save(name, tracks);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text(strings.playlistExported),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  } catch (_) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(strings.exportFailed),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    }
                                  }
                                },
                        ),
                        IconButton(
                          tooltip: strings.downloadAll,
                          icon: playlistDownloads.progress == null
                              ? Icon(
                                  HookIcons.download,
                                  color: colors.textPrimary,
                                )
                              : SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: playlistDownloads.progress,
                                    color: colors.primary,
                                  ),
                                ),
                          onPressed: tracks.isEmpty ||
                                  playlistDownloads.running
                              ? playlistDownloads.running
                                  ? () => ref
                                      .read(playlistDownloadsProvider.notifier)
                                      .cancel()
                                  : null
                              : () => ref
                                  .read(playlistDownloadsProvider.notifier)
                                  .downloadAll(tracks),
                        ),
                        IconButton.filled(
                          tooltip: strings.playPlaylist,
                          style: IconButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            minimumSize: const Size(54, 54),
                          ),
                          icon: const Icon(
                            HookIcons.play,
                            size: 28,
                          ),
                          onPressed: tracks.isEmpty
                              ? null
                              : () => ref
                                    .read(queueProvider.notifier)
                                    .playQueue(tracks),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (tracks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    strings.playlistEmpty,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemBuilder: (context, index) => SpotifyTrackTile(
                  theme: theme,
                  track: tracks[index],
                  onTap: () => ref
                      .read(queueProvider.notifier)
                      .playQueue(tracks, startIndex: index),
                ),
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: colors.border.withValues(alpha: 0.6),
                ),
                itemCount: tracks.length,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}
