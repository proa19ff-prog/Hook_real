import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/localized_labels.dart';
import 'core/localization/locale_provider.dart';
import 'features/audio_player/data/audio_player_service.dart';
import 'features/audio_player/presentation/mini_player.dart';
import 'features/audio_player/presentation/player_state_provider.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/extractor/models/media_track.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/theme_engine/domain/hook_theme.dart';
import 'features/theme_engine/presentation/dynamic_shader_background.dart';
import 'l10n/generated/app_localizations.dart';

class HookApp extends ConsumerWidget {
  const HookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final onboardingDone = ref.watch(onboardingProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: onboardingDone
          ? const MainNavigationShell()
          : const OnboardingScreen(),
    );
  }
}

class MainNavigationShell extends ConsumerStatefulWidget {
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  static const _navigationHeight = 76.0;

  int _currentIndex = 0;
  int _searchFocusRequest = 0;
  bool _youtubeWarningDismissed = false;

  void _openSearch() {
    setState(() {
      _currentIndex = 1;
      _searchFocusRequest++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final currentTrack = ref.watch(currentTrackProvider);
    final strings = AppLocalizations.of(context);
    final youtubeAvailable = ref.watch(youtubeAvailabilityProvider);
    final youtubeLoaded =
        ref.watch(playbackSourceProvider) == TrackSource.youtubeMusic;

    ref.listen<AsyncValue<AudioPlaybackError?>>(playbackErrorProvider, (
      _,
      next,
    ) {
      final error = next.valueOrNull;
      if (error == null || !context.mounted) return;
      final message = switch (error.kind) {
        AudioPlaybackErrorKind.forbidden => strings.audioForbidden,
        AudioPlaybackErrorKind.catalogUnavailable =>
          strings.fullVersionUnavailable,
        AudioPlaybackErrorKind.sourceUnavailable =>
          strings.sourcePlaybackFailed(error.track.source.labelFor(strings)),
      };

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  MingCuteIcons.mgc_alert_line,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$message: ${error.track.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent.shade700.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: strings.retry,
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(audioPlayerServiceProvider).playTrack(error.track),
            ),
          ),
        );
    });

    final screens = [
      HomeScreen(theme: theme, onOpenSearch: _openSearch),
      SearchScreen(theme: theme, focusRequestId: _searchFocusRequest),
      LibraryScreen(theme: theme),
    ];
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return Scaffold(
      bottomNavigationBar: keyboardOpen
          ? null
          : PlaybackDock(theme: theme, navigation: _buildNavigationBar(theme)),
      body: DynamicShaderBackground(
        theme: theme,
        artworkUrl: currentTrack?.artworkUrl,
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  for (var index = 0; index < screens.length; index++)
                    TickerMode(
                      enabled: index == _currentIndex,
                      child: screens[index],
                    ),
                ],
              ),
            ),
            if (!_youtubeWarningDismissed &&
                !youtubeLoaded &&
                youtubeAvailable.valueOrNull == false)
              Positioned(
                top: MediaQuery.paddingOf(context).top + 8,
                left: 12,
                right: 12,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 620),
                    child: _YouTubeVpnBanner(
                      theme: theme,
                      onRetry: () {
                        setState(() => _youtubeWarningDismissed = false);
                        ref.invalidate(youtubeAvailabilityProvider);
                      },
                      onDismiss: () =>
                          setState(() => _youtubeWarningDismissed = true),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar(HookTheme theme) {
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: colors.surface,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textSecondary,
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? colors.textPrimary
                : colors.textSecondary,
            size: 24,
          ),
        ),
      ),
      child: NavigationBar(
        height: _navigationHeight,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(MingCuteIcons.mgc_compass_line),
            label: strings.home,
          ),
          NavigationDestination(
            icon: const Icon(MingCuteIcons.mgc_search_2_line),
            label: strings.search,
          ),
          NavigationDestination(
            icon: const Icon(MingCuteIcons.mgc_disc_line),
            label: strings.library,
          ),
        ],
      ),
    );
  }
}

class _YouTubeVpnBanner extends StatelessWidget {
  const _YouTubeVpnBanner({
    required this.theme,
    required this.onRetry,
    required this.onDismiss,
  });

  final HookTheme theme;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    final strings = AppLocalizations.of(context);
    return Material(
      color: colors.surface,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.38),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 13, 8, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.accent.withValues(alpha: 0.48)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shield_outlined,
                color: colors.accent,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.youtubeUnavailableTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    strings.youtubeUnavailableBody,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.3,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      foregroundColor: colors.accent,
                    ),
                    child: Text(strings.checkAgain),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: strings.dismiss,
              onPressed: onDismiss,
              icon: const Icon(Icons.close_rounded, size: 19),
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
