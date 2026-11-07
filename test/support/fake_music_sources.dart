import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/models/resolved_stream.dart';
import 'package:hook/features/extractor/soundcloud/soundcloud_extractor.dart';
import 'package:hook/features/extractor/sources/music_source.dart';
import 'package:hook/features/extractor/spotify/spotify_catalog_service.dart';

typedef Search = FutureOr<List<MediaTrack>> Function(String query);

class FakeMusicSource implements MusicSource {
  @override
  final TrackSource source;
  Search? onSearch;
  FutureOr<ResolvedStream?> Function(MediaTrack track)? onResolve;
  final queries = <String>[];
  final resolved = <MediaTrack>[];
  bool closed = false;

  FakeMusicSource(this.source, {this.onSearch, this.onResolve});
  @override
  Future<List<MediaTrack>> searchTracks(String query, {int limit = 20}) async {
    queries.add(query);
    return await onSearch?.call(query) ?? const [];
  }

  @override
  Future<ResolvedStream?> resolveTrack(MediaTrack track) async {
    resolved.add(track);
    return onResolve?.call(track);
  }

  @override
  void close() => closed = true;
}

class FakeSoundCloud extends SoundCloudExtractor {
  Search? onSearch;
  FutureOr<String?> Function(String id)? onResolve;
  final queries = <String>[];
  final resolved = <String>[];
  FakeSoundCloud({this.onSearch, this.onResolve});

  @override
  Future<List<MediaTrack>> searchTracks(String query,
      {int limit = 25, bool isRetry = false}) async {
    queries.add(query);
    return await onSearch?.call(query) ?? const [];
  }

  @override
  Future<ResolvedAudioStream?> resolveAudioStream(String id,
      {bool isRetry = false, bool fullFileOnly = false}) async {
    resolved.add(id);
    final url = await onResolve?.call(id);
    if (url == null || url.isEmpty) return null;
    return ResolvedAudioStream(url);
  }
}

class FakeCatalog extends SpotifyCatalogService {
  final Search? onSearch;
  final queries = <String>[];
  FakeCatalog({this.onSearch});
  @override
  Future<List<MediaTrack>> searchTracks(String query,
      {int limit = 25, String? country}) async {
    queries.add(query);
    return await onSearch?.call(query) ?? const [];
  }
}

class FakeHttpAdapter implements HttpClientAdapter {
  final FutureOr<ResponseBody> Function(RequestOptions request) respond;
  final requests = <RequestOptions>[];
  FakeHttpAdapter(this.respond);

  @override
  Future<ResponseBody> fetch(RequestOptions options,
      Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    requests.add(options);
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(Object? data, {int status = 200}) =>
    ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: ['application/json']
      },
    );
