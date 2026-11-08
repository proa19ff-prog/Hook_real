import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio_player/presentation/player_state_provider.dart';
import '../audio_player/presentation/mini_player.dart';
import '../audio_player/presentation/spotify_track_tile.dart';
import '../extractor/models/media_track.dart';
import '../library/presentation/library_provider.dart';
import '../theme_engine/domain/hook_theme.dart';
import '../theme_engine/presentation/dynamic_shader_background.dart';
import '../../l10n/generated/app_localizations.dart';

/// "Your week" — an honest look at the listening signals the app already
/// collects: replay counts (per artist|title), library sizes, and the top
/// tracks as a one-tap queue.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, required this.theme});

  final HookTheme theme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final storage = ref.watch(localStorageServiceProvider);
    final counts = storage.getPlayCounts();
    final history = storage.getHistory();
    final favorites = storage.getFavorites();
    final playlists = storage.getPlaylists();

    final totalPlays =
        counts.values.fold<int>(0, (sum, value) => sum + value);
    final artistPlays = <String, int>{};
    for (final entry in counts.entries) {
      final artist = entry.key.split('|').first.trim();
      if (artist.isEmpty) continue;
      artistPlays[artist] = (artistPlays[artist] ?? 0) + entry.value;
    }
    final topArtists = artistPlays.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Top tracks: replay counts joined back onto known library tracks, so
    // the queue carries real playable items rather than text keys.
    final byKey = <String, MediaTrack>{
      for (final track in {
        ...history,
        ...favorites,
        for (final list in playlists.values) ...list,
      })
        '${track.artist.toLowerCase()}|${track.title.toLowerCase()}': track,
    };
    final topTracks = <MediaTrack>[];
    final trackCounts = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in trackCounts) {
      final track = byKey[entry.key];
      if (track != null && topTracks.length < 8) topTracks.add(track);
    }
    final maxArtistPlays =
        topArtists.isEmpty ? 1 : topArtists.first.value.toDouble();

    String two(int value) => value.toString().padLeft(2, '0');
    final now = DateTime.now();
    final weekLabel =
        '${two(now.day)}.${two(now.month)} — играет Hook';

    return Theme(
      data: theme.toThemeData(),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: PlaybackDock(theme: theme),
        body: SafeArea(
          bottom: false,
          child: DynamicShaderBackground(
            theme: theme,
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
                            Icons.arrow_back_rounded,
                            color: colors.textPrimary,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            strings.statsTitle,
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
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.statsTitle,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 28,
                            height: 1.15,
                            letterSpacing: -0.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weekLabel,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _StatCard(
                              label: strings.statsPlays,
                              value: '$totalPlays',
                              colors: colors,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: strings.statsFavorites,
                              value: '${favorites.length}',
                              colors: colors,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: strings.statsPlaylists,
                              value: '${playlists.length}',
                              colors: colors,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (topArtists.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.statsTopArtists,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          for (final entry in topArtists.take(10))
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: colors.textPrimary,
                                            fontSize: 13.5,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${entry.value}',
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(3),
                                    child: LinearProgressIndicator(
                                      value: entry.value / maxArtistPlays,
                                      minHeight: 5,
                                      color: colors.primary,
                                      backgroundColor:
                                          colors.textSecondary.withValues(
                                        alpha: 0.16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (topTracks.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              strings.statsTopTracks,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: strings.playPlaylist,
                            icon: Icon(
                              Icons.play_circle_fill_rounded,
                              color: colors.primary,
                              size: 30,
                            ),
                            onPressed: () => ref
                                .read(queueProvider.notifier)
                                .playQueue(topTracks),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList.separated(
                    itemBuilder: (context, index) => SpotifyTrackTile(
                      theme: theme,
                      track: topTracks[index],
                      onTap: () => ref
                          .read(queueProvider.notifier)
                          .playQueue(topTracks, startIndex: index),
                    ),
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      indent: 80,
                      color: colors.border.withValues(alpha: 0.6),
                    ),
                    itemCount: topTracks.length,
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 60)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.colors,
  });

  final String label;
  final String value;
  final dynamic colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surfaceGlass,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
