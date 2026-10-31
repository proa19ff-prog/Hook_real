import 'dart:convert';

import 'package:dio/dio.dart';

import '../extractor/models/media_track.dart';

enum ImportPlatform {
  spotify,
  text,
  unknown,
}

class ImportedCollection {
  final String title;
  final String author;
  final String artworkUrl;
  final List<MediaTrack> tracks;
  final ImportPlatform platform;

  const ImportedCollection({
    required this.title,
    required this.author,
    required this.artworkUrl,
    required this.tracks,
    required this.platform,
  });
}

class MusicImportException implements Exception {
  final String message;
  final bool blocked;

  const MusicImportException(this.message, {this.blocked = false});

  @override
  String toString() => message;
}

class MusicImportService {
  final Dio _dio;

  MusicImportService({Dio? dio}) : _dio = dio ?? Dio();

  static ImportPlatform detectPlatform(String input) {
    final value = input.trim();
    final lower = value.toLowerCase();
    if (lower.contains('spotify.com') ||
        lower.contains('spotify.link') ||
        lower.startsWith('spotify:')) {
      return ImportPlatform.spotify;
    }
    if (value.contains('\n') ||
        RegExp(r'\S+\s+(?:—|–|-)\s+\S+').hasMatch(value)) {
      return ImportPlatform.text;
    }
    return ImportPlatform.unknown;
  }

  Future<ImportedCollection> importFromUrl(String url) async {
    if (detectPlatform(url) != ImportPlatform.spotify) {
      throw ArgumentError(
          'Неподдерживаемая ссылка. Вставьте ссылку на Spotify.');
    }
    return _importSpotify(url.trim());
  }

  Future<ImportedCollection> importFromText(
    String text, {
    String? title,
  }) async {
    final tracks = parseTrackList(text);
    if (tracks.isEmpty) {
      throw const FormatException(
          'Не удалось найти треки в вставленном тексте.');
    }
    return ImportedCollection(
      title:
          title?.trim().isNotEmpty == true ? title!.trim() : 'Импорт из текста',
      author: 'Импорт',
      artworkUrl: '',
      tracks: tracks,
      platform: ImportPlatform.text,
    );
  }

  /// Parses plain `Артист — Трек` lines and common Exportify/TuneMyMusic CSV.
  static List<MediaTrack> parseTrackList(String input) {
    final source = input.replaceAll('\r\n', '\n').trim();
    if (source.isEmpty) return const [];
    final lines = source.split('\n');
    final csv = _parseCsv(lines);
    if (csv != null) return csv;

    final tracks = <MediaTrack>[];
    final seen = <String>{};
    for (final raw in lines) {
      var line = raw.trim();
      if (line.isEmpty || RegExp(r'^(https?://|spotify:)').hasMatch(line)) {
        continue;
      }
      line = line.replaceFirst(RegExp(r'^(?:\d+\s*[.)]|[-*•])\s*'), '');
      line = line.replaceFirst(RegExp(r'\s+\(?\d{1,2}:\d{2}\)?\s*$'), '');
      if (_isHeader(line)) continue;

      String artist = '';
      String title = line;
      final separator = RegExp(r'\s+(?:—|–|\|)\s+|\s+-\s+').firstMatch(line);
      if (separator != null) {
        artist = line.substring(0, separator.start).trim();
        title = line.substring(separator.end).trim();
      }
      if (title.isEmpty) continue;
      final key = '${artist.toLowerCase()}|${title.toLowerCase()}';
      if (!seen.add(key)) continue;
      tracks.add(_textTrack(artist, title, tracks.length));
      if (tracks.length >= 500) break;
    }
    return tracks;
  }

