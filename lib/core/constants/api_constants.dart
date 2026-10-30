class ApiConstants {
  static const String lrclibBaseUrl = 'https://lrclib.net/api';
  static const String soundCloudApiBaseUrl = 'https://api-v2.soundcloud.com';

  // Public fallback client ID for SoundCloud v2 API (auto-refreshed dynamically if expired)
  static const String soundCloudFallbackClientId =
      'ZeISTkUY1Q4so1FsHJKZaJo898iWk0d3';

  // InnerTube Music client identification
  static const String innerTubeMusicClientName = 'WEB_REMIX';
  static const String innerTubeMusicClientVersion = '1.20240401.01.00';

  // Invidious fallback mirrors for network environments where YouTube DNS is blocked
  static const List<String> invidiousInstances = [
    'https://yt.chocolatemoo53.com',
    'https://invidious.jing.rocks',
    'https://invidious.privacydev.net',
  ];
}
