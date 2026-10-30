import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/models/media_track.dart';
import '../../import/presentation/import_bottom_sheet.dart';
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
  bool _isLoadingRecommendations = false;
  String? _searchError;
  String _lastQuery = '';
  // YouTube is the main source; searching one source also answers faster.
  String _activeSourceFilter = 'soundcloud'; // 'all', 'youtube', 'soundcloud'
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
      _isLoadingRecommendations = false;
      _searchError = null;
      _lastQuery = '';
    });
  }

  Future<void> _loadPersonalizedMix({bool playImmediately = true}) async {
    if (_isLoadingRecommendations) return;
    setState(() {
      _isLoadingRecommendations = true;
      _searchError = null;
    });

    try {
      final recService = ref.read(recommendationServiceProvider);
      final tracks = await recService.getPersonalizedRecommendations(limit: 30);
      if (!mounted) return;

      setState(() {
        _isLoadingRecommendations = false;
      });

      if (tracks.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Не удалось подобрать треки. Попробуйте поиск.'),
              backgroundColor: widget.theme.colors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      if (playImmediately) {
        ref.read(queueProvider.notifier).playQueue(tracks, startIndex: 0);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Включен персональный микс (${tracks.length} треков)'),
              backgroundColor: widget.theme.colors.surface,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        setState(() {
          _searchResults = tracks;
          _hasSearched = true;
          _lastQuery = '✨ Мои предпочтения';
          _searchController.text = 'Мои предпочтения';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка создания микса: $e'),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
              // Page Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Поиск',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (_isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: colors.primary,
                        ),
                      ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: HookGlassCard(
                  theme: widget.theme,
                  elevation: 1.0,
                  borderRadius: BorderRadius.circular(18),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    cursorColor: colors.primary,
                    decoration: InputDecoration(
                      hintText: 'Трек, артист или альбом...',
                      hintStyle: TextStyle(
                        color: colors.textSecondary.withValues(alpha: 0.7),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: colors.primary,
                        size: 22,
                      ),
                      suffixIcon: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _searchController,
                        builder: (context, value, _) => value.text.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                tooltip: 'Очистить',
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: colors.textSecondary,
                                  size: 20,
                                ),
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

              // Source Filter Chips
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildFilterChip('soundcloud', 'SoundCloud', Icons.cloud_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('youtube', 'YouTube', Icons.play_circle_fill_rounded),
                    const SizedBox(width: 8),
                    _buildFilterChip('all', 'Все источники', Icons.auto_awesome_rounded),
                  ],
                ),
              ),

              const SizedBox(height: 4),

              // Linear Progress Line
              SizedBox(
                height: 3,
                child: _isLoading && _searchResults.isNotEmpty
                    ? LinearProgressIndicator(
                        color: colors.primary,
                        backgroundColor: colors.surfaceGlass.withValues(alpha: 0.2),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: widget.theme.colors.primary),
            const SizedBox(height: 16),
            Text(
              'Поиск музыки...',
              style: TextStyle(
                color: widget.theme.colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    if (_searchError != null) return _buildSearchError();
    if (_searchResults.isEmpty) return _buildEmptyState();

    return ListView.builder(
      key: const ValueKey('search-results'),
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 180),
      itemCount: _searchResults.length,
      itemExtent: 72,
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

    if (_hasSearched) {
      return Center(
        key: const ValueKey('search-empty'),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colors.surfaceGlass.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: colors.textSecondary.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Ничего не найдено',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Попробуйте изменить запрос или сменить источник',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final favorites = ref.watch(favoritesProvider);
    final favoriteArtists = favorites
        .map((t) => t.artist.trim())
        .where((a) => a.isNotEmpty)
        .toSet()
        .take(6)
        .toList();

    return SingleChildScrollView(
      key: const ValueKey('search-discovery'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 140),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized Recommendation Card
          _buildPersonalizedCard(colors),

          if (favoriteArtists.isNotEmpty) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: 16,
                  color: Colors.redAccent.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'Ваши любимые артисты',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favoriteArtists.map((artist) {
                return _buildPillChip(
                  label: artist,
                  icon: Icons.person_rounded,
                  onTap: () {
                    _searchController.text = artist;
                    _performSearch(artist);
                    _focusNode.unfocus();
                  },
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 24),
          Row(
            children: [
              Icon(
                Icons.explore_rounded,
                size: 16,
                color: colors.accent,
              ),
              const SizedBox(width: 8),
              Text(
                'Популярные жанры и настроения',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPillChip(
                label: '📥 Импорт (Spotify / YT)',
                icon: Icons.add_link_rounded,
                onTap: () => ImportBottomSheet.show(context, widget.theme),
              ),
              _buildPillChip(
                label: '🔥 В тренде',
                onTap: () => _quickSearch('Тренды'),
              ),
              _buildPillChip(
                label: '⚡ Phonk / Фонк',
                onTap: () => _quickSearch('Phonk'),
              ),
              _buildPillChip(
                label: '🎧 Chill & Relax',
                onTap: () => _quickSearch('Chill'),
              ),
              _buildPillChip(
                label: '🎸 Рок / Rock Hits',
                onTap: () => _quickSearch('Rock'),
              ),
              _buildPillChip(
                label: '🌙 Lo-Fi Beats',
                onTap: () => _quickSearch('Lo-Fi'),
              ),
              _buildPillChip(
                label: '💿 Рэп и Хип-Хоп',
                onTap: () => _quickSearch('Hip-Hop'),
              ),
              _buildPillChip(
                label: '🌌 Synthwave / Retro',
                onTap: () => _quickSearch('Synthwave'),
              ),
              _buildPillChip(
                label: '✨ Поп Хиты',
                onTap: () => _quickSearch('Pop hits'),
              ),
              _buildPillChip(
                label: '🚗 Ночной драйв',
                onTap: () => _quickSearch('Night drive'),
              ),
              _buildPillChip(
                label: '🏋️ Тренировка',
                onTap: () => _quickSearch('Workout music'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalizedCard(HookColors colors) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.22),
            colors.accent.withValues(alpha: 0.12),
            colors.surfaceGlass.withValues(alpha: 0.4),
          ],
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          size: 13,
                          color: colors.accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'AI РЕКОМЕНДАЦИИ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: colors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.graphic_eq_rounded,
                        size: 16,
                        color: colors.textSecondary.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Smart Flow',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: colors.textSecondary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                'Музыка по моим предпочтениям',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                'Умный персональный микс на основе ваших лайков, истории и вкусовых предпочтений.',
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textSecondary.withValues(alpha: 0.9),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: _isLoadingRecommendations
                          ? null
                          : () => _loadPersonalizedMix(playImmediately: true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colors.primary, colors.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: _isLoadingRecommendations
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Слушать микс',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isLoadingRecommendations
                        ? null
                        : () => _loadPersonalizedMix(playImmediately: false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceGlass.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.format_list_bulleted_rounded,
                            color: colors.textPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Треки',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPillChip({
    required String label,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    final colors = widget.theme.colors;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.surfaceGlass.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: colors.primary),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _quickSearch(String query) {
    _searchController.text = query;
    _performSearch(query);
    _focusNode.unfocus();
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    final isSelected = _activeSourceFilter == value;
    final colors = widget.theme.colors;

    return Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          if (isSelected) return;
          setState(() => _activeSourceFilter = value);
          if (_searchController.text.trim().isNotEmpty) {
            _performSearch(_searchController.text, force: true);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [colors.primary, colors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : colors.surfaceGlass.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.25)
                  : colors.border.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : colors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchError() {
    final colors = widget.theme.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  _performSearch(_searchController.text, force: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Повторить попытку'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isCurrent
            ? colors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: isCurrent
            ? Border.all(
                color: colors.primary.withValues(alpha: 0.35),
                width: 1,
              )
            : null,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        onLongPress: () => _showActions(context, ref, isFav),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              // Artwork with shadow and current track overlay
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    TrackArtwork(
                      url: track.artworkUrl,
                      size: 52,
                      borderRadius: BorderRadius.circular(10),
                      placeholderColor: colors.surface,
                      iconColor: colors.textSecondary,
                    ),
                    if (isCurrent)
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: isLoading
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: colors.accent,
                                  ),
                                )
                              : Icon(
                                  Icons.equalizer_rounded,
                                  color: colors.accent,
                                  size: 24,
                                ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Track Info
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
                        fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (track.source == TrackSource.soundcloud) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SC',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.orangeAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'YT',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],
                        Expanded(
                          child: Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
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
                icon: Icon(Icons.more_vert_rounded,
                    color: colors.textSecondary.withValues(alpha: 0.7),
                    size: 20),
                onPressed: () => _showActions(context, ref, isFav),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActions(BuildContext context, WidgetRef ref, bool isFav) {
    final colors = theme.colors;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.textSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: TrackArtwork(
                url: track.artworkUrl,
                size: 46,
                borderRadius: BorderRadius.circular(10),
                placeholderColor: colors.background,
                iconColor: colors.textSecondary,
              ),
              title: Text(
                track.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                track.artist,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colors.textSecondary, fontSize: 13),
              ),
            ),
            Divider(
              height: 1,
              color: colors.border.withValues(alpha: 0.3),
            ),
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
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
