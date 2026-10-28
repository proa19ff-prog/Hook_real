import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/audio_cache_manager.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/models/media_track.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'МЕДИАТЕКА',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: widget.theme.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Локальная коллекция и кэш',
                        style: TextStyle(
                          fontSize: 12,
                          color: widget.theme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  cacheSizeAsync.when(
                    data: (bytes) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.theme.colors.surfaceGlass,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.theme.colors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.sd_storage_rounded,
                              size: 14, color: widget.theme.colors.accent),
                          const SizedBox(width: 4),
                          Text(
                            _formatBytes(bytes),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: widget.theme.colors.textPrimary,
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
            ),

            // Tab bar
            TabBar(
              controller: _tabController,
              indicatorColor: widget.theme.colors.primary,
              indicatorWeight: 3,
              labelColor: widget.theme.colors.primary,
              unselectedLabelColor: widget.theme.colors.textSecondary,
              tabs: const [
                Tab(text: 'Избранное'),
                Tab(text: 'История'),
                Tab(text: 'Офлайн-кэш'),
              ],
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
                        'В избранном пока пусто.\nНажмите ❤️ на треке, чтобы добавить.',
                    emptyIcon: Icons.favorite_border_rounded,
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

                  // 2. History Tab
                  _buildTrackList(
                    tracks: history,
                    emptyMessage:
                        'История прослушиваний пуста.\nВключайте любимые треки в поиске!',
                    emptyIcon: Icons.history_rounded,
                    onPlayAll: history.isNotEmpty
                        ? () => queueNotifier.playQueue(history)
                        : null,
                    trailingHeaderAction: history.isNotEmpty
                        ? TextButton.icon(
                            icon: const Icon(Icons.delete_sweep_rounded,
                                size: 16),
                            label: const Text('Очистить'),
                            onPressed: () =>
                                ref.read(historyProvider.notifier).clear(),
                          )
                        : null,
                    currentTrackId: currentTrack?.id,
                    currentTrackSource: currentTrack?.source,
                  ),

                  // 3. Offline Cache Tab
                  _buildCacheTab(),
                ],
              ),
            ),
          ],
        ),
      ),
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
    if (tracks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon,
                size: 64,
                color:
                    widget.theme.colors.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.theme.colors.textSecondary,
                fontSize: 14,
                height: 1.4,
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
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              if (onPlayAll != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: const Text('Слушать всё'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.theme.colors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: onPlayAll,
                ),
              const SizedBox(width: 8),
              if (onShuffle != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.shuffle_rounded, size: 16),
                  label: const Text('Перемешать'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.theme.colors.textPrimary,
                    side: BorderSide(color: widget.theme.colors.border),
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

        // List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            itemCount: tracks.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: widget.theme.colors.border.withValues(alpha: 0.3),
            ),
            itemBuilder: (context, index) {
              final track = tracks[index];
              final isCurrent = track.id == currentTrackId &&
                  track.source == currentTrackSource;

              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: TrackArtwork(
                  url: track.artworkUrl,
                  size: 48,
                  placeholderColor: widget.theme.colors.surface,
                  iconColor: widget.theme.colors.textSecondary,
                ),
                title: Text(
                  track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    color: isCurrent
                        ? widget.theme.colors.accent
                        : widget.theme.colors.textPrimary,
                    fontSize: 14,
                  ),
                ),
                subtitle: Row(
                  children: [
                    Text(
                      track.source == TrackSource.youtube
                          ? 'YT Music'
                          : 'SoundCloud',
                      style: TextStyle(
                        fontSize: 10,
                        color: widget.theme.colors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        track.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: widget.theme.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(track.duration),
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.theme.colors.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        ref.watch(favoritesProvider).any((t) =>
                                t.id == track.id && t.source == track.source)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: ref.watch(favoritesProvider).any((t) =>
                                t.id == track.id && t.source == track.source)
                            ? Colors.redAccent
                            : widget.theme.colors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () {
                        ref
                            .read(favoritesProvider.notifier)
                            .toggleFavorite(track);
                      },
                    ),
                  ],
                ),
                onTap: () {
                  ref.read(queueProvider.notifier).playTrack(track);
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

    return FutureBuilder<List<CachedTrack>>(
      future: cacheManager.getCachedTracks(),
      builder: (context, snapshot) {
        final cachedTracks = snapshot.data ?? const <CachedTrack>[];
        final bytes = cachedTracks.fold<int>(
          0,
          (total, cachedTrack) => total + cachedTrack.sizeBytes,
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.theme.colors.surfaceGlass,
                  borderRadius:
                      BorderRadius.circular(widget.theme.styling.borderRadius),
                  border: Border.all(color: widget.theme.colors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.download_done_rounded,
                        size: 48, color: widget.theme.colors.accent),
                    const SizedBox(height: 12),
                    Text(
                      'Локальный аудио-кэш',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.theme.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Прослушанные треки автоматически сохраняются в локальное хранилище для мгновенного повторного воспроизведения без интернета.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: widget.theme.colors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.theme.colors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Занято на устройстве: ${_formatBytes(bytes)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: widget.theme.colors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Очистить весь кэш'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.redAccent.withValues(alpha: 0.15),
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(color: Colors.redAccent),
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
                'СОХРАНЁННЫЕ ТРЕКИ:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: widget.theme.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator())
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
                  color: widget.theme.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              _buildFeatureTile(
                Icons.wifi_off_rounded,
                'Полный Offline-First',
                'При повторном запуске аудио проигрывается напрямую из файловой системы устройства.',
              ),
              _buildFeatureTile(
                Icons.high_quality_rounded,
                'Максимальный битрейт',
                'Кэшируются чистые аудиопотоки Opus/M4A 160-256 kbps без перекодирования.',
              ),
              _buildFeatureTile(
                Icons.battery_charging_full_rounded,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: widget.theme.colors.surfaceGlass,
        borderRadius: BorderRadius.circular(widget.theme.styling.borderRadius),
        border: Border.all(color: widget.theme.colors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_download_outlined,
            size: 36,
            color: widget.theme.colors.textSecondary,
          ),
          const SizedBox(height: 8),
          Text(
            'Кэш пока пуст',
            style: TextStyle(
              color: widget.theme.colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Скачанные треки появятся здесь',
            style: TextStyle(
              color: widget.theme.colors.textSecondary,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.colors.surfaceGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: widget.theme.colors.border),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          leading: TrackArtwork(
            url: track.artworkUrl,
            size: 44,
            placeholderColor: widget.theme.colors.surface,
            iconColor: widget.theme.colors.textSecondary,
          ),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.theme.colors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            '${track.artist} · ${_formatBytes(cachedTrack.sizeBytes)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: widget.theme.colors.textSecondary,
              fontSize: 12,
            ),
          ),
          trailing: IconButton(
            tooltip: 'Удалить из кэша',
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: widget.theme.colors.primary),
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
                    color: widget.theme.colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.theme.colors.textSecondary,
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
