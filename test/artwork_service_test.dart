import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/artwork/artwork_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/fake_music_sources.dart';

/// JSON response body for [FakeHttpAdapter].
ResponseBody jsonBody(Object payload) => ResponseBody.fromString(
  jsonEncode(payload),
  200,
  headers: {
    Headers.contentTypeHeader: [Headers.jsonContentType],
  },
);

/// Deezer-shaped search payload with a single recording.
Map<String, dynamic> _deezerHit({
  required String artist,
  required String title,
  required String cover,
  int duration = 185,
}) => {
  'data': [
    {
      'title': title,
      'duration': duration,
      'artist': {'name': artist},
      'album': {'cover_xl': cover},
    },
  ],
};

/// iTunes-shaped search payload with a single recording.
Map<String, dynamic> _itunesHit({
  required String artist,
  required String title,
  required String cover,
  int millis = 185000,
}) => {
  'results': [
    {
      'trackName': title,
      'artistName': artist,
      'artworkUrl100': cover,
      'trackTimeMillis': millis,
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('url classification', () {
    test('YouTube video frames are never usable covers', () {
      const frames = [
        'https://i.ytimg.com/vi/abc123/maxresdefault.jpg',
        'https://img.youtube.com/vi/abc123/0.jpg',
        'https://www.youtube.com/vi/abc123/hqdefault.jpg',
      ];
      for (final url in frames) {
        expect(ArtworkService.isVideoThumbnail(url), isTrue, reason: url);
        expect(ArtworkService.isUsable(url), isFalse, reason: url);
      }
    });

    test('real art hosts stay usable, including YouTube Music art', () {
      const covers = [
        'https://lh3.googleusercontent.com/abc=w600',
        'https://yt3.ggpht.com/abc=w600',
        'https://i.scdn.co/image/abc',
        'https://cdn-images.dzcdn.net/images/cover/abc/1000x1000-000000-80-0-0.jpg',
        'https://is1-ssl.mzstatic.com/image/thumb/abc/1000x1000bb.jpg',
        'https://i1.sndcdn.com/artworks-abc-t500x500.jpg',
      ];
      for (final url in covers) {
        expect(ArtworkService.isVideoThumbnail(url), isFalse, reason: url);
        expect(ArtworkService.isUsable(url), isTrue, reason: url);
      }
    });

    test('empty, relative and non-http urls are not usable', () {
      expect(ArtworkService.isUsable(''), isFalse);
      expect(ArtworkService.isUsable('images/cover.jpg'), isFalse);
      expect(ArtworkService.isUsable('data:image/png;base64,AAAA'), isFalse);
    });
  });

  group('cache keys', () {
    test('punctuation, brackets and case do not multiply lookups', () {
      final a = ArtworkService.resolveKey(
        'Post Malone',
        'Sunflower (Spider-Man)',
      );
      final b = ArtworkService.resolveKey('post malone', 'sunflower');
      expect(a, isNotNull);
      expect(a, b);
    });

    test('a missing title has no key', () {
      expect(ArtworkService.resolveKey('Artist', ''), isNull);
      expect(ArtworkService.resolveKey(null, null), isNull);
    });

    test('a title alone still resolves', () {
      expect(ArtworkService.resolveKey('', 'Addiction'), '|addiction');
    });
  });

  group('matching', () {
    test('exact recording scores well above the threshold', () {
      final score = ArtworkService.scoreCandidate(
        artist: 'Post Malone, Swae Lee',
        title: 'Sunflower (Spider-Man: Into the Spider-Verse)',
        candidateArtist: 'Post Malone',
        candidateTitle: 'Sunflower (Spider-Man: Into the Spider-Verse)',
        expectedSeconds: 158,
        candidateSeconds: 158,
      );
      expect(score, greaterThanOrEqualTo(120));
    });

    test('a slightly misspelled title still matches the same artist', () {
      final score = ArtworkService.scoreCandidate(
        artist: 'Madkid',
        title: 'Sunflowee',
        candidateArtist: 'Madkid',
        candidateTitle: 'Sunflower',
      );
      expect(score, greaterThanOrEqualTo(120));
    });

    test('covers and karaoke versions are rejected', () {
      for (final title in [
        'Addiction (Cover)',
        'Addiction Karaoke Version',
        'Addiction Tribute',
      ]) {
        final score = ArtworkService.scoreCandidate(
          artist: 'Madkid',
          title: 'Addiction',
          candidateArtist: 'Madkid',
          candidateTitle: title,
        );
        expect(score, lessThan(120), reason: title);
      }
    });

    test('an unrelated artist is rejected even with the right title', () {
      final score = ArtworkService.scoreCandidate(
        artist: 'Madkid',
        title: 'Addiction',
        candidateArtist: 'Some Wedding Band',
        candidateTitle: 'Addiction',
      );
      expect(score, lessThan(120));
    });

    test('a wildly different runtime loses points', () {
      final close = ArtworkService.scoreCandidate(
        artist: 'Madkid',
        title: 'Addiction',
        candidateArtist: 'Madkid',
        candidateTitle: 'Addiction',
        expectedSeconds: 180,
        candidateSeconds: 182,
      );
      final far = ArtworkService.scoreCandidate(
        artist: 'Madkid',
        title: 'Addiction',
        candidateArtist: 'Madkid',
        candidateTitle: 'Addiction',
        expectedSeconds: 180,
        candidateSeconds: 420,
      );
      expect(close, greaterThan(far));
    });

    test('credit lists collapse to their first artist', () {
      expect(
        ArtworkService.primaryArtist('Post Malone, Swae Lee'),
        'Post Malone',
      );
      expect(ArtworkService.primaryArtist('A feat. B'), 'A');
      expect(ArtworkService.primaryArtist('A & B'), 'A');
      expect(ArtworkService.primaryArtist('MadK1d и Villian'), 'MadK1d');
      expect(ArtworkService.primaryArtist('  '), '');
    });

    test('splitArtists splits multi-artist credits into individual performers', () {
      expect(
        ArtworkService.splitArtists('MadK1d и Villian'),
        ['MadK1d', 'Villian'],
      );
      expect(
        ArtworkService.splitArtists('Madk1d & Villian'),
        ['Madk1d', 'Villian'],
      );
      expect(
        ArtworkService.splitArtists('Post Malone, Swae Lee'),
        ['Post Malone', 'Swae Lee'],
      );
      expect(
        ArtworkService.splitArtists('Miyagi & Andy Panda feat. TumaniYO'),
        ['Miyagi', 'Andy Panda', 'TumaniYO'],
      );
      expect(
        ArtworkService.splitArtists('Alan Walker'),
        ['Alan Walker'],
      );
    });

    test('digit-loosened artist variants stay comparable', () {
      final score = ArtworkService.scoreCandidate(
        artist: 'madk1d',
        title: 'Addiction',
        candidateArtist: 'Madkid',
        candidateTitle: 'Addiction',
      );
      expect(score, greaterThanOrEqualTo(120));
    });
  });

  group('resolution', () {
    test('prefers a Deezer album cover and remembers it', () async {
      final dio = Dio();
      final adapter = FakeHttpAdapter(
        (request) => jsonBody(
          _deezerHit(
            artist: 'Madkid',
            title: 'Addiction',
            cover:
                'https://cdn-images.dzcdn.net/images/cover/x/1000x1000-80.jpg',
          ),
        ),
      );
      dio.httpClientAdapter = adapter;
      final service = ArtworkService(dio: dio);

      final url = await service.resolve(
        artist: 'Madkid',
        title: 'Addiction',
        duration: const Duration(seconds: 185),
      );
      expect(
        url,
        'https://cdn-images.dzcdn.net/images/cover/x/1000x1000-80.jpg',
      );
      expect(adapter.requests.single.path, contains('api.deezer.com/search'));

      // The second call is served from memory, without another request.
      expect(await service.resolve(artist: 'Madkid', title: 'Addiction'), url);
      expect(adapter.requests, hasLength(1));
      dio.close(force: true);
    });

    test('falls back to iTunes when Deezer has no usable cover', () async {
      final dio = Dio();
      final adapter = FakeHttpAdapter((request) {
        if (request.path.contains('deezer')) {
          return jsonBody({
            'data': [
              {
                'title': 'Addiction',
                'duration': 185,
                'artist': {'name': 'Madkid'},
                'album': const <String, dynamic>{},
              },
            ],
          });
        }
        return jsonBody(
          _itunesHit(
            artist: 'Madkid',
            title: 'Addiction',
            cover: 'https://is1-ssl.mzstatic.com/image/thumb/abc/100x100bb.jpg',
          ),
        );
      });
      dio.httpClientAdapter = adapter;
      final service = ArtworkService(dio: dio);

      final url = await service.resolve(artist: 'Madkid', title: 'Addiction');
      expect(
        url,
        'https://is1-ssl.mzstatic.com/image/thumb/abc/1000x1000bb.jpg',
      );
      expect(adapter.requests.map((r) => r.path).toList(), hasLength(2));
      dio.close(force: true);
    });

    test('a video frame from the catalog is not accepted as a cover', () async {
      final dio = Dio();
      final adapter = FakeHttpAdapter(
        (request) => jsonBody(
          _deezerHit(
            artist: 'Madkid',
            title: 'Addiction',
            cover: 'https://i.ytimg.com/vi/abc/maxresdefault.jpg',
          ),
        ),
      );
      dio.httpClientAdapter = adapter;
      final service = ArtworkService(dio: dio);

      expect(
        await service.resolve(artist: 'Madkid', title: 'Addiction'),
        isNull,
      );
      dio.close(force: true);
    });

    test('displayUrl hides frames and prefers a resolved cover', () {
      final service = ArtworkService(dio: Dio());
      expect(
        service.displayUrl('https://i.ytimg.com/vi/abc/maxresdefault.jpg'),
        isNull,
      );
      expect(service.displayUrl(''), isNull);
      expect(
        service.displayUrl('https://i.scdn.co/image/abc'),
        'https://i.scdn.co/image/abc',
      );
    });

    test('resolved urls survive a restart through SharedPreferences', () async {
      final dio = Dio();
      dio.httpClientAdapter = FakeHttpAdapter(
        (request) => jsonBody(
          _deezerHit(
            artist: 'Madkid',
            title: 'Addiction',
            cover:
                'https://cdn-images.dzcdn.net/images/cover/y/1000x1000-80.jpg',
          ),
        ),
      );
      final first = ArtworkService(dio: dio);
      await first.resolve(artist: 'Madkid', title: 'Addiction');
      await first.persistNow();

      final second = ArtworkService(dio: dio);
      await second.hydrate();
      expect(
        second.cached('Madkid', 'Addiction'),
        'https://cdn-images.dzcdn.net/images/cover/y/1000x1000-80.jpg',
      );
      dio.close(force: true);
    });

    test('a broken persisted cache is ignored instead of throwing', () async {
      SharedPreferences.setMockInitialValues({
        'hook_artwork_urls_v1': 'not json at all',
      });
      final service = ArtworkService(dio: Dio());
      await service.hydrate();
      expect(service.cached('Madkid', 'Addiction'), isNull);
    });

    test(
      'a network failure resolves to null and is not retried at once',
      () async {
        final dio = Dio();
        var calls = 0;
        dio.httpClientAdapter = FakeHttpAdapter((request) {
          calls++;
          throw DioException(
            requestOptions: request,
            type: DioExceptionType.connectionError,
          );
        });
        final service = ArtworkService(dio: dio);

        expect(
          await service.resolve(artist: 'Madkid', title: 'Addiction'),
          isNull,
        );
        expect(
          await service.resolve(artist: 'Madkid', title: 'Addiction'),
          isNull,
        );
        expect(calls, 1);
        dio.close(force: true);
      },
    );

    test('concurrent lookups for one recording share a single request', () async {
      final dio = Dio();
      final adapter = FakeHttpAdapter(
        (request) => jsonBody(
          _deezerHit(
            artist: 'Madkid',
            title: 'Addiction',
            cover:
                'https://cdn-images.dzcdn.net/images/cover/z/1000x1000-80.jpg',
          ),
        ),
      );
      dio.httpClientAdapter = adapter;
      final service = ArtworkService(dio: dio);

      final results = await Future.wait([
        service.resolve(artist: 'Madkid', title: 'Addiction'),
        service.resolve(artist: 'Madkid', title: 'Addiction'),
        service.resolve(artist: 'Madkid', title: 'Addiction'),
      ]);
      expect(results.toSet(), hasLength(1));
      expect(adapter.requests, hasLength(1));
      dio.close(force: true);
    });

    test('resolves noisy YouTube video titles and channel artists', () async {
      final dio = Dio();
      final adapter = FakeHttpAdapter(
        (request) => jsonBody(
          _deezerHit(
            artist: 'Kush Kush',
            title: 'Sweet & Bitter',
            cover:
                'https://cdn-images.dzcdn.net/images/cover/kk/1000x1000-80.jpg',
          ),
        ),
      );
      dio.httpClientAdapter = adapter;
      final service = ArtworkService(dio: dio);

      final url = await service.resolve(
        artist: "Pablo's Dance Panic",
        title: 'Kush Kush – Sweet & Bitter [Official Video]',
      );
      expect(
        url,
        'https://cdn-images.dzcdn.net/images/cover/kk/1000x1000-80.jpg',
      );
      dio.close(force: true);
    });
  });

  group('title and artist cleaning', () {
    test('cleans channel artifacts from artist names', () {
      expect(ArtworkService.cleanArtist('Queen - Topic'), 'Queen');
      expect(ArtworkService.cleanArtist('EminemVEVO'), 'Eminem');
      expect(ArtworkService.cleanArtist('KatyPerryVEVO'), 'KatyPerry');
      expect(ArtworkService.cleanArtist('Post Malone'), 'Post Malone');
    });

    test('cleans video tags from titles', () {
      expect(
        ArtworkService.cleanTitle(
          'Sweet & Bitter [Official Video]',
        ),
        'Sweet & Bitter',
      );
      expect(
        ArtworkService.cleanTitle(
          'Bohemian Rhapsody (Official Video Remastered)',
        ),
        'Bohemian Rhapsody',
      );
      expect(
        ArtworkService.cleanTitle('Without Me (Lyrics)'),
        'Without Me',
      );
      expect(
        ArtworkService.cleanTitle('Sunflower [Visualizer]'),
        'Sunflower',
      );
      expect(
        ArtworkService.cleanTitle('Song Title | Official Music Video'),
        'Song Title',
      );
    });

    test('extracts artist and title from YouTube title formats', () {
      final (artist, title) = ArtworkService.extractArtistAndTitle(
        "Pablo's Dance Panic",
        'Kush Kush – Sweet & Bitter [Official Video]',
      );
      expect(artist, 'Kush Kush');
      expect(title, 'Sweet & Bitter');
    });

    test('scoreCandidate recognizes extracted artist and title', () {
      final score = ArtworkService.scoreCandidate(
        artist: "Pablo's Dance Panic",
        title: 'Kush Kush – Sweet & Bitter [Official Video]',
        candidateArtist: 'Kush Kush',
        candidateTitle: 'Sweet & Bitter',
      );
      expect(score, greaterThanOrEqualTo(120));
    });
  });
}
