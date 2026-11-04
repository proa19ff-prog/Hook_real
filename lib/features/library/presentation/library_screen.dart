import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../core/storage/audio_cache_manager.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../import/presentation/import_bottom_sheet.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import 'playlist_detail_screen.dart';
import 'library_provider.dart';
import '../../../l10n/generated/app_localizations.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  final HookTheme theme;

  const LibraryScreen({super.key, required this.theme});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    key: const ValueKey('library-import'),
                    tooltip: strings.importMusic,
                    constraints: const BoxConstraints(
                      minWidth: 48,
                      minHeight: 48,
                    ),
                    icon: Icon(
                      MingCuteIcons.mgc_download_2_line,
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
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
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
                    emptyIcon: MingCuteIcons.mgc_heart_line,
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
                    emptyIcon: MingCuteIcons.mgc_history_line,
                    onPlayAll: history.isNotEmpty
                        ? () => queueNotifier.playQueue(history)
                        : null,
                    trailingHeaderAction: history.isNotEmpty
                        ? TextButton.icon(
                            icon: const Icon(
                              MingCuteIcons.mgc_delete_2_line,
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

    if (playlists.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
        child: Column(
          children: [
            Icon(
              MingCuteIcons.mgc_playlist_line,
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
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(MingCuteIcons.mgc_download_2_line, size: 20),
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
        final firstTrackArt = tracks.isNotEmpty ? tracks.first.artworkUrl : '';

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
              leading: TrackArtwork(
                url: firstTrackArt,
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
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                strings.tracksCount(tracks.length),
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
              trailing: PopupMenuButton<String>(
                tooltip: strings.playlistActions,
                icon: Icon(
                  MingCuteIcons.mgc_more_2_line,
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
                      style: const TextStyle(color: Colors.redAccent),
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
                fontSize: 14,
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
                    icon: const Icon(MingCuteIcons.mgc_play_fill, size: 20),
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
                      MingCuteIcons.mgc_shuffle_2_line,
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
                      MingCuteIcons.mgc_download_2_line,
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
                        fontSize: 13,
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
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(MingCuteIcons.mgc_delete_line, size: 18),
                      label: Text(strings.clearCache),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                        elevation: 0,
                        backgroundColor: Colors.redAccent.withValues(
                          alpha: 0.15,
                        ),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
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
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                Center(child: CircularProgressIndicator(color: colors.primary))
              else if (cachedTracks.isEmpty)
                _buildEmptyCacheList()
              else
                ...cachedTracks.map(
                  (cachedTrack) =>
                      _buildCachedTrackTile(cachedTrack, cacheManager),
                ),
              const SizedBox(height: 24),
              Text(
                strings.cacheFeaturesUpper,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                MingCuteIcons.mgc_wifi_off_line,
                strings.offlineFirst,
                strings.offlineFirstDescription,
              ),
              _buildFeatureTile(
                MingCuteIcons.mgc_diamond_line,
                strings.maximumBitrate,
                strings.maximumBitrateDescription,
              ),
              _buildFeatureTile(
                MingCuteIcons.mgc_battery_charging_line,
                strings.trafficAndBattery,
                strings.trafficAndBatteryDescription,
              ),
            ],
          ),
        );
      },
    );
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
            MingCuteIcons.mgc_file_download_line,
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
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
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
            style: TextStyle(color: colors.textSecondary, fontSize: 12),
          ),
          trailing: IconButton(
            tooltip: strings.removeFromCache,
            icon: const Icon(MingCuteIcons.mgc_delete_line),
            color: Colors.redAccent.withValues(alpha: 0.8),
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
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
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
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
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
