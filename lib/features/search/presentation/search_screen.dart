import 'dart:async';

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
  static const _debounce = Duration(milliseconds: 400);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<MediaTrack> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _searchError;
  String _lastQuery = '';
  // YouTube is the main source; searching one source also answers faster.
  String _activeSourceFilter = 'youtube'; // 'all', 'youtube', 'soundcloud'
  int _searchRequestId = 0;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      _clear(keepText: true);
      return;
    }
    _debounceTimer = Timer(_debounce, () => _performSearch(value));
  }

  void _clear({bool keepText = false}) {
    _debounceTimer?.cancel();
    if (!keepText) _searchController.clear();
    setState(() {
      _searchRequestId++;
      _searchResults = [];
      _hasSearched = false;
      _isLoading = false;
      _searchError = null;
      _lastQuery = '';
    });
  }

  Future<void> _performSearch(String query, {bool force = false}) async {
    _debounceTimer?.cancel();
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) return;
    if (!force && normalizedQuery == _lastQuery && _searchError == null) {
      return;
    }
    _lastQuery = normalizedQuery;

    // A newer request supersedes the one in flight instead of being dropped.
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
    final colors = widget.theme.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => _focusNode.unfocus(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Поиск',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: HookGlassCard(
                  theme: widget.theme,
                  borderRadius: BorderRadius.circular(16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(color: colors.textPrimary, fontSize: 15),
                    cursorColor: colors.primary,
                    decoration: InputDecoration(
                      hintText: 'Трек, артист или альбом',
                      hintStyle: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 15,
                      ),
                      prefixIcon:
                          Icon(Icons.search_rounded, color: colors.textSecondary),
                      // Only the clear button listens to the text, so typing
                      // does not rebuild the results list.
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) => value.text.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                tooltip: 'Очистить',
                                icon: Icon(Icons.close_rounded,
                                    color: colors.textSecondary),
                                onPressed: _clear,
                              ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: _onQueryChanged,
                    onSubmitted: (value) {
                      _performSearch(value);
                      _focusNode.unfocus();
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('youtube', 'YouTube'),
                    const SizedBox(width: 8),
                    _buildFilterChip('soundcloud', 'SoundCloud'),
                    const SizedBox(width: 8),
                    _buildFilterChip('all', 'Все'),
                  ],
                ),
              ),
              // Thin progress bar keeps old results visible while a new
              // query loads, instead of flashing a full-screen spinner.
              SizedBox(
                height: 2,
                child: _isLoading && _searchResults.isNotEmpty
                    ? LinearProgressIndicator(
                        color: colors.primary,
                        backgroundColor: Colors.transparent,
                      )
                    : null,
              ),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _searchResults.isEmpty) {
      return Center(
        child: CircularProgressIndicator(color: widget.theme.colors.primary),
      );
    }
    if (_searchError != null) return _buildSearchError();
    if (_searchResults.isEmpty) return _buildEmptyState();

    return ListView.builder(
      key: const ValueKey('search-results'),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 180),
      itemCount: _searchResults.length,
      itemExtent: 68,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemBuilder: (context, index) => _SearchResultTile(
        theme: widget.theme,
        track: _searchResults[index],
        onTap: () {
          _focusNode.unfocus();
          ref
              .read(queueProvider.notifier)
              .playQueue(_searchResults, startIndex: index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final colors = widget.theme.colors;
    return Center(
      key: const ValueKey('search-empty'),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _hasSearched ? Icons.search_off_rounded : Icons.headphones_rounded,
              size: 56,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            Text(
              _hasSearched ? 'Ничего не найдено' : 'Найдите, что послушать',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _hasSearched
                  ? 'Попробуйте другой запрос или источник'
                  : 'Результаты появятся во время ввода',
              style: TextStyle(color: colors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _activeSourceFilter == value;
    final colors = widget.theme.colors;
    return Center(
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        selectedColor: colors.primary,
        backgroundColor: colors.surface,
        side: BorderSide(
          color: isSelected ? colors.primary : colors.border,
        ),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : colors.textSecondary,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          fontSize: 13,
        ),
        onSelected: (selected) {
          if (!selected || isSelected) return;
          setState(() => _activeSourceFilter = value);
          if (_searchController.text.trim().isNotEmpty) {
            _performSearch(_searchController.text, force: true);
          }
        },
      ),
    );
  }

  Widget _buildSearchError() {
    final colors = widget.theme.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 56, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _searchError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () =>
                  _performSearch(_searchController.text, force: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

/// One search result row. It watches only the providers it needs, so a
/// track change or a favourite toggle rebuilds the affected rows rather
/// than the whole screen.
class _SearchResultTile extends ConsumerWidget {
  final HookTheme theme;
  final MediaTrack track;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.theme,
    required this.track,
    required this.onTap,
  });

  static String _formatDuration(Duration d) {
    if (d == Duration.zero) return '';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = theme.colors;
    final isCurrent = ref.watch(
      currentTrackProvider.select((current) => current == track),
    );
    final isLoading =
        isCurrent && ref.watch(isTrackLoadingProvider);
    final isFav = ref.watch(
      favoritesProvider.select((favs) => favs.contains(track)),
    );
    final duration = _formatDuration(track.duration);
    final subtitle = [
      track.artist,
      if (duration.isNotEmpty) duration,
    ].join(' · ');

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      onLongPress: () => _showActions(context, ref, isFav),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  TrackArtwork(
                    url: track.artworkUrl,
                    size: 52,
                    placeholderColor: colors.surface,
                    iconColor: colors.textSecondary,
                  ),
                  if (isCurrent)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.graphic_eq_rounded,
                                color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isCurrent ? colors.accent : colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (track.source == TrackSource.soundcloud) ...[
                        const Icon(Icons.cloud_rounded,
                            size: 13, color: Colors.orangeAccent),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Действия',
              icon: Icon(Icons.more_vert_rounded, color: colors.textSecondary),
              onPressed: () => _showActions(context, ref, isFav),
            ),
          ],
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, bool isFav) {
    final colors = theme.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: TrackArtwork(
                url: track.artworkUrl,
                size: 44,
                placeholderColor: colors.background,
                iconColor: colors.textSecondary,
              ),
              title: Text(track.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: colors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: Text(track.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? Colors.redAccent : colors.textPrimary,
              ),
              title: Text(
                isFav ? 'Убрать из избранного' : 'В избранное',
                style: TextStyle(color: colors.textPrimary),
              ),
              onTap: () {
                ref.read(favoritesProvider.notifier).toggleFavorite(track);
                Navigator.of(sheetContext).pop();
              },
            ),
            ListTile(
              leading:
                  Icon(Icons.playlist_add_rounded, color: colors.textPrimary),
              title: Text('Добавить в очередь',
                  style: TextStyle(color: colors.textPrimary)),
              onTap: () {
                ref.read(audioPlayerServiceProvider).addToQueue(track);
                Navigator.of(sheetContext).pop();
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('В очереди: ${track.title}'),
                    duration: const Duration(seconds: 2),
                  ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
