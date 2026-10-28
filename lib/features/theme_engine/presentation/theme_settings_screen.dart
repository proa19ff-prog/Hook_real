import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: widget.theme.colors.surface,
          title: Text(
            'Импорт темы из JSON',
            style: TextStyle(color: widget.theme.colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Вставьте конфигурационный JSON темы:',
                style: TextStyle(
                    color: widget.theme.colors.textSecondary, fontSize: 13),
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
                  fillColor: widget.theme.colors.surfaceGlass,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: widget.theme.colors.border),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.theme.colors.primary,
                foregroundColor: Colors.white,
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

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colors.surface,
          title: Text(
            'Экспорт темы (JSON)',
            style: TextStyle(color: theme.colors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                constraints: const BoxConstraints(maxHeight: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colors.surfaceGlass,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colors.border),
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
              child: const Text('Закрыть'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy_rounded, size: 16),
              label: const Text('Скопировать JSON'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colors.primary,
                foregroundColor: Colors.white,
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ДВИЖОК ТЕМ И ШЕЙДЕРОВ',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: theme.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'GLSL фрагментные шейдеры и дизайн',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Экспорт JSON',
                        icon: Icon(Icons.file_upload_outlined,
                            color: theme.colors.textSecondary),
                        onPressed: () => _showExportJsonDialog(context, theme),
                      ),
                      IconButton(
                        tooltip: 'Импорт JSON',
                        icon: Icon(Icons.file_download_outlined,
                            color: theme.colors.textSecondary),
                        onPressed: () => _showImportJsonDialog(context),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Theme Presets Selector
              Text(
                'ГОТОВЫЕ ТЕМЫ ОФОРМЛЕНИЯ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colors.textSecondary,
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
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colors.surfaceGlass,
                          borderRadius:
                              BorderRadius.circular(theme.styling.borderRadius),
                          border: Border.all(
                            color: isSelected
                                ? theme.colors.primary
                                : theme.colors.border,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Color dots preview
                            Row(
                              children: [
                                _colorCircle(t.colors.primary),
                                const SizedBox(width: 4),
                                _colorCircle(t.colors.accent),
                                const SizedBox(width: 4),
                                _colorCircle(t.colors.background),
                              ],
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
                                      color: theme.colors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    t.author,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle_rounded,
                                  color: theme.colors.primary, size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),

              // Live Shader Controls
              Text(
                'GPU ШЕЙДЕРЫ (IMPELLER / SKIA GLSL)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: theme.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colors.surfaceGlass,
                  borderRadius:
                      BorderRadius.circular(theme.styling.borderRadius),
                  border: Border.all(color: theme.colors.border),
                ),
                child: Column(
                  children: [
                    // Mesh Shader Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.auto_awesome_rounded,
                                color: theme.colors.accent, size: 20),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Mesh Gradient Shader',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: theme.colors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Плавный GPU-градиент по цветам трека',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.colors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Switch(
                          value: theme.styling.shaderMeshEnabled,
                          activeThumbColor: theme.colors.primary,
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
                    const Divider(height: 20),

                    // Noise Intensity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Аналоговое виниловое зерно (Noise)',
                          style: TextStyle(
                              fontSize: 12, color: theme.colors.textPrimary),
                        ),
                        Text(
                          '${(theme.styling.shaderNoiseIntensity * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colors.accent,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: theme.styling.shaderNoiseIntensity,
                      min: 0.0,
                      max: 0.15,
                      activeColor: theme.colors.primary,
                      inactiveColor: theme.colors.border,
                      onChanged: (val) {
                        final updatedTheme = theme.copyWith(
                          styling:
                              theme.styling.copyWith(shaderNoiseIntensity: val),
                        );
                        themeNotifier
                            .importJson(jsonEncode(updatedTheme.toJson()));
                      },
                    ),

                    const Divider(height: 20),

                    // Card Blur
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Размытие стекла (Backdrop Blur)',
                          style: TextStyle(
                              fontSize: 12, color: theme.colors.textPrimary),
                        ),
                        Text(
                          '${theme.styling.cardBlur.toInt()}px',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colors.accent,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: theme.styling.cardBlur,
                      min: 0.0,
                      max: 50.0,
                      activeColor: theme.colors.accent,
                      inactiveColor: theme.colors.border,
                      onChanged: (val) {
                        final updatedTheme = theme.copyWith(
                          styling: theme.styling.copyWith(cardBlur: val),
                        );
                        themeNotifier
                            .importJson(jsonEncode(updatedTheme.toJson()));
                      },
                    ),

                    const Divider(height: 20),

                    // Border Radius
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Скругление элементов интерфейса',
                          style: TextStyle(
                              fontSize: 12, color: theme.colors.textPrimary),
                        ),
                        Text(
                          '${theme.styling.borderRadius.toInt()}px',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: theme.colors.primary,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: theme.styling.borderRadius,
                      min: 0.0,
                      max: 32.0,
                      activeColor: theme.colors.primary,
                      inactiveColor: theme.colors.border,
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

              const SizedBox(height: 80), // Padding for MiniPlayer
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorCircle(Color color) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
      ),
    );
  }
}
