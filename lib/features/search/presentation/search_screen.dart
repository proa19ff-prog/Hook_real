import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/localized_labels.dart';
import '../../../core/ui/hook_icons.dart';
import '../../../core/ui/hook_skeleton.dart';
import '../../../core/ui/hook_tokens.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../artwork/artwork_service.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../import/presentation/import_bottom_sheet.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../data/lyrics_search_service.dart';
import 'artist_screen.dart';
import 'search_history_provider.dart';

final lyricsSearchServiceProvider = Provider<LyricsSearchService>((ref) {
  final service = LyricsSearchService();
  ref.onDispose(service.close);
  return service;
});

enum MusicSearchMode { tracks, lyrics }

class SearchScreen extends ConsumerStatefulWidget {
  final HookTheme theme;
  final int focusRequestId;
  const SearchScreen({
    super.key,
    required this.theme,
    required this.focusRequestId,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<MediaTrack> _results = const [];
  Map<MediaTrack, String> _snippets = const {};
  MusicSearchMode _mode = MusicSearchMode.tracks;
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  int _requestId = 0;
  // Null = every source; otherwise the search is scoped to one.
  TrackSource? _source;

  @override
  void didUpdateWidget(covariant SearchScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusRequestId != oldWidget.focusRequestId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _requestId++;
    _debounceTimer?.cancel();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clear({bool keepText = false}) {
    _debounceTimer?.cancel();
    if (!keepText) _searchController.clear();
    setState(() {
      _requestId++;
      _results = const [];
      _snippets = const {};
      _isLoading = false;
      _hasSearched = false;
      _error = null;
    });
  }

  void _onQueryChanged(String value) {
    _debounceTimer?.cancel();
    if (value.trim().isEmpty) {
      _clear(keepText: true);
      return;
    }
    // Invalidate immediately, not after debounce: an older network response
    // must not replace the text the listener is currently typing.
    setState(() {
      _requestId++;
      _results = const [];
      _snippets = const {};
      _isLoading = true;
      _hasSearched = true;
      _error = null;
    });
    _debounceTimer = Timer(
      const Duration(milliseconds: 400),
      () => _search(value),
    );
  }

  Future<void> _search(String value) async {
    _debounceTimer?.cancel();
    final query = value.trim();
    if (query.isEmpty) return;
    final id = ++_requestId;
    final mode = _mode;
    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _error = null;
    });
    try {
      List<MediaTrack> results;
      var snippets = <MediaTrack, String>{};
      if (mode == MusicSearchMode.lyrics) {
        final hits = await ref.read(lyricsSearchServiceProvider).search(query);
        results = hits.map((hit) => hit.track).toList(growable: false);
        snippets = {for (final hit in hits) hit.track: hit.snippet};
      } else {
        results = await ref
            .read(streamResolverProvider)
            .search(query: query, sources: _source == null ? null : {_source!});
      }
      if (!mounted || id != _requestId) return;
      setState(() {
        _results = results;
        _snippets = snippets;
        _isLoading = false;
      });
      // Do not resolve several expensive catalogs on every keystroke. Only the
      // leading result is warmed; the queue prefetch handles subsequent songs.
      ref.read(audioPlayerServiceProvider).prefetch(results.take(1));
      // A query worth results is worth remembering; dead queries stay out.
      if (results.isNotEmpty) {
        ref.read(searchHistoryProvider.notifier).record(query);
      }
    } catch (_) {
      if (!mounted || id != _requestId) return;
      final strings = AppLocalizations.of(context);
      setState(() {
        _isLoading = false;
        _error = mode == MusicSearchMode.lyrics
            ? strings.lyricsUnavailable
            : strings.searchUnavailable;
      });
    }
  }

  void _changeMode(MusicSearchMode mode) {
    if (mode == _mode) return;
    _clear(keepText: true);
    setState(() => _mode = mode);
    if (_searchController.text.trim().isNotEmpty) {
      _search(_searchController.text);
    }
  }

  void _quickSearch(
    String value, {
    MusicSearchMode mode = MusicSearchMode.tracks,
  }) {
    _searchController.text = value;
    setState(() => _mode = mode);
    _search(value);
    _focusNode.unfocus();
  }

  void _play(int index) {
    _focusNode.unfocus();
    ref.read(queueProvider.notifier).playQueue(_results, startIndex: index);
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HookBreakpoints.readingMax,
            ),
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      HookSpace.xxl,
                      HookSpace.lg,
                      HookSpace.xl,
                      HookSpace.xs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.findYourMusic,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: HookType.display,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.7,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: strings.importMusic,
                          onPressed: () =>
                              ImportBottomSheet.show(context, widget.theme),
                          icon: Icon(
                            HookIcons.link,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // The field stays reachable while results scroll under it.
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _PinnedSearchFieldDelegate(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        HookSpace.xl,
                        HookSpace.md,
                        HookSpace.xl,
                        HookSpace.md,
                      ),
                      child: _buildSearchField(strings, colors),
                    ),
                    background: colors.background,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
                        child: Row(
                          children: [
                            _modeButton(MusicSearchMode.tracks, strings.music),
                            const SizedBox(width: 8),
                            _modeButton(
                              MusicSearchMode.lyrics,
                              strings.byLyrics,
                            ),
                            const Spacer(),
                            _sourceFilterButton(strings),
                          ],
                        ),
                      ),
                      if (_mode == MusicSearchMode.lyrics)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
                          child: Text(
                            strings.lyricsSearchCaption,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: HookType.label,
                            ),
                          ),
                        ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
              ],
              body: _buildBody(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(AppLocalizations strings, HookColors colors) {
    return TextField(
      key: const ValueKey('music-search-field'),
      controller: _searchController,
      focusNode: _focusNode,
      maxLength: 200,
      style: TextStyle(color: colors.textPrimary, fontSize: HookType.heading),
      cursorColor: colors.primary,
      decoration: InputDecoration(
        counterText: '',
        hintText: _mode == MusicSearchMode.lyrics
            ? strings.rememberedLyricsHint
            : strings.trackArtistHint,
        hintStyle: TextStyle(color: colors.textSecondary, fontSize: HookType.body),
        filled: true,
        fillColor: colors.surface,
        prefixIcon: Icon(HookIcons.search, color: colors.textSecondary),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _searchController,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: strings.clear,
                  onPressed: _clear,
                  icon: Icon(HookIcons.close, color: colors.textSecondary),
                ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary.withValues(alpha: 0.65)),
        ),
      ),
      textInputAction: TextInputAction.search,
      onChanged: _onQueryChanged,
      onSubmitted: (value) {
        _search(value);
        _focusNode.unfocus();
      },
    );
  }

  Widget _modeButton(MusicSearchMode mode, String label) {
    final colors = widget.theme.colors;
    final selected = _mode == mode;
    return Expanded(
      child: Semantics(
        selected: selected,
        child: TextButton(
          onPressed: () => _changeMode(mode),
          style: TextButton.styleFrom(
            foregroundColor: selected
                ? colors.textPrimary
                : colors.textSecondary,
            backgroundColor: selected
                ? colors.textPrimary.withValues(alpha: 0.08)
                : Colors.transparent,
            minimumSize: const Size(48, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: TextStyle(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          child: Text(label, textAlign: TextAlign.center),
        ),
      ),
    );
  }

  /// One quiet button instead of a whole chip row; the sources themselves
  /// live in a sheet, so the header stays a single tidy line.
  Widget _sourceFilterButton(AppLocalizations strings) {
    final colors = widget.theme.colors;
    return IconButton(
      tooltip: _source == null
          ? strings.allSources
          : '${strings.allSources}: ${_source!.labelFor(strings)}',
      visualDensity: VisualDensity.compact,
      onPressed: _showSourceSheet,
      icon: Badge(
        isLabelVisible: _source != null,
        smallSize: 7,
        backgroundColor: colors.primary,
        child: Icon(
          HookIcons.filter,
          size: 21,
          color: _source == null
              ? colors.textSecondary
              : colors.textPrimary,
        ),
      ),
    );
  }

  Future<void> _showSourceSheet() async {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  strings.allSources,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            for (final source in <TrackSource?>[
              null,
              TrackSource.spotify,
              TrackSource.youtubeMusic,
              TrackSource.soundcloud,
              TrackSource.remote,
            ])
              ListTile(
                dense: true,
                leading: Icon(
                  switch (source) {
                    null => HookIcons.apps,
                    TrackSource.spotify => HookIcons.music,
                    TrackSource.youtubeMusic => HookIcons.youtube,
                    TrackSource.soundcloud => HookIcons.syncCloud,
                    TrackSource.remote => HookIcons.server,
                    _ => HookIcons.note,
                  },
                  size: 21,
                  color: colors.primary,
                ),
                title: Text(
                  source == null
                      ? strings.allSources
                      : source.labelFor(strings),
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: HookType.body,
                    fontWeight: source == _source
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
                trailing: source == _source
                    ? Icon(
                        HookIcons.check,
                        size: 20,
                        color: colors.primary,
                      )
                    : null,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  if (source == _source) return;
                  setState(() => _source = source);
                  if (_searchController.text.trim().isNotEmpty) {
                    _search(_searchController.text);
                  }
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    if (_isLoading) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(8, HookSpace.lg, 8, HookSpace.xxl),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HookSpace.md,
                0,
                HookSpace.md,
                HookSpace.md,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: HookSpace.sm),
                  Expanded(
                    child: Text(
                      _mode == MusicSearchMode.lyrics
                          ? strings.searchingLyrics
                          : strings.searchingSources,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: HookType.label,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // The result rows keep their exact final footprint while the
            // query runs, so nothing jumps when the answer lands.
            SkeletonTrackList(label: strings.loading),
          ],
        ),
      );
    }
    if (_error != null || (_hasSearched && _results.isEmpty)) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 48, 28, 24),
        child: Column(
          children: [
            Icon(
              _error != null
                  ? HookIcons.offline
                  : HookIcons.noResults,
              size: 38,
              color: colors.textSecondary,
            ),
            const SizedBox(height: 18),
            Text(
              _error != null ? strings.connectionFailed : strings.noMatches,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _error ??
                  (_mode == MusicSearchMode.lyrics
                      ? strings.lyricsNoMatches
                      : strings.trackNoMatches),
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _search(_searchController.text),
              icon: const Icon(HookIcons.refresh),
              label: Text(strings.repeatSearch),
            ),
          ],
        ),
      );
    }
    if (!_hasSearched) return _buildDiscovery();
    return ListView.builder(
      key: const ValueKey('search-results'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _results.length == 1 ? 1 : _results.length + 1,
      itemBuilder: (_, index) {
        if (index == 0) return _buildTopResult();
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
            child: Text(
              _mode == MusicSearchMode.lyrics
                  ? strings.lyricMatchesUpper
                  : strings.tracksUpper,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: HookType.label,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          );
        }
        final trackIndex = index - 1;
        final track = _results[trackIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SpotifyTrackTile(
              theme: widget.theme,
              track: track,
              showSource: true,
              onTap: () => _play(trackIndex),
            ),
            if (_snippets[track] case final String snippet)
              Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 24, 12),
                child: Text(
                  '«$snippet»',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: HookType.label,
                    height: 1.4,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTopResult() {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final track = _results.first;
    return Semantics(
      button: true,
      label: strings.playTrack(track.title, track.artist),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _play(0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceGlass,
              borderRadius: BorderRadius.circular(16),
              border: Border.fromBorderSide(
                BorderSide(color: colors.border.withValues(alpha: 0.5)),
              ),
            ),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _mode == MusicSearchMode.lyrics
                    ? strings.familiarLinesUpper
                    : strings.bestMatchUpper,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: HookType.label,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  TrackArtwork(
                    url: track.artworkUrl,
                    artist: track.artist,
                    title: track.title,
                    duration: track.duration,
                    size: 84,
                    borderRadius: BorderRadius.circular(12),
                    placeholderColor: colors.surface,
                    iconColor: colors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 23,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          track.artist,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: HookType.body,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          [
                            track.source.labelFor(strings),
                            SpotifyTrackTile.formatDuration(track.duration),
                          ].where((value) => value.isNotEmpty).join(' · '),
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: HookType.label,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_snippets[track] case final String snippet) ...[
                const SizedBox(height: 16),
                Text(
                  '«$snippet»',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: HookType.body,
                    height: 1.5,
                  ),
                ),
              ],
              if (track.source.isCatalog) ...[
                const SizedBox(height: 14),
                Text(
                  strings.fullVersionOnPlayback,
                  style: TextStyle(color: colors.textSecondary, fontSize: HookType.caption),
                ),
              ],
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _buildDiscovery() {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final history = ref.watch(searchHistoryProvider);
    // Circle covers for the artist cards come from whatever artwork the
    // user's own tracks carry; names from favorites first, then history.
    // Collaborating artists are split so each performer gets their own card.
    final artistArt = <String, String>{};
    final artistTracks = <String, MediaTrack>{};
    for (final track in [
      ...ref.watch(favoritesProvider),
      ...ref.watch(historyProvider),
    ]) {
      final names = ArtworkService.splitArtists(track.artist);
      if (names.isEmpty) continue;
      final display = ArtworkService.instance.displayUrl(
        track.artworkUrl,
        artist: track.artist,
        title: track.title,
      );
      for (final name in names) {
        if (name.isEmpty) continue;
        artistTracks.putIfAbsent(name, () => track);
        if (display != null) {
          artistArt.putIfAbsent(name, () => display);
        }
      }
    }
    for (final entry in artistTracks.entries) {
      artistArt.putIfAbsent(entry.key, () => entry.value.artworkUrl);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        Text(
          strings.forgotTitle,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          strings.startAsYouRemember,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: HookType.body,
            height: 1.6,
          ),
        ),
        if (history.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: Text(
                  strings.recentQueriesUpper,
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: HookType.label,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              IconButton(
                tooltip: strings.clearHistory,
                visualDensity: VisualDensity.compact,
                onPressed: () =>
                    ref.read(searchHistoryProvider.notifier).clear(),
                icon: Icon(
                  HookIcons.deleteForever,
                  size: 19,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final query in history)
                InputChip(
                  label: Text(query),
                  avatar: Icon(
                    HookIcons.history,
                    size: 16,
                    color: colors.textSecondary,
                  ),
                  onPressed: () => _quickSearch(query),
                  onDeleted: () =>
                      ref.read(searchHistoryProvider.notifier).remove(query),
                  backgroundColor: colors.surface,
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: colors.textPrimary,
                    fontSize: HookType.bodySmall,
                  ),
                ),
            ],
          ),
        ],
        if (artistArt.isNotEmpty) ...[
          const SizedBox(height: 28),
          Text(
            strings.yourArtistsUpper,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: HookType.label,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: artistArt.length.clamp(0, 10),
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final name = artistArt.keys.elementAt(index);
                final artistTrack = artistTracks[name];
                return GestureDetector(
                  onTap: () => openArtistScreen(context, widget.theme, name),
                  child: SizedBox(
                    width: 76,
                    child: Column(
                      children: [
                        TrackArtwork(
                          url: artistArt[name] ?? '',
                          artist: name,
                          title: artistTrack?.title,
                          duration: artistTrack?.duration,
                          size: 68,
                          borderRadius: BorderRadius.circular(34),
                          placeholderColor: colors.surface,
                          iconColor: colors.textSecondary,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: HookType.caption,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 24),
        _discoveryAction(
          HookIcons.language,
          strings.foreignNameExample,
          strings.foreignNamesCaption,
          () => _quickSearch(strings.foreignNameExample),
        ),
        _discoveryAction(
          HookIcons.lyrics,
          strings.rememberOnlyLine,
          strings.findSongByWords,
          () {
            _clear();
            setState(() => _mode = MusicSearchMode.lyrics);
            _focusNode.requestFocus();
          },
        ),
        _discoveryAction(
          HookIcons.disc,
          'Sunflower',
          'Post Malone & Swae Lee',
          () => _quickSearch('Post Malone Swae Lee Sunflower'),
        ),
      ],
    );
  }

  Widget _discoveryAction(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback action,
  ) {
    final colors = widget.theme.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
      leading: Icon(icon, color: colors.textSecondary, size: 23),
      title: Text(
        title,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: HookType.heading,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: HookType.label,
          height: 1.5,
        ),
      ),
      trailing: Icon(
        HookIcons.external,
        color: colors.textSecondary,
        size: 18,
      ),
      onTap: action,
    );
  }
}

/// Keeps the search field on screen while results scroll underneath.
class _PinnedSearchFieldDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchFieldDelegate({required this.child, required this.background});

  final Widget child;
  final Color background;
  static const double _extent = 74;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // A blurred backdrop instead of a 94%-opaque sheet: rows scrolling under a
    // barely-transparent header used to show through as smudged text. Blurring
    // says "this is a surface above the list" and stays legible on any theme.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: ColoredBox(
          color: background.withValues(alpha: 0.82),
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchFieldDelegate oldDelegate) =>
      oldDelegate.background != background;
}
