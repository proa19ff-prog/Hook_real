import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
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

/// Keeps the optional self-hosted resolver endpoint in storage and mirrored
/// into the static used by [RemoteResolverSource]. The resolver reads the
/// endpoint per call, so changes apply without rebuilding the provider tree.
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
