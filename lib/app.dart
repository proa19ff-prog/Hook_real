import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'features/audio_player/data/audio_player_service.dart';
import 'features/audio_player/presentation/mini_player.dart';
import 'features/audio_player/presentation/player_state_provider.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/theme_engine/domain/hook_theme.dart';
import 'features/theme_engine/presentation/dynamic_shader_background.dart';

class HookApp extends ConsumerWidget {
  const HookApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);

    return MaterialApp(
      title: 'Hook',
      debugShowCheckedModeBanner: false,
      theme: theme.toThemeData(),
      home: const MainNavigationShell(),
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

    ref.listen<AsyncValue<AudioPlaybackError?>>(playbackErrorProvider,
        (_, next) {
      final error = next.valueOrNull;
      if (error == null || !context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MingCuteIcons.mgc_alert_line,
                    color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${error.message}: ${error.track.title}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.redAccent.shade700.withValues(alpha: 0.9),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Повторить',
              textColor: Colors.white,
              onPressed: () =>
                  ref.read(audioPlayerServiceProvider).playTrack(error.track),
            ),
          ),
        );
    });

    final screens = [
      HomeScreen(
        theme: theme,
        onOpenSearch: _openSearch,
      ),
      SearchScreen(
        theme: theme,
        focusRequestId: _searchFocusRequest,
      ),
      LibraryScreen(theme: theme),
    ];
    final navigationHeight =
        _navigationHeight + MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: DynamicShaderBackground(
        theme: theme,
        artworkUrl: currentTrack?.artworkUrl,
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: navigationHeight,
              child: MiniPlayer(theme: theme),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildGlassNavigationBar(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassNavigationBar(HookTheme theme) {
    final colors = theme.colors;
    return SizedBox(
      height: _navigationHeight + MediaQuery.paddingOf(context).bottom,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.98),
          border: Border(
            top: BorderSide(color: colors.border.withValues(alpha: 0.8)),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          8,
          7,
          8,
          7 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(0, MingCuteIcons.mgc_compass_line, 'Главная', theme),
            _navItem(1, MingCuteIcons.mgc_search_2_line, 'Поиск', theme),
            _navItem(2, MingCuteIcons.mgc_disc_line, 'Медиатека', theme),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, HookTheme theme) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  icon,
                  color: isSelected
                      ? theme.colors.primary
                      : theme.colors.textSecondary.withValues(alpha: 0.75),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? theme.colors.primary
                      : theme.colors.textSecondary.withValues(alpha: 0.75),
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: isSelected ? 0.5 : 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
