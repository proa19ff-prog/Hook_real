import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/artwork/artwork_service.dart';
import 'package:hook/features/search/presentation/artist_screen.dart';
import 'package:hook/features/theme_engine/domain/hook_theme.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(
        body: Center(child: child),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final theme = HookTheme.fromJson({});

  group('InteractiveArtistText', () {
    testWidgets('renders single artist and triggers tap callback', (tester) async {
      String? tapped;
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: 'Alan Walker',
            theme: theme,
            style: const TextStyle(fontSize: 14),
            onArtistTap: (name) => tapped = name,
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      final child = span.children!.first as TextSpan;
      expect(child.text, 'Alan Walker');

      final recognizer = child.recognizer as TapGestureRecognizer;
      recognizer.onTap?.call();
      expect(tapped, 'Alan Walker');
    });

    testWidgets('splits collaborators with "и" into independent tap targets', (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: 'MadK1d и Villian',
            theme: theme,
            style: const TextStyle(fontSize: 14),
            onArtistTap: taps.add,
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      final children = span.children!.cast<TextSpan>();

      // Children: [MadK1d, ' и ', Villian]
      expect(children.length, 3);
      expect(children[0].text, 'MadK1d');
      expect(children[1].text, ' и ');
      expect(children[2].text, 'Villian');

      // Tapping first artist
      final firstRecognizer = children[0].recognizer as TapGestureRecognizer;
      firstRecognizer.onTap?.call();
      expect(taps, ['MadK1d']);

      // Tapping second artist
      final secondRecognizer = children[2].recognizer as TapGestureRecognizer;
      secondRecognizer.onTap?.call();
      expect(taps, ['MadK1d', 'Villian']);
    });

    testWidgets('splits complex credit with & and feat. into individual artists', (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: 'Miyagi & Andy Panda feat. TumaniYO',
            theme: theme,
            style: const TextStyle(fontSize: 14),
            onArtistTap: taps.add,
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      final children = span.children!.cast<TextSpan>();

      // Collect only the spans that have recognizers (the performers)
      final performerSpans = children.where((s) => s.recognizer != null).toList();
      expect(performerSpans.map((s) => s.text).toList(), [
        'Miyagi',
        'Andy Panda',
        'TumaniYO',
      ]);

      for (final s in performerSpans) {
        (s.recognizer as TapGestureRecognizer).onTap?.call();
      }
      expect(taps, ['Miyagi', 'Andy Panda', 'TumaniYO']);
    });

    testWidgets('splits comma-separated performers', (tester) async {
      final taps = <String>[];
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: 'Post Malone, Swae Lee',
            theme: theme,
            style: const TextStyle(fontSize: 14),
            onArtistTap: taps.add,
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      final performerSpans = span.children!.cast<TextSpan>().where((s) => s.recognizer != null).toList();
      expect(performerSpans.map((s) => s.text).toList(), [
        'Post Malone',
        'Swae Lee',
      ]);

      for (final s in performerSpans) {
        (s.recognizer as TapGestureRecognizer).onTap?.call();
      }
      expect(taps, ['Post Malone', 'Swae Lee']);
    });

    testWidgets('renders rest subtitle with separator bullet', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: 'Madkid',
            rest: 'Album Name',
            theme: theme,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final span = text.textSpan! as TextSpan;
      final last = span.children!.last as TextSpan;
      expect(last.text, ' • Album Name');
    });

    testWidgets('renders empty artist gracefully with rest text only', (tester) async {
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: '',
            rest: 'Standalone Rest',
            theme: theme,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, 'Standalone Rest');
    });

    testWidgets('custom onLongPress is fired when provided', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          InteractiveArtistText(
            artist: 'MadK1d и Villian',
            theme: theme,
            style: const TextStyle(fontSize: 14),
            onLongPress: () => pressed = true,
          ),
        ),
      );

      await tester.longPress(find.byType(InteractiveArtistText));
      expect(pressed, isTrue);
    });
  });

  group('splitArtists and primaryArtist edge cases', () {
    test('Russian "и" in mid-word is not split', () {
      expect(ArtworkService.splitArtists('Miyagi'), ['Miyagi']);
      expect(ArtworkService.splitArtists('Ария'), ['Ария']);
      expect(ArtworkService.splitArtists('Кино'), ['Кино']);
    });

    test('primaryArtist returns first collaborator', () {
      expect(ArtworkService.primaryArtist('MadK1d и Villian'), 'MadK1d');
      expect(ArtworkService.primaryArtist('Miyagi & Andy Panda'), 'Miyagi');
      expect(ArtworkService.primaryArtist('Kush Kush feat. Sebastian'), 'Kush Kush');
    });

    test('multi-artist track creates separate artist card targets for discovery', () {
      const artist = 'MadK1d и Villian';
      final names = ArtworkService.splitArtists(artist);
      expect(names, ['MadK1d', 'Villian']);
      expect(names, isNot(contains('MadK1d и Villian')));
    });
  });
}
