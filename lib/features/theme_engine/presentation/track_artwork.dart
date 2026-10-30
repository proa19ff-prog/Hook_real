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

  /// Upgrades any thumbnail URL (SoundCloud / YouTube) to its highest resolution.
  static String getHighResUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    var result = rawUrl;
    // SoundCloud: upgrade -large, -t300x300, -badge to -t500x500
    if (result.contains('sndcdn.com')) {
      result = result
          .replaceAll('-large.', '-t500x500.')
          .replaceAll('-t300x300.', '-t500x500.')
          .replaceAll('-badge.', '-t500x500.')
          .replaceAll('-small.', '-t500x500.')
          .replaceAll('-tiny.', '-t500x500.');
    }
    // YouTube: upgrade low-res thumbnails to maxresdefault
    if (result.contains('ytimg.com')) {
      result = result.replaceFirst(
        RegExp(r'(mqdefault|hqdefault|sddefault|default)\.jpg'),
        'maxresdefault.jpg',
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = getHighResUrl(url);
    final targetPixelSize = (size * MediaQuery.devicePixelRatioOf(context)).round();

    final image = effectiveUrl.isEmpty
        ? null
        : Image.network(
            effectiveUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            cacheWidth: targetPixelSize.clamp(48, 1024),
            cacheHeight: targetPixelSize.clamp(48, 1024),
            filterQuality: FilterQuality.medium,
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
