import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'app.dart';
import 'core/storage/local_storage_service.dart';
import 'features/library/presentation/library_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Android background playback notifications
  try {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.hook.music.channel.audio',
      androidNotificationChannelName: 'Hook Music Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
  } catch (_) {
    // Graceful fallback on unsupported platforms
  }

  // Pre-load local storage service for offline favorites & history
  final storageService = await LocalStorageService.create();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const HookApp(),
    ),
  );
}
