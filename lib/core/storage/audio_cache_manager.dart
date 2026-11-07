import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/extractor/models/media_track.dart';
import '../diagnostics/playback_diagnostics.dart';

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
  final Directory? _directory;
  final Map<String, ({Future<File?> future, CancelToken token})> _downloads =
      {};
  static const _extensions = [
    'm4a',
    'webm',
    'mp3',
    'ogg',
    'flac',
    'wav',
    'aac',
  ];
  static const _maxDownloadBytes = 250 * 1024 * 1024;
  int _temporarySequence = 0;

  AudioCacheManager({Dio? dio, this._directory}) : _dio = dio ?? Dio();

  Future<String> _getCacheDirectoryPath() async {
    final cacheDir =
        _directory ??
        Directory(
          '${(await getApplicationSupportDirectory()).path}/hook_audio_cache',
        );
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);
    return cacheDir.path;
  }

  String _sanitizeFileName(String trackId) =>
      trackId.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');

  Future<File> getCachedFile(String trackId) async {
    final dir = await _getCacheDirectoryPath();
    final stem = '$dir/${_sanitizeFileName(trackId)}';
    // Read old .m4a caches as well as original WebM/MP3/etc. containers.
    for (final extension in _extensions) {
      final file = File('$stem.$extension');
      if (await file.exists() && await file.length() > 1024) return file;
    }
    return File('$stem.m4a');
  }

  Future<bool> isTrackCached(String trackId) async =>
      await getLocalCachedUrl(trackId) != null;

  Future<String?> getLocalCachedUrl(String trackId) async {
    final file = await getCachedFile(trackId);
    if (await file.exists() && await file.length() > 1024) {
      return file.uri.toString();
    }
    return null;
  }

  /// Save provider bytes verbatim; never turn a playlist/error page into audio.
  /// Same-key callers share a transfer, and only a completed file is published.
  Future<File?> downloadTrack(
    MediaTrack track,
    String streamUrl, {
    String? cacheKey,
    Map<String, String>? headers,
    String? fileExtension,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  }) {
    final key = cacheKey ?? track.id;
    final pending = _downloads[key];
    if (pending != null && !pending.token.isCancelled) return pending.future;
    final token = cancelToken ?? CancelToken();
    late final Future<File?> future;
    future = () async {
      try {
        return await _download(
          track,
          streamUrl,
          key,
          headers,
          fileExtension,
          token,
          onProgress,
        );
      } finally {
        // A cancelled old transfer must not remove a newer transfer's entry.
        if (identical(_downloads[key]?.future, future)) _downloads.remove(key);
      }
    }();
    _downloads[key] = (future: future, token: token);
    return future;
  }

  Future<File?> _download(
    MediaTrack track,
    String streamUrl,
    String key,
    Map<String, String>? headers,
    String? fileExtension,
    CancelToken? cancelToken,
    void Function(double progress)? onProgress,
  ) async {
    File? temporaryFile;
    File? temporaryMetadata;
    final token = cancelToken ?? CancelToken();
    try {
      final existing = await getLocalCachedUrl(key);
      if (existing != null) return File(Uri.parse(existing).toFilePath());
      final uri = Uri.tryParse(streamUrl);
      if (uri == null ||
          !['http', 'https'].contains(uri.scheme) ||
          uri.path.toLowerCase().endsWith('.m3u8')) {
        return null;
      }

      final dir = await _getCacheDirectoryPath();
      final stem = '$dir/${_sanitizeFileName(key)}';
      final nonce =
          '${DateTime.now().microsecondsSinceEpoch}_${_temporarySequence++}';
      temporaryFile = File('$stem.$nonce.part');
      final response = await _dio
          .download(
            streamUrl,
            temporaryFile.path,
            cancelToken: token,
            options: Options(
              headers: {
                // Ask for the whole file via Range: several CDNs (SoundCloud's
                // among them) reject or mishandle a plain range-less GET even
                // though the same URL streams fine with Range in the player.
                'Range': 'bytes=0-',
                for (final entry in (headers ?? <String, String>{}).entries)
                  if (entry.key.toLowerCase() != 'range')
                    entry.key: entry.value,
              },
              // 200 is a whole-file GET; 206 is the same for a bytes=0- ask.
              validateStatus: (status) => status == 200 || status == 206,
              receiveTimeout: const Duration(seconds: 20),
              sendTimeout: const Duration(seconds: 10),
            ),
            onReceiveProgress: (received, total) {
              if (received > _maxDownloadBytes || total > _maxDownloadBytes) {
                token.cancel('Audio download exceeds cache limit');
                return;
              }
              if (total > 0) {
                onProgress?.call((received / total).clamp(0.0, 1.0));
              }
            },
          )
          .timeout(
            const Duration(minutes: 2),
            onTimeout: () {
              token.cancel('Audio download timed out');
              throw const HttpException('Audio download timed out');
            },
          );
      if (token.isCancelled || !await temporaryFile.exists()) return null;
      // 206 must answer our bytes=0- ask: a response starting mid-file is a
      // partial body, never a whole recording.
      if (response.statusCode == 206) {
        final range = RegExp(
          r'^bytes (\d+)-\d+/(\d+|\*)',
        ).firstMatch(response.headers.value('content-range') ?? '');
        if (range == null || int.parse(range.group(1)!) != 0) {
          PlaybackDiagnostics.record(
            'download.rejected',
            source: 'cache',
            detail:
                'partial content-range: ${response.headers.value('content-range')}',
          );
          return null;
        }
      }
      final size = await temporaryFile.length();
      if (size <= 1024 || size > _maxDownloadBytes) {
        PlaybackDiagnostics.record(
          'download.rejected',
          source: 'cache',
          detail: 'size=$size',
        );
        return null;
      }
      final expected = int.tryParse(
        response.headers.value('content-length') ?? '',
      );
      final encoding = response.headers.value('content-encoding');
      if (expected != null &&
          (encoding == null || encoding == 'identity') &&
          size != expected) {
        PlaybackDiagnostics.record(
          'download.rejected',
          source: 'cache',
          detail: 'length mismatch: $size != $expected',
        );
        return null;
      }

      final input = await temporaryFile.open();
      late final List<int> prefix;
      try {
        prefix = await input.read(64);
      } finally {
        await input.close();
      }
      final extension = _audioExtension(
        prefix,
        fileExtension,
        response.headers.value('content-type') ?? '',
      );
      if (extension == null) {
        PlaybackDiagnostics.record(
          'download.rejected',
          source: 'cache',
          detail:
              'not audio bytes, content-type=${response.headers.value('content-type')}',
        );
        return null;
      }
      final file = File('$stem.$extension');
      final metadataFile = File('${file.path}.json');
      temporaryMetadata = File('${metadataFile.path}.$nonce.part');
      await temporaryMetadata.writeAsString(
        jsonEncode(track.toJson()),
        flush: true,
      );
      if (token.isCancelled) return null;
      // No transcoding or renamed playlist: the extension matches the bytes.
      // Publish metadata first: a visible audio entry must already retain the
      // recording's source/id/title, never fall back to an invented local ID.
      await temporaryMetadata.rename(metadataFile.path);
      if (token.isCancelled) return null;
      await temporaryFile.rename(file.path);
      return file;
    } catch (error) {
      if (!token.isCancelled) {
        PlaybackDiagnostics.record(
          'download.failed',
          source: 'cache',
          error: error,
          url: streamUrl,
        );
      }
      return null;
    } finally {
      for (final file in [temporaryFile, temporaryMetadata]) {
        if (file != null && await file.exists()) await file.delete();
      }
    }
  }

  static String? _audioExtension(List<int> bytes, String? hint, String mime) {
    if (bytes.length < 12) return null;
    bool starts(List<int> signature) => List.generate(
      signature.length,
      (i) => bytes[i] == signature[i],
    ).every((same) => same);
    if (ascii.decode(bytes.sublist(4, 8), allowInvalid: true) == 'ftyp') {
      return 'm4a';
    }
    if (starts([0x1a, 0x45, 0xdf, 0xa3])) return 'webm';
    if (starts(ascii.encode('OggS'))) return 'ogg';
    if (starts(ascii.encode('fLaC'))) return 'flac';
    if (starts(ascii.encode('RIFF')) &&
        ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WAVE') {
      return 'wav';
    }
    if (starts(ascii.encode('ID3'))) return 'mp3';
    if (bytes[0] == 0xff && (bytes[1] & 0xe0) == 0xe0) {
      return hint == 'aac' || mime.contains('aac') ? 'aac' : 'mp3';
    }
    // In particular, reject #EXTM3U, HTML and JSON even with audio MIME types.
    return null;
  }

  Future<void> removeCachedTrack(String trackId) async {
    final dir = await _getCacheDirectoryPath();
    final stem = '$dir/${_sanitizeFileName(trackId)}';
    for (final extension in _extensions) {
      for (final file in [
        File('$stem.$extension'),
        File('$stem.$extension.json'),
      ]) {
        if (await file.exists()) await file.delete();
      }
    }
  }

  bool _isAudioFile(File file) =>
      _extensions.any((ext) => file.path.endsWith('.$ext'));

  Future<List<CachedTrack>> getCachedTracks() async {
    final cacheDir = Directory(await _getCacheDirectoryPath());
    final tracks = <CachedTrack>[];
    await for (final entity in cacheDir.list(recursive: false)) {
      if (entity is! File || !_isAudioFile(entity)) continue;
      final size = await entity.length();
      if (size <= 1024) continue;
      final filename = entity.path.split(Platform.pathSeparator).last;
      final cacheKey = filename.substring(0, filename.lastIndexOf('.'));
      final metadataFile = File('${entity.path}.json');
      MediaTrack? track;
      if (await metadataFile.exists()) {
        try {
          final json = jsonDecode(await metadataFile.readAsString());
          if (json is Map<String, dynamic>) track = MediaTrack.fromJson(json);
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
      tracks.add(
        CachedTrack(cacheKey: cacheKey, track: track, sizeBytes: size),
      );
    }
    tracks.sort(
      (a, b) =>
          a.track.title.toLowerCase().compareTo(b.track.title.toLowerCase()),
    );
    return tracks;
  }

  Future<int> getTotalCacheSize() async {
    final cacheDir = Directory(await _getCacheDirectoryPath());
    var total = 0;
    await for (final entity in cacheDir.list(recursive: false)) {
      if (entity is File && _isAudioFile(entity)) {
        total += await entity.length();
      }
    }
    return total;
  }

  Future<void> clearAllCache() async {
    final cacheDir = Directory(await _getCacheDirectoryPath());
    if (await cacheDir.exists()) await cacheDir.delete(recursive: true);
  }
}
