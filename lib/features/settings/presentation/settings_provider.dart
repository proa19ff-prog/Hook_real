import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
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
