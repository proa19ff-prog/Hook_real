import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../import/music_import_service.dart';
import '../../import/presentation/import_bottom_sheet.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/track_artwork.dart';
import '../data/youtube_account_service.dart';

class YouTubeAccountScreen extends ConsumerStatefulWidget {
  const YouTubeAccountScreen({super.key, required this.theme});
  final HookTheme theme;
  @override
  ConsumerState<YouTubeAccountScreen> createState() =>
      _YouTubeAccountScreenState();
}

class _YouTubeAccountScreenState extends ConsumerState<YouTubeAccountScreen> {
  late YouTubeAccountService _service;
  YouTubeAccountStatus? _status;
  YouTubeProfile? _profile;
  List<YouTubePlaylist> _playlists = [];
  String? _nextPage;
  final Set<String> _pageTokens = {};
  String? _errorCode;
  bool _busy = true;
  int _generation = 0;
  int? _progress;

  @override
  void initState() {
    super.initState();
    _service = ref.read(youtubeAccountServiceProvider);
    unawaited(_reload());
  }

  @override
  void dispose() {
    _generation++;
    if (_busy) unawaited(_service.cancel());
    super.dispose();
  }

  Future<void> _operation(Future<void> Function(bool Function()) action) async {
    final generation = ++_generation;
    bool active() => mounted && _generation == generation;
    setState(() {
      _busy = true;
      _errorCode = null;
    });
    try {
      await action(active);
    } on PlatformException catch (error) {
      if (active() && error.code != 'cancelled') {
        setState(() {
          _errorCode = error.code;
          if ([
            'expired',
            'permissionDenied',
            'noChannel',
          ].contains(error.code)) {
            _profile = null;
            _playlists = [];
            _nextPage = null;
          }
        });
      }
    } on MissingPluginException {
      if (active()) setState(() => _errorCode = 'unsupported');
    } catch (_) {
      if (active()) setState(() => _errorCode = 'unavailable');
    } finally {
      if (active()) {
        setState(() {
          _busy = false;
          _progress = null;
        });
      }
    }
  }

  Future<void> _reload() => _operation((active) async {
    final status = await _service.status();
    final profile = await _service.profile();
    if (!active()) return;
    setState(() {
      _status = status;
      _profile = profile;
      _playlists = [];
      _nextPage = null;
      _pageTokens.clear();
    });
    if (profile != null) await _fetchPlaylists(active);
  });

  Future<void> _fetchPlaylists(
    bool Function() active, {
    bool more = false,
  }) async {
    final token = more ? _nextPage : null;
    final page = await _service.playlists(pageToken: token);
    if (!active()) return;
    if (page.nextPageToken != null && !_pageTokens.add(page.nextPageToken!)) {
      throw PlatformException(code: 'unavailable');
    }
    setState(() {
      final seen = <String>{};
      _playlists = [
        ...(more ? _playlists : <YouTubePlaylist>[]),
        ...page.items,
      ].where((list) => seen.add(list.id)).toList();
      _nextPage = page.nextPageToken;
    });
  }

  Future<void> _connect() => _operation((active) async {
    final profile = await _service.connect();
    if (!active()) return;
    setState(() {
      _profile = profile;
      _playlists = [];
      _nextPage = null;
      _pageTokens.clear();
    });
    await _fetchPlaylists(active);
  });

