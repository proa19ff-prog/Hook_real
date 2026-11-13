import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../../core/ui/hook_tokens.dart';

import '../../artwork/artwork_service.dart';
import '../../audio_player/presentation/mini_player.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../audio_player/presentation/spotify_track_tile.dart';
import '../../extractor/models/media_track.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../core/ui/hook_icons.dart';

/// Pushes the artist page from any track tile or sheet.
void openArtistScreen(BuildContext context, HookTheme theme, String artistName) {
  final name = artistName.trim();
  if (name.isEmpty) return;
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ArtistScreen(theme: theme, artistName: name),
    ),
  );
}

/// Opens the artist screen for [artistName]. If [artistName] contains
/// multiple collaborators (e.g. "MadK1d и Villian"), presents a bottom sheet
/// to pick the intended performer instead of combining them into one page.
Future<void> showArtistPickerOrOpen(
  BuildContext context,
  HookTheme theme,
  String artistName,
) async {
  final artists = ArtworkService.splitArtists(artistName);
  if (artists.isEmpty) return;
  if (artists.length == 1) {
    openArtistScreen(context, theme, artists.first);
    return;
  }

  final colors = theme.colors;
  final strings = AppLocalizations.of(context);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 34,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                strings.goToArtist,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: HookType.heading,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final name in artists)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                leading: TrackArtwork(
                  url: '',
                  artist: name,
                  title: '',
                  size: 40,
                  borderRadius: BorderRadius.circular(20),
                  placeholderColor: colors.background,
                  iconColor: colors.textSecondary,
                ),
                title: Text(
                  name,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: HookType.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Icon(
                  HookIcons.forward,
                  size: 18,
                  color: colors.textSecondary,
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  openArtistScreen(context, theme, name);
                },
              ),
          ],
        ),
      ),
    ),
  );
}

/// Renders an artist credit line where each collaborator's name can be
/// tapped individually to navigate to that artist's discography page.
///
/// If there are multiple artists (e.g. "MadK1d и Villian"), each performer
/// gets their own tap gesture instead of merging them into one destination.
class InteractiveArtistText extends StatefulWidget {
  final String artist;
  final String? rest;
  final HookTheme theme;
  final TextStyle style;
  final int maxLines;
  final TextOverflow overflow;
  final void Function(String artistName)? onArtistTap;
  final VoidCallback? onLongPress;

  const InteractiveArtistText({
    super.key,
    required this.artist,
    required this.theme,
    required this.style,
    this.rest,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.onArtistTap,
    this.onLongPress,
  });

  @override
  State<InteractiveArtistText> createState() => _InteractiveArtistTextState();
}

class _InteractiveArtistTextState extends State<InteractiveArtistText> {
  final List<TapGestureRecognizer> _recognizers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    _clearRecognizers();
    super.dispose();
  }

  void _clearRecognizers() {
    for (final recognizer in _recognizers) {
      recognizer.dispose();
    }
    _recognizers.clear();
  }

  @override
  Widget build(BuildContext context) {
    _clearRecognizers();
    final text = widget.artist.trim();
    if (text.isEmpty) {
      return Text(
        widget.rest ?? '',
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        style: widget.style,
      );
    }

    final delimiterPattern = RegExp(
      r'(\s*(?:[,;&/]|(?:\s+(?:feat\.?|ft\.?|and|with|vs\.?|versus|x|и)(?=\s|$)))\s*)',
      caseSensitive: false,
    );

    final spans = <InlineSpan>[];
    final matches = delimiterPattern.allMatches(text).toList();
    var lastIndex = 0;

    void addArtistSpan(String name) {
      final cleanName = name
          .replaceAll(RegExp(r'[\(\[].*?[\)\]]'), '')
          .replaceAll(RegExp(r'\s*-\s*topic$', caseSensitive: false), '')
          .replaceAll(RegExp(r'vevo$', caseSensitive: false), '')
          .trim();
      if (cleanName.isEmpty) {
        spans.add(TextSpan(text: name));
        return;
      }
      final recognizer = TapGestureRecognizer()
        ..onTap = () {
          HookHaptics.tap();
          if (widget.onArtistTap != null) {
            widget.onArtistTap!(cleanName);
          } else {
            openArtistScreen(context, widget.theme, cleanName);
          }
        };
      _recognizers.add(recognizer);
      spans.add(
        TextSpan(
          text: name,
          recognizer: recognizer,
        ),
      );
    }

    for (final match in matches) {
      if (match.start > lastIndex) {
        addArtistSpan(text.substring(lastIndex, match.start));
      }
      spans.add(TextSpan(text: match.group(0)));
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      addArtistSpan(text.substring(lastIndex));
    }

    final rest = widget.rest?.trim();
    if (rest != null && rest.isNotEmpty) {
      spans.add(TextSpan(text: ' • $rest'));
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: widget.onLongPress ??
          () {
            final list = ArtworkService.splitArtists(widget.artist);
            if (list.length > 1) {
              showArtistPickerOrOpen(context, widget.theme, widget.artist);
            }
          },
      child: Text.rich(
        TextSpan(children: spans),
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        style: widget.style,
      ),
    );
  }
}

