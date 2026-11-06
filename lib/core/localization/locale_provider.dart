import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/local_storage_service.dart';
import '../../features/library/presentation/library_provider.dart';

class LocaleNotifier extends StateNotifier<Locale?> {
  LocaleNotifier(this._storage) : super(_fromCode(_storage.getLocaleCode()));

  final LocalStorageService _storage;

  static Locale? _fromCode(String? code) {
    if (code == null || code.isEmpty || code == 'system') return null;
    return Locale(code);
  }

  Future<void> select(String code) async {
    state = _fromCode(code);
    await _storage.saveLocaleCode(code);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale?>((ref) {
  return LocaleNotifier(ref.watch(localStorageServiceProvider));
});
