import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Local, opt-in diagnostics. Never log signed URLs, query strings, headers,
/// cookies, response bodies or the raw exception (which can contain all of them).
class PlaybackDiagnostics {
  static void Function(String message)? sink;

  static String failureLabel(Object error) {
    if (error is DioException) {
      final status = error.response?.statusCode;
      if (status != null) return 'HTTP $status';
      return 'Dio.${error.type.name}';
    }
    if (error is TimeoutException) return 'timeout';
    if (error is SocketException) return 'connection';
    if (error is HandshakeException) return 'TLS';
    // PlayerException and YoutubeExplodeException include an HTTP status in
    // their text. Extract only the number, never copy the full message to logs.
    final status = RegExp(
      r'(?:response code:|status code[: ]|returned|HTTP)\s*(\d{3})\b',
      caseSensitive: false,
    ).firstMatch(error.toString());
    if (status != null) return 'HTTP ${status.group(1)}';
    return error.runtimeType.toString();
  }

  static void record(
    String stage, {
    required String source,
    String? url,
    Object? error,
    int? count,
    int? durationMs,
    String? detail,
  }) {
    final output = sink;
    if (output == null) return;
    final host = url == null ? null : Uri.tryParse(url)?.host;
    output(
      '[HookAudio] ${jsonEncode({'stage': stage, 'source': source, if (detail != null) 'detail': detail, if (host != null && host.isNotEmpty) 'host': host, if (error != null) 'failure': failureLabel(error), if (count != null) 'count': count, if (durationMs != null) 'durationMs': durationMs})}',
    );
  }
}