/// All findable recordings by one artist: structured catalog discography
/// merged with a multi-source search, playable as a list or as a wave seed.
class ArtistScreen extends ConsumerStatefulWidget {
  final HookTheme theme;
  final String artistName;

  const ArtistScreen({
    super.key,
    required this.theme,
    required this.artistName,
  });

  @override
  ConsumerState<ArtistScreen> createState() => _ArtistScreenState();
}

class _ArtistScreenState extends ConsumerState<ArtistScreen> {
  List<MediaTrack>? _tracks;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final tracks = await ref
          .read(streamResolverProvider)
          .artistTracks(widget.artistName);
      if (!mounted) return;
      setState(() => _tracks = tracks);
      final first = tracks.firstOrNull;
      if (first != null) {
        // Warm the leading result like the search screen does after a query.
        ref.read(audioPlayerServiceProvider).prefetch([first]);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tracks = const [];
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final tracks = _tracks;
    final leadTrack = tracks == null || tracks.isEmpty
        ? null
        : tracks.firstWhere(
            (t) => ArtworkService.isUsable(t.artworkUrl),
            orElse: () => tracks.first,
          );
    final artwork = leadTrack?.artworkUrl ?? '';

    return Scaffold(
      backgroundColor: colors.background,
      bottomNavigationBar: PlaybackDock(theme: widget.theme),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 12, 0),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: strings.back,
                      icon: Icon(
                        HookIcons.back,
                        color: colors.textPrimary,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.goToArtist,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: HookType.body,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: TrackArtwork(
                        url: artwork,
                        artist: leadTrack?.artist ?? widget.artistName,
                        title: leadTrack?.title,
                        duration: leadTrack?.duration,
                        size: 160,
                        borderRadius: BorderRadius.circular(80),
                        placeholderColor: colors.surface,
                        iconColor: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      widget.artistName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 28,
                        height: 1.15,
                        letterSpacing: -0.7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tracks == null
                          ? strings.searchingSources
                          : strings.artistTracksCount(tracks.length),
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Spacer(),
                        IconButton.filled(
                          tooltip: strings.waveFromArtist,
                          style: IconButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            minimumSize: const Size(54, 54),
                          ),
                          icon: const Icon(
                            HookIcons.waveform,
                            size: 26,
                          ),
                          onPressed: tracks == null || tracks.isEmpty
                              ? null
                              : () => ref
                                  .read(queueProvider.notifier)
                                  .startWave(tracks.first),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (tracks != null && tracks.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                  child: Text(
                    strings.popularTracksUpper,
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: HookType.label,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            if (tracks == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (tracks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    _failed ? strings.searchUnavailable : strings.playlistEmpty,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
              )
            else
              SliverList.separated(
                itemBuilder: (context, index) => SpotifyTrackTile(
                  theme: widget.theme,
                  track: tracks[index],
                  showSource: true,
                  onTap: () => ref
                      .read(queueProvider.notifier)
                      .playQueue(tracks, startIndex: index),
                ),
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  indent: 80,
                  color: colors.border.withValues(alpha: 0.6),
                ),
                itemCount: tracks.length,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 60)),
          ],
        ),
      ),
    );
  }
}
