import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/extractor/models/media_track.dart';
import 'package:hook/features/extractor/soundcloud/soundcloud_extractor.dart';
import 'package:hook/features/extractor/sources/audius_source.dart';
import 'package:hook/features/extractor/sources/youtube_music_source.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'support/fake_music_sources.dart';

Map<String, dynamic> audiusRecord(
        {String id = 'track', Map<String, dynamic> extra = const {}}) =>
    {
      'id': id,
      'title': 'A full song',
      'user': {'name': 'An artist'},
      'duration': 158,
      'is_streamable': true,
      'is_stream_gated': false,
      'access': {'stream': true},
      'artwork': {'480x480': 'https://image.example/cover.jpg'},
      ...extra,
    };

void main() {
  test('SoundCloud rejects restricted and preview records', () {
    expect(
        SoundCloudExtractor.isFullTrack(
            {'duration': 158000, 'streamable': true}),
        isTrue);
    for (final data in [
      {'policy': 'SNIP'},
      {'policy': 'BLOCK'},
      {'streamable': false},
      {'monetization_model': 'SUB_HIGH_TIER'},
      {'duration': 30000, 'full_duration': 158000},
    ]) {
      expect(SoundCloudExtractor.isFullTrack(data), isFalse);
    }
  });

  test(
      'a saved SoundCloud track with only preview transcodings resolves to null',
      () async {
    final adapter = FakeHttpAdapter((request) => jsonResponse({
          'duration': 158000,
          'media': {
            'transcodings': [
              {
                'url': 'https://api.example/preview',
                'snipped': true,
                'duration': 30000,
                'format': {'protocol': 'progressive', 'mime_type': 'audio/mpeg'}
              },
            ]
          },
        }));
    final source = SoundCloudExtractor(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(source.close);
    expect(await source.resolveAudioStreamUrl('123'), isNull);
    expect(adapter.requests, hasLength(1));
  });

  test(
      'SoundCloud selects full unencrypted audio instead of an advertised preview',
      () async {
    final adapter = FakeHttpAdapter((request) {
      if (request.uri.path == '/tracks/123') {
        return jsonResponse({
          'duration': 158000,
          'track_authorization': 'public-track-token',
          'media': {
            'transcodings': [
              {
                'url': 'https://api.example/preview',
                'snipped': true,
                'format': {'protocol': 'progressive', 'mime_type': 'audio/mpeg'}
              },
              {
                'url': 'https://api.example/locked',
                'format': {
                  'protocol': 'encrypted_hls',
                  'mime_type': 'audio/mpeg'
                }
              },
              {
                'url': 'https://api.example/full',
                'duration': 158000,
                'format': {'protocol': 'progressive', 'mime_type': 'audio/mpeg'}
              },
            ]
          },
        });
      }
      expect(request.uri.path, '/full');
      expect(
          request.queryParameters['track_authorization'], 'public-track-token');
      return jsonResponse({'url': 'https://cdn.example/full.mp3'});
    });
    final source = SoundCloudExtractor(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(source.close);
    expect(await source.resolveAudioStreamUrl('123'),
        'https://cdn.example/full.mp3');
    expect(adapter.requests, hasLength(2));
  });

  test('Audius filters paid, gated, inaccessible and malformed tracks',
      () async {
    final adapter = FakeHttpAdapter((request) {
      expect(request.queryParameters['query'], 'A song');
      expect(request.queryParameters['app_name'], 'Hook');
      return jsonResponse({
        'data': [
          audiusRecord(),
          audiusRecord(id: 'gated', extra: {'is_stream_gated': true}),
          audiusRecord(id: 'blocked', extra: {
            'access': {'stream': false}
          }),
          audiusRecord(id: 'conditions', extra: {
            'stream_conditions': {'usdc_purchase': {}}
          }),
          audiusRecord(id: 'download-only', extra: {'is_streamable': false}),
          audiusRecord(id: 'zero', extra: {'duration': 0}),
          audiusRecord(
              id: 'paid-download-free-stream',
              extra: {'is_download_gated': true}),
        ]
      });
    });
    final source = AudiusSource(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(source.close);
    final results = await source.searchTracks('A song');
    expect(results.map((track) => track.id),
        ['track', 'paid-download-free-stream']);
    expect(results.first.duration, const Duration(seconds: 158));
    expect(results.first.source, TrackSource.audius);
  });

  test('Audius rechecks access for a previously saved track', () async {
    final saved = AudiusSource.fromJson(audiusRecord())!;
    final adapter = FakeHttpAdapter((request) {
      expect(request.uri.path, '/v1/tracks/track');
      return jsonResponse({
        'data': [
          audiusRecord(extra: {'is_stream_gated': true})
        ]
      });
    });
    final source = AudiusSource(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(source.close);
    expect(await source.resolveTrack(saved), isNull);
    expect(adapter.requests, hasLength(1));
  });

  test(
      'Audius returns its public full-stream endpoint only for accessible records',
      () async {
    final adapter = FakeHttpAdapter((_) => jsonResponse({
          'data': [audiusRecord()]
        }));
    final source = AudiusSource(dio: Dio()..httpClientAdapter = adapter);
    addTearDown(source.close);
    final stream =
        await source.resolveTrack(AudiusSource.fromJson(audiusRecord())!);
    expect(stream?.source, TrackSource.audius);
    expect(Uri.parse(stream!.url).path, '/v1/tracks/track/stream');
    expect(stream.duration, const Duration(seconds: 158));
  });

  test('YouTube upload noise is normalized without erasing version identity',
      () {
    expect(
        YouTubeMusicSource.cleanArtist('Post Malone - Topic'), 'Post Malone');
    expect(YouTubeMusicSource.cleanArtist('PostMaloneVEVO'), 'PostMalone');
    expect(
        YouTubeMusicSource.cleanTitle(
            'Post Malone - Sunflower (Official Audio)', 'Post Malone'),
        'Sunflower');
    expect(
        YouTubeMusicSource.cleanTitle(
            'Sunflower (Remix) [Official Video]', 'Post Malone'),
        'Sunflower (Remix)');
    expect(YouTubeMusicSource.cleanTitle('Sunflower (Live)', 'Post Malone'),
        'Sunflower (Live)');
  });

  test('YouTube metadata distinguishes full tracks from livestreams and shorts',
      () {
    Video video({int seconds = 158, bool live = false}) => Video(
          VideoId('abcdefghijk'),
          'Sunflower',
          'Post Malone - Topic',
          ChannelId('UC${List.filled(22, 'a').join()}'),
          null,
          null,
          null,
          '',
          Duration(seconds: seconds),
          const ThumbnailSet('abcdefghijk'),
          const [],
          const Engagement(100, 20, 0),
          live,
        );
    final full = YouTubeMusicSource.fromVideo(video());
    expect(full?.source, TrackSource.youtubeMusic);
    expect(full?.artist, 'Post Malone');
    expect(full?.duration, const Duration(seconds: 158));
    expect(YouTubeMusicSource.fromVideo(video(seconds: 30)), isNull);
    expect(YouTubeMusicSource.fromVideo(video(live: true)), isNull);
  });

  test(
      'new source keys round-trip without changing the legacy YouTube migration',
      () {
    for (final source in [TrackSource.youtubeMusic, TrackSource.audius]) {
      final track = MediaTrack(
          id: 'same',
          title: 'Song',
          artist: 'Artist',
          duration: const Duration(seconds: 158),
          artworkUrl: '',
          source: source);
      expect(MediaTrack.fromJson(track.toJson()).source, source);
    }
    expect(MediaTrack.fromJson({'source': 'youtube', 'id': 'legacy'}).source,
        TrackSource.spotify);
  });
}
