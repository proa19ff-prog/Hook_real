import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../lyrics/presentation/karaoke_lyrics_view.dart';
import '../../lyrics/presentation/lyrics_mode_selector.dart';
import '../../settings/presentation/settings_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'lyrics_focus_frame.dart';
import 'playback_controls.dart';
import 'player_state_provider.dart';
import 'spotify_track_tile.dart';
import 'swipe_track_transition.dart';
import 'track_downloads_provider.dart';

class FullscreenPlayer extends ConsumerStatefulWidget {
  final HookTheme theme;
  const FullscreenPlayer({super.key, required this.theme, this.initialLyrics = false});

  /// Opens straight into the lyrics panel, used by the "lyrics" button on the
  /// desktop player bar.
  final bool initialLyrics;

  @override
  ConsumerState<FullscreenPlayer> createState() => _FullscreenPlayerState();
}

class _FullscreenPlayerState extends ConsumerState<FullscreenPlayer> {
  late bool _showLyrics = widget.initialLyrics;
  bool _isChangingTrack = false;
  bool _randomBusy = false;
  final Set<String> _recentRandomKeys = <String>{};
  String? _refreshedDownloadKey;
  final _trackTransitionKey = GlobalKey<SwipeTrackTransitionState>();

  String _trackKey(MediaTrack? track) =>
      track == null ? 'empty' : '${track.source.name}:${track.id}';

  /// Rolls the dice over the listener's personalized pool and starts a wave
  /// from the winner, so the music keeps flowing after the picked track.
  Future<void> _playRandomPick() async {
    if (_randomBusy) return;
    setState(() => _randomBusy = true);
    try {
      final pool = await ref
          .read(recommendationServiceProvider)
          .getPersonalizedRecommendations(limit: 40)
          .timeout(const Duration(seconds: 20));
      final track = pickRandomTrack(
        pool,
        current: ref.read(currentTrackProvider),
        avoidKeys: _recentRandomKeys,
      );
      if (track == null || !mounted) return;
      final key = '${track.source.name}:${track.id}';
      if (_recentRandomKeys.length >= 6) {
        _recentRandomKeys.remove(_recentRandomKeys.first);
      }
      _recentRandomKeys.add(key);
      await ref.read(queueProvider.notifier).startWave(track);
    } catch (_) {
      // The profile is unreachable right now; the player stays as it was.
    } finally {
      if (mounted) setState(() => _randomBusy = false);
    }
  }

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
                        icon: const Icon(HookIcons.close),
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
                          // The wave grows asynchronously: while the playing
                          // track is the last one, the next batch is still
                          // being fetched — say so instead of looking broken.
                          itemCount:
                              queue.length + (player.waveActive ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= queue.length) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colors.accent,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      strings.waveLoading,
                                      style: TextStyle(
                                        color: colors.textSecondary,
                                        fontSize: HookType.bodySmall,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return SpotifyTrackTile(
                              theme: widget.theme,
                              track: queue[index],
                              isCurrent: index == player.currentIndex,
                              onTap: () {
                                ref
                                    .read(queueProvider.notifier)
                                    .playAt(index);
                                Navigator.of(sheetContext).pop();
                              },
                            );
                          },
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

    // Keep the header badge honest when the app comes back or the track
    // changes: one disk check per newly opened track, never while downloading.
    final trackKey = _trackKey(track);
    if (track != null && _refreshedDownloadKey != trackKey) {
      _refreshedDownloadKey = trackKey;
      Future.microtask(
        () => ref.read(trackDownloadsProvider.notifier).refresh(track),
      );
    }
    final dlState = track == null
        ? null
        : ref.watch(
            trackDownloadsProvider.select(
              (downloads) => downloads[TrackDownloadsNotifier.keyOf(track)],
            ),
          );
    final isDownloading =
        dlState?.status == TrackDownloadStatus.downloading;
    final isDownloaded = dlState?.status == TrackDownloadStatus.downloaded;
    final isFailed = dlState?.status == TrackDownloadStatus.failed;
    // Announce the outcome once per state change, outside the sheet.
    ref.listen(
      trackDownloadsProvider.select(
        (downloads) =>
            track == null ? null : downloads[TrackDownloadsNotifier.keyOf(track)]?.status,
      ),
      (previous, next) {
        if (track == null || !context.mounted) return;
        if (next == TrackDownloadStatus.downloaded &&
            previous != TrackDownloadStatus.downloaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.downloadSavedOffline),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (next == TrackDownloadStatus.failed &&
            previous != TrackDownloadStatus.failed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(strings.downloadFailed),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );

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
                    // A phone-width column centred in a desktop window; the
                    // artwork and the lyrics line stay in one readable column.
                    constraints: const BoxConstraints(
                      maxWidth: HookBreakpoints.readingMax,
                    ),
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
                                  HookIcons.collapse,
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
                                        fontSize: HookType.heading,
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
                                        fontSize: HookType.label,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                tooltip: isDownloaded
                                    ? strings.removeDownload
                                    : strings.download,
                                onPressed: track == null || isDownloading
                                    ? null
                                    : () {
                                        final notifier = ref.read(
                                          trackDownloadsProvider.notifier,
                                        );
                                        if (isDownloaded) {
                                          notifier.remove(track);
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                strings.trackRemovedFromCache,
                                              ),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        } else {
                                          notifier.download(track);
                                        }
                                      },
                                icon: isDownloading
                                    ? SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: text,
                                        ),
                                      )
                                    : Icon(
                                        isDownloaded
                                            ? HookIcons.downloadDone
                                            : HookIcons.download,
                                        color: isDownloaded
                                            ? colors.primary
                                            : isFailed
                                            ? colors.danger
                                            : text,
                                      ),
                              ),
                              // The header used to carry five icons and the
                              // eye could not tell queue from shuffle from
                              // download. Two verbs stay visible — download
                              // and everything-else — and the third opens a
                              // named menu instead of another glyph.
                              PopupMenuButton<String>(
                                tooltip: strings.moreActions,
                                icon: Icon(HookIcons.moreVertical, color: text),
                                onSelected: (value) {
                                  if (value == 'queue') _showQueueSheet();
                                  if (value == 'random') _playRandomPick();
                                },
                                itemBuilder: (menuContext) => [
                                  PopupMenuItem(
                                    value: 'queue',
                                    child: Row(
                                      children: [
                                        Icon(
                                          HookIcons.queue,
                                          size: 18,
                                          color: colors.textSecondary,
                                        ),
                                        const SizedBox(width: HookSpace.md),
                                        Text(strings.queue),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'random',
                                    enabled: !_randomBusy,
                                    child: Row(
                                      children: [
                                        Icon(
                                          HookIcons.dice,
                                          size: 18,
                                          color: colors.textSecondary,
                                        ),
                                        const SizedBox(width: HookSpace.md),
                                        Text(strings.randomPick),
                                      ],
                                    ),
                                  ),
                                ],
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
                                          fontSize: HookType.heading,
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
                                        fontSize: HookType.body,
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
                                    : () {
                                        HookHaptics.tap();
                                        ref
                                            .read(favoritesProvider.notifier)
                                            .toggleFavorite(track);
                                      },
                                icon: Icon(
                                  isFavorite
                                      ? HookIcons.heartFilled
                                      : HookIcons.heart,
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
                                      ? HookIcons.disc
                                      : HookIcons.lyrics,
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
                                  HookIcons.waveform,
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
                        icon: const Icon(HookIcons.collapse),
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
