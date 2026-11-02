import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../import/presentation/import_bottom_sheet.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../data/lyrics_search_service.dart';

final lyricsSearchServiceProvider = Provider<LyricsSearchService>((ref) {
  final service = LyricsSearchService();
  ref.onDispose(service.close);
  return service;
});

enum MusicSearchMode { tracks, lyrics }

class SearchScreen extends ConsumerStatefulWidget {
  final HookTheme theme;
  final int focusRequestId;
  const SearchScreen(
      {super.key, required this.theme, required this.focusRequestId});

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
  TrackSource? _source;
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _error;
  int _requestId = 0;

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
    _debounceTimer =
        Timer(const Duration(milliseconds: 400), () => _search(value));
  }

  Future<void> _search(String value) async {
    _debounceTimer?.cancel();
    final query = value.trim();
    if (query.isEmpty) return;
    final id = ++_requestId;
    final mode = _mode;
    final source = _source;
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
        results = await ref.read(streamResolverProvider).search(
              query: query,
              sources: source == null ? null : {source},
            );
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
    } catch (_) {
      if (!mounted || id != _requestId) return;
      setState(() {
        _isLoading = false;
        _error = mode == MusicSearchMode.lyrics
            ? 'Сервис поиска по тексту сейчас недоступен. Попробуйте позже или ищите по названию.'
            : 'Не удалось выполнить поиск. Проверьте соединение и попробуйте ещё раз.';
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

  void _quickSearch(String value,
      {MusicSearchMode mode = MusicSearchMode.tracks}) {
    _searchController.text = value;
    setState(() {
      _mode = mode;
      _source = null;
    });
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 18, 20, 16),
                      child: Row(children: [
                        Expanded(
                            child: Text('Найти своё.',
                                style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -1.2,
                                ))),
                        IconButton(
                          tooltip: 'Импорт музыки',
                          onPressed: () =>
                              ImportBottomSheet.show(context, widget.theme),
                          icon: Icon(MingCuteIcons.mgc_link_line,
                              color: colors.textSecondary),
                        ),
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        key: const ValueKey('music-search-field'),
                        controller: _searchController,
                        focusNode: _focusNode,
                        maxLength: 200,
                        style:
                            TextStyle(color: colors.textPrimary, fontSize: 16),
                        cursorColor: colors.primary,
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: _mode == MusicSearchMode.lyrics
                              ? 'Слова, которые запомнились…'
                              : 'Трек, артист — можно по-русски',
                          hintStyle: TextStyle(
                              color: colors.textSecondary, fontSize: 14),
                          filled: true,
                          fillColor: colors.surface,
                          prefixIcon: Icon(Icons.search_rounded,
                              color: colors.textSecondary),
                          suffixIcon: ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _searchController,
                            builder: (_, value, __) => value.text.isEmpty
                                ? const SizedBox.shrink()
                                : IconButton(
                                    tooltip: 'Очистить',
                                    onPressed: _clear,
                                    icon: Icon(Icons.close_rounded,
                                        color: colors.textSecondary)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                  color:
                                      colors.primary.withValues(alpha: 0.65))),
                        ),
                        textInputAction: TextInputAction.search,
                        onChanged: _onQueryChanged,
                        onSubmitted: (value) {
                          _search(value);
                          _focusNode.unfocus();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                      child: Row(children: [
                        _modeButton(MusicSearchMode.tracks, 'Музыка',
                            Icons.music_note_rounded),
                        const SizedBox(width: 8),
                        _modeButton(MusicSearchMode.lyrics, 'По тексту',
                            Icons.lyrics_outlined),
                      ]),
                    ),
                    if (_mode == MusicSearchMode.tracks)
                      SizedBox(
                          height: 44,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            children: [
                              _sourceChip(null, 'Все источники'),
                              for (final source in [
                                TrackSource.spotify,
                                TrackSource.youtubeMusic,
                                TrackSource.soundcloud,
                                TrackSource.audius
                              ])
                                _sourceChip(source, source.label),
                            ],
                          ))
                    else
                      Padding(
                          padding: const EdgeInsets.fromLTRB(24, 6, 24, 12),
                          child: Text(
                              'Ищем фразу в песне, а не только в названии.',
                              style: TextStyle(
                                  color: colors.textSecondary, fontSize: 12))),
                    const SizedBox(height: 6),
                    Expanded(child: _buildBody()),
                  ]),
            ),
          )),
    );
  }

  Widget _modeButton(MusicSearchMode mode, String label, IconData icon) {
    final colors = widget.theme.colors;
    final selected = _mode == mode;
    return Expanded(
        child: Semantics(
            selected: selected,
            child: TextButton.icon(
              onPressed: () => _changeMode(mode),
              icon: Icon(icon, size: 18),
              label: Text(label),
              style: TextButton.styleFrom(
                foregroundColor:
                    selected ? colors.textPrimary : colors.textSecondary,
                backgroundColor: selected
                    ? colors.textPrimary.withValues(alpha: 0.08)
                    : Colors.transparent,
                minimumSize: const Size(0, 44),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                textStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
              ),
            )));
  }

  Widget _sourceChip(TrackSource? source, String label) {
    final colors = widget.theme.colors;
    final selected = source == _source;
    return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          showCheckmark: false,
          onSelected: (_) {
            if (selected) return;
            _clear(keepText: true);
            setState(() => _source = source);
            if (_searchController.text.trim().isNotEmpty) {
              _search(_searchController.text);
            }
          },
          selectedColor: colors.textPrimary,
          backgroundColor: Colors.transparent,
          side: BorderSide.none,
          labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: selected ? colors.background : colors.textSecondary),
          shape: const StadiumBorder(),
        ));
  }

  Widget _buildBody() {
    final colors = widget.theme.colors;
    if (_isLoading) {
      return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: colors.primary)),
        const SizedBox(height: 16),
        Text(
            _mode == MusicSearchMode.lyrics
                ? 'Ищем знакомые строки…'
                : 'Собираем музыку из источников…',
            style: TextStyle(color: colors.textSecondary, fontSize: 13)),
      ]));
    }
    if (_error != null || (_hasSearched && _results.isEmpty)) {
      return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 48, 28, 160),
          child: Column(children: [
            Icon(
                _error != null
                    ? Icons.wifi_off_rounded
                    : Icons.search_off_rounded,
                size: 38,
                color: colors.textSecondary),
            const SizedBox(height: 18),
            Text(
                _error != null ? 'Не удалось связаться' : 'Пока без совпадений',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text(
                _error ??
                    (_mode == MusicSearchMode.lyrics
                        ? 'Попробуйте другую строчку. Не все тексты есть в индексе.'
                        : 'Уточните исполнителя или выберите другой источник. Часть сервисов может быть недоступна в вашей сети.'),
                textAlign: TextAlign.center,
                style: TextStyle(color: colors.textSecondary, height: 1.5)),
            const SizedBox(height: 16),
            TextButton.icon(
                onPressed: () => _search(_searchController.text),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Повторить поиск')),
          ]));
    }
    if (!_hasSearched) return _buildDiscovery();
    return ListView.builder(
      key: const ValueKey('search-results'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 180),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: _results.length == 1 ? 1 : _results.length + 1,
      itemBuilder: (_, index) {
        if (index == 0) return _buildTopResult();
        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(12, 24, 12, 10),
            child: Text(
                _mode == MusicSearchMode.lyrics
                    ? 'СОВПАДЕНИЯ ПО ТЕКСТУ'
                    : 'ТРЕКИ',
                style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8)),
          );
        }
        final trackIndex = index - 1;
        final track = _results[trackIndex];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SpotifyTrackTile(
              theme: widget.theme,
              track: track,
              showSource: true,
              onTap: () => _play(trackIndex),
              onFindArtist: () => _quickSearch(track.artist)),
          if (_snippets[track] case final String snippet)
            Padding(
                padding: const EdgeInsets.fromLTRB(80, 0, 24, 12),
                child: Text(
                  '«$snippet»',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: colors.textSecondary, fontSize: 12, height: 1.4),
                )),
        ]);
      },
    );
  }

  Widget _buildTopResult() {
    final colors = widget.theme.colors;
    final track = _results.first;
    return Semantics(
        button: true,
        label: 'Воспроизвести ${track.title}, ${track.artist}',
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _play(0),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      _mode == MusicSearchMode.lyrics
                          ? 'ЗНАКОМЫЕ СТРОКИ'
                          : 'ЛУЧШЕЕ СОВПАДЕНИЕ',
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.8)),
                  const SizedBox(height: 18),
                  Row(children: [
                    TrackArtwork(
                        url: track.artworkUrl,
                        size: 84,
                        borderRadius: BorderRadius.circular(12),
                        placeholderColor: colors.surface,
                        iconColor: colors.textSecondary),
                    const SizedBox(width: 16),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(track.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: colors.textPrimary,
                                  fontSize: 23,
                                  height: 1.1,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.6)),
                          const SizedBox(height: 6),
                          Text(track.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: colors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(
                              [
                                track.source.label,
                                SpotifyTrackTile.formatDuration(track.duration)
                              ].where((value) => value.isNotEmpty).join(' · '),
                              style: TextStyle(
                                  color: colors.textSecondary, fontSize: 11)),
                        ])),
                    const SizedBox(width: 8),
                    Icon(Icons.play_circle_fill_rounded,
                        color: colors.textPrimary, size: 42),
                  ]),
                  if (_snippets[track] case final String snippet) ...[
                    const SizedBox(height: 16),
                    Text('«$snippet»',
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            height: 1.5)),
                  ],
                  if (track.source.isCatalog) ...[
                    const SizedBox(height: 14),
                    Text('Полную версию подберём при воспроизведении.',
                        style: TextStyle(
                            color: colors.textSecondary, fontSize: 11)),
                  ],
                ],
              )),
        ));
  }

  Widget _buildDiscovery() {
    final colors = widget.theme.colors;
    final artists = ref
        .watch(favoritesProvider)
        .map((track) => track.artist.trim())
        .where((artist) => artist.isNotEmpty)
        .toSet()
        .take(6);
    return ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 180),
        children: [
          Text('Название забыли.\nМузыку — нет.',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 30,
                height: 1.12,
                fontWeight: FontWeight.w700,
                letterSpacing: -1,
              )),
          const SizedBox(height: 14),
          Text(
              'Имя на слух, название или строчка из песни.\nНачните так, как помните.',
              style: TextStyle(
                  color: colors.textSecondary, fontSize: 14, height: 1.6)),
          const SizedBox(height: 24),
          _discoveryAction(
              Icons.language_rounded,
              'Мартин роз',
              'Иностранные имена — русскими буквами',
              () => _quickSearch('Мартин роз')),
          _discoveryAction(Icons.lyrics_outlined, 'Помню только строчку',
              'Найти песню по словам', () {
            _clear();
            setState(() => _mode = MusicSearchMode.lyrics);
            _focusNode.requestFocus();
          }),
          _discoveryAction(
              Icons.album_outlined,
              'Sunflower',
              'Post Malone & Swae Lee',
              () => _quickSearch('Post Malone Swae Lee Sunflower')),
          if (artists.isNotEmpty) ...[
            const SizedBox(height: 28),
            Text('ВАШИ АРТИСТЫ',
                style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final artist in artists)
                ActionChip(
                    label: Text(artist),
                    onPressed: () => _quickSearch(artist),
                    backgroundColor: colors.surface,
                    side: BorderSide.none,
                    labelStyle: TextStyle(color: colors.textPrimary)),
            ]),
          ],
        ]);
  }

  Widget _discoveryAction(
      IconData icon, String title, String subtitle, VoidCallback action) {
    final colors = widget.theme.colors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      minVerticalPadding: 12,
      leading: Icon(icon, color: colors.textSecondary, size: 23),
      title: Text(title,
          style: TextStyle(
              color: colors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: TextStyle(
              color: colors.textSecondary, fontSize: 12, height: 1.5)),
      trailing:
          Icon(Icons.north_east_rounded, color: colors.textSecondary, size: 18),
      onTap: action,
    );
  }
}
