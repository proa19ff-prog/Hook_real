import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Dart notification drawables survive Android release shrinking', () {
    final keepFile = File('android/app/src/main/res/raw/keep.xml');
    final keepXml = keepFile.readAsStringSync();
    final keepMatch = RegExp(r'tools:keep="([^"]+)"').firstMatch(keepXml);
    expect(keepMatch, isNotNull);
    final kept = keepMatch!
        .group(1)!
        .split(',')
        .map((name) => name.trim())
        .toSet();

    final drawablePattern = RegExp(r'''['"](drawable/[a-z0-9_]+)['"]''');
    final sources = [
      File('lib/main.dart'),
      File('lib/features/audio_player/data/audio_player_service.dart'),
    ];
    final icons = sources
        .expand((file) => drawablePattern.allMatches(file.readAsStringSync()))
        .map((match) => match.group(1)!)
        .toSet();
    expect(icons, contains('drawable/ic_stat_hook'));
    expect(icons, contains('drawable/ic_notification_favorite'));
    expect(icons, contains('drawable/ic_notification_favorite_border'));

    for (final icon in icons) {
      expect(
        kept,
        contains('@$icon'),
        reason:
            '$icon is looked up by name at runtime, not an Android R reference',
      );
      expect(
        File('android/app/src/main/res/$icon.xml').existsSync(),
        isTrue,
        reason: 'The notification drawable $icon must exist',
      );
    }
  });
}