  static List<MediaTrack>? _parseCsv(List<String> lines) {
    final headerIndex = lines.indexWhere((line) {
      final lower = line.toLowerCase();
      return lower.contains('track name') ||
          (lower.contains('title') && lower.contains('artist'));
    });
    if (headerIndex < 0) return null;
    final header =
        _csvRow(lines[headerIndex]).map((e) => e.toLowerCase()).toList();
    final titleIndex = header.indexWhere(
      (h) => h.contains('track name') || h == 'title' || h.contains('track'),
    );
    final artistIndex = header.indexWhere(
      (h) => h.contains('artist name') || h == 'artist' || h.contains('artist'),
    );
    if (titleIndex < 0) return null;

    final tracks = <MediaTrack>[];
    final seen = <String>{};
    for (final line in lines.skip(headerIndex + 1)) {
      if (line.trim().isEmpty) continue;
      final row = _csvRow(line);
      if (titleIndex >= row.length) continue;
      final title = row[titleIndex].trim();
      final artist = artistIndex >= 0 && artistIndex < row.length
          ? row[artistIndex].replaceAll(';', ',').trim()
          : '';
      if (title.isEmpty) continue;
      final key = '${artist.toLowerCase()}|${title.toLowerCase()}';
      if (!seen.add(key)) continue;
      tracks.add(_textTrack(artist, title, tracks.length));
      if (tracks.length >= 500) break;
    }
    return tracks;
  }

