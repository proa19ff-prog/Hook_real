import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/lyrics/data/lyrics_result.dart';

void main() {
  test('auto intro offset only fires for a plausible intro', () {
    const canonical = 210000; // 3:30 of canonical timings

    // A 15-second uploader intro: lyrics must be delayed (negative offset).
    expect(
      LyricsResult.autoIntroOffsetSeconds(
        isRealSync: true,
        sourceDurationMs: canonical,
        playingDuration: const Duration(milliseconds: canonical + 15000),
      ),
      -15.0,
    );

    // Slightly different masters (2 s) are left alone — shifting those would
    // do more harm than good.
    expect(
      LyricsResult.autoIntroOffsetSeconds(
        isRealSync: true,
        sourceDurationMs: canonical,
        playingDuration: const Duration(milliseconds: canonical + 1500),
      ),
      isNull,
    );

    // Beyond 40 s it is a different edit (extended remix), not an intro.
    expect(
      LyricsResult.autoIntroOffsetSeconds(
        isRealSync: true,
        sourceDurationMs: canonical,
        playingDuration: const Duration(milliseconds: canonical + 45000),
      ),
      isNull,
    );

    // A shorter playing version has no intro to compensate for.
    expect(
      LyricsResult.autoIntroOffsetSeconds(
        isRealSync: true,
        sourceDurationMs: canonical,
        playingDuration: const Duration(milliseconds: canonical - 5000),
      ),
      isNull,
    );

    // Estimated timings from plain text are never worth shifting.
    expect(
      LyricsResult.autoIntroOffsetSeconds(
        isRealSync: false,
        sourceDurationMs: canonical,
        playingDuration: const Duration(milliseconds: canonical + 10000),
      ),
      isNull,
    );

    // Unknown record duration — nothing to compare with.
    expect(
      LyricsResult.autoIntroOffsetSeconds(
        isRealSync: true,
        sourceDurationMs: null,
        playingDuration: const Duration(minutes: 4),
      ),
      isNull,
    );
  });

  test('source duration survives the json round trip', () {
    const result = LyricsResult(
      isRealSync: true,
      sourceDurationMs: 210000,
    );
    final restored = LyricsResult.fromJson(result.toJson());
    expect(restored.sourceDurationMs, 210000);

    // Old cache entries without the field stay readable.
    final legacy = LyricsResult.fromJson({
      'isRealSync': true,
      'lines': <Object>[],
    });
    expect(legacy.sourceDurationMs, isNull);
  });
}
