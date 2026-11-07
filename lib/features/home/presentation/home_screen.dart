import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/theme_settings_screen.dart';
import '../../theme_engine/presentation/track_artwork.dart';

class HomeScreen extends ConsumerWidget {
  final HookTheme theme;
  final VoidCallback onOpenSearch;

  const HomeScreen({
    super.key,
    required this.theme,
    required this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);
    final currentTrack = ref.watch(currentTrackProvider);
    final seen = <String>{};
    final recent =
        [if (currentTrack != null) currentTrack, ...history, ...favorites]
            .where((track) => seen.add('${track.source.name}:${track.id}'))
            .take(8)
            .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/icons/app_mark.png',
                          width: 28,
                          height: 36,
                          color: colors.textPrimary,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Hook',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: strings.themeSettings,
                          icon: Icon(
                            MingCuteIcons.mgc_palette_line,
                            color: colors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => ThemeSettingsScreen(theme: theme),
                            ),
                          ),
                        ),
                        IconButton(
                          key: const ValueKey('home-settings-button'),
                          tooltip: strings.settings,
                          constraints: const BoxConstraints(
                            minWidth: 48,
                            minHeight: 48,
                          ),
                          icon: Icon(
                            Icons.settings_outlined,
                            color: colors.textSecondary,
                          ),
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Material(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: onOpenSearch,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                MingCuteIcons.mgc_search_2_line,
                                color: colors.textSecondary,
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  strings.homeSearchHint,
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
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _WaveField(
                    theme: theme,
                    seed: recent.firstOrNull,
                    onOpenSearch: onOpenSearch,
                  ),
                ),
                if (recent.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _SectionHeading(
                      title: strings.onYourAir,
                      detail: strings.recentSignals(recent.length),
                      theme: theme,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height:
                          144 +
                          MediaQuery.textScalerOf(context).scale(14) * 3.6,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: recent.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final track = recent[index];
                          return SizedBox(
                            width: 144,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => ref
                                    .read(queueProvider.notifier)
                                    .playQueue(recent, startIndex: index),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TrackArtwork(
                                      url: track.artworkUrl,
                                      size: 144,
                                      borderRadius: BorderRadius.circular(12),
                                      placeholderColor: colors.surface,
                                      iconColor: colors.textSecondary,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      track.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      track.artist,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
                SliverToBoxAdapter(
                  child: _SectionHeading(
                    title: favorites.isEmpty
                        ? strings.collectionWaiting
                        : strings.saved,
                    detail: favorites.isEmpty
                        ? strings.collectionEmptyDetail
                        : strings.tracksCount(favorites.length),
                    theme: theme,
                  ),
                ),
                if (favorites.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.favoriteWaveHint,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: onOpenSearch,
                            icon: const Icon(
                              MingCuteIcons.mgc_search_2_line,
                              size: 20,
                            ),
                            label: Text(strings.openSearch),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList.builder(
                    itemCount: math.min(favorites.length, 6),
                    itemBuilder: (context, index) => SpotifyTrackTile(
                      theme: theme,
                      track: favorites[index],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      onTap: () => ref
                          .read(queueProvider.notifier)
                          .playQueue(favorites, startIndex: index),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveField extends ConsumerWidget {
  final HookTheme theme;
  final MediaTrack? seed;
  final VoidCallback onOpenSearch;

  const _WaveField({
    required this.theme,
    required this.seed,
    required this.onOpenSearch,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    final active = ref.watch(waveActiveProvider);
    final playing = ref.watch(isPlayingProvider);
    final loading = ref.watch(isTrackLoadingProvider);
    // With nothing listened to yet, the personal mix proposes a starter track
    // so the wave works from the very first minute.
    final personalSeed = seed == null
        ? ref.watch(personalMixSeedProvider).valueOrNull
        : null;
    final effectiveSeed = seed ?? personalSeed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    strings.yourWaveLabel,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (effectiveSeed != null) ...[
                  const SizedBox(width: 12),
                  TrackArtwork(
                    url: effectiveSeed.artworkUrl,
                    size: 40,
                    borderRadius: BorderRadius.circular(8),
                    placeholderColor: colors.background,
                    iconColor: colors.textSecondary,
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: WaveRibbon(
                color: colors.accent,
                animate: active && playing && !loading,
              ),
            ),
            Text(
              effectiveSeed?.title ?? strings.findFirstTrack,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.7,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              effectiveSeed == null
                  ? strings.chooseTrackWaveDetail
                  : strings.continuationAfter(effectiveSeed.artist),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              key: const ValueKey('home-wave-button'),
              onPressed: loading
                  ? null
                  : effectiveSeed == null
                  ? onOpenSearch
                  : () =>
                        ref.read(queueProvider.notifier).startWave(effectiveSeed),
              style: FilledButton.styleFrom(
                backgroundColor: colors.textPrimary,
                foregroundColor: colors.background,
              ),
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      effectiveSeed == null
                          ? MingCuteIcons.mgc_search_2_line
                          : MingCuteIcons.mgc_play_fill,
                      size: 20,
                    ),
              label: Text(
                effectiveSeed == null ? strings.chooseTrack : strings.continueWave,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WaveRibbon extends StatefulWidget {
  const WaveRibbon({super.key, required this.color, required this.animate});
  final Color color;
  final bool animate;

  @override
  State<WaveRibbon> createState() => _WaveRibbonState();
}

class _WaveRibbonState extends State<WaveRibbon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );

  void _updateMotion() {
    final enabled =
        widget.animate &&
        !MediaQuery.disableAnimationsOf(context) &&
        TickerMode.valuesOf(context).enabled;
    if (enabled && !_motion.isAnimating) {
      _motion.repeat();
    } else if (!enabled) {
      _motion.stop();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateMotion();
  }

  @override
  void didUpdateWidget(covariant WaveRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateMotion();
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: SizedBox(
        height: 84,
        width: double.infinity,
        child: CustomPaint(painter: _WavePainter(_motion, widget.color)),
      ),
    ),
  );
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.motion, this.color) : super(repaint: motion);
  final Animation<double> motion;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final phase = motion.value * math.pi * 2;
    for (var layer = 0; layer < 4; layer++) {
      final path = Path();
      for (var x = 0.0; x <= size.width; x += 2) {
        final t = x / math.max(1, size.width);
        final envelope = math.pow(math.sin(t * math.pi), 1.4);
        final y =
            size.height / 2 +
            math.sin(t * math.pi * 3 + phase + layer * 0.5) *
                envelope *
                (30 - layer * 4);
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = layer == 0 ? 2.5 : 1.5
          ..strokeCap = StrokeCap.round
          ..color = color.withValues(alpha: 1 - layer * 0.22),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.motion != motion;
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.detail,
    required this.theme,
  });
  final String title;
  final String detail;
  final HookTheme theme;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: theme.colors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          style: TextStyle(color: theme.colors.textSecondary, fontSize: 13),
        ),
      ],
    ),
  );
}
