import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';

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
    final artwork = tracks.isEmpty ? '' : tracks.first.artworkUrl;
    return Scaffold(
      backgroundColor: colors.background,
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
                      tooltip: 'Назад',
                      icon: Icon(MingCuteIcons.mgc_arrow_left_line,
                          color: colors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Действия с плейлистом',
                      icon: Icon(MingCuteIcons.mgc_more_2_line,
                          color: colors.textPrimary),
                      onPressed: () {},
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
                      child: TrackArtwork(
                        url: artwork,
                        size: 190,
                        borderRadius: BorderRadius.circular(6),
                        placeholderColor: colors.surface,
                        iconColor: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      'ПЛЕЙЛИСТ',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 30,
                        height: 1.02,
                        letterSpacing: -1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Hook • ${tracks.length} ${_trackWord(tracks.length)}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Перемешать',
                          icon: Icon(MingCuteIcons.mgc_shuffle_2_line,
                              color: colors.primary),
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
                          tooltip: 'Слушать плейлист',
                          style: IconButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(54, 54),
                          ),
                          icon:
                              const Icon(MingCuteIcons.mgc_play_fill, size: 28),
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
                child: Center(
                  child: Text(
                    'В этом плейлисте пока нет треков',
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

  String _trackWord(int value) {
    final last = value % 10;
    final hundred = value % 100;
    if (hundred >= 11 && hundred <= 14) return 'треков';
    if (last == 1) return 'трек';
    if (last >= 2 && last <= 4) return 'трека';
    return 'треков';
  }
}
