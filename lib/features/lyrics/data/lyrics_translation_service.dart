import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lyricsTranslationServiceProvider = Provider<LyricsTranslationService>((
  ref,
) {
  return LyricsTranslationService();
});

/// Text stays on-device. Only ML Kit language model files need a download.
class LyricsTranslationService {
  static const _channel = MethodChannel('hook/lyrics_translation');
  final Map<String, Map<String, String>> _cache = {};
  int _sequence = 0;

  String newRequestId() => 'lyrics-${++_sequence}';

  Future<Map<String, String>> translate({
    required String id,
    required List<String> lines,
    required String target,
    bool allowDownload = false,
  }) async {
    final unique = lines
        .where((line) => line.trim().isNotEmpty)
        .toSet()
        .toList();
    if (unique.isEmpty) return const {};
    if (unique.length > 500 ||
        unique.fold<int>(0, (n, s) => n + s.length) > 50000 ||
        unique.any((s) => s.length > 5000)) {
      throw PlatformException(code: 'tooLarge');
    }
    final key = jsonEncode([target, unique]);
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached;
      return cached;
    }
    try {
      final output = await _channel
          .invokeListMethod<String>('translate', {
            'id': id,
            'lines': unique,
            'target': target,
            'allowDownload': allowDownload,
          })
          .timeout(const Duration(seconds: 155));
      if (output == null ||
          output.length != unique.length ||
          output.any((line) => line.trim().isEmpty)) {
        throw PlatformException(code: 'translationFailed');
      }
      final result = Map<String, String>.unmodifiable(
        Map.fromIterables(unique, output),
      );
      if (_cache.length >= 8) _cache.remove(_cache.keys.first);
      _cache[key] = result;
      return result;
    } on TimeoutException {
      await cancel(id);
      throw PlatformException(code: 'timeout');
    }
  }

  Future<void> cancel(String id) async {
    try {
      await _channel.invokeMethod<void>('cancel', {'id': id});
    } on MissingPluginException {
      // The UI can still close on unsupported platforms.
    } on PlatformException {
      // Activity teardown may have already cancelled this request.
    }
  }
}