  Future<void> _disconnect() async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.youtubeAccountDisconnect),
        content: Text(strings.youtubeAccountDisconnectNotice),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.youtubeAccountDisconnect),
          ),
        ],
      ),
    );
    if (!mounted || confirmed != true) return;
    await _operation((active) async {
      await _service.disconnect();
      if (active()) {
        setState(() {
          _profile = null;
          _playlists = [];
          _nextPage = null;
          _pageTokens.clear();
        });
      }
    });
  }

  Future<void> _cancel() async {
    _generation++;
    setState(() {
      _busy = true;
      _progress = null;
    });
    await _service.cancel();
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _prepareImport(YouTubePlaylist playlist) async {
    final strings = AppLocalizations.of(context);
    final author = _profile?.name ?? 'YouTube';
    YouTubeImportResult? prepared;
    await _operation((active) async {
      setState(() => _progress = 0);
      final result = await _service.importPlaylist(
        playlist,
        isActive: active,
        onProgress: (count) {
          if (active()) setState(() => _progress = count);
        },
      );
      if (!active()) return;
      if (result.tracks.isEmpty) throw PlatformException(code: 'empty');
      prepared = result;
    });
    final result = prepared;
    if (!mounted || result == null) return;
    // Network work is finished before opening confirmation or the save preview.
    final generation = _generation;
    if (result.unavailableCount > 0) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.youtubeAccountPreview),
          content: Text(
            strings.youtubeAccountUnavailableTracks(result.unavailableCount),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.importMusic),
            ),
          ],
        ),
      );
      if (!mounted || _generation != generation || proceed != true) return;
    }
    await ImportBottomSheet.show(
      context,
      widget.theme,
      initialCollection: ImportedCollection(
        title: playlist.title,
        author: author,
        artworkUrl: playlist.artworkUrl,
        tracks: result.tracks,
        platform: ImportPlatform.youtube,
      ),
    );
  }

  String _errorMessage(AppLocalizations s) => switch (_errorCode) {
    'configurationRequired' => s.youtubeAccountConfigError,
    'servicesUnavailable' => s.youtubeAccountServicesMissing,
    'unsupported' => s.youtubeAccountUnsupported,
    'permissionDenied' => s.youtubeAccountPermissionError,
    'expired' => s.youtubeAccountExpired,
    'noChannel' => s.youtubeAccountNoChannel,
    'quotaExceeded' => s.youtubeAccountQuota,
    'tooLarge' => s.importTooManyTracks,
    'empty' => s.playlistEmpty,
    _ => s.youtubeAccountFailed,
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = widget.theme.colors;
    final profile = _profile;
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(strings.youtubeAccount),
        actions: [
          IconButton(
            tooltip: strings.checkAgain,
            onPressed: _busy ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  strings.youtubeAccountSubtitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.youtubeAccountReadOnly,
                  style: TextStyle(color: colors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 16),
                if (_status?.systemServicesAvailable == false)
                  Text(
                    strings.youtubeAccountServicesMissing,
                    style: TextStyle(color: colors.textSecondary),
                  ),

                if (profile != null)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: TrackArtwork(
                      url: profile.artworkUrl,
                      size: 48,
                      placeholderColor: colors.surface,
                      iconColor: colors.textSecondary,
                    ),
                    title: Text(profile.name),
                    subtitle: Text(
                      'YouTube',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ),
                if (profile == null)
                  Text(
                    strings.youtubeAccountDisconnected,
                    style: TextStyle(color: colors.textPrimary),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (profile == null)
                      FilledButton.icon(
                        key: const ValueKey('youtube-connect'),
                        onPressed: _busy || _status?.supported != true
                            ? null
                            : _connect,
                        icon: const Icon(Icons.account_circle_outlined),
                        label: Text(strings.youtubeAccountConnect),
                      ),
                    if (profile != null)
                      OutlinedButton(
                        onPressed: _busy ? null : _disconnect,
                        child: Text(strings.youtubeAccountDisconnect),
                      ),
                    TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(strings.youtubeAccountSetup),
                          scrollable: true,
                          content: Text(strings.youtubeAccountSetupBody),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(strings.close),
                            ),
                          ],
                        ),
                      ),
                      child: Text(strings.youtubeAccountSetup),
                    ),
                  ],
                ),
                if (_busy)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accent,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _progress == null
                                ? strings.loading
                                : strings.youtubeAccountProgress(_progress!),
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ),
                        TextButton(
                          onPressed: _cancel,
                          child: Text(strings.cancel),
                        ),
                      ],
                    ),
                  ),
                if (_errorCode != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Semantics(
                      liveRegion: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _errorMessage(strings),
                            style: TextStyle(
                              color: colors.textSecondary,
                              height: 1.5,
                            ),
                          ),
                          TextButton(
                            onPressed: _busy ? null : _reload,
                            child: Text(strings.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                ExpansionTile(
                  key: const ValueKey('youtube-compatibility'),
                  tilePadding: EdgeInsets.zero,
                  title: Text(strings.youtubeAccountCompatibility),
                  children: [
                    Text(
                      strings.youtubeAccountPrivacy,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.youtubeAccountPlaybackNotice,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_status case final YouTubeAccountStatus status) ...[
                      Text(
                        '${strings.youtubeAccountSystem}: ${status.systemServicesVersion ?? '—'}',
                        style: TextStyle(color: colors.textPrimary),
                      ),
                      if (status.revancedGmsCoreVersion != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          'ReVanced GmsCore ${status.revancedGmsCoreVersion}',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                        Text(
                          strings.youtubeAccountMicrogNotice,
                          style: TextStyle(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                      if (status.revancedMusicInstalled)
                        Text(
                          strings.youtubeAccountRevancedFound,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
                if (profile != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    strings.youtubeAccountPlaylists,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_playlists.isEmpty && !_busy && _errorCode == null)
                    Text(
                      strings.youtubeAccountNoPlaylists,
                      style: TextStyle(
                        color: colors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  for (final playlist in _playlists)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: TrackArtwork(
                              url: playlist.artworkUrl,
                              size: 48,
                              placeholderColor: colors.surface,
                              iconColor: colors.textSecondary,
                            ),
                            title: Text(playlist.title),
                            subtitle: Text(
                              strings.tracksCount(playlist.itemCount),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              key: ValueKey('youtube-import-${playlist.id}'),
                              onPressed: _busy
                                  ? null
                                  : () => _prepareImport(playlist),
                              icon: const Icon(Icons.playlist_add_rounded),
                              label: Text(strings.youtubeAccountPreview),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_nextPage != null)
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () => _operation(
                              (active) => _fetchPlaylists(active, more: true),
                            ),
                      child: Text(strings.youtubeAccountMore),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
