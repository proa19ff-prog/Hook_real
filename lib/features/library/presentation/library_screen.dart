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

class LibraryScreen extends ConsumerStatefulWidget {
  final HookTheme theme;

  const LibraryScreen({
    super.key,
    required this.theme,
  });

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
    final cacheSizeAsync = ref.watch(cacheSizeProvider);
    final queueNotifier = ref.read(queueProvider.notifier);
    final currentTrack = ref.watch(currentTrackProvider);
    final colors = widget.theme.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'МЕДИАТЕКА',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Локальная коллекция и плейлисты',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Import Link Button
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            ImportBottomSheet.show(context, widget.theme),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(MingCuteIcons.mgc_link_2_line,
                                  size: 16, color: colors.accent),
                              const SizedBox(width: 4),
                              Text(
                                'Импорт',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      cacheSizeAsync.when(
                        data: (bytes) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colors.primary.withValues(alpha: 0.2),
                                colors.accent.withValues(alpha: 0.15),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(MingCuteIcons.mgc_storage_line,
                                  size: 14, color: colors.accent),
                              const SizedBox(width: 5),
                              Text(
                                _formatBytes(bytes),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TabBar(
                controller: _tabController,
                indicatorColor: colors.primary,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: colors.primary,
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
                tabs: const [
                  Tab(text: 'Избранное'),
                  Tab(text: 'Плейлисты'),
                  Tab(text: 'История'),
                  Tab(text: 'Офлайн'),
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
                    emptyMessage:
                        'В избранном пока пусто.\nНажмите ❤️ на треке, чтобы добавить его сюда.',
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
                    emptyMessage:
                        'История прослушиваний пуста.\nВключайте треки в поиске, чтобы они появились здесь!',
                    emptyIcon: MingCuteIcons.mgc_history_line,
                    onPlayAll: history.isNotEmpty
                        ? () => queueNotifier.playQueue(history)
                        : null,
                    trailingHeaderAction: history.isNotEmpty
                        ? TextButton.icon(
                            icon: const Icon(MingCuteIcons.mgc_delete_2_line,
                                size: 16),
                            label: const Text('Очистить'),
                            style: TextButton.styleFrom(
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
    final playlists = ref.watch(playlistsProvider);
    final queueNotifier = ref.read(queueProvider.notifier);

    if (playlists.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceGlass.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.25),
                  ),
                ),
                child: Icon(
                  MingCuteIcons.mgc_playlist_line,
                  size: 52,
                  color: colors.textSecondary.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'У вас пока нет плейлистов',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Импортируйте плейлист из Spotify или YouTube Music!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                icon: const Icon(MingCuteIcons.mgc_link_2_line, size: 18),
                label: const Text('Импортировать музыку'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => ImportBottomSheet.show(context, widget.theme),
              ),
            ],
          ),
        ),
      );
    }

    final entries = playlists.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final name = entry.key;
        final tracks = entry.value;
        final firstTrackArt = tracks.isNotEmpty ? tracks.first.artworkUrl : '';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: colors.surfaceGlass.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colors.border.withValues(alpha: 0.3),
            ),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
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
              '${tracks.length} треков',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 12,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Слушать плейлист',
                  icon: Icon(MingCuteIcons.mgc_play_circle_fill,
                      color: colors.primary, size: 32),
                  onPressed: () {
                    queueNotifier.playQueue(tracks);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Включен плейлист "$name" (${tracks.length} треков)'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                PopupMenuButton<String>(
                  icon: Icon(MingCuteIcons.mgc_more_2_line,
                      color: colors.textSecondary, size: 20),
                  onSelected: (val) {
                    if (val == 'delete') {
                      ref.read(playlistsProvider.notifier).deletePlaylist(name);
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(MingCuteIcons.mgc_delete_line,
                              color: Colors.redAccent, size: 20),
                          SizedBox(width: 8),
                          Text('Удалить плейлист',
                              style: TextStyle(color: Colors.redAccent)),
                        ],
                      ),
                    ),
                  ],
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

    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.surfaceGlass.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                emptyIcon,
                size: 52,
                color: colors.textSecondary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 16),
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
        // Action Buttons Row (Play All / Shuffle)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              if (onPlayAll != null)
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.accent],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colors.primary.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(MingCuteIcons.mgc_play_fill, size: 20),
                    label: const Text('Слушать всё'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: onPlayAll,
                  ),
                ),
              const SizedBox(width: 8),
              if (onShuffle != null)
                OutlinedButton.icon(
                  icon: Icon(MingCuteIcons.mgc_shuffle_2_line,
                      size: 16, color: colors.textPrimary),
                  label: const Text('Перемешать'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.textPrimary,
                    side:
                        BorderSide(color: colors.border.withValues(alpha: 0.5)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onShuffle,
                ),
              const Spacer(),
              if (trailingHeaderAction != null) trailingHeaderAction,
            ],
          ),
        ),

        // Track List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 160, left: 12, right: 12),
            itemCount: tracks.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: colors.border.withValues(alpha: 0.15),
            ),
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isCurrent = track.id == currentTrackId &&
                  track.source == currentTrackSource;

              return SpotifyTrackTile(
                theme: widget.theme,
                track: track,
                isCurrent: isCurrent,
                onTap: () {
                  ref.read(queueProvider.notifier).playQueue(
                        tracks,
                        startIndex: index,
                      );
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

    return FutureBuilder<List<CachedTrack>>(
      future: cacheManager.getCachedTracks(),
      builder: (context, snapshot) {
        final cachedTracks = snapshot.data ?? const <CachedTrack>[];
        final bytes = cachedTracks.fold<int>(
          0,
          (total, cachedTrack) => total + cachedTrack.sizeBytes,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 160),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Main Cache Info Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.surfaceGlass.withValues(alpha: 0.4),
                  borderRadius:
                      BorderRadius.circular(widget.theme.styling.borderRadius),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors.primary.withValues(alpha: 0.2),
                            colors.accent.withValues(alpha: 0.2),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(MingCuteIcons.mgc_download_2_fill,
                          size: 40, color: colors.accent),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Локальный аудио-кэш',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Прослушанные треки автоматически сохраняются в локальное хранилище для мгновенного повторного воспроизведения без интернета.',
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
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        'Занято на устройстве: ${_formatBytes(bytes)}',
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
                      label: const Text('Очистить весь кэш'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent.withValues(alpha: 0.15),
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
                'СОХРАНЁННЫЕ ТРЕКИ (${cachedTracks.length}):',
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
                  (cachedTrack) => _buildCachedTrackTile(
                    cachedTrack,
                    cacheManager,
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'СВОЙСТВА КЭША:',
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
                'Полный Offline-First',
                'При повторном запуске аудио проигрывается напрямую из файловой системы устройства.',
              ),
              _buildFeatureTile(
                MingCuteIcons.mgc_diamond_line,
                'Максимальный битрейт',
                'Кэшируются чистые аудиопотоки Opus/M4A 160-256 kbps без перекодирования.',
              ),
              _buildFeatureTile(
                MingCuteIcons.mgc_battery_charging_line,
                'Экономия трафика и батареи',
                'Отсутствие повторных сетевых запросов продлевает время работы смартфона.',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyCacheList() {
    final colors = widget.theme.colors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: colors.surfaceGlass.withValues(alpha: 0.3),
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
            'Кэш пока пуст',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Скачанные треки появятся здесь автоматически',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceGlass.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border.withValues(alpha: 0.3)),
        ),
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
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            tooltip: 'Удалить из кэша',
            icon: const Icon(MingCuteIcons.mgc_delete_line),
            color: Colors.redAccent.withValues(alpha: 0.8),
            onPressed: () => _confirmRemoveCachedTrack(
              cacheManager,
              cachedTrack,
            ),
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
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить трек из кэша?'),
        content:
            Text('«${cachedTrack.track.title}» будет удалён с устройства.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (shouldRemove != true || !mounted) return;

    await cacheManager.removeCachedTrack(cachedTrack.cacheKey);
    if (!mounted) return;
    ref.invalidate(cacheSizeProvider);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Трек удалён из кэша')),
    );
  }

  Future<void> _confirmClearCache(AudioCacheManager cacheManager) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить кэш?'),
        content: const Text(
          'Все сохранённые аудиофайлы будут удалены с устройства. '
          'Избранное и история останутся без изменений.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (shouldClear != true || !mounted) return;

    await cacheManager.clearAllCache();
    if (!mounted) return;
    ref.invalidate(cacheSizeProvider);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Локальный кэш очищен')),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title, String subtitle) {
    final colors = widget.theme.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colors.primary),
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
