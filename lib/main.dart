import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'core/diagnostics/playback_diagnostics.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smtc_windows/smtc_windows.dart';

import 'app.dart';
import 'core/storage/audio_cache_manager.dart';
import 'core/storage/local_storage_service.dart';
import 'features/account/account_service.dart';
import 'features/audio_player/data/audio_player_service.dart';
import 'features/audio_player/data/windows_smtc_bridge.dart';
import 'features/audio_player/presentation/player_state_provider.dart';
import 'features/extractor/stream_resolver.dart';
import 'features/extractor/sources/remote_resolver_source.dart';
import 'features/extractor/sources/youtube_proxy.dart';
import 'features/library/presentation/library_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['Inter'], text);
  });
  HttpOverrides.global = SelectiveYouTubeProxyHttpOverrides();
  if (kDebugMode) PlaybackDiagnostics.sink = debugPrint;

  await AccountService.ensureInitialized();
  final storageService = await LocalStorageService.create();
  RemoteResolverSource.endpoint = storageService.getRemoteResolverUrl();
  final selectedLocale = storageService.getLocaleCode();
  final usesRussian =
      selectedLocale == 'ru' ||
      ((selectedLocale == null || selectedLocale == 'system') &&
          Platform.localeName.toLowerCase().startsWith('ru'));
  final resolver = StreamResolver();
  final cacheManager = AudioCacheManager();
  final AudioPlayerService audioService;
  if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    audioService = await AudioService.init<AudioPlayerService>(
      builder: () => AudioPlayerService(
        resolver: resolver,
        storageService: storageService,
        cacheManager: cacheManager,
      ),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.hook.music.channel.audio',
        androidNotificationChannelName: usesRussian
            ? 'Воспроизведение'
            : 'Playback',
        androidNotificationChannelDescription: usesRussian
            ? 'Управление музыкой в шторке'
            : 'Music controls in notifications',
        androidNotificationIcon: 'drawable/ic_stat_hook',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        artDownscaleWidth: 300,
        artDownscaleHeight: 300,
        preloadArtwork: true,
      ),
    );
  } else {
    // audio_service has no desktop backend; the handler works standalone and
    // Windows media keys come from SMTC instead of a notification.
    audioService = AudioPlayerService(
      resolver: resolver,
      storageService: storageService,
      cacheManager: cacheManager,
    );
    if (Platform.isWindows) {
      await SMTCWindows.initialize();
      WindowsSmtcBridge(
        audioService,
        SMTCWindows(
          config: const SMTCConfig(
            playEnabled: true,
            pauseEnabled: true,
            nextEnabled: true,
            prevEnabled: true,
            stopEnabled: false,
            fastForwardEnabled: false,
            rewindEnabled: false,
          ),
        ),
      );
    }
  }
  await audioService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
        audioCacheManagerProvider.overrideWithValue(cacheManager),
        streamResolverProvider.overrideWithValue(resolver),
        audioPlayerServiceProvider.overrideWithValue(audioService),
      ],
      child: const HookApp(),
    ),
  );
}
