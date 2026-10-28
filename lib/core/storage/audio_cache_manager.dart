import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import '../../features/extractor/models/media_track.dart';

class CachedTrack {
  final String cacheKey;
  final MediaTrack track;
  final int sizeBytes;

  const CachedTrack({
    required this.cacheKey,
    required this.track,
    required this.sizeBytes,
  });
}

class AudioCacheManager {
  final Dio _dio;

  AudioCacheManager({Dio? dio}) : _dio = dio ?? Dio();

  Future<String> _getCacheDirectoryPath() async {
    final appDir = await getApplicationSupportDirectory();
    final cacheDir = Directory('${appDir.path}/hook_audio_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir.path;
  }

  String _sanitizeFileName(String trackId) {
    return trackId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
  }

  Future<File> getCachedFile(String trackId) async {
    final dir = await _getCacheDirectoryPath();
    return File('$dir/${_sanitizeFileName(trackId)}.m4a');
  }

  Future<File> _getMetadataFile(String trackId) async {
    final file = await getCachedFile(trackId);
    return File('${file.path}.json');
  }

  Future<bool> isTrackCached(String trackId) async {
    final file = await getCachedFile(trackId);
    return await file.exists() && (await file.length()) > 1024;
  }

  Future<String?> getLocalCachedUrl(String trackId) async {
    final file = await getCachedFile(trackId);
    if (await file.exists() && (await file.length()) > 1024) {
      return file.uri.toString();
    }
    return null;
  }

  Future<File?> downloadTrack(
    MediaTrack track,
    String streamUrl, {
    String? cacheKey,
    void Function(double progress)? onProgress,
  }) async {
    File? temporaryFile;
    try {
      final key = cacheKey ?? track.id;
      final file = await getCachedFile(key);
      temporaryFile = File('${file.path}.part');
      if (await temporaryFile.exists()) await temporaryFile.delete();

      await _dio.download(
        streamUrl,
        temporaryFile.path,
        onReceiveProgress: (received, total) {
          if (total > 0 && onProgress != null) {
            onProgress(received / total);
          }
        },
      );

      if (await temporaryFile.exists() &&
          (await temporaryFile.length()) > 1024) {
        if (await file.exists()) await file.delete();
        await temporaryFile.rename(file.path);

        final metadataFile = await _getMetadataFile(key);
        final temporaryMetadataFile = File('${metadataFile.path}.part');
        if (await temporaryMetadataFile.exists()) {
          await temporaryMetadataFile.delete();
        }
        await temporaryMetadataFile.writeAsString(jsonEncode(track.toJson()));
        if (await metadataFile.exists()) await metadataFile.delete();
        await temporaryMetadataFile.rename(metadataFile.path);
        return file;
      }
      return null;
    } catch (_) {
      return null;
    } finally {
      if (temporaryFile != null && await temporaryFile.exists()) {
        await temporaryFile.delete();
      }
    }
  }

  Future<void> removeCachedTrack(String trackId) async {
    final file = await getCachedFile(trackId);
    if (await file.exists()) {
      await file.delete();
    }
    final metadataFile = await _getMetadataFile(trackId);
    if (await metadataFile.exists()) {
      await metadataFile.delete();
    }
  }

  Future<List<CachedTrack>> getCachedTracks() async {
    final dir = await _getCacheDirectoryPath();
    final cacheDir = Directory(dir);
    final tracks = <CachedTrack>[];

    if (!await cacheDir.exists()) return tracks;

    await for (final entity in cacheDir.list(recursive: false)) {
      if (entity is! File || !entity.path.endsWith('.m4a')) continue;
      final size = await entity.length();
      if (size <= 1024) continue;

      final cacheKey = entity.path
          .split(Platform.pathSeparator)
          .last
          .replaceFirst(RegExp(r'\.m4a$'), '');
      final metadataFile = File('${entity.path}.json');
      MediaTrack? track;

      if (await metadataFile.exists()) {
        try {
          final json = jsonDecode(await metadataFile.readAsString());
          if (json is Map<String, dynamic>) {
            track = MediaTrack.fromJson(json);
          }
        } catch (_) {
          // A damaged sidecar should not hide an otherwise valid audio file.
        }
      }

      track ??= MediaTrack(
        id: cacheKey,
        title: 'Сохранённый трек',
        artist: 'Метаданные недоступны',
        duration: Duration.zero,
        artworkUrl: '',
        source: TrackSource.local,
      );

      tracks.add(CachedTrack(
        cacheKey: cacheKey,
        track: track,
        sizeBytes: size,
      ));
    }

    tracks.sort((a, b) => a.track.title.toLowerCase().compareTo(
          b.track.title.toLowerCase(),
        ));
    return tracks;
  }

  Future<int> getTotalCacheSize() async {
    final dir = await _getCacheDirectoryPath();
    final cacheDir = Directory(dir);
    int total = 0;
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list(recursive: false)) {
        if (entity is File && entity.path.endsWith('.m4a')) {
          total += await entity.length();
        }
      }
    }
    return total;
  }

  Future<void> clearAllCache() async {
    final dir = await _getCacheDirectoryPath();
    final cacheDir = Directory(dir);
    if (await cacheDir.exists()) {
      await cacheDir.delete(recursive: true);
    }
  }
}
