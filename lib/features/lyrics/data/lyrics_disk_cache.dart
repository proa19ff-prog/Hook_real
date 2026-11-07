import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'lyrics_result.dart';

/// Persistent lyrics keep source timestamps intact, including backing vocals.
/// The original full key is checked inside the sidecar to reject hash collisions.
class LyricsDiskCache {
  final Directory? directory;
  int _sequence = 0;
  LyricsDiskCache({this.directory});

  Future<File> _file(String key) async {
    final dir =
        directory ??
        Directory(
          '${(await getApplicationSupportDirectory()).path}/hook_lyrics_cache',
        );
    await dir.create(recursive: true);
    var a = 0x811c9dc5;
    var b = 0x9e3779b9;
    for (final byte in utf8.encode(key)) {
      a = ((a ^ byte) * 0x01000193) & 0xffffffff;
      b = ((b ^ byte) * 0x01000193) & 0xffffffff;
    }
    return File(
      '${dir.path}/${a.toRadixString(16)}_${b.toRadixString(16)}.json',
    );
  }

  Future<LyricsResult?> read(String key) async {
    try {
      final file = await _file(key);
      if (!await file.exists() || await file.length() > 2 * 1024 * 1024) {
        return null;
      }
      final json = jsonDecode(await file.readAsString()) as Map;
      // Version 2: the v1 entries may hold wrong-artist matches accepted
      // before the stricter LyricsMatch rules; refetch them instead.
      if (json['version'] != 3 || json['key'] != key) return null;
      final result = LyricsResult.fromJson(
        Map<String, dynamic>.from(json['lyrics'] as Map),
      );
      return result.isEmpty ? null : result;
    } catch (_) {
      // Missing storage support or an invalid sidecar is a cache miss.
      return null;
    }
  }

  Future<void> write(String key, LyricsResult result) async {
    // An offline miss must never overwrite good lyrics.
    if (result.isEmpty) return;
    File? temporary;
    try {
      final file = await _file(key);
      temporary = File(
        '${file.path}.${DateTime.now().microsecondsSinceEpoch}_${_sequence++}.part',
      );
      await temporary.writeAsString(
        jsonEncode({'version': 3, 'key': key, 'lyrics': result.toJson()}),
        flush: true,
      );
      await temporary.rename(file.path);
    } catch (_) {
      // Lyrics remain available in memory if the disk is full/unavailable.
    } finally {
      if (temporary != null && await temporary.exists()) {
        await temporary.delete();
      }
    }
  }
}
