import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../domain/hook_theme.dart';

class ThemeSettingsScreen extends ConsumerStatefulWidget {
  final HookTheme theme;

  const ThemeSettingsScreen({
    super.key,
    required this.theme,
  });

  @override
  ConsumerState<ThemeSettingsScreen> createState() =>
      _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  final TextEditingController _jsonInputController = TextEditingController();

  void _showImportJsonDialog(BuildContext context) {
    final colors = widget.theme.colors;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Импорт темы из JSON',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Вставьте конфигурационный JSON темы:',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _jsonInputController,
                maxLines: 8,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                decoration: InputDecoration(
                  hintText:
                      '{\n  "id": "my_theme",\n  "name": "Custom",\n  ...\n}',
                  filled: true,
                  fillColor: colors.surfaceGlass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Отмена',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                final jsonStr = _jsonInputController.text.trim();
                if (jsonStr.isNotEmpty) {
                  ref.read(themeProvider.notifier).importJson(jsonStr);
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Тема успешно применена!')),
                  );
                }
              },
              child: const Text('Применить'),
            ),
          ],
        );
      },
    );
  }

  void _showExportJsonDialog(BuildContext context, HookTheme theme) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(theme.toJson());
    final colors = theme.colors;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Экспорт темы (JSON)',
            style: TextStyle(
              color: colors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceGlass,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    jsonStr,
                    style:
                        const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'Закрыть',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(MingCuteIcons.mgc_copy_line, size: 16),
              label: const Text('Скопировать JSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: jsonStr));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('JSON темы скопирован в буфер!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);
    final colors = theme.colors;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ТЕМЫ И ШЕЙДЕРЫ',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GLSL фрагментные шейдеры и дизайн',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceGlass.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colors.border.withValues(alpha: 0.3)),
                          ),
                          child: IconButton(
                            tooltip: 'Экспорт JSON',
                            icon: Icon(MingCuteIcons.mgc_file_upload_line,
                                color: colors.textPrimary, size: 20),
                            onPressed: () =>
                                _showExportJsonDialog(context, theme),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: colors.surfaceGlass.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: colors.border.withValues(alpha: 0.3)),
                          ),
                          child: IconButton(
                            tooltip: 'Импорт JSON',
                            icon: Icon(MingCuteIcons.mgc_file_download_line,
                                color: colors.textPrimary, size: 20),
                            onPressed: () => _showImportJsonDialog(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Theme Presets Selector
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ГОТОВЫЕ ТЕМЫ ОФОРМЛЕНИЯ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: themeNotifier.availableThemes.map((t) {
                  final isSelected = t.id == theme.id;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      borderRadius:
                          BorderRadius.circular(theme.styling.borderRadius),
                      onTap: () => themeNotifier.setTheme(t.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary.withValues(alpha: 0.12)
                              : colors.surfaceGlass.withValues(alpha: 0.35),
                          borderRadius:
                              BorderRadius.circular(theme.styling.borderRadius),
                          border: Border.all(
                            color: isSelected
                                ? colors.primary
                                : colors.border.withValues(alpha: 0.35),
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colors.primary
                                        .withValues(alpha: 0.2),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Color dots preview
                            Row(
                              children: [
                                _colorCircle(t.colors.primary),
                                const SizedBox(width: 5),
                                _colorCircle(t.colors.accent),
                                const SizedBox(width: 5),
                                _colorCircle(t.colors.background),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Mini gradient bar
                            Container(
                              width: 32,
                              height: 18,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    t.colors.primary,
                                    t.colors.accent,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected
                                          ? colors.accent
                                          : colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    t.author,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: colors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  MingCuteIcons.mgc_check_line,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Live Shader Controls
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 14,
                      decoration: BoxDecoration(
                        color: colors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'GPU ШЕЙДЕРЫ (IMPELLER / SKIA GLSL)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceGlass.withValues(alpha: 0.35),
                  borderRadius:
                      BorderRadius.circular(theme.styling.borderRadius),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Mesh Shader Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(MingCuteIcons.mgc_sparkles_line,
                                  color: colors.accent, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mesh Gradient Shader',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Плавный GPU-градиент по цветам трека',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: theme.styling.shaderMeshEnabled,
                          activeThumbColor: colors.primary,
                          onChanged: (val) {
                            final updatedTheme = theme.copyWith(
                              styling: theme.styling
                                  .copyWith(shaderMeshEnabled: val),
                            );
                            themeNotifier
                                .importJson(jsonEncode(updatedTheme.toJson()));
                          },
                        ),
                      ],
                    ),
                    Divider(
                      height: 24,
                      color: colors.border.withValues(alpha: 0.2),
                    ),

                    // Noise Intensity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Аналоговое виниловое зерно (Noise)',
                          style: TextStyle(
                              fontSize: 12, color: colors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(theme.styling.shaderNoiseIntensity * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: theme.styling.shaderNoiseIntensity,
                      min: 0.0,
                      max: 0.15,
                      activeColor: colors.primary,
                      inactiveColor: colors.border.withValues(alpha: 0.3),
                      onChanged: (val) {
                        final updatedTheme = theme.copyWith(
                          styling:
                              theme.styling.copyWith(shaderNoiseIntensity: val),
                        );
                        themeNotifier
                            .importJson(jsonEncode(updatedTheme.toJson()));
                      },
                    ),

                    Divider(
                      height: 24,
                      color: colors.border.withValues(alpha: 0.2),
                    ),

                    // Card Blur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Размытие стекла (Backdrop Blur)',
                          style: TextStyle(
                              fontSize: 12, color: colors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${theme.styling.cardBlur.toInt()}px',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.accent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: theme.styling.cardBlur,
                      min: 0.0,
                      max: 50.0,
                      activeColor: colors.accent,
                      inactiveColor: colors.border.withValues(alpha: 0.3),
                      onChanged: (val) {
                        final updatedTheme = theme.copyWith(
                          styling: theme.styling.copyWith(cardBlur: val),
                        );
                        themeNotifier
                            .importJson(jsonEncode(updatedTheme.toJson()));
                      },
                    ),

                    Divider(
                      height: 24,
                      color: colors.border.withValues(alpha: 0.2),
                    ),

                    // Border Radius
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Скругление элементов интерфейса',
                          style: TextStyle(
                              fontSize: 12, color: colors.textPrimary),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${theme.styling.borderRadius.toInt()}px',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: theme.styling.borderRadius,
                      min: 0.0,
                      max: 32.0,
                      activeColor: colors.primary,
                      inactiveColor: colors.border.withValues(alpha: 0.3),
                      onChanged: (val) {
                        final updatedTheme = theme.copyWith(
                          styling: theme.styling.copyWith(borderRadius: val),
                        );
                        themeNotifier
                            .importJson(jsonEncode(updatedTheme.toJson()));
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 120), // Padding for MiniPlayer
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
