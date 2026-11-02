import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../../extractor/models/media_track.dart';
import '../../lyrics/presentation/karaoke_lyrics_view.dart';
import '../../lyrics/presentation/lyrics_mode_selector.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'playback_controls.dart';
import 'player_state_provider.dart';
import 'spotify_track_tile.dart';

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
  bool _isChangingTrack = false;
  double _horizontalDragDistance = 0;
  int _swipeDirection = -1;

  String _trackKey(MediaTrack? track) {
    if (track == null) return 'empty';
    return '${track.source.name}:${track.id}';
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _horizontalDragDistance = 0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _horizontalDragDistance += details.primaryDelta ?? 0;
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    if (_isChangingTrack) return;

    final velocity = details.primaryVelocity ?? 0;
    final movesToNext = _horizontalDragDistance < -56 || velocity < -520;
    final movesToPrevious = _horizontalDragDistance > 56 || velocity > 520;
    if (!movesToNext && !movesToPrevious) return;

    setState(() {
      _isChangingTrack = true;
      _swipeDirection = movesToNext ? -1 : 1;
    });

    final player = ref.read(audioPlayerServiceProvider);
    if (movesToNext) {
      await player.next();
    } else {
      await player.previousTrack();
    }

    if (mounted) {
      setState(() => _isChangingTrack = false);
    }
  }

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
        ref.watch(queueChangesProvider);
        final queue = playerService.trackQueue;
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
                          color:
                              widget.theme.colors.border.withValues(alpha: 0.2),
                        ),
                        itemBuilder: (context, i) {
                          final track = queue[i];
                          return SpotifyTrackTile(
                            theme: widget.theme,
                            track: track,
                            isCurrent: i == currentIndex,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            onTap: () {
                              ref.read(queueProvider.notifier).playAt(i);
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
    final source = ref.watch(playbackSourceProvider);
    final sourceLabel = source?.label ??
        (track == null
            ? 'HOOK'
            : track.source.isCatalog
                ? 'Подбор источника'
                : track.source.label);
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
            final textSecondary =
                ambient?.textSecondary ?? colors.textSecondary;
            final iconColor = ambient?.iconColor ?? colors.textPrimary;
            final cardBg = ambient?.cardBackground ??
                colors.surfaceGlass.withValues(alpha: 0.3);
            final cardBorder =
                ambient?.cardBorder ?? colors.border.withValues(alpha: 0.3);

            return SafeArea(
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                            tooltip: 'Свернуть плеер',
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        Expanded(
                            child: Column(children: [
                          Text('СЕЙЧАС ИГРАЕТ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 8,
                                  letterSpacing: 1.1)),
                          const SizedBox(height: 4),
                          Text(sourceLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ])),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Favorite toggle with AnimatedSwitcher
                            IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 38,
                                height: 48,
                              ),
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
                                  color:
                                      isFavorite ? Colors.redAccent : iconColor,
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
                              constraints: const BoxConstraints.tightFor(
                                width: 38,
                                height: 48,
                              ),
                              tooltip: 'Очередь',
                              icon: Icon(MingCuteIcons.mgc_playlist_line,
                                  color: iconColor, size: 22),
                              onPressed: () => _showQueueSheet(context),
                            ),
                            IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 38,
                                height: 48,
                              ),
                              tooltip: 'Запустить волну',
                              icon: Icon(
                                MingCuteIcons.mgc_sound_line_fill,
                                color: iconColor,
                                size: 22,
                              ),
                              onPressed: track == null
                                  ? null
                                  : () async {
                                      await ref
                                          .read(queueProvider.notifier)
                                          .startWave(track);
                                    },
                            ),
                            IconButton(
                              constraints: const BoxConstraints.tightFor(
                                width: 38,
                                height: 48,
                              ),
                              tooltip:
                                  _showLyrics ? 'Обложка' : 'Текст караоке',
                              icon: Icon(
                                _showLyrics
                                    ? MingCuteIcons.mgc_music_fill
                                    : MingCuteIcons.mgc_subtitle_line,
                                color: _showLyrics ? colors.accent : iconColor,
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

                  if (_showLyrics) LyricsModeButton(theme: widget.theme),
                  Expanded(
                    child: _buildSwipeableTrackStage(
                      track: track,
                      borderRadius: borderRadius,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),

                  // Playback Controls
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 24, left: 16, right: 16),
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

  Widget _buildSwipeableTrackStage({
    required MediaTrack? track,
    required double borderRadius,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final trackKey = _trackKey(track);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Column(
        children: [
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 340),
              reverseDuration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final isIncoming = child.key == ValueKey(trackKey);
                final offset = isIncoming
                    ? Offset(-_swipeDirection * 0.16, 0)
                    : Offset(_swipeDirection * 0.16, 0);
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: offset,
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey(trackKey),
                child: track == null
                    ? _buildEmptyPlayerState()
                    : _showLyrics
                        ? KaraokeLyricsView(theme: widget.theme)
                        : _buildArtwork(track, borderRadius),
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey('details:$trackKey');
              final offset = isIncoming
                  ? Offset(-_swipeDirection * 0.1, 0)
                  : Offset(_swipeDirection * 0.1, 0);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: offset,
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: KeyedSubtree(
              key: ValueKey('details:$trackKey'),
              child: _buildTrackDetails(track, textPrimary, textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(MediaTrack track, double borderRadius) {
    final colors = widget.theme.colors;
    return LayoutBuilder(builder: (context, constraints) {
      final available = (constraints.maxWidth - 64).clamp(0.0, 380.0);
      final size = (constraints.maxHeight - 24).clamp(0.0, available);
      return Center(
          child: Hero(
        tag: 'current_artwork_${_trackKey(track)}',
        child: TrackArtwork(
          url: track.artworkUrl,
          size: size,
          borderRadius: BorderRadius.circular(borderRadius.clamp(12, 20)),
          placeholderColor: colors.surface,
          iconColor: colors.textSecondary,
        ),
      ));
    });
  }

  Widget _buildTrackDetails(
    MediaTrack? track,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
      child: Column(
        children: [
          Text(
            track?.title ?? 'Очередь пуста',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: _showLyrics ? 19 : 25,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            track?.artist ?? 'Найдите музыку и начните воспроизведение',
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
