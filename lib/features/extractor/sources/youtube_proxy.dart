import 'dart:async';
import 'dart:io';

/// The proxy selected after a successful YouTube request.
///
/// `youtube_explode_dart` runs through Dart's [HttpClient], while the audio
/// player may create a different client for a `googlevideo.com` stream. Keeping
/// the selected proxy here lets both parts use the same route.
class YouTubeProxyRegistry {
  YouTubeProxyRegistry._();

  static String? address;
}

/// Routes only YouTube-owned hosts through the detected local HTTP proxy.
/// Other app traffic remains untouched.
class SelectiveYouTubeProxyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.findProxy = (uri) {
      final proxy = YouTubeProxyRegistry.address;
      if (proxy != null && _isYouTubeHost(uri.host)) {
        return 'PROXY $proxy';
      }
      return 'DIRECT';
    };
    return client;
  }

  static bool _isYouTubeHost(String host) {
    final normalized = host.toLowerCase();
    return normalized == 'youtube.com' ||
        normalized.endsWith('.youtube.com') ||
        normalized == 'youtu.be' ||
        normalized.endsWith('.googlevideo.com') ||
        normalized.endsWith('.ytimg.com') ||
        normalized == 'youtubei.googleapis.com' ||
        normalized.endsWith('.youtubei.googleapis.com');
  }
}

/// Finds local HTTP proxy endpoints exposed by common desktop VPN clients.
///
/// An open port is only a candidate. The YouTube client validates it with a
/// real request before [YouTubeProxyRegistry.address] is changed.
class LocalProxyDetector {
  LocalProxyDetector._();

  static const _commonPorts = [10809, 2080, 7890, 12334, 8888, 10808];

  static Future<List<String>> detectCandidates() async {
    // Android/iOS VPNs route the process at OS level. Probing unrelated local
    // desktop-proxy ports on a phone cannot repair an upstream 403 response.
    if (Platform.isAndroid || Platform.isIOS) return const [];
    final candidates = <String>{};

    for (final name in [
      'HTTPS_PROXY',
      'https_proxy',
      'HTTP_PROXY',
      'http_proxy',
    ]) {
      final parsed = normalizeAddress(Platform.environment[name]);
      if (parsed != null) candidates.add(parsed);
    }

    if (Platform.isWindows) {
      final systemProxy = await _readWindowsProxy();
      if (systemProxy != null) candidates.add(systemProxy);
    }

    for (final port in _commonPorts) {
      candidates.add('127.0.0.1:$port');
    }

    final open = <String>[];
    for (final candidate in candidates) {
      if (await _isOpen(candidate)) open.add(candidate);
    }
    return open;
  }

  static String? normalizeAddress(String? value) {
    var raw = value?.trim() ?? '';
    if (raw.isEmpty) return null;
    if (raw.contains(';')) {
      final entries = raw.split(';').map((entry) => entry.trim());
      raw = entries.firstWhere(
        (entry) => entry.toLowerCase().startsWith('https='),
        orElse: () => entries.firstWhere(
          (entry) => entry.toLowerCase().startsWith('http='),
          orElse: () => entries.first,
        ),
      );
    }
    raw = raw.replaceFirst(RegExp(r'^(?:https?|proxy)='), '');
    final uri = Uri.tryParse(raw.contains('://') ? raw : 'http://$raw');
    if (uri == null || uri.host.isEmpty || uri.port == 0) return null;
    return '${uri.host}:${uri.port}';
  }

  static Future<String?> _readWindowsProxy() async {
    const key =
        r'HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings';
    try {
      final enabled = await Process.run('reg', [
        'query',
        key,
        '/v',
        'ProxyEnable',
      ]).timeout(const Duration(seconds: 2));
      if (enabled.exitCode != 0 ||
          !RegExp(r'ProxyEnable\s+REG_DWORD\s+0x1\b')
              .hasMatch(enabled.stdout.toString())) {
        return null;
      }
      final server = await Process.run('reg', [
        'query',
        key,
        '/v',
        'ProxyServer',
      ]).timeout(const Duration(seconds: 2));
      if (server.exitCode != 0) return null;
      final match = RegExp(
        r'ProxyServer\s+REG_SZ\s+(.+)$',
        multiLine: true,
      ).firstMatch(server.stdout.toString());
      return normalizeAddress(match?.group(1));
    } catch (_) {
      return null;
    }
  }

  static Future<bool> _isOpen(String address) async {
    final separator = address.lastIndexOf(':');
    if (separator <= 0) return false;
    final host = address.substring(0, separator);
    final port = int.tryParse(address.substring(separator + 1));
    if (port == null) return false;
    try {
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(milliseconds: 180),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}
