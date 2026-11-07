import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../import_file_picker.dart';
import '../music_import_service.dart';

enum _ImportInput { link, text, file }

class ImportBottomSheet extends ConsumerStatefulWidget {
  final HookTheme theme;

  final ImportedCollection? initialCollection;

  const ImportBottomSheet({
    super.key,
    required this.theme,
    this.initialCollection,
  });

  static Future<void> show(
    BuildContext context,
    HookTheme theme, {
    ImportedCollection? initialCollection,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (context) =>
          ImportBottomSheet(theme: theme, initialCollection: initialCollection),
    );
  }

  @override
  ConsumerState<ImportBottomSheet> createState() => _ImportBottomSheetState();
}

class _ImportBottomSheetState extends ConsumerState<ImportBottomSheet> {
  final _inputController = TextEditingController();
  final _nameController = TextEditingController();
  _ImportInput _mode = _ImportInput.link;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _fileName;
  String? _errorMessage;
  ImportedCollection? _importedResult;

  bool get _busy => _isLoading || _isSaving;

  @override
  void initState() {
    super.initState();
    _importedResult = widget.initialCollection;
    _nameController.text = widget.initialCollection?.title ?? '';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _fileError(ImportFileError kind, AppLocalizations strings) =>
      switch (kind) {
        ImportFileError.tooLarge => strings.importFileTooLarge,
        ImportFileError.unsupported => strings.importFileUnsupported,
        ImportFileError.invalidEncoding => strings.importFileEncoding,
        ImportFileError.invalidCsv => strings.importCsvInvalid,
        ImportFileError.missingColumns => strings.importCsvMissingColumns,
        ImportFileError.empty => strings.importFileEmpty,
        ImportFileError.tooManyTracks => strings.importTooManyTracks,
      };

  void _setError(Object error, {bool fromFile = false}) {
    if (!mounted) return;
    final strings = AppLocalizations.of(context);
    setState(() {
      _isLoading = false;
      _isSaving = false;
      _errorMessage = switch (error) {
        MusicImportFileException() => _fileError(error.kind, strings),
        // The service writes these for the user (region blocks, private
        // playlists, disabled resolver) — surface them as they are.
        MusicImportException() => error.message,
        FormatException() when _mode != _ImportInput.link =>
          strings.importFileEmpty,
        _ => fromFile ? strings.importFileReadFailed : strings.importError,
      };
    });
  }

  Future<void> _pasteFromClipboard() async {
    if (_busy) return;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted || _busy || data?.text == null) return;
      setState(() {
        _inputController.text = data!.text!.trim();
        final platform = MusicImportService.detectPlatform(
          _inputController.text,
        );
        if (platform == ImportPlatform.csv || platform == ImportPlatform.text) {
          _mode = _ImportInput.text;
        }
        _errorMessage = null;
      });
    } catch (error) {
      _setError(error);
    }
  }

  void _setResult(ImportedCollection result) {
    if (!mounted) return;
    if (result.tracks.isEmpty) {
      throw const MusicImportFileException(ImportFileError.empty);
    }
    setState(() {
      _isLoading = false;
      _importedResult = result;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = result.title;
      }
    });
  }

  Future<void> _chooseFile() async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final file = await ImportFilePicker.pick();
      if (!mounted) return;
      if (file == null) {
        setState(() => _isLoading = false);
        return;
      }
      final service = ref.read(musicImportServiceProvider);
      final name = _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : file.name.replaceFirst(
              RegExp(r'\.(csv|txt)$', caseSensitive: false),
              '',
            );
      final csv = file.name.toLowerCase().endsWith('.csv');
      final result = csv
          ? await service.importFromCsv(file.text, title: name)
          : await service.importFromText(
              file.text,
              title: name,
              resolveTracks: false,
            );
      if (!mounted) return;
      _fileName = file.name;
      _setResult(result);
    } catch (error) {
      _setError(error, fromFile: true);
    }
  }

  Future<void> _startImport() async {
    if (_busy) return;
    final strings = AppLocalizations.of(context);
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(
        () => _errorMessage = _mode == _ImportInput.link
            ? strings.pasteImportLink
            : strings.pasteTrackList,
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final service = ref.read(musicImportServiceProvider);
      final platform = MusicImportService.detectPlatform(input);
      final name = _nameController.text.trim().isEmpty
          ? strings.importedPlaylistName(platform.name)
          : _nameController.text.trim();
      final result = platform == ImportPlatform.csv
          ? await service.importFromCsv(input, title: name)
          : _mode == _ImportInput.text || platform == ImportPlatform.text
          ? await service.importFromText(
              input,
              title: name,
              resolveTracks: false,
            )
          : await service.importFromUrl(input);
      _setResult(result);
    } catch (error) {
      _setError(error);
    }
  }

  void _playImported(List<MediaTrack> tracks) {
    if (_busy) return;
    final strings = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    ref.read(queueProvider.notifier).playQueue(tracks, startIndex: 0);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(strings.importedPlaylistStarted(tracks.length)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveToPlaylists() async {
    final collection = _importedResult;
    if (_busy || collection == null) return;
    final strings = AppLocalizations.of(context);
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = strings.importNameRequired);
      return;
    }
    if (ref.read(playlistsProvider).containsKey(name)) {
      setState(() => _errorMessage = strings.importNameExists);
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await ref
          .read(playlistsProvider.notifier)
          .savePlaylist(name, collection.tracks);
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(strings.playlistSaved(name)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = strings.importSaveFailed;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colors;
    final strings = AppLocalizations.of(context);
    final result = _importedResult;
    final sourceLabel = switch (result?.platform) {
      ImportPlatform.spotify => strings.importedFromSpotify,
      ImportPlatform.csv => strings.importedFromCsv,
      ImportPlatform.youtube => strings.importedFromYouTube,
      ImportPlatform.deezer => strings.importedFromDeezer,
      _ => strings.importedFromText,
    };
    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: colors.textPrimary,
      foregroundColor: colors.surface,
      minimumSize: const Size(double.infinity, 48),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    return PopScope(
      canPop: !_isSaving,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Material(
            color: colors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            clipBehavior: Clip.antiAlias,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        decoration: BoxDecoration(
                          color: colors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            strings.importMusic,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.6,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: strings.close,
                          onPressed: _isSaving
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result == null ? strings.importIntro : sourceLabel,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (result == null) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final mode in _ImportInput.values)
                            if (mode != _ImportInput.file ||
                                ImportFilePicker.isSupported)
                              ChoiceChip(
                                key: ValueKey('import-mode-${mode.name}'),
                                label: Text(switch (mode) {
                                  _ImportInput.link => strings.link,
                                  _ImportInput.text => strings.importTextTab,
                                  _ImportInput.file => strings.importFileTab,
                                }),
                                selected: _mode == mode,
                                selectedColor: colors.background,
                                backgroundColor: colors.surface,
                                labelStyle: TextStyle(
                                  color: colors.textPrimary,
                                ),
                                side: BorderSide(color: colors.border),
                                onSelected: _busy
                                    ? null
                                    : (_) => setState(() {
                                        _mode = mode;
                                        _errorMessage = null;
                                      }),
                              ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (_mode == _ImportInput.file) ...[
                        Text(
                          strings.importFileHint,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          key: const ValueKey('import-choose-file'),
                          onPressed: _busy ? null : _chooseFile,
                          style: buttonStyle,
                          icon: const Icon(
                            MingCuteIcons.mgc_folder_open_line,
                            size: 20,
                          ),
                          label: Text(strings.importChooseFile),
                        ),
                      ] else ...[
                        Text(
                          _mode == _ImportInput.link
                              ? strings.link
                              : strings.trackList,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          key: const ValueKey('import-input'),
                          controller: _inputController,
                          enabled: !_busy,
                          minLines: _mode == _ImportInput.text ? 4 : 1,
                          maxLines: _mode == _ImportInput.text ? 6 : 2,
                          keyboardType: _mode == _ImportInput.link
                              ? TextInputType.url
                              : TextInputType.multiline,
                          autocorrect: false,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: 14,
                          ),
                          onChanged: (_) =>
                              setState(() => _errorMessage = null),
                          decoration: InputDecoration(
                            hintText: _mode == _ImportInput.link
                                ? strings.pastePlaylistOrTrackLink
                                : strings.artistTrackOrCsv,
                            fillColor: colors.background,
                            suffixIcon: IconButton(
                              tooltip: strings.pasteFromClipboard,
                              onPressed: _busy ? null : _pasteFromClipboard,
                              icon: const Icon(
                                MingCuteIcons.mgc_paste_line,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        if (_mode == _ImportInput.text) ...[
                          const SizedBox(height: 10),
                          Text(
                            strings.importTextHint,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                        if (!ImportFilePicker.isSupported) ...[
                          const SizedBox(height: 10),
                          Text(
                            strings.importFileAndroidOnly,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          key: const ValueKey('import-preview'),
                          onPressed: _busy ? null : _startImport,
                          style: buttonStyle,
                          child: Text(strings.importPreview),
                        ),
                      ],
                    ] else ...[
                      Text(
                        strings.tracksCount(result.tracks.length),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (_fileName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _fileName!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      for (var i = 0; i < result.tracks.length && i < 4; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 28,
                                child: Text(
                                  '${i + 1}',
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.tracks[i].title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (result.tracks[i].artist.isNotEmpty)
                                      Text(
                                        result.tracks[i].artist,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: colors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (result.tracks.length > 4)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            strings.importMoreTracks(result.tracks.length - 4),
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                      Text(
                        strings.playlistName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        key: const ValueKey('import-playlist-name'),
                        controller: _nameController,
                        enabled: !_busy,
                        maxLength: 120,
                        style: TextStyle(color: colors.textPrimary),
                        decoration: InputDecoration(
                          fillColor: colors.background,
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() => _errorMessage = null),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        strings.importMetadataHint,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        key: const ValueKey('import-save'),
                        onPressed: _busy ? null : _saveToPlaylists,
                        style: buttonStyle,
                        icon: const Icon(
                          MingCuteIcons.mgc_list_check_line,
                          size: 20,
                        ),
                        label: Text(strings.addToPlaylists),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _busy
                              ? null
                              : () => _playImported(result.tracks),
                          icon: const Icon(
                            MingCuteIcons.mgc_play_fill,
                            size: 20,
                          ),
                          label: Text(strings.listen),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.textPrimary,
                            minimumSize: const Size(0, 48),
                            side: BorderSide(color: colors.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: TextButton(
                          onPressed: _busy
                              ? null
                              : () => setState(() {
                                  _importedResult = null;
                                  _fileName = null;
                                  _nameController.clear();
                                  _errorMessage = null;
                                }),
                          child: Text(strings.importAnother),
                        ),
                      ),
                    ],
                    if (_busy) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colors.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _isSaving
                                    ? strings.importSaving
                                    : strings.importReading,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          _errorMessage!,
                          key: const ValueKey('import-error'),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
