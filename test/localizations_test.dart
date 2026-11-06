import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every shipped .arb file must cover exactly the template's key set and use
/// the same placeholders, so gen-l10n never silently falls back to English.
void main() {
  final arbDir = Directory('lib/l10n');
  final files = arbDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.arb'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('all 20 languages ship an arb file', () {
    expect(files.length, 20, reason: 'locales found: ${files.map((f) => f.path.split('_').last)}');
  });

  test('each locale covers every template key with matching placeholders', () {
    final template = _load(files.firstWhere((f) => f.path.endsWith('app_en.arb')));
    final templateKeys = [
      for (final key in template.keys)
        if (!key.startsWith('@')) key,
    ];

    for (final file in files) {
      final locale = file.uri.pathSegments.last.replaceAll(RegExp(r'^app_|\.arb$'), '');
      final data = _load(file);
      final keys = [
        for (final key in data.keys)
          if (!key.startsWith('@')) key,
      ];
      expect(
        keys.toSet(),
        templateKeys.toSet(),
        reason: '$locale key set differs from template',
      );

      for (final key in templateKeys) {
        final expected = RegExp(r'\{[a-zA-Z_]+\}')
            .allMatches('${template[key]}')
            .map((m) => m.group(0))
            .toSet();
        final actual = RegExp(r'\{[a-zA-Z_]+\}')
            .allMatches('${data[key]}')
            .map((m) => m.group(0))
            .toSet();
        expect(
          actual.difference(expected),
          isEmpty,
          reason: '$locale.$key introduces unknown placeholders: '
              '${actual.difference(expected)}',
        );
        expect(
          expected.difference(actual),
          isEmpty,
          reason: '$locale.$key drops placeholders: ${expected.difference(actual)}',
        );
      }
    }
  });

  test('every arb declares its own locale', () {
    for (final file in files) {
      final locale = file.uri.pathSegments.last.replaceAll(RegExp(r'^app_|\.arb$'), '');
      expect(
        _load(file)['@@locale'],
        locale,
        reason: '${file.path} @@locale does not match its filename',
      );
    }
  });
}

Map<String, dynamic> _load(File file) {
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}
