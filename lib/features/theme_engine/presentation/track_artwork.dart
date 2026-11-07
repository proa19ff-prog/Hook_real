import 'package:flutter/material.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

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

  /// Normalizes artwork urls for reliable loading and upgrades SoundCloud and
  /// catalog thumbnails to their highest resolution.
  ///
  /// Saved playlists keep the url captured at save time, so two failure modes
  /// accumulate there: plain http urls (NetEase covers) now fail because the
  /// manifest blocks cleartext traffic, and signed YouTube thumbnails
  /// (`?sqp=…&rs=…`) expire on the CDN. Both are rewritten here.
  static String getHighResUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    var result = rawUrl;
    // The manifest blocks cleartext traffic; upgrade legacy http urls.
    if (result.startsWith('http://')) {
      result = 'https://${result.substring(7)}';
    }
    // YouTube: rebuild the canonical unsigned url for the same video id —
    // it outlives any signed sqp/rs variant.
    final youTube =
        RegExp(r'ytimg\.com/vi/([\w-]+)/').firstMatch(result);
    if (youTube != null) {
      return 'https://i.ytimg.com/vi/${youTube.group(1)}/hqdefault.jpg';
    }
    // SoundCloud: upgrade -large, -t300x300, -badge to -t500x500
    if (result.contains('sndcdn.com')) {
      result = result
          .replaceAll('-large.', '-t500x500.')
          .replaceAll('-t300x300.', '-t500x500.')
          .replaceAll('-badge.', '-t500x500.')
          .replaceAll('-small.', '-t500x500.')
          .replaceAll('-tiny.', '-t500x500.');
    }
    // Apple / iTunes / Spotify catalog: upgrade 100x100 to 600x600
    if (result.contains('mzstatic.com')) {
      result = result.replaceAll('100x100bb', '600x600bb');
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
        child: Icon(MingCuteIcons.mgc_music_line, color: iconColor),
      );
}
