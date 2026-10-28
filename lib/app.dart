import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/audio_player/data/audio_player_service.dart';
import 'features/audio_player/presentation/mini_player.dart';
import 'features/audio_player/presentation/player_state_provider.dart';
import 'features/library/presentation/library_screen.dart';
import 'features/search/presentation/search_screen.dart';
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${error.message}: ${error.track.title}'),
          duration: const Duration(seconds: 4),
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

  Widget _buildGlassNavigationBar(dynamic theme) {
    return HookGlassCard(
      theme: theme,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
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

  Widget _navItem(int index, IconData icon, String label, dynamic theme) {
    final isSelected = _currentIndex == index;
    final color =
        isSelected ? theme.colors.textPrimary : theme.colors.textSecondary;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colors.primary.withValues(alpha: 0.9)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
