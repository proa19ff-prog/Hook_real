import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'music_import_service.dart';

class ImportTextFile {
  final String name;
  final String text;

  const ImportTextFile({required this.name, required this.text});
}

class ImportFilePicker {
  static const channel = MethodChannel('hook/import_file');

  static bool get isSupported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  static Future<ImportTextFile?> pick() async {
    if (!isSupported) {
      throw const MusicImportFileException(ImportFileError.unsupported);
    }
    try {
      final result = await channel.invokeMapMethod<String, dynamic>(
        'pickTextFile',
      );
      if (result == null) return null;
      final name = result['name'] as String;
      final bytes = result['bytes'] as Uint8List;
      return ImportTextFile(
        name: name,
        text: MusicImportService.decodeFile(bytes, name),
      );
    } on PlatformException catch (error) {
      if (error.code == 'cancelled') return null;
      if (error.code == 'tooLarge') {
        throw const MusicImportFileException(ImportFileError.tooLarge);
      }
      if (error.code == 'unsupported') {
        throw const MusicImportFileException(ImportFileError.unsupported);
      }
      rethrow;
    }
  }
}
