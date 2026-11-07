import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../extractor/models/media_track.dart';
import '../extractor/spotify/spotify_catalog_service.dart';
import '../extractor/sources/remote_resolver_source.dart';
import '../extractor/stream_resolver.dart';

enum ImportPlatform { spotify, text, csv, youtube, deezer, unknown }

enum ImportFileError {
  tooLarge,
  unsupported,
  invalidEncoding,
  invalidCsv,
  missingColumns,
  empty,
  tooManyTracks,
}

class MusicImportFileException implements Exception {
  final ImportFileError kind;

  const MusicImportFileException(this.kind);
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
  final SpotifyCatalogService _catalog;

  MusicImportService({Dio? dio, SpotifyCatalogService? catalog})
    : _dio = dio ?? Dio(),
      _catalog = catalog ?? SpotifyCatalogService();

  static const maxFileBytes = 10 * 1024 * 1024;
  static const maxTracks = 10000;
  static const _titleColumns = {'track name', 'title', 'track title', 'name'};
  static const _artistColumns = {
    'artist name(s)',
    'artist names',
    'artist name',
    'artist',
    'artists',
  };

  static ImportPlatform detectPlatform(String input) {
    final value = input.replaceFirst('﻿', '').trim();
    final uri = Uri.tryParse(value);
    if (value.startsWith('spotify:') ||
        uri != null &&
            const {'https', 'http'}.contains(uri.scheme) &&
            const {
              'open.spotify.com',
              'spotify.com',
              'www.spotify.com',
              'spotify.link',
            }.contains(uri.host.toLowerCase())) {
      return ImportPlatform.spotify;
    }
    // URL hosts first: a pasted link is never a track list, even when the
    // text heuristic below would find a dash somewhere in it.
    if (uri != null && const {'https', 'http'}.contains(uri.scheme)) {
      final host = uri.host.toLowerCase();
      if (const {
        'youtube.com',
        'www.youtube.com',
        'm.youtube.com',
        'music.youtube.com',
        'youtu.be',
      }.contains(host)) {
        return ImportPlatform.youtube;
      }
      if (const {
        'deezer.com',
        'www.deezer.com',
        'link.deezer.com',
        'deezer.page.link',
      }.contains(host)) {
        return ImportPlatform.deezer;
      }
    }
    if (_csvDelimiter(value) != null) return ImportPlatform.csv;
    if (value.contains('\n') ||
        RegExp(r'\S+\s+(?:—|–|-)\s+\S+').hasMatch(value)) {
      return ImportPlatform.text;
    }
    return ImportPlatform.unknown;
  }

  static String decodeFile(List<int> bytes, String fileName) {
    if (bytes.length > maxFileBytes) {
      throw const MusicImportFileException(ImportFileError.tooLarge);
    }
    final extension = fileName.split('.').last.toLowerCase();
    if (extension != 'csv' && extension != 'txt') {
      throw const MusicImportFileException(ImportFileError.unsupported);
    }
    try {
      final text = utf8.decode(bytes).replaceFirst('﻿', '');
      if (text.contains('\u0000')) {
        throw const MusicImportFileException(ImportFileError.invalidEncoding);
      }
      return text;
    } on FormatException {
      throw const MusicImportFileException(ImportFileError.invalidEncoding);
    }
  }

  Future<ImportedCollection> importFromCsv(String csv, {String? title}) async {
    final tracks = await compute(parseCsv, csv);
    return ImportedCollection(
      title: title?.trim().isNotEmpty == true ? title!.trim() : 'Exportify',
      author: 'CSV',
      artworkUrl: '',
      tracks: tracks,
      platform: ImportPlatform.csv,
    );
  }

  Future<ImportedCollection> importFromUrl(String url) async {
    switch (detectPlatform(url)) {
      case ImportPlatform.spotify:
        return _importSpotify(url.trim());
      case ImportPlatform.youtube:
        return _importViaResolver(url.trim(), platform: ImportPlatform.youtube);
      case ImportPlatform.deezer:
        return _importViaResolver(
          url.trim(),
          platform: ImportPlatform.deezer,
        );
      default:
        throw ArgumentError(
          'Неподдерживаемая ссылка. Вставьте ссылку на плейлист Spotify, '
          'YouTube Music или Deezer.',
        );
    }
  }

