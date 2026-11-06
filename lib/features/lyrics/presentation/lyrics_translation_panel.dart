import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../data/lyrics_client.dart';
import '../data/lyrics_translation_service.dart';
import '../domain/lyric_line.dart';

List<String> translationLines(LyricsResult lyrics) {
  final output = <String>[];
  void add(LyricLine line) {
    output.add(line.text);
    for (final backing in line.backingVocals) {
      add(backing);
    }
  }

  if (lyrics.lines.isEmpty) {
    output.addAll((lyrics.plainLyrics ?? '').split('\n'));
  } else {
    for (final line in lyrics.lines) {
      add(line);
    }
  }
  return output;
}

/// Owns the translation request, never the original lyric timings or positions.
/// Re-key this panel when track/lyrics change so stale results cannot be shown.
class LyricsTranslationPanel extends ConsumerStatefulWidget {
  const LyricsTranslationPanel({
    super.key,
    required this.lyrics,
    required this.theme,
    required this.caption,
    required this.builder,
  });
  final LyricsResult lyrics;
  final HookTheme theme;
  final String caption;
  final Widget Function(Map<String, String> translations) builder;

  @override
  ConsumerState<LyricsTranslationPanel> createState() =>
      _LyricsTranslationPanelState();
}

class _LyricsTranslationPanelState
    extends ConsumerState<LyricsTranslationPanel> {
  late LyricsTranslationService _service;
  Map<String, String> _translations = const {};
  String? _request;
  String? _error;
  String? _target;
  bool _visible = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _service = ref.read(lyricsTranslationServiceProvider);
  }

  @override
  void dispose() {
    final request = _request;
    if (request != null) unawaited(_service.cancel(request));
    super.dispose();
  }

  void _cancel() {
    final request = _request;
    _request = null;
    if (request != null) unawaited(_service.cancel(request));
    setState(() => _busy = false);
  }

  Future<void> _toggle() async {
    if (_busy) {
      _cancel();
      return;
    }
    if (_translations.isNotEmpty) {
      setState(() => _visible = !_visible);
      return;
    }
    final id = _service.newRequestId();
    final strings = AppLocalizations.of(context);
    setState(() {
      _request = id;
      _busy = true;
      _error = null;
    });
    bool active() => mounted && _request == id;
    try {
      Future<Map<String, String>> run(bool download) => _service.translate(
        id: id,
        lines: translationLines(widget.lyrics),
        target: _target!,
        allowDownload: download,
      );
      Map<String, String> translated;
      try {
        translated = await run(false);
      } on PlatformException catch (error) {
        if (error.code != 'modelRequired' || !mounted || !active()) rethrow;
        final allow = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.translationModelTitle),
            content: SingleChildScrollView(
              child: Text(strings.translationModelBody),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.translationDownload),
              ),
            ],
          ),
        );
        if (!active() || allow != true) return;
        translated = await run(true);
      }
      if (active()) {
        setState(() {
          _translations = translated;
          _visible = true;
        });
      }
    } on MissingPluginException {
      if (active()) setState(() => _error = strings.translationUnsupported);
    } on PlatformException catch (error) {
      if (active() && error.code != 'cancelled') {
        setState(
          () => _error = switch (error.code) {
            'sameLanguage' => strings.translationSameLanguage,
            'unsupportedLanguage' => strings.translationUnknownLanguage,
            'tooLarge' || 'invalidInput' => strings.translationTooLarge,
            _ => strings.translationUnavailable,
          },
        );
      }
    } catch (_) {
      if (active()) setState(() => _error = strings.translationUnavailable);
    } finally {
      if (active()) {
        setState(() {
          _busy = false;
          _request = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = widget.theme.colors;
    _target ??= Localizations.localeOf(context).languageCode == 'ru'
        ? 'ru'
        : 'en';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.caption,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colors.textSecondary, fontSize: 10),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: Semantics(
                  label: strings.translationTarget,
                  child: DropdownButton<String>(
                    key: const ValueKey('translation-target'),
                    value: _target,
                    isExpanded: true,
                    menuWidth: 240,
                    selectedItemBuilder: (context) => [
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'RU',
                          semanticsLabel: strings.translationRussian,
                        ),
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          'EN',
                          semanticsLabel: strings.translationEnglish,
                        ),
                      ),
                    ],
                    underline: const SizedBox.shrink(),
                    dropdownColor: colors.surface,
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                    items: [
                      DropdownMenuItem(
                        value: 'ru',
                        child: Text(strings.translationRussian),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(strings.translationEnglish),
                      ),
                    ],
                    onChanged: _busy
                        ? null
                        : (target) => setState(() {
                            _target = target;
                            _translations = const {};
                            _visible = false;
                            _error = null;
                          }),
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey('lyrics-translate-button'),
                tooltip: _busy
                    ? strings.cancelTranslation
                    : _visible
                    ? strings.hideTranslation
                    : strings.translateLyrics,
                isSelected: _visible,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                color: _visible ? colors.accent : colors.textPrimary,
                icon: Icon(
                  _busy ? Icons.close_rounded : Icons.translate_rounded,
                ),
                onPressed: _toggle,
              ),
            ],
          ),
        ),
        if (_busy)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Semantics(
              liveRegion: true,
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.translationLoading,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Semantics(
              liveRegion: true,
              child: Text(
                _error!,
                style: TextStyle(color: colors.textSecondary, fontSize: 12),
              ),
            ),
          ),
        if (_visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Tooltip(
              message: strings.translationNotice,
              child: Text(
                strings.translationAttribution,
                style: TextStyle(color: colors.textSecondary, fontSize: 11),
              ),
            ),
          ),
        Expanded(child: widget.builder(_visible ? _translations : const {})),
      ],
    );
  }
}
