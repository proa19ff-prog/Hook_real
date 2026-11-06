import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../lyrics/presentation/karaoke_lyrics_view.dart';
import '../../lyrics/presentation/lyrics_mode_selector.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../../settings/presentation/settings_provider.dart';
import 'lyrics_focus_frame.dart';
import 'playback_controls.dart';
import 'player_state_provider.dart';
import 'spotify_track_tile.dart';
import 'swipe_track_transition.dart';

class FullscreenPlayer extends ConsumerStatefulWidget {
  final HookTheme theme;
  const FullscreenPlayer({super.key, required this.theme});

  @override
  ConsumerState<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends ConsumerState<FullscreenPlayer> {
  bool _showLyrics = false;
  bool _isChangingTrack = false;
  final _trackTransitionKey = GlobalKey<SwipeTrackTransitionState>();

  String _trackKey(MediaTrack? track) =>
      track == null ? 'empty' : '${track.source.name}:${track.id}';

  void _showQueueSheet() {
    final strings = AppLocalizations.of(context);
    final colors = widget.theme.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) {
          final player = ref.watch(audioPlayerServiceProvider);
          ref.watch(queueChangesProvider);
          final queue = player.trackQueue;
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.35,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, controller) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 8, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${strings.playbackQueue} · ${queue.length}',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: strings.close,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: queue.isEmpty
                      ? Center(
                          child: Text(
                            strings.queueEmpty,
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          controller: controller,
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.paddingOf(context).bottom + 16,
                          ),
                          itemCount: queue.length,
                          itemBuilder: (context, index) => SpotifyTrackTile(
                            theme: widget.theme,
                            track: queue[index],
                            isCurrent: index == player.currentIndex,
                            onTap: () {
                              ref.read(queueProvider.notifier).playAt(index);
                              Navigator.of(sheetContext).pop();
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final track = ref.watch(currentTrackProvider);
    final source = ref.watch(playbackSourceProvider);
    final player = ref.watch(audioPlayerServiceProvider);
    final autoHide = ref.watch(lyricsAutoHideProvider);
    final lyrics = _showLyrics
        ? ref.watch(trackLyricsProvider).valueOrNull
        : null;
    final colors = widget.theme.colors;
    final isFavorite =
        track != null &&
        ref
            .watch(favoritesProvider)
            .any((item) => item.id == track.id && item.source == track.source);
    final sourceLabel =
        source?.labelFor(strings) ??
        (track == null
            ? 'Hook'
            : track.source.isCatalog
            ? strings.selectingSource
            : track.source.labelFor(strings));

    return Scaffold(
      body: DynamicShaderBackground(
        theme: widget.theme,
        artworkUrl: track?.artworkUrl,
        child: SafeArea(
          child: LyricsFocusFrame(
            active:
                _showLyrics &&
                track != null &&
                lyrics != null &&
                !lyrics.isEmpty,
            enabled: autoHide,
            trackKey: _trackKey(track),
            builder: (context, hidden, restore) => Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final ambient = AmbientThemeScope.of(context);
                        final text = ambient?.textPrimary ?? colors.textPrimary;
                        final muted =
                            ambient?.textSecondary ?? colors.textSecondary;
                        final reduceMotion = MediaQuery.disableAnimationsOf(
                          context,
                        );
                        final header = Padding(
                          padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                          child: Row(
                            children: [
                              IconButton(
                                tooltip: strings.collapsePlayer,
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  MingCuteIcons.mgc_down_line,
                                  color: text,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      'Hook',
                                      style: TextStyle(
                                        color: text,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      sourceLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: strings.queue,
                                onPressed: _showQueueSheet,
                                icon: Icon(
                                  MingCuteIcons.mgc_playlist_line,
                                  color: text,
                                ),
                              ),
                            ],
                          ),
                        );
                        final stage = AnimatedSwitcher(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 260),
                          child: KeyedSubtree(
                            key: ValueKey(_showLyrics),
                            child: track == null
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Text(
                                        strings.openSearchFirstTrack,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: muted,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  )
                                : _showLyrics
                                ? KaraokeLyricsView(theme: widget.theme)
                                : LayoutBuilder(
                                    builder: (context, bounds) {
                                      final width = (bounds.maxWidth - 48)
                                          .clamp(0.0, 420.0);
                                      final size = (bounds.maxHeight - 16)
                                          .clamp(0.0, width);
                                      return Center(
                                        child: Hero(
                                          tag:
                                              'current_artwork_${_trackKey(track)}',
                                          child: TrackArtwork(
                                            url: track.artworkUrl,
                                            size: size,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            placeholderColor: colors.surface,
                                            iconColor: colors.textSecondary,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        );
                        final details = Padding(
                          padding: const EdgeInsets.fromLTRB(28, 16, 16, 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height:
                                          MediaQuery.textScalerOf(context)
                                              .scale(_showLyrics ? 18 : 24) *
                                          1.2 *
                                          (_showLyrics ? 1 : 2),
                                      child: Text(
                                        track?.title ?? strings.queueEmpty,
                                        maxLines: _showLyrics ? 1 : 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: text,
                                          fontSize: _showLyrics ? 18 : 24,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: -0.5,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      track?.artist ?? strings.findMusicStart,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: muted,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: isFavorite
                                    ? strings.removeFavorite
                                    : strings.addFavorite,
                                onPressed: track == null
                                    ? null
                                    : () => ref
                                          .read(favoritesProvider.notifier)
                                          .toggleFavorite(track),
                                icon: Icon(
                                  isFavorite
                                      ? MingCuteIcons.mgc_heart_fill
                                      : MingCuteIcons.mgc_heart_line,
                                  color: isFavorite ? colors.accent : muted,
                                ),
                              ),
                            ],
                          ),
                        );
                        final footer = Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              TextButton.icon(
                                key: const ValueKey('player-lyrics-toggle'),
                                onPressed: track == null
                                    ? null
                                    : () => setState(
                                        () => _showLyrics = !_showLyrics,
                                      ),
                                style: TextButton.styleFrom(
                                  foregroundColor: _showLyrics ? text : muted,
                                  backgroundColor: _showLyrics
                                      ? colors.surface
                                      : null,
                                  minimumSize: const Size(48, 48),
                                ),
                                icon: Icon(
                                  _showLyrics
                                      ? MingCuteIcons.mgc_disc_line
                                      : MingCuteIcons.mgc_subtitle_line,
                                  size: 20,
                                ),
                                label: Text(
                                  _showLyrics
                                      ? strings.cover
                                      : strings.karaokeLyrics,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: track == null || _isChangingTrack
                                    ? null
                                    : () async {
                                        setState(() => _isChangingTrack = true);
                                        try {
                                          await ref
                                              .read(queueProvider.notifier)
                                              .startWave(track);
                                        } finally {
                                          if (mounted) {
                                            setState(
                                              () => _isChangingTrack = false,
                                            );
                                          }
                                        }
                                      },
                                style: TextButton.styleFrom(
                                  foregroundColor: muted,
                                  minimumSize: const Size(48, 48),
                                ),
                                icon: const Icon(
                                  MingCuteIcons.mgc_sound_line_fill,
                                  size: 20,
                                ),
                                label: Text(strings.startWave),
                              ),
                            ],
                          ),
                        );
                        final scrollLayout =
                            constraints.maxHeight < 560 ||
                            MediaQuery.textScalerOf(context).scale(16) > 24;
                        final trackStage = AnimatedPadding(
                          duration: reduceMotion
                              ? Duration.zero
                              : const Duration(milliseconds: 320),
                          curve: Curves.easeInOutCubic,
                          padding: EdgeInsets.only(top: hidden ? 56 : 0),
                          child: stage,
                        );
                        final trackPanel = SwipeTrackTransition(
                          key: _trackTransitionKey,
                          trackKey: _trackKey(track),
                          queueIndex: player.currentIndex,
                          enabled: track != null,
                          onNext: player.next,
                          onPrevious: player.previousTrack,
                          child: Column(
                            mainAxisSize: scrollLayout
                                ? MainAxisSize.min
                                : MainAxisSize.max,
                            children: [
                              if (scrollLayout)
                                AnimatedContainer(
                                  duration: reduceMotion
                                      ? Duration.zero
                                      : const Duration(milliseconds: 320),
                                  curve: Curves.easeInOutCubic,
                                  height: _showLyrics
                                      ? hidden
                                            ? constraints.maxHeight
                                            : 360
                                      : 260,
                                  child: trackStage,
                                )
                              else
                                Expanded(child: trackStage),
                              LyricsChrome(
                                key: const ValueKey('player-details-chrome'),
                                hidden: hidden,
                                slideUp: false,
                                child: details,
                              ),
                            ],
                          ),
                        );
                        final controls = Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: PlaybackControls(
                            theme: widget.theme,
                            onNext: () => _trackTransitionKey.currentState
                                ?.navigate(TrackSwipeDirection.next),
                            onPrevious: () =>
                                _trackTransitionKey.currentState?.navigate(
                                  TrackSwipeDirection.previous,
                                  action: player.previous,
                                ),
                          ),
                        );
                        final topChrome = LyricsChrome(
                          key: const ValueKey('player-top-chrome'),
                          hidden: hidden,
                          slideUp: true,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              header,
                              if (_showLyrics)
                                LyricsModeButton(theme: widget.theme),
                            ],
                          ),
                        );
                        final bottomChrome = LyricsChrome(
                          key: const ValueKey('player-bottom-chrome'),
                          hidden: hidden,
                          slideUp: false,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [controls, footer],
                          ),
                        );
                        if (scrollLayout) {
                          return SingleChildScrollView(
                            child: Column(
                              children: [topChrome, trackPanel, bottomChrome],
                            ),
                          );
                        }
                        return Column(
                          children: [
                            topChrome,
                            Expanded(child: trackPanel),
                            bottomChrome,
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (hidden)
                  Positioned(
                    top: 8,
                    right: 12,
                    child: Material(
                      color: colors.surface,
                      shape: const CircleBorder(),
                      child: IconButton(
                        key: const ValueKey('player-restore-controls'),
                        tooltip: strings.showPlayerControls,
                        constraints: const BoxConstraints(
                          minWidth: 48,
                          minHeight: 48,
                        ),
                        color: colors.textPrimary,
                        icon: const Icon(Icons.unfold_more_rounded),
                        onPressed: restore,
                      ),
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
