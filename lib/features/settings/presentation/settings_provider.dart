import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../core/ui/hook_haptics.dart';
import '../../audio_player/data/audio_player_service.dart';
import '../../extractor/sources/remote_resolver_source.dart';
import '../../library/presentation/library_provider.dart';

class LyricsAutoHideNotifier extends StateNotifier<bool> {
  LyricsAutoHideNotifier(this._storage) : super(_storage.getLyricsAutoHide());

  final LocalStorageService _storage;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _storage.saveLyricsAutoHide(enabled);
  }
}

final lyricsAutoHideProvider =
    StateNotifierProvider<LyricsAutoHideNotifier, bool>(
      (ref) => LyricsAutoHideNotifier(ref.watch(localStorageServiceProvider)),
    );

/// Keeps the optional resolver endpoint in storage and mirrored into the
/// static used by [RemoteResolverSource]. The resolver reads the endpoint per
/// call, so changes apply without rebuilding the provider tree. Stored value
/// semantics: null = never configured (built-in default stays active),
/// '' = disabled by the user in settings, otherwise the custom endpoint.
class RemoteResolverNotifier extends StateNotifier<String?> {
  RemoteResolverNotifier(this._storage)
    : super(_storage.getRemoteResolverUrl()) {
    RemoteResolverSource.endpoint = state;
  }

  final LocalStorageService _storage;

  Future<void> setEndpoint(String? value) async {
    state = value;
    RemoteResolverSource.endpoint = value;
    await _storage.saveRemoteResolverUrl(value);
  }
}

final remoteResolverProvider =
    StateNotifierProvider<RemoteResolverNotifier, String?>(
      (ref) => RemoteResolverNotifier(ref.watch(localStorageServiceProvider)),
    );

/// Shared shape for the three playback switches below: the value lives in
/// storage, and each listener also mirrors it into the static the playback
/// path reads (which runs far from the widget tree).
class _ToggleNotifier extends StateNotifier<bool> {
  _ToggleNotifier(this._storage, this._initial, this._persist, this._mirror)
    : super(_initial) {
    _mirror(_initial);
  }

  final LocalStorageService _storage;
  final bool _initial;
  final Future<void> Function(LocalStorageService storage, bool value)
  _persist;
  final void Function(bool value) _mirror;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    _mirror(enabled);
    await _persist(_storage, enabled);
  }
}

final hapticsEnabledProvider =
    StateNotifierProvider<_ToggleNotifier, bool>((ref) {
      final storage = ref.watch(localStorageServiceProvider);
      return _ToggleNotifier(
        storage,
        storage.getHapticsEnabled(),
        (s, v) => s.saveHapticsEnabled(v),
        (v) => HookHaptics.enabled = v,
      );
    });

final reduceMotionProvider =
    StateNotifierProvider<_ToggleNotifier, bool>((ref) {
      final storage = ref.watch(localStorageServiceProvider);
      return _ToggleNotifier(
        storage,
        storage.getReduceMotion(),
        (s, v) => s.saveReduceMotion(v),
        (_) {},
      );
    });

final backgroundPrefetchProvider =
    StateNotifierProvider<_ToggleNotifier, bool>((ref) {
      final storage = ref.watch(localStorageServiceProvider);
      return _ToggleNotifier(
        storage,
        storage.getBackgroundPrefetch(),
        (s, v) => s.saveBackgroundPrefetch(v),
        (v) => AudioPlayerService.prefetchEnabled = v,
      );
    });

/// Live cookie-jar state from the resolver. Kept lazy and manual-refresh only:
/// the check makes a real YouTube request, so it must never run on its own
/// during a screen build.
final cookieHealthProvider = FutureProvider.autoDispose<CookieJarHealth?>((
  ref,
) {
  return RemoteResolverSource().cookieHealth();
});
