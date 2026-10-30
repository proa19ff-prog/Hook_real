import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/audio_player/data/audio_player_service.dart';
import 'features/audio_player/presentation/mini_player.dart';
import 'features/audio_player/presentation/player_state_provider.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/search/presentation/search_screen.dart';
import 'features/theme_engine/domain/hook_theme.dart';
import 'features/theme_engine/presentation/dynamic_shader_background.dart';
import 'features/theme_engine/presentation/glass_card.dart';
import 'features/theme_engine/presentation/theme_settings_screen.dart';

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
  int _currentIndex = 0;

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
                Icon(Icons.error_outline_rounded,
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
      SearchScreen(theme: theme),
      LibraryScreen(theme: theme),
      ThemeSettingsScreen(theme: theme),
    ];

    return Scaffold(
      body: DynamicShaderBackground(
        theme: theme,
        artworkUrl: currentTrack?.artworkUrl,
        child: Stack(
          children: [
            // Active Tab Page
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),

            // Persistent MiniPlayer & Floating Glass Bottom Navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MiniPlayer(theme: theme),
                  _buildGlassNavigationBar(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassNavigationBar(HookTheme theme) {
    return HookGlassCard(
      theme: theme,
      elevation: 1.0,
      margin: EdgeInsets.fromLTRB(
          16, 0, 16, 10 + MediaQuery.paddingOf(context).bottom),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      borderRadius: BorderRadius.circular(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(0, Icons.search_rounded, 'Поиск', theme),
          _navItem(1, Icons.library_music_rounded, 'Медиатека', theme),
          _navItem(2, Icons.palette_outlined, 'Темы', theme),
        ],
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colors.primary.withValues(alpha: 0.85),
                      theme.colors.primary.withValues(alpha: 0.6),
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0,
                duration: const Duration(milliseconds: 220),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : theme.colors.textSecondary.withValues(alpha: 0.75),
                  size: 22,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
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
