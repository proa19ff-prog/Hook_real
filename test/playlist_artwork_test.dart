import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/theme_engine/presentation/playlist_artwork.dart';
import 'package:hook/features/theme_engine/presentation/track_artwork.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: ColoredBox(
    color: Colors.black,
    child: Center(child: child),
  ),
);

/// Tests run with HTTP disabled, so a cover request fails and the cell falls
/// back to its placeholder. The collage structure is asserted through the
/// number of artwork cells rather than through decoded images.
Future<void> _pumpArtwork(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(_wrap(child));
  await tester.pump();
}

void main() {
  testWidgets('empty playlist renders a single music-note placeholder', (
    tester,
  ) async {
    await _pumpArtwork(
      tester,
      PlaylistArtwork(
        urls: const [],
        size: 50,
        placeholderColor: Colors.grey,
        iconColor: Colors.white,
      ),
    );
    expect(find.byType(TrackArtwork), findsNothing);
    expect(find.byIcon(MingCuteIcons.mgc_music_line), findsOneWidget);
  });

  testWidgets('one cover fills the whole tile', (tester) async {
    await _pumpArtwork(
      tester,
      PlaylistArtwork(
        urls: const ['https://example.com/a.jpg'],
        size: 50,
        placeholderColor: Colors.grey,
        iconColor: Colors.white,
      ),
    );
    expect(find.byType(TrackArtwork), findsOneWidget);
  });

  testWidgets('two covers split the tile in half', (tester) async {
    await _pumpArtwork(
      tester,
      PlaylistArtwork(
        urls: const ['https://example.com/a.jpg', 'https://example.com/b.jpg'],
        size: 50,
        placeholderColor: Colors.grey,
        iconColor: Colors.white,
      ),
    );
    expect(find.byType(TrackArtwork), findsNWidgets(2));
  });

  testWidgets('four covers form a 2x2 collage, duplicates collapse', (
    tester,
  ) async {
    await _pumpArtwork(
      tester,
      PlaylistArtwork(
        urls: const [
          'https://example.com/a.jpg',
          'https://example.com/a.jpg',
          'https://example.com/b.jpg',
          'https://example.com/c.jpg',
          'https://example.com/d.jpg',
        ],
        size: 50,
        placeholderColor: Colors.grey,
        iconColor: Colors.white,
      ),
    );
    expect(find.byType(TrackArtwork), findsNWidgets(4));
  });

  testWidgets('video frames are not used as collage covers', (tester) async {
    await _pumpArtwork(
      tester,
      PlaylistArtwork(
        urls: const [
          'https://i.ytimg.com/vi/abc123/mqdefault.jpg',
          'https://example.com/real.jpg',
        ],
        size: 50,
        placeholderColor: Colors.grey,
        iconColor: Colors.white,
      ),
    );
    expect(find.byType(TrackArtwork), findsOneWidget);
  });
}
