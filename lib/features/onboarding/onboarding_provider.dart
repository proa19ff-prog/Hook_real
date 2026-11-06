import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/local_storage_service.dart';
import '../../features/library/presentation/library_provider.dart';

/// Whether the first-launch onboarding (language + MicroG) is finished.
/// The flag lives in storage, so it survives restarts and reinstalls-over.
class OnboardingNotifier extends StateNotifier<bool> {
  OnboardingNotifier(this._storage) : super(_storage.getOnboardingDone());

  final LocalStorageService _storage;

  Future<void> complete() async {
    state = true;
    await _storage.saveOnboardingDone();
  }
}

final onboardingProvider = StateNotifierProvider<OnboardingNotifier, bool>((
  ref,
) {
  return OnboardingNotifier(ref.watch(localStorageServiceProvider));
});
