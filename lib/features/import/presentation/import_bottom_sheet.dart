import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../extractor/models/media_track.dart';
import '../../library/presentation/library_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../music_import_service.dart';

class ImportBottomSheet extends ConsumerStatefulWidget {
  final HookTheme theme;

  const ImportBottomSheet({
    super.key,
    required this.theme,
  });

  static Future<void> show(BuildContext context, HookTheme theme) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ImportBottomSheet(theme: theme),
    );
  }

  @override
  ConsumerState<ImportBottomSheet> createState() => _ImportBottomSheetState();
}

class _ImportBottomSheetState extends ConsumerState<ImportBottomSheet> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  ImportedCollection? _importedResult;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
        _errorMessage = null;
      });
    }
  }

  Future<void> _startImport() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _errorMessage = 'Вставьте ссылку для импорта');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _importedResult = null;
    });

    try {
      final importService = ref.read(musicImportServiceProvider);
      final result = await importService.importFromUrl(url);

      if (!mounted) return;

      if (result.tracks.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Не удалось найти треки по указанной ссылке.';
        });
        return;
      }

      setState(() {
        _isLoading = false;
        _importedResult = result;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e is FormatException || e is ArgumentError
            ? e.toString().replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '')
            : 'Ошибка импорта: Проверьте ссылку и интернет-соединение.';
      });
    }
  }

  void _playImported(List<MediaTrack> tracks) {
    ref.read(queueProvider.notifier).playQueue(tracks, startIndex: 0);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Включен импортированный плейлист (${tracks.length} треков)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _saveToPlaylists(ImportedCollection collection) async {
    final playlistName = collection.title.isNotEmpty
        ? collection.title
        : 'Импорт (${collection.platform.name})';

    await ref
        .read(playlistsProvider.notifier)
        .savePlaylist(playlistName, collection.tracks);

    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Плейлист "$playlistName" сохранен в медиатеку!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.theme.colors;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentInput = _urlController.text;
    final detectedPlatform = MusicImportService.detectPlatform(currentInput);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.35),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textSecondary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    MingCuteIcons.mgc_link_2_line,
                    color: colors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Импорт музыки',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Spotify • Плейлисты, альбомы и треки',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_importedResult == null) ...[
              // Input field
              Container(
                decoration: BoxDecoration(
                  color: colors.surfaceGlass.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 14),
                    Icon(
                      detectedPlatform == ImportPlatform.spotify
                          ? MingCuteIcons.mgc_music_3_fill
                          : MingCuteIcons.mgc_link_line,
                      color: detectedPlatform == ImportPlatform.spotify
                          ? const Color(0xFF1DB954)
                          : colors.textSecondary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _urlController,
                        onChanged: (_) => setState(() => _errorMessage = null),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Вставьте ссылку на плейлист или трек',
                          hintStyle: TextStyle(
                            color: colors.textSecondary.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Вставить из буфера',
                      icon: Icon(
                        MingCuteIcons.mgc_paste_line,
                        color: colors.primary,
                        size: 20,
                      ),
                      onPressed: _pasteFromClipboard,
                    ),
                  ],
                ),
              ),

              // Supported badges
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 4),
                child: Row(
                  children: [
                    _buildPlatformBadge(
                      'Spotify',
                      const Color(0xFF1DB954),
                      detectedPlatform == ImportPlatform.spotify,
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(MingCuteIcons.mgc_alert_line,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              // Import action button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startImport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(MingCuteIcons.mgc_download_2_line, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Начать импорт',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ] else ...[
              // Success result card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceGlass.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    TrackArtwork(
                      url: _importedResult!.artworkUrl,
                      size: 64,
                      borderRadius: BorderRadius.circular(14),
                      placeholderColor: colors.background,
                      iconColor: colors.textSecondary,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _importedResult!.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${_importedResult!.author} • ${_importedResult!.tracks.length} треков',
                            style: TextStyle(
                              fontSize: 13,
                              color: colors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Импортировано из Spotify',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _importedResult!.platform ==
                                      ImportPlatform.spotify
                                  ? const Color(0xFF1DB954)
                                  : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(MingCuteIcons.mgc_play_fill, size: 20),
                      label: const Text('Слушать'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _playImported(_importedResult!.tracks),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon:
                          const Icon(MingCuteIcons.mgc_list_check_line, size: 20),
                      label: const Text('В плейлисты'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colors.textPrimary,
                        side: BorderSide(
                          color: colors.border.withValues(alpha: 0.6),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _saveToPlaylists(_importedResult!),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlatformBadge(String label, Color color, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.18)
            : widget.theme.colors.surfaceGlass.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? color.withValues(alpha: 0.6)
              : widget.theme.colors.border.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? widget.theme.colors.textPrimary : widget.theme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