  Future<ImportedCollection> importFromText(
    String text, {
    String? title,
    bool resolveTracks = true,
  }) async {
    if (detectPlatform(text) == ImportPlatform.csv) {
      return importFromCsv(text, title: title);
    }
    final parsedTracks = parseTrackList(text);
    if (parsedTracks.isEmpty) {
      throw const FormatException(
        'Не удалось найти треки в вставленном тексте.',
      );
    }
    final tracks = resolveTracks
        ? await _resolveTextTracks(parsedTracks)
        : parsedTracks;
    return ImportedCollection(
      title: title?.trim().isNotEmpty == true
          ? title!.trim()
          : 'Импорт из текста',
      author: 'Импорт',
      artworkUrl: tracks
          .firstWhere(
            (track) => track.artworkUrl.isNotEmpty,
            orElse: () => tracks.first,
          )
          .artworkUrl,
      tracks: tracks,
      platform: ImportPlatform.text,
    );
  }

  /// YouTube Music / YouTube and Deezer playlists are read by the resolver
  /// server (yt-dlp + Deezer's public API): the device's network often
  /// cannot reach either host directly. YouTube entries carry real video
  /// ids and play as-is; Deezer entries are placeholders matched against
  /// the catalog exactly like a pasted track list.
  Future<ImportedCollection> _importViaResolver(
    String url, {
    required ImportPlatform platform,
  }) async {
    if (!RemoteResolverSource.enabled) {
      throw const MusicImportException(
        'Для импорта с YouTube Music и Deezer нужен сервер-резолвер: '
        'включите его в настройках или вставьте треки списком.',
        blocked: true,
      );
    }
    final base = RemoteResolverSource.effectiveEndpoint.replaceFirst(
      RegExp(r'/+$'),
      '',
    );
    final response = await _dio
        .get<Map<String, dynamic>>(
          '$base/playlist',
          queryParameters: {'url': url},
          options: Options(
            validateStatus: (_) => true,
            headers: {'User-Agent': 'Hook-Music-Player/1.0'},
          ),
        )
        .timeout(const Duration(seconds: 120));
    final data = response.data;
    if (response.statusCode != 200 || data == null) {
      throw const MusicImportException(
        'Сервер не смог прочитать этот плейлист. Убедитесь, что он '
        'публичный, или вставьте треки списком.',
      );
    }
    final entries = data['tracks'];
    if (entries is! List || entries.isEmpty) {
      throw const MusicImportFileException(ImportFileError.empty);
    }
    final playlistTitle = (data['title'] as String? ?? '').trim();

    final tracks = <MediaTrack>[];
    final seen = <String>{};
    for (final entry in entries) {
      if (entry is! Map) continue;
      final id = (entry['id'] as String? ?? '').trim();
      final trackTitle = (entry['title'] as String? ?? '').trim();
      final artist = (entry['artist'] as String? ?? '').trim();
      if (id.isEmpty || trackTitle.isEmpty || !seen.add(id)) continue;
      final seconds = (entry['duration'] as num?)?.toInt() ?? 0;
      final artwork = (entry['artwork'] as String? ?? '').trim();
      switch (platform) {
        case ImportPlatform.youtube:
          tracks.add(
            MediaTrack(
              id: id,
              title: trackTitle,
              artist: artist.isEmpty ? 'YouTube' : artist,
              duration: Duration(seconds: seconds),
              artworkUrl: artwork.isNotEmpty
                  ? artwork
                  : 'https://i.ytimg.com/vi/$id/hqdefault.jpg',
              source: TrackSource.youtubeMusic,
            ),
          );
        case ImportPlatform.deezer:
          tracks.add(
            _textTrack(artist, trackTitle, tracks.length).copyWith(
              duration: Duration(seconds: seconds),
              artworkUrl: artwork,
            ),
          );
        default:
          break;
      }
      if (tracks.length > maxTracks) {
        throw const MusicImportFileException(ImportFileError.tooManyTracks);
      }
    }
    if (tracks.isEmpty) {
      throw const MusicImportFileException(ImportFileError.empty);
    }

    final resolved = platform == ImportPlatform.deezer
        ? await _resolveTextTracks(tracks)
        : tracks;
    return ImportedCollection(
      title: playlistTitle.isNotEmpty
          ? playlistTitle
          : platform == ImportPlatform.youtube
          ? 'Импорт с YouTube'
          : 'Импорт с Deezer',
      author: platform == ImportPlatform.youtube ? 'YouTube' : 'Deezer',
      artworkUrl: resolved
          .firstWhere(
            (track) => track.artworkUrl.isNotEmpty,
            orElse: () => resolved.first,
          )
          .artworkUrl,
      tracks: resolved,
      platform: platform,
    );
  }

