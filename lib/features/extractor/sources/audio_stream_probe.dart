import 'dart:async';
import 'dart:io';

/// A numeric, safe error: never retain signed URLs, response bodies or headers.
class AudioStreamProbeException implements Exception {
  const AudioStreamProbeException(this.reason, {this.statusCode});
  final String reason;
  final int? statusCode;

  @override
  String toString() => statusCode == null
      ? 'Audio stream unavailable: $reason'
      : 'Audio stream HTTP $statusCode: $reason';
}

/// Verify the selected URL with the intended source headers for ExoPlayer,
/// not HEAD on a different manifest stream. Preserve the caller's transfer range
/// exactly; never replace it with a fixed-size probe-only range.
/// Cancel after the first nonempty chunk; never download/cache the entire song.
/// The caller owns the client and its route, timeout and disposal.
Future<void> probeAudioStream(
  HttpClient client,
  Uri url,
  Map<String, String> headers,
) async {
  final request = await client.getUrl(url);
  headers.forEach(request.headers.set);
  request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
  final response = await request.close();
  if (response.statusCode < 200 || response.statusCode >= 300) {
    await response.listen((_) {}).cancel();
    throw AudioStreamProbeException(
      'response rejected',
      statusCode: response.statusCode,
    );
  }
  final mime = response.headers.contentType?.mimeType.toLowerCase();
  if (mime != null &&
      !mime.startsWith('audio/') &&
      mime != 'video/mp4' &&
      mime != 'video/webm' &&
      mime != 'application/octet-stream') {
    await response.listen((_) {}).cancel();
    throw AudioStreamProbeException(
      'not audio',
      statusCode: response.statusCode,
    );
  }
  try {
    // firstWhere automatically cancels the response subscription after a chunk.
    await response.firstWhere((chunk) => chunk.isNotEmpty);
  } on StateError {
    throw const AudioStreamProbeException('empty response');
  }
}
