import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/theme_engine/presentation/playlist_artwork.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: ColoredBox(
        color: Colors.black,
        child: Center(child: child),
      ),
    );

void main() {
  testWidgets('empty playlist renders a single music-note placeholder', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        PlaylistArtwork(
          urls: const [],
          size: 50,
          placeholderColor: Colors.grey,
          iconColor: Colors.white,
        ),
      ),
    );
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(MingCuteIcons.mgc_music_line), findsOneWidget);
  });

  testWidgets('one cover fills the whole tile', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PlaylistArtwork(
          urls: const ['https://example.com/a.jpg'],
          size: 50,
          placeholderColor: Colors.grey,
          iconColor: Colors.white,
        ),
      ),
    );
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('two covers split the tile in half', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PlaylistArtwork(
          urls: const [
            'https://example.com/a.jpg',
            'https://example.com/b.jpg',
          ],
          size: 50,
          placeholderColor: Colors.grey,
          iconColor: Colors.white,
        ),
      ),
    );
    expect(find.byType(Image), findsNWidgets(2));
  });

  testWidgets('four covers form a 2x2 collage, duplicates collapse', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
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
      ),
    );
    expect(find.byType(Image), findsNWidgets(4));
  });
}