  /// Resolves pasted entries against the catalog before the playlist is saved.
  /// A small worker pool avoids both a burst of requests and slow serial imports;
  /// unmatched lines are deliberately retained so a temporary network failure
  /// never destroys the user's exported playlist.
  Future<List<MediaTrack>> _resolveTextTracks(List<MediaTrack> tracks) async {
    final resolved = List<MediaTrack?>.filled(tracks.length, null);
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= tracks.length) return;
        final source = tracks[index];
        try {
          final query = '${source.artist} ${source.title}'.trim();
          final results = await Future.wait([
            _catalog.searchTracks(query, country: 'us'),
            _catalog.searchTracks(query, country: 'ru'),
          ]);
          final candidates = <MediaTrack>[...results[0], ...results[1]]
              .where(
                (candidate) =>
                    StreamResolver.isCatalogMetadataMatch(source, candidate),
              )
              .toList();
          if (candidates.isNotEmpty) {
            final scored =
                candidates
                    .map(
                      (candidate) => (
                        track: candidate,
                        score: StreamResolver.scoreTrack(candidate, query),
                      ),
                    )
                    .toList()
                  ..sort((a, b) => b.score.compareTo(a.score));
            // Do not replace a precise pasted title with a vague catalog hit.
            if (scored.first.score >= 220) resolved[index] = scored.first.track;
          }
        } catch (_) {
          // Keep the lightweight text placeholder below.
        }
      }
    }

    final workers = List.generate(
      tracks.length < 4 ? tracks.length : 4,
      (_) => worker(),
    );
    await Future.wait(workers);
    return List<MediaTrack>.generate(
      tracks.length,
      (index) => resolved[index] ?? tracks[index],
      growable: false,
    );
  }

  /// Parses plain `Артист — Трек` lines and common Exportify/TuneMyMusic CSV.
  static List<MediaTrack> parseTrackList(String input) {
    final source = input.replaceFirst('﻿', '').replaceAll('\r\n', '\n').trim();
    if (source.isEmpty) return const [];
    if (_csvDelimiter(source) != null) return parseCsv(source);
    final lines = source.split('\n');

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
      if (tracks.length > maxTracks) {
        throw const MusicImportFileException(ImportFileError.tooManyTracks);
      }
    }
    return tracks;
  }

  static List<MediaTrack> parseCsv(String input) {
    if (utf8.encode(input).length > maxFileBytes) {
      throw const MusicImportFileException(ImportFileError.tooLarge);
    }
    final source = input
        .replaceFirst('﻿', '')
        .replaceAll('\r\n', '\n')
        .replaceAll('\r', '\n')
        .trim();
    if (source.isEmpty) {
      throw const MusicImportFileException(ImportFileError.empty);
    }
    final delimiter = _csvDelimiter(source);
    if (delimiter == null) {
      throw const MusicImportFileException(ImportFileError.missingColumns);
    }
    final records = _csvRecords(source, delimiter).iterator;
    records.moveNext();
    final header = records.current
        .map((cell) => cell.trim().toLowerCase())
        .toList();
    final titleIndex = header.indexWhere(_titleColumns.contains);
    final artistIndex = header.indexWhere(_artistColumns.contains);
    final uriIndex = header.indexWhere(
      (cell) => cell == 'track uri' || cell == 'track url',
    );
    final albumIndex = header.indexWhere(
      (cell) => cell == 'album name' || cell == 'album',
    );
    final durationIndex = header.indexWhere(
      (cell) => cell == 'duration (ms)' || cell == 'duration_ms',
    );
    final tracks = <MediaTrack>[];
    while (records.moveNext()) {
      final row = records.current;
      if (row.every((cell) => cell.trim().isEmpty)) continue;
      if (row.length != header.length || row[titleIndex].trim().isEmpty) {
        throw const MusicImportFileException(ImportFileError.invalidCsv);
      }
      final title = row[titleIndex].trim();
      final artist = row[artistIndex]
          .split(';')
          .map((name) => name.trim())
          .where((name) => name.isNotEmpty)
          .join(', ');
      final uri = uriIndex < 0 ? '' : row[uriIndex].trim();
      final id =
          RegExp(r'^spotify:track:([A-Za-z0-9]+)$').firstMatch(uri)?.group(1) ??
          RegExp(
            r'^https?://open\.spotify\.com/track/([A-Za-z0-9]+)(?:[?#].*)?$',
          ).firstMatch(uri)?.group(1);
      final duration = durationIndex < 0 || row[durationIndex].trim().isEmpty
          ? 0
          : int.tryParse(row[durationIndex].trim());
      if (duration == null || duration < 0) {
        throw const MusicImportFileException(ImportFileError.invalidCsv);
      }
      tracks.add(
        _textTrack(artist, title, tracks.length).copyWith(
          id: id == null ? null : 'sp_$id',
          album: albumIndex < 0 ? null : row[albumIndex].trim(),
          duration: Duration(milliseconds: duration),
        ),
      );
      if (tracks.length > maxTracks) {
        throw const MusicImportFileException(ImportFileError.tooManyTracks);
      }
    }
    if (tracks.isEmpty) {
      throw const MusicImportFileException(ImportFileError.empty);
    }
    return tracks;
  }

  static String? _csvDelimiter(String source) {
    final header = source.split('\n').first;
    for (final delimiter in const [',', ';', '\t']) {
      try {
        final cells = _csvRecords(
          header,
          delimiter,
        ).firstOrNull?.map((cell) => cell.trim().toLowerCase()).toSet();
        if (cells != null &&
            cells.any(_titleColumns.contains) &&
            cells.any(_artistColumns.contains)) {
          return delimiter;
        }
      } on MusicImportFileException {
        continue;
      }
    }
    return null;
  }

  static Iterable<List<String>> _csvRecords(
    String source,
    String delimiter,
  ) sync* {
    var row = <String>[];
    final value = StringBuffer();
    var quoted = false;
    var afterQuote = false;
    for (var i = 0; i < source.length; i++) {
      final char = source[i];
      if (quoted) {
        if (char == '"') {
          if (i + 1 < source.length && source[i + 1] == '"') {
            value.write('"');
            i++;
          } else {
            quoted = false;
            afterQuote = true;
          }
        } else {
          value.write(char);
        }
      } else if (char == delimiter || char == '\n') {
        row.add(value.toString());
        value.clear();
        afterQuote = false;
        if (char == '\n') {
          yield row;
          row = <String>[];
        }
      } else if (afterQuote) {
        if (char != ' ' && char != '\t' && char != '\r') {
          throw const MusicImportFileException(ImportFileError.invalidCsv);
        }
      } else if (char == '"') {
        if (value.toString().trim().isNotEmpty) {
          throw const MusicImportFileException(ImportFileError.invalidCsv);
        }
        value.clear();
        quoted = true;
      } else {
        value.write(char);
      }
    }
    if (quoted) {
      throw const MusicImportFileException(ImportFileError.invalidCsv);
    }
    if (value.isNotEmpty || row.isNotEmpty || afterQuote) {
      yield [...row, value.toString()];
    }
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
        'Не удалось распознать идентификатор Spotify.',
      );
    }

    final response = await _dio
        .get<String>(
          'https://open.spotify.com/embed/$type/$id',
          options: Options(
            validateStatus: (_) => true,
            headers: {
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 Chrome/124 Safari/537.36',
              'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
            },
          ),
        )
        .timeout(const Duration(seconds: 15));
    final html = response.data ?? '';
    final blocked =
        response.statusCode == 451 ||
        RegExp(
          r'(451|not available in your country|unavailable in your region)',
          caseSensitive: false,
        ).hasMatch(html);
    if (blocked) {
      throw const MusicImportException(
        'Spotify не отдал этот плейлист в вашем регионе. Скопируйте треки и вставьте их списком или CSV.',
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
    return parseSpotifyData(
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
            options: Options(
              followRedirects: true,
              validateStatus: (_) => true,
            ),
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
        parts.length > 2 ? parts[2] : '',
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

  /// Parses both the current embedded Spotify state shape and the older
  /// playlist/album payloads. Keeping this public makes the parser testable
  /// without attempting a real Spotify request (which can be region-blocked).
  static ImportedCollection parseSpotifyData(
    Map<String, dynamic> data, {
    required String type,
    required String id,
  }) {
    final entity = _map(data['entity']);
    final legacy = _map(data[type]);
    final root = entity ?? legacy ?? data;
    final title = _string(root, ['name', 'title']) ?? 'Импорт Spotify';
    final author = _author(root) ?? 'Spotify';
    final cover = _image(root) ?? '';
    final rawItems = _extractTrackItems(root, data);
    final tracks = <MediaTrack>[];
    final seen = <String>{};

    for (final raw in rawItems) {
      final item = _map(raw);
      if (item == null) continue;
      // New embeds place the actual record at entry.track; legacy data may
      // use item.track or contain the track directly.
      final track = _map(item['track']) ?? item;
      final trackTitle = _string(track, ['title', 'name']);
      if (trackTitle == null || trackTitle.isEmpty) continue;
      final artist =
          _author(track) ??
          _author(item) ??
          _string(item, ['subtitle', 'artist']) ??
          author;
      final trackId =
          _spotifyId(track['uri']) ??
          _spotifyId(item['uri']) ??
          _string(track, ['uid', 'id']) ??
          _string(item, ['uid', 'id']) ??
          '${id}_${tracks.length}';
      final key =
          '$trackId|${trackTitle.toLowerCase()}|${artist.toLowerCase()}';
      if (!seen.add(key)) continue;
      tracks.add(
        MediaTrack(
          id: trackId.startsWith('sp_') ? trackId : 'sp_$trackId',
          title: trackTitle,
          artist: artist,
          album: _string(track, ['album', 'albumName']) ?? title,
          duration: _duration(track['duration'] ?? item['duration']),
          artworkUrl: _image(track) ?? _image(item) ?? cover,
          source: TrackSource.spotify,
        ),
      );
    }

    if (tracks.isEmpty && type == 'track') {
      final trackTitle = _string(root, ['name', 'title']) ?? title;
      tracks.add(
        MediaTrack(
          id: 'sp_$id',
          title: trackTitle,
          artist: author,
          duration: _duration(root['duration']),
          artworkUrl: cover,
          source: TrackSource.spotify,
        ),
      );
    }
    return ImportedCollection(
      title: title,
      author: author,
      artworkUrl: cover,
      tracks: tracks,
      platform: ImportPlatform.spotify,
    );
  }

  static Map<String, dynamic>? _map(dynamic value) {
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  /// Handles `entity.trackList`, `trackList.items`, legacy `tracks.items`, and
  /// the nested `state.data.entity.trackList` representations Spotify has used.
  static List<dynamic> _extractTrackItems(
    Map<String, dynamic> root,
    Map<String, dynamic> data,
  ) {
    final candidates = <dynamic>[
      root['trackList'],
      root['tracks'],
      root['items'],
      data['trackList'],
      data['tracks'],
      _map(data['entity'])?['trackList'],
    ];
    for (final candidate in candidates) {
      final items = _itemsFrom(candidate);
      if (items.isNotEmpty) return items;
    }
    return const [];
  }

  static List<dynamic> _itemsFrom(dynamic value, {int depth = 0}) {
    if (value is List) return List<dynamic>.from(value);
    if (value is! Map || depth > 3) return const [];
    for (final key in const ['items', 'tracks', 'trackList', 'entries']) {
      final items = _itemsFrom(value[key], depth: depth + 1);
      if (items.isNotEmpty) return items;
    }
    return const [];
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
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map((artist) => _string(artist, ['name', 'title']) ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      if (names.isNotEmpty) return names.join(', ');
    }
    if (artists is Map) {
      final items = _itemsFrom(artists);
      final names = items
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map((artist) => _string(artist, ['name', 'title']) ?? '')
          .where((name) => name.isNotEmpty)
          .toList();
      if (names.isNotEmpty) return names.join(', ');
    }
    final owner = _map(map['owner']);
    if (owner != null) return _string(owner, ['name', 'displayName']);
    return _string(map, ['subtitle', 'artist', 'artistName']);
  }

  static String? _image(Map<String, dynamic> map) {
    final candidates = <dynamic>[
      _map(map['coverArt'])?['sources'],
      _map(map['visualIdentity'])?['image'],
      map['images'],
      _map(map['visual'])?['url'],
      map['image'],
      map['artworkUrl'],
    ];
    for (final value in candidates) {
      if (value is String && value.isNotEmpty) return value;
      if (value is Map) {
        final url = value['url'];
        if (url is String && url.isNotEmpty) return url;
      }
      if (value is List) {
        for (final source in value) {
          final sourceMap = _map(source);
          final url = sourceMap?['url'];
          if (url is String && url.isNotEmpty) return url;
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
      final trimmed = value.trim();
      final numeric = double.tryParse(trimmed);
      if (numeric != null) {
        // Embed durations are milliseconds; very small numeric strings occur
        // only in legacy second-based values.
        final milliseconds = numeric > 1000 ? numeric : numeric * 1000;
        return Duration(milliseconds: milliseconds.round());
      }
      final match = RegExp(r'^(\d+):(\d{1,2})$').firstMatch(trimmed);
      if (match != null) {
        final seconds =
            int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
        return Duration(seconds: seconds);
      }
    }
    return Duration.zero;
  }

  void close() {
    _dio.close(force: true);
    _catalog.close();
  }
}
