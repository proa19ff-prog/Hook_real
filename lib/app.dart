import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/localization/localized_labels.dart';
import 'core/localization/locale_provider.dart';
import 'core/platform/system_volume.dart';
import 'core/ui/hook_haptics.dart';
import 'core/ui/hook_icons.dart';
import 'core/ui/hook_shortcuts.dart';
import 'core/ui/hook_tokens.dart';
import 'features/audio_player/data/audio_player_service.dart';
import 'features/audio_player/presentation/mini_player.dart';
import 'features/audio_player/presentation/player_state_provider.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/onboarding_provider.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/extractor/models/media_track.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/settings/presentation/settings_provider.dart';
import 'features/settings/presentation/settings_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/theme_engine/domain/hook_theme.dart';
import 'features/theme_engine/presentation/dynamic_shader_background.dart';
import 'features/theme_engine/presentation/theme_settings_screen.dart';
import 'l10n/generated/app_localizations.dart';

class HookApp extends ConsumerWidget {
  const HookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);
    final onboardingDone = ref.watch(onboardingProvider);
    // Watching these two here is what applies them: the providers mirror the
    // stored value into the statics the code below the widget tree reads.
    ref.watch(hapticsEnabledProvider);
    ref.watch(backgroundPrefetchProvider);
    final reduceMotion = ref.watch(reduceMotionProvider);

    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      // Keyboard conveniences on desktop, carried above the navigator.
      //
      // `CallbackShortcuts` only sees keys no descendant consumed, and a
      // `TextField` consumes almost nothing — so a bare `M` while typing in
      // search both muted the machine and swallowed the letter. Every binding
      // is therefore gated on "no text field has focus".
      builder: (context, child) {
        final tree = CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.space):
                HookShortcuts.whenNotTyping(
                  () => ref.read(audioPlayerServiceProvider).togglePlayPause(),
                ),
            const SingleActivator(LogicalKeyboardKey.arrowRight):
                HookShortcuts.whenNotTyping(() async {
                  final player = ref.read(audioPlayerServiceProvider);
                  await player.seek(
                    player.rawPlayer.position + const Duration(seconds: 10),
                  );
                }),
            const SingleActivator(LogicalKeyboardKey.arrowLeft):
                HookShortcuts.whenNotTyping(() async {
                  final player = ref.read(audioPlayerServiceProvider);
                  await player.seek(
                    player.rawPlayer.position - const Duration(seconds: 10),
                  );
                }),
            const SingleActivator(LogicalKeyboardKey.arrowRight, control: true):
                HookShortcuts.whenNotTyping(
                  () => ref.read(audioPlayerServiceProvider).skipToNext(),
                ),
            const SingleActivator(LogicalKeyboardKey.arrowLeft, control: true):
                HookShortcuts.whenNotTyping(
                  () => ref.read(audioPlayerServiceProvider).skipToPrevious(),
                ),
            // Volume needs a modifier: bare ↑/↓ belong to list navigation.
            const SingleActivator(LogicalKeyboardKey.arrowUp, control: true):
                HookShortcuts.whenNotTyping(
                  () => ref.read(systemVolumeProvider.notifier).nudge(1),
                ),
            const SingleActivator(LogicalKeyboardKey.arrowDown, control: true):
                HookShortcuts.whenNotTyping(
                  () => ref.read(systemVolumeProvider.notifier).nudge(-1),
                ),
            const SingleActivator(LogicalKeyboardKey.keyM):
                HookShortcuts.whenNotTyping(
                  () => ref.read(systemVolumeProvider.notifier).toggleMute(),
                ),
          },
          child: Focus(autofocus: true, child: child!),
        );
        if (!reduceMotion) return tree;
        // The settings toggle has to reach every implicit animation, and the
        // media query is the single place the whole tree reads it from.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(disableAnimations: true),
          child: tree,
        );
      },
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
        AudioPlaybackErrorKind.ageRestricted => strings.ageRestrictedTrack,
      };

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  HookIcons.warning,
                  color: theme.colors.onDanger,
                  size: 20,
                ),
                const SizedBox(width: HookSpace.sm),
                Expanded(
                  child: Text(
                    '$message: ${error.track.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: theme.colors.danger,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(
              HookSpace.lg,
              0,
              HookSpace.lg,
              HookSpace.md,
            ),
            shape: RoundedRectangleBorder(borderRadius: HookRadius.smAll),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: strings.retry,
              textColor: theme.colors.onDanger,
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
    final desktop = HookBreakpoints.isDesktop(context);

    // A wide window gets a rail and a full width player bar; a phone keeps the
    // bottom navigation it already had. Only the frame changes — the screens
    // are the same widgets, so nothing can drift between the two layouts.
    final content = Stack(
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
                  onDismiss: () => setState(() => _youtubeWarningDismissed = true),
                ),
              ),
            ),
          ),
      ],
    );

    return Scaffold(
      bottomNavigationBar: desktop || keyboardOpen
          ? null
          : PlaybackDock(theme: theme, navigation: _buildNavigationBar(theme)),
      body: DynamicShaderBackground(
        theme: theme,
        artworkUrl: currentTrack?.artworkUrl,
        child: desktop
            ? Row(
                children: [
                  _DesktopRail(
                    theme: theme,
                    index: _currentIndex,
                    onSelect: (index) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      setState(() => _currentIndex = index);
                    },
                    onOpenSettings: () => _push(
                      SettingsScreen(),
                    ),
                    onOpenTheme: () => _push(
                      ThemeSettingsScreen(theme: ref.read(themeProvider)),
                    ),
                    onOpenStats: () => _push(StatsScreen(theme: theme)),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: theme.colors.border,
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(child: content),
                        PlaybackDock(theme: theme),
                      ],
                    ),
                  ),
                ],
              )
            : content,
      ),
    );
  }

  void _push(Widget screen) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionDuration: HookMotion.base,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: HookMotion.enter,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
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
            fontSize: HookType.label,
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
          HookHaptics.tap();
          setState(() => _currentIndex = index);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(HookIcons.home),
            label: strings.home,
          ),
          NavigationDestination(
            icon: const Icon(HookIcons.search),
            label: strings.search,
          ),
          NavigationDestination(
            icon: const Icon(HookIcons.library),
            label: strings.library,
          ),
        ],
      ),
    );
  }
}

