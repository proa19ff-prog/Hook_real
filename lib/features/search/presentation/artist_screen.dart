import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ui/hook_tokens.dart';

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
    final artwork = tracks == null
        ? ''
        : tracks.map((t) => t.artworkUrl).firstWhere(
              (url) => url.isNotEmpty,
              orElse: () => '',
            );

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
