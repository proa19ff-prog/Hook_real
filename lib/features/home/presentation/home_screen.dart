import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
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

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Доброй ночи';
    if (hour < 12) return 'Доброе утро';
    if (hour < 18) return 'Добрый день';
    return 'Добрый вечер';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);
    final currentTrack = ref.watch(currentTrackProvider);
    final recent = <MediaTrack>[];
    final seen = <String>{};
    for (final track in [
      if (currentTrack != null) currentTrack,
      ...history,
      ...favorites,
    ]) {
      final key = '${track.source.name}:${track.id}';
      if (seen.add(key)) recent.add(track);
      if (recent.length == 8) break;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOOK / LIVE',
                            style: TextStyle(
                              color: colors.accent,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _greeting,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 30,
                              letterSpacing: -1.1,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Настройки темы',
                      style: IconButton.styleFrom(
                        foregroundColor: colors.textSecondary,
                        side: BorderSide(
                          color: colors.border.withValues(alpha: 0.8),
                        ),
                      ),
                      icon: const Icon(MingCuteIcons.mgc_palette_line),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ThemeSettingsScreen(theme: theme),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                child: _SearchLaunch(
                  theme: theme,
                  onTap: onOpenSearch,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _WaveField(
                theme: theme,
                seed: recent.isNotEmpty ? recent.first : null,
                onOpenSearch: onOpenSearch,
              ),
            ),
            if (recent.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: _SectionHeading(
                  title: 'В вашем эфире',
                  detail: '${recent.length} последних сигналов',
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 206,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => _RecentSignalCard(
                      theme: theme,
                      track: recent[index],
                      index: index,
                      onTap: () => ref
                          .read(queueProvider.notifier)
                          .playQueue(recent, startIndex: index),
                    ),
                  ),
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: _SectionHeading(
                title: favorites.isEmpty ? 'Коллекция ждёт' : 'Сохранённые',
                detail: favorites.isEmpty
                    ? 'Здесь останется то, к чему хочется вернуться'
                    : '${favorites.length} треков',
              ),
            ),
            if (favorites.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 164),
                  child: _CollectionPrompt(
                    theme: theme,
                    onOpenSearch: onOpenSearch,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 166),
                sliver: SliverList.separated(
                  itemCount: favorites.length > 6 ? 6 : favorites.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: colors.border.withValues(alpha: 0.45),
                  ),
                  itemBuilder: (context, index) => _SavedTrackRow(
                    theme: theme,
                    track: favorites[index],
                    index: index,
                    onTap: () => ref
                        .read(queueProvider.notifier)
                        .playQueue(favorites, startIndex: index),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchLaunch extends StatelessWidget {
  final HookTheme theme;
  final VoidCallback onTap;

  const _SearchLaunch({required this.theme, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return Material(
      color: colors.surface.withValues(alpha: 0.82),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          child: Row(
            children: [
              Icon(
                MingCuteIcons.mgc_search_2_line,
                color: colors.accent,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Трек, артист или слова песни',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'ПОИСК',
                style: TextStyle(
                  color: colors.textPrimary.withValues(alpha: 0.48),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
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
    final hasSeed = seed != null;
    final title = hasSeed ? seed!.title : 'Найдите первый трек';
    final subtitle = hasSeed
        ? 'Продолжение после ${seed!.artist}'
        : 'Выберите трек — и соберём волну в его настроении.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Container(
        height: 228,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: colors.border.withValues(alpha: 0.8)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: _WaveBackdrop(theme: theme, artworkUrl: seed?.artworkUrl),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0, 0.52, 1],
                    colors: [
                      colors.surface.withValues(alpha: 0.92),
                      colors.surface.withValues(alpha: 0.56),
                      colors.background.withValues(alpha: 0.94),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 18,
              right: 18,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.background.withValues(alpha: 0.48),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colors.textPrimary.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(
                  MingCuteIcons.mgc_radar_2_line,
                  color: colors.accent,
                  size: 22,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSeed ? 'ПРОДОЛЖИМ / 01' : 'ВАША ВОЛНА / 01',
                    style: TextStyle(
                      color: colors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.65,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 235,
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 24,
                        height: 1.05,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 240,
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.25,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accent,
                      foregroundColor: colors.background,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                    ),
                    onPressed: hasSeed
                        ? () =>
                            ref.read(queueProvider.notifier).startWave(seed!)
                        : onOpenSearch,
                    icon: Icon(
                      hasSeed
                          ? MingCuteIcons.mgc_play_fill
                          : MingCuteIcons.mgc_search_line,
                      size: 17,
                    ),
                    label: Text(hasSeed ? 'Продолжить волну' : 'Выбрать трек'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveBackdrop extends StatelessWidget {
  final HookTheme theme;
  final String? artworkUrl;

  const _WaveBackdrop({required this.theme, required this.artworkUrl});

  @override
  Widget build(BuildContext context) {
    final url = artworkUrl ?? '';
    if (url.isEmpty) return _WaveFallback(theme: theme);

    return Image.network(
      TrackArtwork.getHighResUrl(url),
      fit: BoxFit.cover,
      opacity: const AlwaysStoppedAnimation(0.5),
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _WaveFallback(theme: theme),
    );
  }
}

class _WaveFallback extends StatelessWidget {
  final HookTheme theme;

  const _WaveFallback({required this.theme});

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    const heights = [34.0, 62.0, 92.0, 54.0, 112.0, 72.0, 42.0, 84.0, 56.0];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.8, -0.25),
          radius: 1.1,
          colors: [
            colors.primary.withValues(alpha: 0.42),
            colors.surface,
          ],
        ),
      ),
      child: Align(
        alignment: const Alignment(0.72, -0.12),
        child: Transform.rotate(
          angle: -0.14,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var index = 0; index < heights.length; index++)
                Container(
                  width: 7,
                  height: heights[index],
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index.isEven
                        ? colors.accent.withValues(alpha: 0.9)
                        : colors.textPrimary.withValues(alpha: 0.42),
                    boxShadow: [
                      BoxShadow(
                        color: colors.accent.withValues(alpha: 0.2),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String detail;

  const _SectionHeading({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 22,
              letterSpacing: -0.7,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.54),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSignalCard extends StatelessWidget {
  final HookTheme theme;
  final MediaTrack track;
  final int index;
  final VoidCallback onTap;

  const _RecentSignalCard({
    required this.theme,
    required this.track,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return SizedBox(
      width: 132,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    TrackArtwork(
                      url: track.artworkUrl,
                      size: 132,
                      borderRadius: BorderRadius.circular(18),
                      placeholderColor: colors.surface,
                      iconColor: colors.textSecondary,
                    ),
                    Positioned(
                      left: 9,
                      top: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.background.withValues(alpha: 0.72),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${index + 1}'.padLeft(2, '0'),
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SavedTrackRow extends StatelessWidget {
  final HookTheme theme;
  final MediaTrack track;
  final int index;
  final VoidCallback onTap;

  const _SavedTrackRow({
    required this.theme,
    required this.track,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            children: [
              Text(
                '${index + 1}'.padLeft(2, '0'),
                style: TextStyle(
                  color: colors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 12),
              TrackArtwork(
                url: track.artworkUrl,
                size: 48,
                borderRadius: BorderRadius.circular(13),
                placeholderColor: colors.surface,
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
              Icon(
                MingCuteIcons.mgc_play_fill,
                size: 19,
                color: colors.textSecondary.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionPrompt extends StatelessWidget {
  final HookTheme theme;
  final VoidCallback onOpenSearch;

  const _CollectionPrompt({required this.theme, required this.onOpenSearch});

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            MingCuteIcons.mgc_bookmark_line,
            size: 30,
            color: colors.accent,
          ),
          const SizedBox(height: 16),
          Text(
            'Оставьте здесь первый след',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.45,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Добавляйте любимые треки — и ваша волна станет точнее.',
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: onOpenSearch,
            icon: const Icon(MingCuteIcons.mgc_search_2_line, size: 18),
            label: const Text('Открыть поиск'),
          ),
        ],
      ),
    );
  }
}
