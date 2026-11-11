import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/audio_cache_manager.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_skeleton.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../import/presentation/import_bottom_sheet.dart';
import '../../stats/stats_screen.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/playlist_artwork.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../../youtube_account/presentation/youtube_account_screen.dart';
import 'library_provider.dart';
import 'playlist_detail_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final HookTheme theme;

  const LibraryScreen({super.key, required this.theme});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Resolved once per screen: the directory does not move while the app runs,
  /// and asking the filesystem on every rebuild would make the tab flicker.
  Future<String>? _cachePathFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);
    final history = ref.watch(historyProvider);
    final queueNotifier = ref.read(queueProvider.notifier);
    final currentTrack = ref.watch(currentTrackProvider);
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.library,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.7,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.localCollection,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: HookType.bodySmall,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const ValueKey('library-stats'),
                    tooltip: strings.statsTitle,
                    icon: Icon(
                      HookIcons.stats,
                      color: colors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StatsScreen(theme: widget.theme),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('library-youtube-account'),
                    tooltip: strings.youtubeAccount,
                    icon: Icon(
                      HookIcons.accountCircle,
                      color: colors.textSecondary,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            YouTubeAccountScreen(theme: widget.theme),
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('library-import'),
                    tooltip: strings.importMusic,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: Icon(
                      HookIcons.download,
                      color: colors.textPrimary,
                    ),
                    onPressed: () =>
                        ImportBottomSheet.show(context, widget.theme),
                  ),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorColor: colors.textPrimary,
                indicatorWeight: 2,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: colors.textPrimary,
                unselectedLabelColor: colors.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: HookType.body,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: HookType.body,
                ),
                dividerColor: colors.border.withValues(alpha: 0.2),
                tabs: [
                  Tab(text: strings.favorites),
                  Tab(text: strings.playlists),
                  Tab(text: strings.history),
                  Tab(text: strings.offline),
                ],
              ),
            ),

            // Tab contents
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // 1. Favorites Tab
                  _buildTrackList(
                    tracks: favorites,
                    emptyMessage: strings.favoritesEmpty,
                    emptyIcon: HookIcons.heart,
                    onPlayAll: favorites.isNotEmpty
                        ? () => queueNotifier.playQueue(favorites)
                        : null,
                    onShuffle: favorites.isNotEmpty
                        ? () {
                            final shuffled = List<MediaTrack>.from(favorites)
                              ..shuffle();
                            queueNotifier.playQueue(shuffled);
                          }
                        : null,
                    currentTrackId: currentTrack?.id,
                    currentTrackSource: currentTrack?.source,
                  ),

                  // 2. Playlists Tab
                  _buildPlaylistsTab(),

                  // 3. History Tab
                  _buildTrackList(
                    tracks: history,
                    emptyMessage: strings.historyEmpty,
                    emptyIcon: HookIcons.history,
                    onPlayAll: history.isNotEmpty
                        ? () => queueNotifier.playQueue(history)
                        : null,
                    trailingHeaderAction: history.isNotEmpty
                        ? TextButton.icon(
                            icon: const Icon(
                              HookIcons.deleteForever,
                              size: 16,
                            ),
                            label: Text(strings.clear),
                            style: TextButton.styleFrom(
                              minimumSize: const Size(48, 48),
                              foregroundColor: colors.textSecondary,
                            ),
                            onPressed: () =>
                                ref.read(historyProvider.notifier).clear(),
                          )
                        : null,
                    currentTrackId: currentTrack?.id,
                    currentTrackSource: currentTrack?.source,
                  ),

                  // 4. Offline Cache Tab
                  _buildCacheTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final playlists = ref.watch(playlistsProvider);
    final queueNotifier = ref.read(queueProvider.notifier);
    // Imported playlists ship without covers; resolve them in the background
    // (idempotent inside the notifier, so rebuilds are cheap). The catalog
    // goes first; SoundCloud and the resolver server cover it when Apple is
    // unreachable.
    Future.microtask(() {
      if (!mounted) return;
      ref
          .read(playlistsProvider.notifier)
          .backfillArtwork(
            catalog: ref.read(playlistArtworkCatalogProvider),
            artworkFallback: (query) => ref
                .read(streamResolverProvider)
                .search(query: query, sources: {
                  TrackSource.soundcloud,
                  TrackSource.remote,
                }),
          );
    });

    if (playlists.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          children: [
            Icon(
              HookIcons.playlist,
              size: 40,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              strings.noPlaylists,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              strings.importPlaylistHint,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: HookType.body,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(HookIcons.download, size: 20),
              label: Text(strings.importMusicAction),
              style: FilledButton.styleFrom(
                backgroundColor: colors.textPrimary,
                foregroundColor: colors.background,
                minimumSize: const Size(48, 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
              ),
              onPressed: () => ImportBottomSheet.show(context, widget.theme),
            ),
          ],
        ),
      );
    }

    final entries = playlists.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final name = entry.key;
        final tracks = entry.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: PlaylistArtwork(
                urls: tracks.map((track) => track.artworkUrl),
                size: 50,
                borderRadius: BorderRadius.circular(10),
                placeholderColor: colors.surface,
                iconColor: colors.textSecondary,
              ),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: HookType.body,
                ),
              ),
              subtitle: Text(
                strings.tracksCount(tracks.length),
                style: TextStyle(color: colors.textSecondary, fontSize: HookType.label),
              ),
              trailing: PopupMenuButton<String>(
                tooltip: strings.playlistActions,
                icon: Icon(
                  HookIcons.more,
                  color: colors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'play') queueNotifier.playQueue(tracks);
                  if (value == 'delete') {
                    ref.read(playlistsProvider.notifier).deletePlaylist(name);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'play',
                    enabled: tracks.isNotEmpty,
                    child: Text(strings.playPlaylist),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      strings.deletePlaylist,
                      style: TextStyle(color: widget.theme.colors.danger),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PlaylistDetailScreen(
                      theme: widget.theme,
                      name: name,
                      tracks: tracks,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackList({
    required List<MediaTrack> tracks,
    required String emptyMessage,
    required IconData emptyIcon,
    VoidCallback? onPlayAll,
    VoidCallback? onShuffle,
    Widget? trailingHeaderAction,
    String? currentTrackId,
    TrackSource? currentTrackSource,
  }) {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);

    if (tracks.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          children: [
            Icon(emptyIcon, size: 40, color: colors.textSecondary),
            const SizedBox(height: 20),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: HookType.body,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (onPlayAll != null)
                  FilledButton.icon(
                    icon: const Icon(HookIcons.play, size: 20),
                    label: Text(strings.playAll),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.textPrimary,
                      foregroundColor: colors.background,
                      minimumSize: const Size(48, 48),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: onPlayAll,
                  ),
                if (onShuffle != null)
                  IconButton.outlined(
                    tooltip: strings.shuffle,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: const Icon(
                      HookIcons.shuffle,
                      size: 22,
                    ),
                    color: colors.textPrimary,
                    onPressed: onShuffle,
                  ),
                if (trailingHeaderAction != null) trailingHeaderAction,
              ],
            ),
          ),
        ),

        // Track List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 24, left: 12, right: 12),
            itemCount: tracks.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: colors.border.withValues(alpha: 0.15),
            ),
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isCurrent =
                  track.id == currentTrackId &&
                  track.source == currentTrackSource;

              return SpotifyTrackTile(
                theme: widget.theme,
                track: track,
                isCurrent: isCurrent,
                onTap: () {
                  ref
                      .read(queueProvider.notifier)
                      .playQueue(tracks, startIndex: index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCacheTab() {
    final cacheManager = ref.watch(audioCacheManagerProvider);
    final colors = widget.theme.colors;
    final danger = colors.danger;
    final strings = AppLocalizations.of(context);

    return FutureBuilder<List<CachedTrack>>(
      future: cacheManager.getCachedTracks(),
      builder: (context, snapshot) {
        final cachedTracks = snapshot.data ?? const <CachedTrack>[];
        final bytes = cachedTracks.fold<int>(
          0,
          (total, cachedTrack) => total + cachedTrack.sizeBytes,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Cache Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(
                    widget.theme.styling.borderRadius,
                  ),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.4),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      HookIcons.download,
                      size: 32,
                      color: colors.textSecondary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.localAudioCache,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      strings.cacheDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: HookType.bodySmall,
                        color: colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        strings.deviceUsage(_formatBytes(bytes)),
                        style: TextStyle(
                          fontSize: HookType.bodySmall,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(HookIcons.delete, size: 18),
                      label: Text(strings.clearCache),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        elevation: 0,
                        backgroundColor: danger.withValues(alpha: 0.15),
                        foregroundColor: danger,
                        side: BorderSide(color: danger),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: bytes > 0
                          ? () => _confirmClearCache(cacheManager)
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.savedTracksUpper(cachedTracks.length),
                style: TextStyle(
                  fontSize: HookType.label,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                SkeletonTrackList(count: 3, label: strings.loading)
              else if (cachedTracks.isEmpty)
                _buildEmptyCacheList()
              else
                ...cachedTracks.map(
                  (cachedTrack) =>
                      _buildCachedTrackTile(cachedTrack, cacheManager),
                ),
              const SizedBox(height: HookSpace.xxl),
              Text(
                strings.cacheFeaturesUpper,
                style: TextStyle(
                  fontSize: HookType.caption,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: HookSpace.md),
              _buildStoragePanel(cacheManager),
              _buildFeatureTile(
                HookIcons.offline,
                strings.offlineFirst,
                strings.offlineFirstDescription,
              ),
              _buildFeatureTile(
                HookIcons.premium,
                strings.maximumBitrate,
                strings.maximumBitrateDescription,
              ),
              _buildFeatureTile(
                HookIcons.battery,
                strings.trafficAndBattery,
                strings.trafficAndBatteryDescription,
              ),
            ],
          ),
        );
      },
    );
  }

  /// The folder the files actually live in. The old copy here only advertised
  /// "offline first" and "maximum bitrate" with nothing a listener could act
  /// on; a path they can copy is worth more than three slogans.
  Widget _buildStoragePanel(AudioCacheManager cacheManager) {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: HookSpace.md),
      child: Material(
        color: colors.surface,
        borderRadius: HookRadius.mdAll,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            HookSpace.lg,
            HookSpace.md,
            HookSpace.sm,
            HookSpace.md,
          ),
          child: Row(
            children: [
              Icon(HookIcons.folder, size: 20, color: colors.textSecondary),
              const SizedBox(width: HookSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.cacheFolder,
                      style: TextStyle(
                        fontSize: HookType.bodySmall,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: HookSpace.hair),
                    FutureBuilder<String>(
                      future: _cachePathFuture ??= _resolveCachePath(
                        cacheManager,
                      ),
                      builder: (context, snapshot) {
                        // No resolvable directory (unsupported platform, fake
                        // in a widget test): say nothing rather than show a
                        // path that does not exist.
                        final path = snapshot.data;
                        if (path == null || path.isEmpty) {
                          return Text(
                            snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? strings.loading
                                : '',
                            style: TextStyle(
                              fontSize: HookType.label,
                              color: colors.textSecondary,
                            ),
                          );
                        }
                        return Text(
                          path,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: HookType.label,
                            color: colors.textSecondary,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: strings.copyPath,
                icon: Icon(HookIcons.copy, size: 18),
                color: colors.textSecondary,
                onPressed: () async {
                  final path = await _resolveCachePath(cacheManager);
                  if (path.isEmpty) return;
                  await Clipboard.setData(ClipboardData(text: path));
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(strings.pathCopied)));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Wraps the lookup so a platform without a cache directory (or a test
  /// double that does not implement it) degrades to "no path", not a red
  /// screen.
  Future<String> _resolveCachePath(AudioCacheManager cacheManager) async {
    try {
      return await cacheManager.getCacheDirectoryPath();
    } catch (_) {
      return '';
    }
  }

  Widget _buildEmptyCacheList() {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(widget.theme.styling.borderRadius),
        border: Border.all(color: colors.border.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            HookIcons.downloadFile,
            size: 36,
            color: colors.textSecondary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 8),
          Text(
            strings.cacheEmpty,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            strings.cachedTracksAppear,
            style: TextStyle(color: colors.textSecondary, fontSize: HookType.label),
          ),
        ],
      ),
    );
  }

  Widget _buildCachedTrackTile(
    CachedTrack cachedTrack,
    AudioCacheManager cacheManager,
  ) {
    final track = cachedTrack.track;
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: TrackArtwork(
            url: track.artworkUrl,
            size: 44,
            borderRadius: BorderRadius.circular(8),
            placeholderColor: colors.surface,
            iconColor: colors.textSecondary,
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${track.artist} · ${_formatBytes(cachedTrack.sizeBytes)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: colors.textSecondary, fontSize: HookType.label),
          ),
          trailing: IconButton(
            tooltip: strings.removeFromCache,
            icon: const Icon(HookIcons.delete),
            color: widget.theme.colors.danger.withValues(alpha: 0.8),
            onPressed: () =>
                _confirmRemoveCachedTrack(cacheManager, cachedTrack),
          ),
          onTap: () {
            ref.read(queueProvider.notifier).playTrack(track);
          },
        ),
      ),
    );
  }

  Future<void> _confirmRemoveCachedTrack(
    AudioCacheManager cacheManager,
    CachedTrack cachedTrack,
  ) async {
    final strings = AppLocalizations.of(context);
    final dialogColors = widget.theme.colors;
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.removeCachedTrackTitle),
        content: Text(strings.removeCachedTrackBody(cachedTrack.track.title)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: dialogColors.danger,
              foregroundColor: dialogColors.onDanger,
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );

    if (shouldRemove != true || !mounted) return;

    await cacheManager.removeCachedTrack(cachedTrack.cacheKey);
    if (!mounted) return;
    ref.invalidate(cacheSizeProvider);
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(strings.trackRemovedFromCache)));
  }

  Future<void> _confirmClearCache(AudioCacheManager cacheManager) async {
    final strings = AppLocalizations.of(context);
    final dialogColors = widget.theme.colors;
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.clearCacheTitle),
        content: Text(strings.clearCacheBody),
        actions: [
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: dialogColors.danger,
              foregroundColor: dialogColors.onDanger,
            ),
            child: Text(strings.delete),
          ),
        ],
      ),
    );

    if (shouldClear != true || !mounted) return;

    await cacheManager.clearAllCache();
    if (!mounted) return;
    ref.invalidate(cacheSizeProvider);
    setState(() {});
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(strings.cacheCleared)));
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    final colors = widget.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 20, color: colors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: HookType.bodySmall,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: HookType.label,
                    color: colors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
