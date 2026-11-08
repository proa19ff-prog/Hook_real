import 'package:file_picker/file_picker.dart';
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

  /// Android talks to the SAF channel; Windows uses the shared file_picker
  /// plugin. Both produce the same [ImportTextFile] contract.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.windows);

  static Future<ImportTextFile?> pick() async {
    if (!isSupported) {
      throw const MusicImportFileException(ImportFileError.unsupported);
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return _pickOnWindows();
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

  static Future<ImportTextFile?> _pickOnWindows() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );
    // An empty list means the dialog was dismissed.
    if (files.isEmpty) return null;
    final file = files.single;
    const maxBytes = 10 * 1024 * 1024;
    final length = await file.length();
    if (length != null && length > maxBytes) {
      throw const MusicImportFileException(ImportFileError.tooLarge);
    }
    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes > maxBytes) {
      throw const MusicImportFileException(ImportFileError.tooLarge);
    }
    final name = file.name;
    return ImportTextFile(
      name: name,
      text: MusicImportService.decodeFile(bytes, name),
    );
  }
}
