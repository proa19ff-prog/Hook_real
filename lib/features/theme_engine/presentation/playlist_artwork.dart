import 'package:flutter/material.dart';

import 'track_artwork.dart';
import '../../../core/ui/hook_icons.dart';

/// Cover for a playlist: a collage of the first distinct track artworks,
/// a single cover when only one is available, or a music-note placeholder.
///
/// Playlists keep the artwork url captured when each track was saved, so
/// imported collections often carry empty urls and old entries carry ones
/// that stopped resolving. Deriving the cover from several tracks at render
/// time keeps the tab alive without a storage migration.
class PlaylistArtwork extends StatelessWidget {
  final Iterable<String> urls;
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
  });

  @override
  Widget build(BuildContext context) {
    final candidates = urls
        .map(TrackArtwork.getHighResUrl)
        .where((url) => url.isNotEmpty)
        .toSet()
        .take(4)
        .toList(growable: false);

    Widget content;
    switch (candidates.length) {
      case 0:
        content = _placeholder();
      case 1:
        content = _Cell(url: candidates[0], placeholderColor: placeholderColor, iconColor: iconColor);
      case 2:
        content = Row(
          children: [
            Expanded(child: _Cell(url: candidates[0], placeholderColor: placeholderColor, iconColor: iconColor)),
            Expanded(child: _Cell(url: candidates[1], placeholderColor: placeholderColor, iconColor: iconColor)),
          ],
        );
      case 3:
        content = Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _Cell(url: candidates[0], placeholderColor: placeholderColor, iconColor: iconColor)),
                  Expanded(child: _Cell(url: candidates[1], placeholderColor: placeholderColor, iconColor: iconColor)),
                ],
              ),
            ),
            Expanded(child: _Cell(url: candidates[2], placeholderColor: placeholderColor, iconColor: iconColor)),
          ],
        );
      default:
        content = Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _Cell(url: candidates[0], placeholderColor: placeholderColor, iconColor: iconColor)),
                  Expanded(child: _Cell(url: candidates[1], placeholderColor: placeholderColor, iconColor: iconColor)),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _Cell(url: candidates[2], placeholderColor: placeholderColor, iconColor: iconColor)),
                  Expanded(child: _Cell(url: candidates[3], placeholderColor: placeholderColor, iconColor: iconColor)),
                ],
              ),
            ),
          ],
        );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(width: size, height: size, child: content),
    );
  }

  Widget _placeholder() => ColoredBox(
        color: placeholderColor,
        child: Icon(
          HookIcons.note,
          color: iconColor,
          size: size * 0.4,
        ),
      );
}

/// One collage cell: the normalized artwork, scaled down to the cell size.
class _Cell extends StatelessWidget {
  final String url;
  final Color placeholderColor;
  final Color iconColor;

  const _Cell({
    required this.url,
    required this.placeholderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final target = (MediaQuery.devicePixelRatioOf(context) * 96).round().clamp(48, 512);
    return ColoredBox(
      color: placeholderColor,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        cacheWidth: target,
        cacheHeight: target,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => Center(
          child: Icon(HookIcons.note, color: iconColor),
        ),
      ),
    );
  }
}
