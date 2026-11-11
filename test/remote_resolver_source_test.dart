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
      } else if (request.uri.path == '/resolve' &&
          request.uri.queryParameters['id'] == 'aged') {
        response.statusCode = 403;
        response.write(
          jsonEncode({
            'error': 'age_restricted',
            'detail': 'sign in to confirm your age',
            'cookie_state': 'visitor_only',
          }),
        );
      } else if (request.uri.path == '/resolve' &&
          request.uri.queryParameters['id'] == 'stale') {
        response.statusCode = 403;
        response.write(jsonEncode({'error': 'cookies_stale'}));
      } else if (request.uri.path == '/resolve' &&
          request.uri.queryParameters['id'] == 'blocked') {
        response.statusCode = 403;
        response.write('<html>forbidden</html>');
      } else if (request.uri.path == '/cookies/upload') {
        final body = await utf8.decoder.bind(request).join();
        if (body.contains('BAD')) {
          response.statusCode = 400;
          response.write(jsonEncode({'error': 'no youtube cookies in the file'}));
        } else if (body.contains('VISITOR')) {
          response.write(
            jsonEncode({
              'ok': true,
              'cookies': 14,
              'signed_in': false,
              'logged_in': false,
              'warning': 'this export is not a signed-in YouTube session',
            }),
          );
        } else {
          response.write(
            jsonEncode({
              'ok': true,
              'cookies': 23,
              'signed_in': true,
              'logged_in': true,
              'warning': '',
            }),
          );
        }
      } else if (request.uri.path == '/cookies/verify') {
        response.write(
          jsonEncode({
            'configured': true,
            'healthy': true,
            'signed_in': true,
            'age_restricted_ready': true,
            'cookies': 23,
            'detail': '',
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

  test('an 18+ refusal surfaces instead of looking like a dead endpoint', () async {
    await expectLater(
      source.resolveTrack(_track(id: 'aged', source: TrackSource.remote)),
      throwsA(
        isA<AgeRestrictedStreamException>()
            .having((e) => e.reason, 'reason', 'age_restricted')
            .having((e) => e.isStaleCookies, 'isStaleCookies', isFalse),
      ),
    );
  });

  test('stale cookies are reported as their own reason', () async {
    await expectLater(
      source.resolveTrack(_track(id: 'stale', source: TrackSource.remote)),
      throwsA(
        isA<AgeRestrictedStreamException>()
            .having((e) => e.reason, 'reason', 'cookies_stale')
            .having((e) => e.isStaleCookies, 'isStaleCookies', isTrue),
      ),
    );
  });

  test('a plain 403 stays a failed endpoint, not an age refusal', () async {
    final stream = await source.resolveTrack(
      _track(id: 'blocked', source: TrackSource.remote),
    );
    expect(stream, isNull);
  });

  test('a signed-in export reports 18+ as unlocked', () async {
    final result = await source.uploadCookies('SID\tsomething\nLOGIN_INFO\tx\n');
    expect(result.isError, isFalse);
    expect(result.cookies, 23);
    expect(result.ready, isTrue);
  });

  test('a visitor export is accepted but does not claim 18+ works', () async {
    final result = await source.uploadCookies('VISITOR\n');
    expect(result.isError, isFalse);
    expect(result.signedIn, isFalse);
    expect(result.ready, isFalse);
    expect(result.warning, isNotEmpty);
  });

  test('a rejected file surfaces the server reason and keeps the jar', () async {
    final result = await source.uploadCookies('BAD\n');
    expect(result.isError, isTrue);
    expect(result.error, 'no youtube cookies in the file');
    expect(result.ready, isFalse);
  });

  test('cookie health reports the live verdict, not just the file', () async {
    final health = await source.cookieHealth();
    expect(health, isNotNull);
    expect(health!.ageRestrictedReady, isTrue);
    expect(health.needsSignIn, isFalse);
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
