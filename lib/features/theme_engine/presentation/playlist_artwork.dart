import 'dart:async';

import 'package:flutter/material.dart';

import 'track_artwork.dart';
import '../../../core/ui/hook_icons.dart';

import 'package:hook/features/artwork/artwork_service.dart';
import 'package:hook/features/extractor/models/media_track.dart';

/// Cover for a playlist: a collage of the first distinct track artworks,
/// a single cover when only one is available, or a music-note placeholder.
///
/// Playlists keep the artwork url captured when each track was saved, so
/// imported collections often carry empty urls and old entries carry ones
/// that stopped resolving. Deriving the cover from several tracks at render
/// time keeps the tab alive without a storage migration; when [tracks] is
/// given, missing or video-frame covers are also resolved from the catalog.
class PlaylistArtwork extends StatefulWidget {
  final Iterable<String> urls;
  final List<MediaTrack>? tracks;
  final double size;
  final Color placeholderColor;
  final Color iconColor;
  final BorderRadius borderRadius;

  const PlaylistArtwork({
    super.key,
    required this.urls,
    required this.size,
    required this.placeholderColor,
    required this.iconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.tracks,
  });

  @override
  State<PlaylistArtwork> createState() => _PlaylistArtworkState();
}

class _PlaylistArtworkState extends State<PlaylistArtwork> {
  bool _resolving = false;

  @override
  void initState() {
    super.initState();
    _resolveMissing();
  }

  @override
  void didUpdateWidget(PlaylistArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.tracks, widget.tracks)) {
      _resolveMissing();
    }
  }

  /// Resolves covers for a handful of the playlist's first tracks so the card
  /// fills in on its own. Results land in the shared artwork cache, so the
  /// next build (and every other screen) picks them up.
  Future<void> _resolveMissing() async {
    if (_resolving) {
      return;
    }
    final tracks = widget.tracks;
    if (tracks == null || tracks.isEmpty) {
      return;
    }
    _resolving = true;
    var found = false;
    try {
      for (final track in tracks.take(6)) {
        if (ArtworkService.isUsable(track.artworkUrl)) {
          continue;
        }
        final url = await ArtworkService.instance.resolve(
          artist: track.artist,
          title: track.title,
          duration: track.duration,
        );
        if (url != null) {
          found = true;
        }
      }
    } finally {
      _resolving = false;
    }
    if (found && mounted) {
      setState(() {});
    }
  }

  List<String> _candidates() {
    final tracks = widget.tracks;
    final Iterable<String> source;
    if (tracks != null && tracks.isNotEmpty) {
      source = tracks.map(
        (track) =>
            ArtworkService.instance.displayUrl(
              track.artworkUrl,
              artist: track.artist,
              title: track.title,
            ) ??
            '',
      );
    } else {
      source = widget.urls;
    }
    return source
        .map(TrackArtwork.getHighResUrl)
        .where(ArtworkService.isUsable)
        .toSet()
        .take(4)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final candidates = _candidates();

    Widget cell(int index) => TrackArtwork(
      url: candidates[index],
      size: null,
      borderRadius: BorderRadius.zero,
      placeholderColor: widget.placeholderColor,
      iconColor: widget.iconColor,
    );

    Widget content;
    switch (candidates.length) {
      case 0:
        content = _placeholder();
      case 1:
        content = cell(0);
      case 2:
        content = Row(
          children: [
            Expanded(child: cell(0)),
            Expanded(child: cell(1)),
          ],
        );
      case 3:
        content = Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: cell(0)),
                  Expanded(child: cell(1)),
                ],
              ),
            ),
            Expanded(child: cell(2)),
          ],
        );
      default:
        content = Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: cell(0)),
                  Expanded(child: cell(1)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: cell(2)),
                  Expanded(child: cell(3)),
                ],
              ),
            ),
          ],
        );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(width: widget.size, height: widget.size, child: content),
    );
  }

  Widget _placeholder() => ColoredBox(
    color: widget.placeholderColor,
    child: Icon(
      HookIcons.note,
      color: widget.iconColor,
      size: widget.size * 0.4,
    ),
  );
}