/// The desktop sidebar. Wide windows have the vertical room that phones do
/// not, so settings, the theme editor and listening stats stop being hidden
/// behind an icon on the home header.
class _DesktopRail extends StatelessWidget {
  const _DesktopRail({
    required this.theme,
    required this.index,
    required this.onSelect,
    required this.onOpenSettings,
    required this.onOpenTheme,
    required this.onOpenStats,
  });

  final HookTheme theme;
  final int index;
  final ValueChanged<int> onSelect;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenTheme;
  final VoidCallback onOpenStats;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;

    Widget destination({
      required int value,
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      final selected = index == value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: HookSpace.sm),
        child: Material(
          color: selected ? colors.wash : Colors.transparent,
          borderRadius: HookRadius.mdAll,
          child: InkWell(
            onTap: onTap,
            borderRadius: HookRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: HookSpace.md,
                vertical: HookSpace.md,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: 22,
                    color: selected ? colors.textPrimary : colors.textSecondary,
                  ),
                  const SizedBox(width: HookSpace.md),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? colors.textPrimary
                            : colors.textSecondary,
                        fontSize: HookType.bodySmall,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      width: 232,
      color: colors.background,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                HookSpace.lg,
                HookSpace.lg,
                HookSpace.lg,
                HookSpace.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: HookRadius.smAll,
                    ),
                    child: Icon(
                      HookIcons.music,
                      size: 17,
                      color: colors.onPrimary,
                    ),
                  ),
                  const SizedBox(width: HookSpace.md),
                  Text(
                    strings.appTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: HookType.heading,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: HookSpace.xs),
            destination(
              value: 0,
              icon: HookIcons.home,
              label: strings.home,
              onTap: () => onSelect(0),
            ),
            const SizedBox(height: 2),
            destination(
              value: 1,
              icon: HookIcons.search,
              label: strings.search,
              onTap: () => onSelect(1),
            ),
            const SizedBox(height: 2),
            destination(
              value: 2,
              icon: HookIcons.library,
              label: strings.library,
              onTap: () => onSelect(2),
            ),
            const Spacer(),
            Divider(color: colors.border, height: 1),
            const SizedBox(height: HookSpace.sm),
            _RailAction(
              theme: theme,
              icon: HookIcons.stats,
              label: strings.statsTitle,
              onTap: onOpenStats,
            ),
            _RailAction(
              theme: theme,
              icon: HookIcons.palette,
              label: strings.themeSettings,
              onTap: onOpenTheme,
            ),
            _RailAction(
              theme: theme,
              icon: HookIcons.settings,
              label: strings.settings,
              onTap: onOpenSettings,
            ),
            const SizedBox(height: HookSpace.sm),
          ],
        ),
      ),
    );
  }
}

class _RailAction extends StatelessWidget {
  const _RailAction({
    required this.theme,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final HookTheme theme;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: HookSpace.sm),
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(
          foregroundColor: colors.textSecondary,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: HookSpace.md,
            vertical: HookSpace.sm,
          ),
          minimumSize: const Size(0, 36),
        ),
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          style: const TextStyle(fontSize: HookType.bodySmall),
        ),
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
      borderRadius: HookRadius.mdAll,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          HookSpace.lg,
          HookSpace.md,
          HookSpace.sm,
          HookSpace.md,
        ),
        decoration: BoxDecoration(
          borderRadius: HookRadius.mdAll,
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
              child: Icon(HookIcons.shield, color: colors.accent, size: 19),
            ),
            const SizedBox(width: HookSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.youtubeUnavailableTitle,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: HookType.bodySmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: HookSpace.xs),
                  Text(
                    strings.youtubeUnavailableBody,
                    style: TextStyle(
                      color: colors.textSecondary,
                      height: 1.35,
                      fontSize: HookType.label,
                    ),
                  ),
                  const SizedBox(height: HookSpace.sm),
                  TextButton(
                    onPressed: onRetry,
                    style: TextButton.styleFrom(
                      minimumSize: const Size(0, 34),
                      padding: const EdgeInsets.symmetric(
                        horizontal: HookSpace.md,
                      ),
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
              icon: const Icon(HookIcons.close, size: 19),
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
