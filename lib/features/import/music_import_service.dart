import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../extractor/innertube/youtube_extractor.dart';
import '../extractor/models/media_track.dart';

enum ImportPlatform {
  spotify,
  youtubeMusic,
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

class MusicImportService {
  final Dio _dio;
  final YoutubeExplode _yt;

  MusicImportService({Dio? dio, YoutubeExplode? yt})
      : _dio = dio ?? Dio(),
        _yt = yt ?? YoutubeExplode();

  static ImportPlatform detectPlatform(String input) {
    final lower = input.trim().toLowerCase();
    if (lower.contains('spotify.com') ||
        lower.contains('spotify.link') ||
        lower.startsWith('spotify:')) {
      return ImportPlatform.spotify;
    }
    if (lower.contains('music.youtube.com') ||
        lower.contains('youtube.com') ||
        lower.contains('youtu.be')) {
      return ImportPlatform.youtubeMusic;
    }
    return ImportPlatform.unknown;
  }

  /// Imports tracks or playlists from Spotify or YouTube / YouTube Music.
  Future<ImportedCollection> importFromUrl(String url) async {
    final cleanUrl = url.trim();
    final platform = detectPlatform(cleanUrl);

    switch (platform) {
      case ImportPlatform.spotify:
        return _importSpotify(cleanUrl);
      case ImportPlatform.youtubeMusic:
        return _importYouTubeMusic(cleanUrl);
      case ImportPlatform.unknown:
        throw ArgumentError(
          'Неподдерживаемая ссылка. Вставьте ссылку на Spotify или YouTube Music.',
        );
    }
  }

  // --- SPOTIFY PARSER ---
  Future<ImportedCollection> _importSpotify(String rawUrl) async {
    // 1. Extract type and ID: playlist, album, track
    final uri = Uri.tryParse(rawUrl);
    String type = 'playlist';
    String id = '';

    if (rawUrl.startsWith('spotify:')) {
      final parts = rawUrl.split(':');
      if (parts.length >= 3) {
        type = parts[1];
        id = parts[2];
      }
    } else if (uri != null) {
      final segments = uri.pathSegments;
      for (var i = 0; i < segments.length - 1; i++) {
        if (segments[i] == 'playlist' ||
            segments[i] == 'album' ||
            segments[i] == 'track') {
          type = segments[i];
          id = segments[i + 1];
          break;
        }
      }
      if (id.isEmpty && segments.isNotEmpty) {
        id = segments.last;
      }
    }

    if (id.isEmpty) {
      throw const FormatException('Не удалось распознать идентификатор Spotify.');
    }

    // 2. Fetch public Spotify embed page
    final embedUrl = 'https://open.spotify.com/embed/$type/$id';
    final response = await _dio.get<String>(
      embedUrl,
      options: Options(
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
          'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
        },
      ),
    ).timeout(const Duration(seconds: 12));

    final html = response.data ?? '';

    // 3. Extract JSON state from __NEXT_DATA__
    final nextDataMatch = RegExp(
      r'<script id="__NEXT_DATA__" type="application/json">(.*?)</script>',
      dotAll: true,
    ).firstMatch(html);

    if (nextDataMatch != null) {
      try {
        final jsonStr = nextDataMatch.group(1)!;
        final json = jsonDecode(jsonStr) as Map<String, dynamic>;
        final state = json['props']?['pageProps']?['state']?['data'];

        if (state is Map<String, dynamic>) {
          if (type == 'playlist' && state['playlist'] != null) {
            final p = state['playlist'] as Map<String, dynamic>;
            final title = p['name'] as String? ?? 'Плейлист Spotify';
            final author = p['owner']?['name'] as String? ?? 'Spotify';
            final covers = p['coverArt']?['sources'] as List?;
            final coverUrl = covers != null && covers.isNotEmpty
                ? (covers.first['url'] as String? ?? '')
                : '';

            final tracks = <MediaTrack>[];
            final items = p['tracks']?['items'] as List? ?? [];
            for (final item in items) {
              if (item is! Map<String, dynamic>) continue;
              final t = item['track'] as Map<String, dynamic>? ?? item;
              final tName = t['name'] as String? ?? '';
              final artistsList = t['artists'] as List? ?? [];
              final artist = artistsList
                  .map((a) => (a is Map) ? (a['name'] ?? '') : a.toString())
                  .where((a) => a.toString().isNotEmpty)
                  .join(', ');
              final durMs = (t['duration'] as num?)?.toInt() ?? 0;
              final tCovers = t['album']?['coverArt']?['sources'] as List?;
              final tArt = tCovers != null && tCovers.isNotEmpty
                  ? (tCovers.first['url'] as String? ?? coverUrl)
                  : coverUrl;

              if (tName.isNotEmpty) {
                tracks.add(
                  MediaTrack(
                    id: 'sp_${t['id'] ?? tracks.length}',
                    title: tName,
                    artist: artist.isNotEmpty ? artist : author,
                    duration: Duration(milliseconds: durMs),
                    artworkUrl: tArt,
                    source: TrackSource.spotify,
                  ),
                );
              }
            }

            return ImportedCollection(
              title: title,
              author: author,
              artworkUrl: coverUrl,
              tracks: tracks,
              platform: ImportPlatform.spotify,
            );
          } else if (type == 'album' && state['album'] != null) {
            final a = state['album'] as Map<String, dynamic>;
            final title = a['name'] as String? ?? 'Альбом Spotify';
            final artistsList = a['artists'] as List? ?? [];
            final author = artistsList.isNotEmpty
                ? (artistsList.first['name'] as String? ?? 'Артист')
                : 'Spotify';
            final covers = a['coverArt']?['sources'] as List?;
            final coverUrl = covers != null && covers.isNotEmpty
                ? (covers.first['url'] as String? ?? '')
                : '';

            final tracks = <MediaTrack>[];
            final items = a['tracks']?['items'] as List? ?? [];
            for (final item in items) {
              if (item is! Map<String, dynamic>) continue;
              final t = item['track'] as Map<String, dynamic>? ?? item;
              final tName = t['name'] as String? ?? '';
              final durMs = (t['duration'] as num?)?.toInt() ?? 0;

              if (tName.isNotEmpty) {
                tracks.add(
                  MediaTrack(
                    id: 'sp_${t['id'] ?? tracks.length}',
                    title: tName,
                    artist: author,
                    duration: Duration(milliseconds: durMs),
                    artworkUrl: coverUrl,
                    source: TrackSource.spotify,
                  ),
                );
              }
            }

            return ImportedCollection(
              title: title,
              author: author,
              artworkUrl: coverUrl,
              tracks: tracks,
              platform: ImportPlatform.spotify,
            );
          } else if (type == 'track' && state['entity'] != null) {
            final e = state['entity'] as Map<String, dynamic>;
            final title = e['name'] as String? ?? 'Трек Spotify';
            final artistsList = e['artists'] as List? ?? [];
            final author = artistsList
                .map((a) => (a is Map) ? (a['name'] ?? '') : a.toString())
                .where((a) => a.toString().isNotEmpty)
                .join(', ');
            final coverUrl = e['visual']?['url'] as String? ?? '';
            final durMs = (e['duration'] as num?)?.toInt() ?? 0;

            final track = MediaTrack(
              id: 'sp_$id',
              title: title,
              artist: author,
              duration: Duration(milliseconds: durMs),
              artworkUrl: coverUrl,
              source: TrackSource.spotify,
            );

            return ImportedCollection(
              title: title,
              author: author,
              artworkUrl: coverUrl,
              tracks: [track],
              platform: ImportPlatform.spotify,
            );
          }
        }
      } catch (_) {}
    }

