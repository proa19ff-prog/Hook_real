enum TrackSource {
  soundcloud,
  local,
  // Retained for saved libraries: this is catalog metadata, not Spotify audio.
  spotify,
  // A distinct key keeps old `youtube` catalog entries on the migration path.
  youtubeMusic,
  audius;

  String get label => switch (this) {
    soundcloud => 'SoundCloud',
    local => 'На устройстве',
    spotify => 'Каталог',
    youtubeMusic => 'YouTube',
    audius => 'Audius',
  };

  bool get isCatalog => this == spotify;
}

class MediaTrack {
  final String id;
  final String title;
  final String artist;
  final String? album;
  final Duration duration;
  final String artworkUrl;
  final TrackSource source;
  final String? streamUrl;
  final bool isCached;

  /// Public view/play count supplied by the source; zero means unknown.
  /// Only used to rank otherwise relevant recordings, never to infer identity.
  final int playbackCount;

  const MediaTrack({
    required this.id,
    required this.title,
    required this.artist,
    this.album,
    required this.duration,
    required this.artworkUrl,
    required this.source,
    this.streamUrl,
    this.isCached = false,
    this.playbackCount = 0,
  });

  MediaTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? album,
    Duration? duration,
    String? artworkUrl,
    TrackSource? source,
    String? streamUrl,
    bool? isCached,
    int? playbackCount,
  }) {
    return MediaTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      duration: duration ?? this.duration,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      source: source ?? this.source,
      streamUrl: streamUrl ?? this.streamUrl,
      isCached: isCached ?? this.isCached,
      playbackCount: playbackCount ?? this.playbackCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'album': album,
      'durationMs': duration.inMilliseconds,
      'artworkUrl': artworkUrl,
      'source': source.name,
      'streamUrl': streamUrl,
      'isCached': isCached,
      if (playbackCount > 0) 'playbackCount': playbackCount,
    };
  }

  factory MediaTrack.fromJson(Map<String, dynamic> json) {
    final durationValue = json['durationMs'];
    return MediaTrack(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown title',
      artist: json['artist']?.toString() ?? 'Unknown artist',
      album: json['album'] as String?,
      duration: Duration(
        milliseconds: durationValue is num ? durationValue.toInt() : 0,
      ),
      artworkUrl: json['artworkUrl'] as String? ?? '',
      source: TrackSource.values.firstWhere(
        (e) => e.name == json['source'],
        // Legacy `youtube` entries were catalog records, not playable video IDs.
        orElse: () => TrackSource.spotify,
      ),
      streamUrl: json['streamUrl'] as String?,
      isCached: json['isCached'] as bool? ?? false,
      playbackCount:
          json['playbackCount'] is num &&
              (json['playbackCount'] as num).isFinite &&
              (json['playbackCount'] as num) > 0
          ? (json['playbackCount'] as num).toInt()
          : 0,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaTrack &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          source == other.source;

  @override
  int get hashCode => id.hashCode ^ source.hashCode;
}
