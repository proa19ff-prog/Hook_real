import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../library/presentation/library_provider.dart';
import '../domain/lyrics_display_mode.dart';

class LyricsDisplayModeNotifier extends StateNotifier<LyricsDisplayMode> {
  final LocalStorageService _storage;
  LyricsDisplayModeNotifier(this._storage)
      : super(LyricsDisplayMode.fromName(_storage.getLyricsDisplayMode()));

  Future<void> select(LyricsDisplayMode mode) async {
    state = mode;
    await _storage.saveLyricsDisplayMode(mode.name);
  }
}

final lyricsDisplayModeProvider =
    StateNotifierProvider<LyricsDisplayModeNotifier, LyricsDisplayMode>((ref) {
  return LyricsDisplayModeNotifier(ref.watch(localStorageServiceProvider));
});