    // 4. Fallback oEmbed metadata
    try {
      final oembedRes = await _dio.get<Map<String, dynamic>>(
        'https://open.spotify.com/oembed',
        queryParameters: {'url': rawUrl},
      ).timeout(const Duration(seconds: 8));

      final data = oembedRes.data;
      if (data != null) {
        final title = data['title'] as String? ?? 'Spotify Track';
        final cover = data['thumbnail_url'] as String? ?? '';
        final track = MediaTrack(
          id: 'sp_$id',
          title: title,
          artist: 'Spotify',
          duration: const Duration(minutes: 3),
          artworkUrl: cover,
          source: TrackSource.spotify,
        );
        return ImportedCollection(
          title: title,
          author: 'Spotify',
          artworkUrl: cover,
          tracks: [track],
          platform: ImportPlatform.spotify,
        );
      }
    } catch (_) {}

    throw const FormatException('Не удалось извлечь список треков из Spotify.');
  }

  // --- YOUTUBE / YOUTUBE MUSIC PARSER ---
  Future<ImportedCollection> _importYouTubeMusic(String rawUrl) async {
    final uri = Uri.tryParse(rawUrl);
    final playlistId = uri?.queryParameters['list'];

    // 1. YouTube Playlist
    if (playlistId != null && playlistId.isNotEmpty) {
      final playlist = await _yt.playlists
          .get(playlistId)
          .timeout(const Duration(seconds: 10));

      final tracks = <MediaTrack>[];
      await for (final video in _yt.playlists.getVideos(playlistId)) {
        if (video.duration == null || video.duration! < const Duration(seconds: 5)) {
          continue;
        }
        tracks.add(
          MediaTrack(
            id: video.id.value,
            title: YouTubeExtractor.cleanTrackTitle(video.title),
            artist: video.author,
            duration: video.duration!,
            artworkUrl: video.thumbnails.highResUrl,
            source: TrackSource.youtube,
          ),
        );
        if (tracks.length >= 200) break; // Practical cap for mobile memory
      }

      return ImportedCollection(
        title: playlist.title,
        author: playlist.author,
        artworkUrl: playlist.thumbnails.highResUrl,
        tracks: tracks,
        platform: ImportPlatform.youtubeMusic,
      );
    }

    // 2. Single Video / Music Track
    String videoId = '';
    if (uri != null) {
      if (uri.host.contains('youtu.be') && uri.pathSegments.isNotEmpty) {
        videoId = uri.pathSegments.first;
      } else {
        videoId = uri.queryParameters['v'] ?? '';
      }
    }

    if (videoId.isNotEmpty) {
      final video =
          await _yt.videos.get(videoId).timeout(const Duration(seconds: 8));

      final track = MediaTrack(
        id: video.id.value,
        title: YouTubeExtractor.cleanTrackTitle(video.title),
        artist: video.author,
        duration: video.duration ?? Duration.zero,
        artworkUrl: video.thumbnails.highResUrl,
        source: TrackSource.youtube,
      );

      return ImportedCollection(
        title: track.title,
        author: track.artist,
        artworkUrl: track.artworkUrl,
        tracks: [track],
        platform: ImportPlatform.youtubeMusic,
      );
    }

    throw const FormatException('Не удалось распознать ссылку на YouTube Music.');
  }

  void close() {
    _dio.close(force: true);
    _yt.close();
  }
}