  static List<String> _csvRow(String line) {
    final values = <String>[];
    final value = StringBuffer();
    var quoted = false;
    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (quoted && i + 1 < line.length && line[i + 1] == '"') {
          value.write('"');
          i++;
        } else {
          quoted = !quoted;
        }
      } else if (char == ',' && !quoted) {
        values.add(value.toString());
        value.clear();
      } else {
        value.write(char);
      }
    }
    values.add(value.toString());
    return values;
  }

  static bool _isHeader(String line) {
    final lower = line.toLowerCase();
    return lower == 'track name' ||
        lower == 'title' ||
        lower.contains('artist name') && lower.contains('track');
  }

  static MediaTrack _textTrack(String artist, String title, int index) {
    final value =
        '${artist.trim().toLowerCase()}|${title.trim().toLowerCase()}';
    var hash = 2166136261;
    for (final codeUnit in value.codeUnits) {
      hash ^= codeUnit;
      hash = (hash * 16777619) & 0x7fffffff;
    }
    return MediaTrack(
      id: 'txt_${hash.toRadixString(16)}_$index',
      title: title,
      artist: artist,
      duration: Duration.zero,
      artworkUrl: '',
      source: TrackSource.spotify,
    );
  }

  Future<ImportedCollection> _importSpotify(String rawUrl) async {
    final canonicalUrl = await _resolveSpotifyUrl(rawUrl);
    final parsed = _spotifyPath(canonicalUrl);
    final type = parsed.$1;
    final id = parsed.$2;
    if (id.isEmpty) {
      throw const FormatException(
          'Не удалось распознать идентификатор Spotify.');
    }

    final response = await _dio
        .get<String>(
          'https://open.spotify.com/embed/$type/$id',
          options: Options(
            validateStatus: (_) => true,
            headers: {
              'User-Agent':
                  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124 Safari/537.36',
              'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
            },
          ),
        )
        .timeout(const Duration(seconds: 15));
    final html = response.data ?? '';
    final blocked = response.statusCode == 451 ||
        RegExp(
          r'(451|not available in your country|unavailable in your region)',
          caseSensitive: false,
        ).hasMatch(html);
    if (blocked) {
      throw const MusicImportException(
        'Spotify недоступен в этом регионе. Используйте VPN или вставьте список треков текстом.',
        blocked: true,
      );
    }

    final match = RegExp(
      r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>',
      dotAll: true,
    ).firstMatch(html);
    if (match == null) {
      throw const FormatException('Spotify не вернул данные плейлиста.');
    }
    final json = jsonDecode(match.group(1)!) as Map<String, dynamic>;
    final data = json['props']?['pageProps']?['state']?['data'];
    if (data is! Map) {
      throw const FormatException('Неверный формат данных Spotify.');
    }
    return _parseSpotifyData(
      Map<String, dynamic>.from(data),
      type: type,
      id: id,
    );
  }

  Future<String> _resolveSpotifyUrl(String rawUrl) async {
    if (!rawUrl.toLowerCase().contains('spotify.link')) return rawUrl;
    try {
      final response = await _dio
          .get<String>(
            rawUrl,
            options:
                Options(followRedirects: true, validateStatus: (_) => true),
          )
          .timeout(const Duration(seconds: 8));
      return response.realUri.toString();
    } catch (_) {
      return rawUrl;
    }
  }

  static (String, String) _spotifyPath(String rawUrl) {
    if (rawUrl.startsWith('spotify:')) {
      final parts = rawUrl.split(':');
      return (
        parts.length > 2 ? parts[1] : 'playlist',
        parts.length > 2 ? parts[2] : ''
      );
    }
    final uri = Uri.tryParse(rawUrl);
    if (uri == null) return ('playlist', '');
    for (var i = 0; i + 1 < uri.pathSegments.length; i++) {
      final segment = uri.pathSegments[i];
      if (segment == 'playlist' || segment == 'album' || segment == 'track') {
        return (segment, uri.pathSegments[i + 1]);
      }
    }
    return ('playlist', '');
  }

  static ImportedCollection _parseSpotifyData(
    Map<String, dynamic> data, {
    required String type,
    required String id,
  }) {
    final entity = data['entity'] is Map
        ? Map<String, dynamic>.from(data['entity'] as Map)
        : null;
    final legacy =
        data[type] is Map ? Map<String, dynamic>.from(data[type] as Map) : null;
    final root = entity ?? legacy;
    if (root == null) throw const FormatException('Список Spotify пуст.');

    final title = _string(root, ['name', 'title']) ?? 'Импорт Spotify';
    final author = _author(root) ?? 'Spotify';
    final cover = _image(root) ?? '';
    final rawItems = root['trackList'] is List
        ? root['trackList'] as List
        : root['tracks'] is Map && root['tracks']['items'] is List
            ? root['tracks']['items'] as List
            : const [];
    final tracks = <MediaTrack>[];
    for (final raw in rawItems) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final track = item['track'] is Map
          ? Map<String, dynamic>.from(item['track'] as Map)
          : item;
      final trackTitle = _string(track, ['title', 'name']);
      if (trackTitle == null || trackTitle.isEmpty) continue;
      final artist = _author(track) ?? _string(item, ['subtitle']) ?? author;
      final duration = _duration(track['duration'] ?? item['duration']);
      final trackId = _spotifyId(track['uri']) ??
          _string(track, ['uid', 'id']) ??
          '${id}_${tracks.length}';
      tracks.add(MediaTrack(
        id: 'sp_$trackId',
        title: trackTitle,
        artist: artist,
        duration: duration,
        artworkUrl: _image(track) ?? cover,
        source: TrackSource.spotify,
      ));
    }
    if (tracks.isEmpty && type == 'track') {
      final trackTitle = _string(root, ['name', 'title']) ?? title;
      tracks.add(MediaTrack(
        id: 'sp_$id',
        title: trackTitle,
        artist: author,
        duration: _duration(root['duration']),
        artworkUrl: cover,
        source: TrackSource.spotify,
      ));
    }
    return ImportedCollection(
      title: title,
      author: author,
      artworkUrl: cover,
      tracks: tracks,
      platform: ImportPlatform.spotify,
    );
  }

  static String? _string(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  static String? _author(Map<String, dynamic> map) {
    final artists = map['artists'];
    if (artists is List) {
      final names = artists
          .whereType<Map>()
          .map((a) => a['name']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      if (names.isNotEmpty) return names.join(', ');
    }
    final owner = map['owner'];
    if (owner is Map && owner['name'] is String) return owner['name'] as String;
    return _string(map, ['subtitle', 'artist']);
  }

  static String? _image(Map<String, dynamic> map) {
    final candidates = <dynamic>[
      map['coverArt'] is Map ? map['coverArt']['sources'] : null,
      map['visualIdentity'] is Map ? map['visualIdentity']['image'] : null,
      map['images'],
      map['visual'] is Map ? map['visual']['url'] : null,
    ];
    for (final value in candidates) {
      if (value is String && value.isNotEmpty) return value;
      if (value is List) {
        for (final source in value) {
          if (source is Map && source['url'] is String) {
            return source['url'] as String;
          }
        }
      }
    }
    return null;
  }

  static String? _spotifyId(dynamic uri) {
    if (uri is! String) return null;
    final parts = uri.split(':');
    return parts.length >= 3 ? parts.last : null;
  }

  static Duration _duration(dynamic value) {
    if (value is num) return Duration(milliseconds: value.toInt());
    if (value is String) {
      final seconds = double.tryParse(value);
      if (seconds != null) {
        return Duration(milliseconds: (seconds * 1000).round());
      }
    }
    return Duration.zero;
  }

  void close() => _dio.close(force: true);
}
