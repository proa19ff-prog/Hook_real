import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../../lyrics/presentation/karaoke_lyrics_view.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'playback_controls.dart';
import 'player_state_provider.dart';

class FullscreenPlayer extends ConsumerStatefulWidget {
  final HookTheme theme;

  const FullscreenPlayer({
    super.key,
    required this.theme,
  });

  @override
  ConsumerState<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends ConsumerState<FullscreenPlayer> {
  bool _showLyrics = false;

  void _showQueueSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.theme.colors.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(widget.theme.styling.borderRadius.clamp(20, 32)),
        ),
      ),
      builder: (ctx) {
        final playerService = ref.watch(audioPlayerServiceProvider);
        final queue = playerService.queue;
        final currentIndex = playerService.currentIndex;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Drag handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: widget.theme.colors.textSecondary
                            .withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            MingCuteIcons.mgc_playlist_line,
                            size: 20,
                            color: widget.theme.colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Очередь воспроизведения',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.colors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.theme.colors.primary
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${queue.length}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.theme.colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(
                          'Закрыть',
                          style: TextStyle(
                            color: widget.theme.colors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (queue.isEmpty)
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                MingCuteIcons.mgc_playlist_line,
                                size: 48,
                                color: widget.theme.colors.textSecondary
                                    .withValues(alpha: 0.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Очередь пуста',
                                style: TextStyle(
                                  color: widget.theme.colors.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: queue.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: widget.theme.colors.border
                              .withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, i) {
                          final track = queue[i];
                          final isCurrent = i == currentIndex;
                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            tileColor: isCurrent
                                ? widget.theme.colors.primary
                                    .withValues(alpha: 0.12)
                                : null,
                            leading: Stack(
                              children: [
                                TrackArtwork(
                                  url: track.artworkUrl,
                                  size: 44,
                                  borderRadius: BorderRadius.circular(10),
                                  placeholderColor: widget.theme.colors.surface,
                                  iconColor: widget.theme.colors.textSecondary,
                                ),
                                if (isCurrent)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.35),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          MingCuteIcons.mgc_sound_line_fill,
                                          size: 20,
                                          color: widget.theme.colors.accent,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              track.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: isCurrent
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isCurrent
                                    ? widget.theme.colors.accent
                                    : widget.theme.colors.textPrimary,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: widget.theme.colors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            trailing: isCurrent
                                ? Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: widget.theme.colors.accent
                                          .withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      MingCuteIcons.mgc_volume_line,
                                      size: 16,
                                      color: widget.theme.colors.accent,
                                    ),
                                  )
                                : null,
                            onTap: () {
                              playerService.playTrack(track);
                              Navigator.of(ctx).pop();
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    final isFavorite = track != null &&
        ref.watch(favoritesProvider).any(
              (favorite) =>
                  favorite.id == track.id && favorite.source == track.source,
            );

    final colors = widget.theme.colors;
    final borderRadius = widget.theme.styling.borderRadius;

    return Scaffold(
      body: DynamicShaderBackground(
        theme: widget.theme,
        artworkUrl: track?.artworkUrl,
        child: Builder(
          builder: (context) {
            final ambient = AmbientThemeScope.of(context);
            final textPrimary = ambient?.textPrimary ?? colors.textPrimary;
            final textSecondary = ambient?.textSecondary ?? colors.textSecondary;
            final iconColor = ambient?.iconColor ?? colors.textPrimary;
            final cardBg = ambient?.cardBackground ?? colors.surfaceGlass.withValues(alpha: 0.3);
            final cardBorder = ambient?.cardBorder ?? colors.border.withValues(alpha: 0.3);

            return SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: cardBorder,
                            ),
                          ),
                          child: IconButton(
                            icon: Icon(
                              MingCuteIcons.mgc_down_line,
                              color: iconColor,
                              size: 26,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        // Frosted pill badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: cardBorder,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'СЕЙЧАС ИГРАЕТ',
                                style: TextStyle(
                                  letterSpacing: 1.6,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            // Favorite toggle with AnimatedSwitcher
                            IconButton(
                              tooltip: isFavorite
                                  ? 'Убрать из избранного'
                                  : 'Добавить в избранное',
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: Icon(
                                  isFavorite
                                      ? MingCuteIcons.mgc_heart_fill
                                      : MingCuteIcons.mgc_heart_line,
                                  key: ValueKey(isFavorite),
                                  color: isFavorite
                                      ? Colors.redAccent
                                      : iconColor,
                                  size: 22,
                                ),
                              ),
                              onPressed: track == null
                                  ? null
                                  : () => ref
                                      .read(favoritesProvider.notifier)
                                      .toggleFavorite(track),
                            ),
                            IconButton(
                              tooltip: 'Очередь',
                              icon: Icon(MingCuteIcons.mgc_playlist_line,
                                  color: iconColor, size: 22),
                              onPressed: () => _showQueueSheet(context),
                            ),
                            IconButton(
                              tooltip: _showLyrics ? 'Обложка' : 'Текст караоке',
                              icon: Icon(
                                _showLyrics
                                    ? MingCuteIcons.mgc_music_fill
                                    : MingCuteIcons.mgc_subtitle_line,
                                color: _showLyrics
                                    ? colors.accent
                                    : iconColor,
                                size: 22,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showLyrics = !_showLyrics;
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Center: Album Art OR Lyrics View
                  Expanded(
                    child: track == null
                        ? _buildEmptyPlayerState()
                        : _showLyrics
                            ? KaraokeLyricsView(theme: widget.theme)
                            : Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0, vertical: 16.0),
                                  child: Hero(
                                    tag: 'current_artwork',
                                    child: Container(
                                      constraints: const BoxConstraints(
                                          maxHeight: 340, maxWidth: 340),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            (borderRadius * 1.2).clamp(18, 28)),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.12),
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.45),
                                            blurRadius: 36,
                                            spreadRadius: 2,
                                            offset: const Offset(0, 18),
                                          ),
                                          BoxShadow(
                                            color: colors.primary
                                                .withValues(alpha: 0.18),
                                            blurRadius: 44,
                                            spreadRadius: 0,
                                            offset: const Offset(0, 6),
                                          ),
                                        ],
                                        image: track.artworkUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  TrackArtwork.getHighResUrl(track.artworkUrl),
                                                ),
                                                fit: BoxFit.cover,
                                                filterQuality: FilterQuality.high,
                                              )
                                            : null,
                                        color: colors.surface,
                                      ),
                                      child: track.artworkUrl.isEmpty
                                          ? Icon(
                                              MingCuteIcons.mgc_music_fill,
                                              size: 96,
                                              color: colors.textSecondary
                                                  .withValues(alpha: 0.6),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                  ),

                  // Track Title & Artist
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                    child: Column(
                      children: [
                        Text(
                          track?.title ?? 'Очередь пуста',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          track?.artist ??
                              'Найдите музыку и начните воспроизведение',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Playback Controls
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                    child: PlaybackControls(theme: widget.theme),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyPlayerState() {
    final colors = widget.theme.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: colors.surfaceGlass.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                MingCuteIcons.mgc_headphone_line,
                size: 56,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Воспроизведение ещё не началось',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Откройте поиск, чтобы найти первый трек',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
