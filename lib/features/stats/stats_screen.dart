import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../audio_player/presentation/mini_player.dart';
import '../audio_player/presentation/player_state_provider.dart';
import '../audio_player/presentation/spotify_track_tile.dart';
import '../extractor/models/media_track.dart';
import '../library/presentation/library_provider.dart';
import '../theme_engine/domain/hook_theme.dart';
import '../theme_engine/presentation/dynamic_shader_background.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/ui/hook_icons.dart';
import '../../core/ui/hook_tokens.dart';

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

    final totalPlays = counts.values.fold<int>(0, (sum, value) => sum + value);
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
    final maxArtistPlays = topArtists.isEmpty
        ? 1
        : topArtists.first.value.toDouble();

    // Seven buckets from the timestamps that already exist for recency decay.
    // Counting events per day turns the same data into an answer to "how much
    // did I listen this week", which is what a stats screen is actually for.
    final week = _weekBuckets(storage.getPlayTimestamps());
    final weekPeak = week.fold<int>(
      0,
      (best, day) => day.count > best ? day.count : best,
    );

    String two(int value) => value.toString().padLeft(2, '0');
    final now = DateTime.now();
    final weekLabel = '${two(now.day)}.${two(now.month)} — играет Hook';

    return Theme(
      data: theme.toThemeData(),
      child: Scaffold(
        backgroundColor: colors.background,
        bottomNavigationBar: PlaybackDock(theme: theme),
        body: SafeArea(
          bottom: false,
          child: DynamicShaderBackground(
            theme: theme,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: HookBreakpoints.readingMax,
                ),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          HookSpace.xs,
                          HookSpace.xs,
                          HookSpace.md,
                          0,
                        ),
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
                            const SizedBox(width: HookSpace.sm),
                            Expanded(
                              child: Text(
                                strings.statsTitle,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: HookType.bodySmall,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        HookSpace.xxl,
                        HookSpace.lg,
                        HookSpace.xxl,
                        0,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.statsTitle,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: HookType.display,
                                height: 1.15,
                                letterSpacing: -0.7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: HookSpace.xs),
                            Text(
                              weekLabel,
                              style: TextStyle(
                                color: colors.textSecondary,
                                fontSize: HookType.bodySmall,
                              ),
                            ),
                            const SizedBox(height: HookSpace.lg),
                            Row(
                              children: [
                                _StatCard(
                                  label: strings.statsPlays,
                                  value: '$totalPlays',
                                  colors: colors,
                                ),
                                const SizedBox(width: HookSpace.sm),
                                _StatCard(
                                  label: strings.statsFavorites,
                                  value: '${favorites.length}',
                                  colors: colors,
                                ),
                                const SizedBox(width: HookSpace.sm),
                                _StatCard(
                                  label: strings.statsPlaylists,
                                  value: '${playlists.length}',
                                  colors: colors,
                                ),
                              ],
                            ),
                            if (weekPeak > 0) ...[
                              const SizedBox(height: HookSpace.xxl),
                              _WeekChart(
                                days: week,
                                peak: weekPeak,
                                colors: colors,
                                title: strings.statsWeek,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    if (topArtists.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          HookSpace.xxl,
                          HookSpace.xxl,
                          HookSpace.xxl,
                          0,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                strings.statsTopArtists,
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: HookType.heading,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: HookSpace.md),
                              for (final entry in topArtists.take(10))
                                _ArtistBar(
                                  name: entry.key,
                                  plays: entry.value,
                                  fraction: entry.value / maxArtistPlays,
                                  colors: colors,
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (topTracks.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          HookSpace.xxl,
                          HookSpace.xl,
                          HookSpace.xxl,
                          HookSpace.sm,
                        ),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  strings.statsTopTracks,
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: HookType.heading,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: strings.playPlaylist,
                                icon: Icon(
                                  HookIcons.play,
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
                    SliverToBoxAdapter(
                      child: SizedBox(height: HookSpace.xxl * 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Seven trailing days, oldest first, so the chart reads left to right.
  static List<_DayCount> _weekBuckets(Map<String, int> timestamps) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final buckets = List<int>.filled(7, 0);
    for (final stamp in timestamps.values) {
      final played = DateTime.fromMillisecondsSinceEpoch(stamp);
      final playedStart = DateTime(played.year, played.month, played.day);
      final daysAgo = todayStart.difference(playedStart).inDays;
      if (daysAgo < 0 || daysAgo > 6) continue;
      buckets[6 - daysAgo] += 1;
    }
    return [
      for (var index = 0; index < 7; index++)
        _DayCount(
          date: todayStart.subtract(Duration(days: 6 - index)),
          count: buckets[index],
        ),
    ];
  }
}

class _DayCount {
  const _DayCount({required this.date, required this.count});

  final DateTime date;
  final int count;
}

/// Bars for the last seven days. Heights are proportional to the busiest day,
/// so an empty week does not render as seven identical stubs.
class _WeekChart extends StatelessWidget {
  const _WeekChart({
    required this.days,
    required this.peak,
    required this.colors,
    required this.title,
  });

  final List<_DayCount> days;
  final int peak;
  final HookColors colors;
  final String title;

  @override
  Widget build(BuildContext context) {
    // Localized by the framework, so a Russian device reads Пн/Вт and an
    // English one Mon/Tue without a translation table per language.
    final weekdays = MaterialLocalizations.of(context).narrowWeekdays;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: HookType.heading,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: HookSpace.md),
        SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in days)
                Expanded(
                  child: _Bar(
                    count: day.count,
                    fraction: day.count / peak,
                    label: weekdays[day.date.weekday % 7],
                    colors: colors,
                    isToday: day == days.last,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.count,
    required this.fraction,
    required this.label,
    required this.colors,
    required this.isToday,
  });

  final int count;
  final double fraction;
  final String label;
  final HookColors colors;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $count',
      excludeSemantics: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            count == 0 ? '' : '$count',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: HookType.caption,
            ),
          ),
          const SizedBox(height: HookSpace.hair),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: HookMotion.slow,
            curve: HookMotion.enter,
            builder: (context, value, _) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 8 + 52 * value,
              decoration: BoxDecoration(
                color: isToday
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.55),
                borderRadius: HookRadius.xsAll,
              ),
            ),
          ),
          const SizedBox(height: HookSpace.sm),
          Text(
            label,
            style: TextStyle(
              color: isToday ? colors.textPrimary : colors.textSecondary,
              fontSize: HookType.caption,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArtistBar extends StatelessWidget {
  const _ArtistBar({
    required this.name,
    required this.plays,
    required this.fraction,
    required this.colors,
  });

  final String name;
  final int plays;
  final double fraction;
  final HookColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: HookSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: HookType.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: HookSpace.sm),
              Text(
                '$plays',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: HookType.label,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          ...[
            const SizedBox(height: HookSpace.xs),
            ClipRRect(
              borderRadius: HookRadius.xsAll,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction.clamp(0.02, 1.0)),
                duration: HookMotion.slow,
                curve: HookMotion.enter,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 5,
                  color: colors.primary,
                  backgroundColor: colors.textSecondary.withValues(alpha: 0.16),
                ),
              ),
            ),
          ],
        ],
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
  final HookColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: HookSpace.md,
          vertical: HookSpace.md,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceGlass,
          borderRadius: HookRadius.mdAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: HookType.title,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: HookSpace.hair),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: HookType.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
