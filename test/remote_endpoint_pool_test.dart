import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/sources/remote_resolver_source.dart';
import 'package:http/http.dart' as http;

void _reset() {
  RemoteResolverSource.endpoint = null;
  RemoteResolverSource.fetchOverride = null;
  RemoteResolverSource.resetRotation();
}

http.Response _json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {
      'content-type': 'application/json',
    });

void main() {
  setUp(_reset);
  tearDown(_reset);

  test('a 429 from the primary rotates to the next endpoint', () async {
    final hosts = <String>[];
    RemoteResolverSource.fetchOverride = (uri) async {
      hosts.add(uri.host);
      if (uri.host.contains('workers.dev')) return _json('quota', 429);
      return _json([
        {
          'id': 'r1',
          'title': 'Song',
          'artist': 'Artist',
          'duration': 200,
          'artwork': '',
        },
      ]);
    };

    final results = await RemoteResolverSource().searchTracks('query');

    expect(results.single.id, 'r1');
    expect(hosts.first.contains('workers.dev'), isTrue);
    expect(hosts.last.contains('expresshost'), isTrue);
    // The working endpoint becomes sticky for everything that follows.
    expect(RemoteResolverSource.debugActiveEndpoint, contains('expresshost'));
  });

  test('the exhausted endpoint cools down until the next UTC midnight',
      () async {
    RemoteResolverSource.fetchOverride = (uri) async {
      if (uri.host.contains('workers.dev')) return _json('quota', 429);
      return _json([]);
    };
    await RemoteResolverSource().searchTracks('query');

    // The server download URL is built on the sticky endpoint now.
    final download = RemoteResolverSource().serverDownloadFor(
      const MediaTrack(
        id: '1',
        title: 't',
        artist: 'a',
        duration: Duration(minutes: 1),
        artworkUrl: '',
        source: TrackSource.soundcloud,
        streamUrl: 'https://soundcloud.com/artist/track',
      ),
    );
    expect(download!.url, contains('expresshost'));
  });

  test('a manual override pins one endpoint and disables rotation', () async {
    RemoteResolverSource.endpoint =
        'https://custom.example/base';
    final hosts = <String>[];
    RemoteResolverSource.fetchOverride = (uri) async {
      hosts.add(uri.host);
      return _json([]);
    };

    await RemoteResolverSource().searchTracks('query');
    await RemoteResolverSource().searchTracks('query');

    expect(hosts, everyElement('custom.example'));
  });

  test('every endpoint failing yields an empty result, not a crash',
      () async {
    RemoteResolverSource.fetchOverride = (uri) async {
      return _json('nope', 429);
    };

    final results = await RemoteResolverSource().searchTracks('query');
    expect(results, isEmpty);

    final stream = await RemoteResolverSource()
        .resolveTrack(_remoteTrack());
    expect(stream, isNull);
  });
}

MediaTrack _remoteTrack() => const MediaTrack(
      id: 'abc123',
      title: 'Song',
      artist: 'Artist',
      duration: Duration(minutes: 3),
      artworkUrl: '',
      source: TrackSource.remote,
    );
