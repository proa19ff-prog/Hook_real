import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/ui/hook_icons.dart';

import 'package:hook/features/artwork/artwork_service.dart';

/// Bounded artwork widget used in scrolling lists and player chrome.
///
/// Search results frequently contain remote 500px/1080px images.  Decoding
/// those at their source size for a 48px tile can block the raster thread on
/// lower-end Android devices.  `cacheWidth` keeps both the network image
/// cache and the decoded bitmap close to the size actually displayed.
///
/// The widget is also the last line of defence for cover quality:
///
///  * A YouTube video frame (`i.ytimg.com`) is never a real album cover. When
///    [artist]/[title] are known the frame is dropped and a square cover is
///    resolved from the catalog.
///  * An empty url is resolved the same way instead of leaving a bare icon.
///  * Covers are read from a small on-disk cache when possible, so lists keep
///    their artwork across launches and while offline.
///  * A failed download is retried once with a freshly resolved cover, then
///    falls back to a neutral placeholder instead of a broken tile.
class TrackArtwork extends StatefulWidget {
  final String url;
  final String? artist;
  final String? title;
  final Duration? duration;
  final double? size;
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
    this.artist,
    this.title,
    this.duration,
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
    final youTube = RegExp(r'ytimg\.com/vi/([\w-]+)/').firstMatch(result);
    if (youTube != null) {
      return 'https://i.ytimg.com/vi/${youTube.group(1)}/mqdefault.jpg';
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
    // Deezer: small covers ship as /250x250-... on the CDN.
    if (result.contains('dzcdn.net')) {
      result = result
          .replaceAll('/250x250-', '/1000x1000-')
          .replaceAll('/500x500-', '/1000x1000-');
    }
    // Apple / iTunes / Spotify catalog: upgrade 100x100 to 600x600
    if (result.contains('mzstatic.com')) {
      result = result.replaceAll('100x100bb', '600x600bb');
    }
    return result;
  }

  /// True when [url] points at a YouTube video frame rather than a cover.
  static bool isVideoThumbnail(String url) =>
      ArtworkService.isVideoThumbnail(url);

  @override
  State<TrackArtwork> createState() => _TrackArtworkState();
}

class _TrackArtworkState extends State<TrackArtwork> {
  String _url = '';
  String? _failedUrl;
  bool _lookupStarted = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  @override
  void didUpdateWidget(TrackArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url ||
        oldWidget.artist != widget.artist ||
        oldWidget.title != widget.title) {
      _failedUrl = null;
      _lookupStarted = false;
      _prepare();
    }
  }

  void _prepare() {
    final normalized = TrackArtwork.getHighResUrl(widget.url);
    if (ArtworkService.isUsable(normalized)) {
      _url = normalized;
      ArtworkService.instance.warm(_url);
      return;
    }
    final cached = ArtworkService.instance.cached(widget.artist, widget.title);
    if (cached != null && ArtworkService.isUsable(cached)) {
      _url = cached;
      ArtworkService.instance.warm(_url);
      return;
    }
    _url = '';
    _startLookup();
  }

  void _startLookup() {
    if (_lookupStarted) {
      return;
    }
    final artist = widget.artist?.trim() ?? '';
    final title = widget.title?.trim() ?? '';
    if (artist.isEmpty && title.isEmpty) {
      return;
    }
    _lookupStarted = true;
    unawaited(
      ArtworkService.instance
          .resolve(artist: artist, title: title, duration: widget.duration)
          .then((found) {
            if (!mounted || found == null) {
              return;
            }
            final highRes = TrackArtwork.getHighResUrl(found);
            if (!ArtworkService.isUsable(highRes) || highRes == _url) {
              return;
            }
            setState(() {
              _url = highRes;
              _failedUrl = null;
            });
            ArtworkService.instance.warm(highRes);
          }),
    );
  }

  /// Called by the image builder when a cover fails to decode or download.
  /// Schedules a catalog lookup (once) and hides the broken image.
  void _handleLoadError() {
    final failed = _url;
    if (failed.isEmpty) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _failedUrl == failed) {
        return;
      }
      setState(() {
        _failedUrl = failed;
        if (_url == failed) {
          _url = '';
        }
      });
      _startLookup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final ratio = MediaQuery.devicePixelRatioOf(context);

    Widget buildImage(double? width, int cacheWidth) {
      if (_url.isEmpty || _url == _failedUrl) {
        return _placeholder();
      }
      return _ArtworkImage(
        key: ValueKey<String>(_url),
        url: _url,
        width: width,
        cacheWidth: cacheWidth,
        onError: _handleLoadError,
        placeholder: _placeholder(),
      );
    }

    final Widget content;
    if (size == null) {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : 96.0;
          final pixels = (width * ratio).round().clamp(48, 1024);
          return buildImage(null, pixels);
        },
      );
    } else {
      final pixels = (size * ratio).round().clamp(48, 1024);
      content = buildImage(size, pixels);
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: ColoredBox(color: widget.placeholderColor, child: content),
    );
  }

  Widget _placeholder() {
    final size = widget.size;
    return SizedBox(
      width: size,
      height: size,
      child: Icon(HookIcons.note, color: widget.iconColor),
    );
  }
}

class _ArtworkImage extends StatefulWidget {
  final String url;
  final double? width;
  final int cacheWidth;
  final VoidCallback onError;
  final Widget placeholder;

  const _ArtworkImage({
    super.key,
    required this.url,
    required this.width,
    required this.cacheWidth,
    required this.onError,
    required this.placeholder,
  });

  @override
  State<_ArtworkImage> createState() => _ArtworkImageState();
}

class _ArtworkImageState extends State<_ArtworkImage> {
  ImageProvider? _provider;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final width = widget.cacheWidth;
    // Show the network image immediately: waiting for the disk probe would
    // leave a hole in the list for a frame on every cold tile.
    _provider = ResizeImage(
      NetworkImage(widget.url),
      width: width,
      height: width,
      allowUpscaling: false,
    );
    // If the bytes were cached during an earlier session, swap to the local
    // file — it paints instantly and works offline.
    ArtworkService.instance
        .existingFile(widget.url)
        .then((file) {
          if (file == null || !mounted) {
            return;
          }
          setState(() {
            _provider = ResizeImage(
              FileImage(file),
              width: width,
              height: width,
              allowUpscaling: false,
            );
          });
        })
        .catchError((Object _) {});
    ArtworkService.instance.warm(widget.url);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;
    if (provider == null) {
      return widget.placeholder;
    }
    return Image(
      image: provider,
      width: widget.width ?? double.infinity,
      height: widget.width ?? double.infinity,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: child,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        widget.onError();
        return widget.placeholder;
      },
    );
  }
}
