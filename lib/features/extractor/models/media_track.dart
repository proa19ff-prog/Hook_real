enum TrackSource {
  youtube,
  soundcloud,
  local,
  spotify,
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
        orElse: () => TrackSource.youtube,
      ),
      streamUrl: json['streamUrl'] as String?,
      isCached: json['isCached'] as bool? ?? false,
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
