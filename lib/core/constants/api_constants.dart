class ApiConstants {
  static const String lrclibBaseUrl = 'https://lrclib.net/api';
  static const String soundCloudApiBaseUrl = 'https://api-v2.soundcloud.com';

  // Public fallback client ID for SoundCloud v2 API (auto-refreshed dynamically if expired)
  static const String soundCloudFallbackClientId =
      'ZeISTkUY1Q4so1FsHJKZaJo898iWk0d3';

  // User-Agent used for SoundCloud API requests and CDN playback probes.
  static const String streamUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36';
}
