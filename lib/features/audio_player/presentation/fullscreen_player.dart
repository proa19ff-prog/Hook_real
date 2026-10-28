import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.theme.styling.borderRadius)),
      ),
      builder: (ctx) {
        final playerService = ref.watch(audioPlayerServiceProvider);
        final queue = playerService.queue;
        final currentIndex = playerService.currentIndex;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Очередь воспроизведения (${queue.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.theme.colors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Закрыть'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (queue.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Очередь пуста',
                      style:
                          TextStyle(color: widget.theme.colors.textSecondary),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: queue.length,
                    itemBuilder: (context, i) {
                      final track = queue[i];
                      final isCurrent = i == currentIndex;
                      return ListTile(
                        leading: TrackArtwork(
                          url: track.artworkUrl,
                          size: 40,
                          borderRadius: BorderRadius.circular(6),
                          placeholderColor: widget.theme.colors.surface,
                          iconColor: widget.theme.colors.textSecondary,
                        ),
                        title: Text(
                          track.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight:
                                isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent
                                ? widget.theme.colors.accent
                                : widget.theme.colors.textPrimary,
                          ),
                        ),
                        subtitle: Text(track.artist,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: isCurrent
                            ? Icon(Icons.volume_up_rounded,
                                color: widget.theme.colors.accent)
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
  }

  @override
  Widget build(BuildContext context) {
    final track = ref.watch(currentTrackProvider);
    final isFavorite = track != null &&
        ref.watch(favoritesProvider).any(
              (favorite) =>
                  favorite.id == track.id && favorite.source == track.source,
            );

    return Scaffold(
      body: DynamicShaderBackground(
        theme: widget.theme,
        artworkUrl: track?.artworkUrl,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down_rounded,
                          color: widget.theme.colors.textPrimary, size: 32),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Text(
                      'СЕЙЧАС ИГРАЕТ',
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colors.textSecondary,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          tooltip: isFavorite
                              ? 'Убрать из избранного'
                              : 'Добавить в избранное',
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: isFavorite
                                ? Colors.redAccent
                                : widget.theme.colors.textPrimary,
                          ),
                          onPressed: track == null
                              ? null
                              : () => ref
                                  .read(favoritesProvider.notifier)
                                  .toggleFavorite(track),
                        ),
                        IconButton(
                          tooltip: 'Очередь',
                          icon: Icon(Icons.queue_music_rounded,
                              color: widget.theme.colors.textPrimary),
                          onPressed: () => _showQueueSheet(context),
                        ),
                        IconButton(
                          tooltip: _showLyrics ? 'Обложка' : 'Текст караоке',
                          icon: Icon(
                            _showLyrics
                                ? Icons.music_note_rounded
                                : Icons.subtitles_rounded,
                            color: _showLyrics
                                ? widget.theme.colors.accent
                                : widget.theme.colors.textPrimary,
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
                              padding: const EdgeInsets.all(32.0),
                              child: Hero(
                                tag: 'current_artwork',
                                child: Container(
                                  constraints: const BoxConstraints(
                                      maxHeight: 340, maxWidth: 340),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        widget.theme.styling.borderRadius),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 30,
                                        spreadRadius: 4,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                    image: track.artworkUrl.isNotEmpty
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(track.artworkUrl),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                    color: widget.theme.colors.surface,
                                  ),
                                  child: track.artworkUrl.isEmpty
                                      ? Icon(
                                          Icons.music_note_rounded,
                                          size: 100,
                                          color:
                                              widget.theme.colors.textSecondary,
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
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                child: Column(
                  children: [
                    Text(
                      track?.title ?? 'Очередь пуста',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      track?.artist ??
                          'Найдите музыку и начните воспроизведение',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: widget.theme.colors.textSecondary,
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
        ),
      ),
    );
  }

  Widget _buildEmptyPlayerState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.queue_music_rounded,
              size: 72,
              color: widget.theme.colors.textSecondary.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 16),
            Text(
              'Воспроизведение ещё не началось',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.theme.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Откройте поиск, чтобы найти первый трек',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.theme.colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
