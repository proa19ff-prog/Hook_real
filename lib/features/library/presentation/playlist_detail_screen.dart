import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../audio_player/presentation/mini_player.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/playlist_artwork.dart';
import '../../../l10n/generated/app_localizations.dart';

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
                        MingCuteIcons.mgc_arrow_left_line,
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
                          fontSize: 14,
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
                            MingCuteIcons.mgc_shuffle_2_line,
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
                        IconButton.filled(
                          tooltip: strings.playPlaylist,
                          style: IconButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: theme
                                .toThemeData()
                                .colorScheme
                                .onPrimary,
                            minimumSize: const Size(54, 54),
                          ),
                          icon: const Icon(
                            MingCuteIcons.mgc_play_fill,
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
