import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/sources/remote_resolver_source.dart';

void main() {
  late HttpServer server;
  late RemoteResolverSource source;

  setUp(() async {
    source = RemoteResolverSource();
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final response = request.response
        ..headers.contentType = ContentType.json;
      if (request.uri.path == '/search') {
        response.write(
          jsonEncode([
            {
              'id': 'srv-1',
              'title': 'Sunflower',
              'artist': 'Post Malone',
              'album': 'Album',
              'duration': 158,
              'artwork': 'https://example.com/art.jpg',
            },
            {'title': 'missing id'},
            'not-a-map',
          ]),
        );
      } else if (request.uri.path == '/resolve' &&
          request.uri.queryParameters['id'] == 'srv-1') {
        response.write(
          jsonEncode({
            'url': 'http://127.0.0.1:${server.port}/stream/srv-1',
            'user_agent': 'HookTest/1.0',
            'ext': 'm4a',
          }),
        );
      } else {
        response.statusCode = 404;
      }
      await response.close();
    });
    RemoteResolverSource.endpoint = 'http://127.0.0.1:${server.port}/';
  });

  tearDown(() async {
    RemoteResolverSource.endpoint = null;
    await server.close(force: true);
  });

  test('is inert until an endpoint is configured', () async {
    RemoteResolverSource.endpoint = '';
    expect(RemoteResolverSource.enabled, isFalse);
    expect(await source.searchTracks('anything'), isEmpty);
    expect(
      await source.resolveTrack(_track(id: 'srv-1', source: TrackSource.remote)),
      isNull,
    );
  });

  test('falls back to the built-in endpoint when never configured', () {
    RemoteResolverSource.endpoint = null;
    expect(RemoteResolverSource.enabled, isTrue);
    expect(
      RemoteResolverSource.effectiveEndpoint,
      RemoteResolverSource.defaultEndpoint,
    );
  });

  test('custom endpoint overrides the built-in one', () {
    RemoteResolverSource.endpoint = 'http://127.0.0.1:${server.port}/';
    expect(RemoteResolverSource.effectiveEndpoint,
        'http://127.0.0.1:${server.port}/');
    RemoteResolverSource.endpoint = null;
    expect(RemoteResolverSource.effectiveEndpoint,
        RemoteResolverSource.defaultEndpoint);
  });

  test('search maps server items and skips malformed entries', () async {
    final tracks = await source.searchTracks('sunflower');
    expect(tracks, hasLength(1));
    final track = tracks.single;
    expect(track.id, 'srv-1');
    expect(track.title, 'Sunflower');
    expect(track.artist, 'Post Malone');
    expect(track.album, 'Album');
    expect(track.duration, const Duration(seconds: 158));
    expect(track.artworkUrl, 'https://example.com/art.jpg');
    expect(track.source, TrackSource.remote);
  });

  test('search ignores empty or blank queries', () async {
    expect(await source.searchTracks('   '), isEmpty);
  });

  test('resolve maps url, user agent and extension', () async {
    final stream = await source.resolveTrack(
      _track(id: 'srv-1', source: TrackSource.remote),
    );
    expect(stream, isNotNull);
    expect(stream!.url, 'http://127.0.0.1:${server.port}/stream/srv-1');
    expect(stream.headers['User-Agent'], 'HookTest/1.0');
    expect(stream.fileExtension, 'm4a');
    expect(stream.source, TrackSource.remote);
  });

  test('resolve returns null when the server rejects the id', () async {
    final stream = await source.resolveTrack(
      _track(id: 'unknown', source: TrackSource.remote),
    );
    expect(stream, isNull);
  });
}

MediaTrack _track({required String id, required TrackSource source}) {
  return MediaTrack(
    id: id,
    title: 'Sunflower',
    artist: 'Post Malone',
    duration: const Duration(seconds: 158),
    artworkUrl: '',
    source: source,
  );
}
