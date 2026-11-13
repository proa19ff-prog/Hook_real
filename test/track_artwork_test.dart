import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/artwork/artwork_service.dart';
import 'package:hook/features/theme_engine/presentation/track_artwork.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: ColoredBox(
    color: Colors.black,
    child: Center(child: child),
  ),
);

TrackArtwork _art(String url, {String? artist, String? title}) => TrackArtwork(
  url: url,
  artist: artist,
  title: title,
  size: 52,
  placeholderColor: Colors.grey,
  iconColor: Colors.white,
);

/// A service that never reaches the network and never touches the disk, so
/// no timer outlives the widget and the placeholder assertions stay
/// deterministic.
class _StubArtworkService extends ArtworkService {
  _StubArtworkService() : super(dio: Dio());

  @override
  Future<String?> resolve({
    required String artist,
    required String title,
    Duration? duration,
  }) async => null;

  @override
  void warm(String url) {}

  @override
  Future<File?> existingFile(String url) async => null;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    ArtworkService.instance = _StubArtworkService();
  });

  tearDown(ArtworkService.resetInstance);

  testWidgets('an empty url shows the music-note placeholder', (tester) async {
    await tester.pumpWidget(_wrap(_art('')));
    await tester.pump();
    expect(find.byIcon(MingCuteIcons.mgc_music_line), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a YouTube video frame is rejected in favour of a placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        _art(
          'https://i.ytimg.com/vi/abc123/maxresdefault.jpg',
          artist: 'Madkid',
          title: 'Addiction',
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(MingCuteIcons.mgc_music_line), findsOneWidget);
  });

  testWidgets('a real cover url is rendered as an image', (tester) async {
    await tester.pumpWidget(
      _wrap(_art('https://i.scdn.co/image/abcdef', artist: 'A', title: 'B')),
    );
    await tester.pump();
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('a null size fills its parent instead of forcing a square', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 120,
          height: 80,
          child: TrackArtwork(
            url: 'https://i.scdn.co/image/abcdef',
            size: null,
            placeholderColor: Colors.grey,
            iconColor: Colors.white,
          ),
        ),
      ),
    );
    await tester.pump();
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, double.infinity);
  });

  test('getHighResUrl upgrades catalog hosts and keeps YouTube frames', () {
    expect(
      TrackArtwork.getHighResUrl('http://example.com/a.jpg'),
      'https://example.com/a.jpg',
    );
    expect(
      TrackArtwork.getHighResUrl('https://i.ytimg.com/vi/abc/hqdefault.jpg'),
      'https://i.ytimg.com/vi/abc/mqdefault.jpg',
    );
    expect(
      TrackArtwork.getHighResUrl('https://i1.sndcdn.com/art-large.jpg'),
      'https://i1.sndcdn.com/art-t500x500.jpg',
    );
    expect(
      TrackArtwork.getHighResUrl(
        'https://cdn-images.dzcdn.net/images/cover/abc/250x250-000000-80.jpg',
      ),
      'https://cdn-images.dzcdn.net/images/cover/abc/1000x1000-000000-80.jpg',
    );
    expect(
      TrackArtwork.getHighResUrl(
        'https://is1-ssl.mzstatic.com/image/thumb/abc/100x100bb.jpg',
      ),
      'https://is1-ssl.mzstatic.com/image/thumb/abc/600x600bb.jpg',
    );
    expect(TrackArtwork.getHighResUrl(null), '');
  });

  test('isVideoThumbnail matches YouTube frame hosts only', () {
    expect(
      TrackArtwork.isVideoThumbnail('https://i.ytimg.com/vi/a/0.jpg'),
      isTrue,
    );
    expect(
      TrackArtwork.isVideoThumbnail('https://lh3.googleusercontent.com/a'),
      isFalse,
    );
  });
}
