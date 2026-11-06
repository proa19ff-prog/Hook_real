import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extractor/models/media_track.dart';

final youtubeAccountServiceProvider = Provider<YouTubeAccountService>(
  (ref) => YouTubeAccountService(),
);

class YouTubeAccountStatus {
  final bool supported;
  final bool systemServicesAvailable;
  final String? systemServicesVersion;
  final String? revancedGmsCoreVersion;
  final bool revancedMusicInstalled;
  const YouTubeAccountStatus({
    this.supported = false,
    this.systemServicesAvailable = false,
    this.systemServicesVersion,
    this.revancedGmsCoreVersion,
    this.revancedMusicInstalled = false,
  });
  factory YouTubeAccountStatus.fromMap(Map<Object?, Object?> map) =>
      YouTubeAccountStatus(
        supported: map['supported'] == true,
        systemServicesAvailable: map['systemServicesAvailable'] == true,
        systemServicesVersion: map['systemServicesVersion'] as String?,
        revancedGmsCoreVersion: map['revancedGmsCoreVersion'] as String?,
        revancedMusicInstalled: map['revancedMusicInstalled'] == true,
      );
}

class YouTubeProfile {
  final String channelId;
  final String name;
  final String artworkUrl;
  const YouTubeProfile({
    required this.channelId,
    required this.name,
    this.artworkUrl = '',
  });
  factory YouTubeProfile.fromMap(Map<Object?, Object?> map) => YouTubeProfile(
    channelId: map['channelId'] as String,
    name: map['name'] as String,
    artworkUrl: map['artworkUrl'] as String? ?? '',
  );
}

class YouTubePlaylist {
  final String id;
  final String title;
  final String artworkUrl;
  final int itemCount;
  const YouTubePlaylist({
    required this.id,
    required this.title,
    this.artworkUrl = '',
    this.itemCount = 0,
  });
  factory YouTubePlaylist.fromMap(Map<Object?, Object?> map) => YouTubePlaylist(
    id: map['id'] as String,
    title: map['title'] as String,
    artworkUrl: map['artworkUrl'] as String? ?? '',
    itemCount: (map['itemCount'] as num?)?.toInt() ?? 0,
  );
}

class YouTubePage<T> {
  final List<T> items;
  final String? nextPageToken;
  final int unavailableCount;
  const YouTubePage(
    this.items, {
    this.nextPageToken,
    this.unavailableCount = 0,
  });
}

class YouTubeImportResult {
  final List<MediaTrack> tracks;
  final int unavailableCount;
  const YouTubeImportResult(this.tracks, this.unavailableCount);
}

/// OAuth stays in the native API client. Dart receives display metadata only.
class YouTubeAccountService {
  static const channel = MethodChannel('hook/youtube_account');

  Future<Map<Object?, Object?>> _call(
    String method, [
    Map<String, Object?>? args,
  ]) async {
    final map = await channel.invokeMapMethod<Object?, Object?>(method, args);
    if (map == null) throw PlatformException(code: 'unavailable');
    return map;
  }

  Future<YouTubeAccountStatus> status() async {
    try {
      return YouTubeAccountStatus.fromMap(await _call('status'));
    } on MissingPluginException {
      return const YouTubeAccountStatus();
    }
  }

  Future<YouTubeProfile?> profile() async {
    try {
      final map = await channel.invokeMapMethod<Object?, Object?>('profile');
      return map == null ? null : YouTubeProfile.fromMap(map);
    } on MissingPluginException {
      return null;
    }
  }

  Future<YouTubeProfile> connect() async =>
      YouTubeProfile.fromMap(await _call('connect'));
  Future<void> disconnect() => channel.invokeMethod<void>('disconnect');
  Future<void> cancel() async {
    try {
      await channel.invokeMethod<void>('cancel');
    } on MissingPluginException {
      /* Unsupported platforms can still leave. */
    } on PlatformException {
      /* The activity may have already closed. */
    }
  }

  String? _next(Map<Object?, Object?> map) {
    final token = map['nextPageToken'] as String?;
    return token == null || token.isEmpty ? null : token;
  }

  Future<YouTubePage<YouTubePlaylist>> playlists({String? pageToken}) async {
    final map = await _call('playlists', {'pageToken': pageToken});
    final items = (map['items'] as List)
        .map(
          (item) =>
              YouTubePlaylist.fromMap(Map<Object?, Object?>.from(item as Map)),
        )
        .toList();
    return YouTubePage(items, nextPageToken: _next(map));
  }

  Future<YouTubePage<MediaTrack>> playlistTracks(
    String playlistId, {
    String? pageToken,
  }) async {
    final map = await _call('playlistTracks', {
      'playlistId': playlistId,
      'pageToken': pageToken,
    });
    final items = (map['items'] as List).map((item) {
      final record = Map<Object?, Object?>.from(item as Map);
      final id = record['id'] as String;
      if (!RegExp(r'^[\w-]{11}$').hasMatch(id)) {
        throw PlatformException(code: 'unavailable');
      }
      return MediaTrack(
        id: id,
        title: record['title'] as String,
        artist: record['artist'] as String,
        artworkUrl: record['artworkUrl'] as String? ?? '',
        duration: Duration(
          milliseconds: (record['durationMs'] as num?)?.toInt() ?? 0,
        ),
        source: TrackSource.youtubeMusic,
      );
    }).toList();
    return YouTubePage(
      items,
      nextPageToken: _next(map),
      unavailableCount: (map['unavailableCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<YouTubeImportResult> importPlaylist(
    YouTubePlaylist playlist, {
    required bool Function() isActive,
    required void Function(int) onProgress,
  }) async {
    const limit = 10000;
    if (playlist.itemCount > limit) throw PlatformException(code: 'tooLarge');
    final tracks = <MediaTrack>[];
    final seenTokens = <String>{};
    String? token;
    var unavailable = 0;
    do {
      if (!isActive()) throw PlatformException(code: 'cancelled');
      final page = await playlistTracks(playlist.id, pageToken: token);
      if (!isActive()) throw PlatformException(code: 'cancelled');
      tracks.addAll(
        page.items,
      ); // Keep playlist order and duplicate recordings.
      unavailable += page.unavailableCount;
      if (tracks.length + unavailable > limit || seenTokens.length >= 200) {
        throw PlatformException(code: 'tooLarge');
      }
      onProgress(tracks.length);
      token = page.nextPageToken;
      if (token != null && !seenTokens.add(token)) {
        throw PlatformException(code: 'unavailable');
      }
    } while (token != null);
    return YouTubeImportResult(List.unmodifiable(tracks), unavailable);
  }
}
