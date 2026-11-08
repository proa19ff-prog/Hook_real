import 'package:flutter_test/flutter_test.dart';
import 'package:hook/features/updates/update_service.dart';

Map<String, Object> _release({
  String tag = 'v0.4.0',
  bool draft = false,
  List<Map<String, Object>>? assets,
}) {
  return {
    'tag_name': tag,
    'draft': draft,
    'body': 'Release notes',
    'published_at': '2026-11-08T12:00:00Z',
    'assets':
        assets ??
        [
          {
            'name': 'Hook-$tag-arm64.apk',
            'browser_download_url': 'https://example/Hook-$tag-arm64.apk',
            'size': 42000000,
          },
          {
            'name': 'Hook-$tag-universal.apk',
            'browser_download_url': 'https://example/Hook-$tag-universal.apk',
            'size': 119000000,
          },
          {
            'name': 'SHA256SUMS.txt',
            'browser_download_url': 'https://example/SHA256SUMS.txt',
            'size': 400,
          },
        ],
  };
}

void main() {
  group('version comparison', () {
    test('strictly newer wins per component', () {
      expect(UpdateService.isNewerVersion('0.4.0', '0.3.0'), isTrue);
      expect(UpdateService.isNewerVersion('0.3.1', '0.3.0'), isTrue);
      expect(UpdateService.isNewerVersion('1.0.0', '0.9.9'), isTrue);
      expect(UpdateService.isNewerVersion('0.3.0', '0.3.0'), isFalse);
      expect(UpdateService.isNewerVersion('0.2.9', '0.3.0'), isFalse);
    });

    test('tolerates v-prefixes and build suffixes', () {
      expect(UpdateService.isNewerVersion('v0.4.0', '0.3.0'), isTrue);
      expect(UpdateService.isNewerVersion('0.4.0+12', '0.3.0'), isTrue);
      expect(UpdateService.isNewerVersion('0.3.0', 'v0.3.0+3'), isFalse);
    });
  });

  test('parseRelease picks the asset for this device ABI', () {
    final update = UpdateService.parseRelease(_release())!;
    expect(update.version, '0.4.0');
    expect(update.notes, 'Release notes');
    expect(update.apkUrl, contains(UpdateService.currentAbi()));
    expect(update.apkBytes, 42000000);
  });

  test('parseRelease falls back to universal and skips drafts', () {
    final universalOnly = _release(assets: [
      {
        'name': 'Hook-v0.4.0-universal.apk',
        'browser_download_url': 'https://example/universal.apk',
        'size': 119000000,
      },
    ]);
    expect(UpdateService.parseRelease(universalOnly)!.apkUrl,
        contains('universal'));

    expect(
      UpdateService.parseRelease(_release(draft: true)),
      isNull,
    );
    expect(UpdateService.parseRelease(_release(tag: '')), isNull);
  });

  test('the endpoint contract stays public and unauthenticated', () {
    expect(UpdateService.repoApiUrl, contains('repos/proa19ff-prog/Hook_real'));
    expect(UpdateService.repoApiUrl, startsWith('https://api.github.com'));
  });
}
