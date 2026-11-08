import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

import '../../extractor/models/media_track.dart';

/// Playlist export in the Exportify CSV dialect, so a Hook playlist opens
/// in TuneMyMusic/Exportify and travels anywhere. On Android the file goes
/// through the system share sheet; on desktop a save dialog picks the spot.
abstract final class PlaylistExport {
  static String csv(String name, List<MediaTrack> tracks) {
    String esc(String value) => '"${value.replaceAll('"', '""')}"';
    final rows = <String>[
      'Playlist Name,Track URI,Track Name,Artist Name(s),Album Name,Duration (ms)',
    ];
    for (final track in tracks) {
      rows.add([
        esc(name),
        esc('hook:${track.source.name}:${track.id}'),
        esc(track.title),
        esc(track.artist),
        esc(track.album ?? ''),
        '${track.duration.inMilliseconds}',
      ].join(','));
    }
    return rows.join('\r\n');
  }

  static Future<void> save(String name, List<MediaTrack> tracks) async {
    final content = csv(name, tracks);
    final fileName = '${name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')}.csv';
    if (!kIsWeb && Platform.isAndroid) {
      final dir = await Directory.systemTemp.createTemp('hook_export');
      final file = File('${dir.path}${Platform.pathSeparator}$fileName');
      await file.writeAsString(content, flush: true);
      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path, mimeType: 'text/csv')], subject: name),
      );
      return;
    }
    final bytes = Uint8List.fromList(content.codeUnits);
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'text/csv',
    );
    if (uri == null) return;
    // Some platforms only stage the file; write through when we got a path.
    final path = uri.scheme == 'file' ? uri.toFilePath() : null;
    if (path != null && !File(path).existsSync()) {
      await File(path).writeAsString(content, flush: true);
    }
  }
}
