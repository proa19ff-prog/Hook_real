import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/glass_card.dart';
import '../../theme_engine/presentation/track_artwork.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final HookTheme theme;

  const SearchScreen({
    super.key,
    required this.theme,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MediaTrack> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _searchError;
  String _activeSourceFilter = 'all'; // 'all', 'youtube', 'soundcloud'
  int _searchRequestId = 0;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty || _isLoading) return;

    final requestId = ++_searchRequestId;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _searchError = null;
    });

    final resolver = ref.read(streamResolverProvider);
    final includeYt =
        _activeSourceFilter == 'all' || _activeSourceFilter == 'youtube';
    final includeSc =
        _activeSourceFilter == 'all' || _activeSourceFilter == 'soundcloud';

    try {
      final results = await resolver.search(
        query: normalizedQuery,
        includeYouTube: includeYt,
        includeSoundCloud: includeSc,
      );

      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
          _searchError = null;
        });
      }
    } catch (e) {
      if (mounted && requestId == _searchRequestId) {
        setState(() {
          _isLoading = false;
          _searchError =
              'Не удалось выполнить поиск. Проверьте соединение и повторите попытку.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = ref.watch(currentTrackProvider);
    final queueNotifier = ref.read(queueProvider.notifier);
    final favoritesNotifier = ref.read(favoritesProvider.notifier);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Поиск музыки',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                      color: widget.theme.colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'YouTube Music · SoundCloud',
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.theme.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: HookGlassCard(
                theme: widget.theme,
                padding: EdgeInsets.zero,
                borderRadius: BorderRadius.circular(18),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: widget.theme.colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Поиск трека, альбома или артиста...',
                    hintStyle: TextStyle(
                      color: widget.theme.colors.textSecondary,
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: widget.theme.colors.textSecondary,
                    ),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            tooltip: 'Очистить',
                            icon: Icon(Icons.close_rounded,
                                color: widget.theme.colors.textSecondary),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchRequestId++;
                                _searchResults = [];
                                _hasSearched = false;
                                _searchError = null;
                              });
                            },
                          ),
                        IconButton(
                          tooltip: 'Найти',
                          icon: Icon(Icons.arrow_forward_rounded,
                              color: widget.theme.colors.primary),
                          onPressed: () =>
                              _performSearch(_searchController.text),
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onChanged: (_) => setState(() {}),
                  onSubmitted: _performSearch,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Все источники'),
                    const SizedBox(width: 8),
                    _buildFilterChip('youtube', 'YouTube Music'),
                    const SizedBox(width: 8),
                    _buildFilterChip('soundcloud', 'SoundCloud'),
                  ],
                ),
              ),
            ),

            // Results List / Loading / Empty
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchError != null
                      ? _buildSearchError()
                      : _searchResults.isEmpty
                          ? Center(
                              key: const ValueKey('search-empty'),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.music_note_rounded,
                                    size: 64,
                                    color: widget.theme.colors.textSecondary
                                        .withValues(alpha: 0.4),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _hasSearched
                                        ? 'Ничего не найдено'
                                        : 'Введите запрос для поиска музыки',
                                    style: TextStyle(
                                      color: widget.theme.colors.textSecondary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _hasSearched
                                        ? 'Попробуйте изменить запрос или источник'
                                        : 'Прямое клиентское извлечение потоков без сервера',
                                    style: TextStyle(
                                      color: widget.theme.colors.textSecondary
                                          .withValues(alpha: 0.6),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              key: const ValueKey('search-results'),
                              padding: const EdgeInsets.only(
                                  bottom: 120, left: 16, right: 16, top: 8),
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final track = _searchResults[index];
                                final isCurrent =
                                    currentTrack?.id == track.id &&
                                        currentTrack?.source == track.source;
                                final isFav = favorites.any((t) =>
                                    t.id == track.id &&
                                    t.source == track.source);

                                return Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      queueNotifier.playQueue(
                                        _searchResults,
                                        startIndex: index,
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        leading: TrackArtwork(
                                          url: track.artworkUrl,
                                          size: 48,
                                          placeholderColor:
                                              widget.theme.colors.surface,
                                          iconColor:
                                              widget.theme.colors.textSecondary,
                                        ),
                                        title: Text(
                                          track.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: isCurrent
                                                ? widget.theme.colors.accent
                                                : widget
                                                    .theme.colors.textPrimary,
                                            fontWeight: isCurrent
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1),
                                              decoration: BoxDecoration(
                                                color: track.source ==
                                                        TrackSource.youtube
                                                    ? Colors.red
                                                        .withValues(alpha: 0.15)
                                                    : Colors.orange.withValues(
                                                        alpha: 0.15),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                track.source ==
                                                        TrackSource.youtube
                                                    ? 'YT Music'
                                                    : 'SoundCloud',
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: track.source ==
                                                          TrackSource.youtube
                                                      ? Colors.redAccent
                                                      : Colors.orangeAccent,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                track.artist,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: widget.theme.colors
                                                      .textSecondary,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                isFav
                                                    ? Icons.favorite_rounded
                                                    : Icons
                                                        .favorite_border_rounded,
                                                color: isFav
                                                    ? Colors.redAccent
                                                    : widget.theme.colors
                                                        .textSecondary,
                                                size: 20,
                                              ),
                                              onPressed: () {
                                                favoritesNotifier
                                                    .toggleFavorite(track);
                                              },
                                            ),
                                            if (isCurrent)
                                              Icon(Icons.graphic_eq_rounded,
                                                  color: widget
                                                      .theme.colors.accent)
                                            else
                                              IconButton(
                                                icon: Icon(
                                                    Icons.playlist_add_rounded,
                                                    color: widget.theme.colors
                                                        .textSecondary,
                                                    size: 22),
                                                onPressed: () {
                                                  ref
                                                      .read(
                                                          audioPlayerServiceProvider)
                                                      .addToQueue(track);
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Добавлено в очередь: ${track.title}'),
                                                      duration: const Duration(
                                                          seconds: 1),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                        onTap: null,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _activeSourceFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: widget.theme.colors.primary,
      backgroundColor: widget.theme.colors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : widget.theme.colors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _activeSourceFilter = value);
          if (_searchController.text.isNotEmpty) {
            _performSearch(_searchController.text);
          }
        }
      },
    );
  }

  Widget _buildSearchError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 56,
              color: widget.theme.colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              _searchError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: widget.theme.colors.textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => _performSearch(_searchController.text),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
