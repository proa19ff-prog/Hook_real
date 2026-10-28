import 'package:flutter/material.dart';

/// Small, bounded artwork widget used in scrolling lists and player chrome.
///
/// Search results frequently contain remote 500px/1080px images.  Decoding
/// those at their source size for a 48px tile can block the raster thread on
/// lower-end Android devices.  `cacheWidth` keeps both the network image
/// cache and the decoded bitmap close to the size actually displayed.
class TrackArtwork extends StatelessWidget {
  final String url;
  final double size;
  final Color placeholderColor;
  final Color iconColor;
  final BorderRadius borderRadius;

  const TrackArtwork({
    super.key,
    required this.url,
    required this.size,
    required this.placeholderColor,
    required this.iconColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  Widget build(BuildContext context) {
    final image = url.isEmpty
        ? null
        : Image.network(
            url,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(1, 512),
            cacheHeight: (size * MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(1, 512),
            filterQuality: FilterQuality.low,
            errorBuilder: (_, __, ___) => _placeholder(),
          );

    return ClipRRect(
      borderRadius: borderRadius,
      child: ColoredBox(
        color: placeholderColor,
        child: image ?? _placeholder(),
      ),
    );
  }

  Widget _placeholder() => SizedBox(
        width: size,
        height: size,
        child: Icon(Icons.music_note_rounded, color: iconColor),
      );
}
