import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/diagnostics/playback_diagnostics.dart';
import '../../core/storage/local_storage_service.dart';
import '../audio_player/presentation/player_state_provider.dart';
import '../library/presentation/library_provider.dart';
import '../search/presentation/search_history_provider.dart';
import 'account_service.dart';
import 'sync_engine.dart';

/// Where the account UI stands.
enum AccountStage { signedOut, signedIn }

class AccountState {
  const AccountState({
    this.stage = AccountStage.signedOut,
    this.nickname,
    this.syncing = false,
    this.lastSyncAt,
    this.errorKind,
    this.configured = true,
  });

  final AccountStage stage;
  final String? nickname;

  /// A push or pull is in flight.
  final bool syncing;

  /// Last successful sync completion (either direction).
  final DateTime? lastSyncAt;

  /// Kind of the last failed auth/sync attempt, for the UI copy.
  final AccountErrorKind? errorKind;
  final bool configured;

  AccountState copyWith({
    AccountStage? stage,
    String? nickname,
    bool? syncing,
    DateTime? lastSyncAt,
    AccountErrorKind? errorKind,
    bool clearError = false,
    bool? configured,
  }) {
    return AccountState(
      stage: stage ?? this.stage,
      nickname: nickname ?? this.nickname,
      syncing: syncing ?? this.syncing,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      errorKind: clearError ? null : (errorKind ?? this.errorKind),
      configured: configured ?? this.configured,
    );
  }
}

/// Server-side snapshot access against the `sync_snapshots` table
/// (supabase/schema.sql). Row-level security scopes every read and write
/// to the signed-in user.
class SupabaseSyncTransport implements SyncTransport {
  const SupabaseSyncTransport();

  GoTrueClient get _auth => Supabase.instance.client.auth;
  SupabaseClient get _client => Supabase.instance.client;

  @override
  Future<Map<String, Object?>?> fetchSnapshot() async {
    final userId = _auth.currentUser?.id;
    if (userId == null) {
      throw const AccountException(
        AccountErrorKind.invalidCredentials,
        'Not signed in.',
      );
    }
    final row = await _client
        .from('sync_snapshots')
        .select('data')
        .eq('user_id', userId)
        .maybeSingle();
    if (row == null) return null;
    final data = row['data'];
    if (data is Map<String, Object?>) return data;
    if (data is Map) return Map<String, Object?>.from(data);
    return null;
  }

  @override
  Future<void> saveSnapshot(Map<String, Object?> data) async {
    final userId = _auth.currentUser?.id;
    if (userId == null) {
      throw const AccountException(
        AccountErrorKind.invalidCredentials,
        'Not signed in.',
      );
    }
    await _client.from('sync_snapshots').upsert({
      'user_id': userId,
      'data': data,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

/// Account lifecycle + the change-driven push loop.
class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier(this._ref) : super(const AccountState()) {
    _storage = _ref.read(localStorageServiceProvider);
    if (!AccountService.isConfigured) {
      state = const AccountState(configured: false);
      return;
    }
    if (AccountService.currentUserId != null) {
      state = AccountState(
        stage: AccountStage.signedIn,
        nickname: AccountService.currentNickname,
      );
      _startEngine(initialPull: true);
    }
    _changesSubscription = _storage.changes.listen(_onStorageChanged);
  }

  static const pushDebounce = Duration(seconds: 8);

  final Ref _ref;
  late final LocalStorageService _storage;
  SyncEngine? _engine;
  StreamSubscription<String>? _changesSubscription;
  Timer? _pushDebounce;
  Future<void>? _syncInFlight;

  void _startEngine({bool initialPull = false}) {
    final engine = SyncEngine(
      storage: _storage,
      transport: const SupabaseSyncTransport(),
    );
    _engine = engine;
    if (initialPull) {
      unawaited(_runSync(() => engine.pull()));
    }
  }

  Future<void> _runSync(Future<void> Function() action) async {
    if (_syncInFlight != null) return _syncInFlight;
    final task = action();
    _syncInFlight = task;
    state = state.copyWith(syncing: true, clearError: true);
    try {
      await task;
      _refreshListeners();
      _ref.invalidate(resumeStateProvider);
      state = state.copyWith(
        syncing: false,
        lastSyncAt: DateTime.now(),
      );
    } on AccountException catch (error) {
      state = state.copyWith(syncing: false, errorKind: error.kind);
      PlaybackDiagnostics.record('sync.error', source: 'sync', error: error.message);
    } catch (error) {
      state = state.copyWith(syncing: false);
      PlaybackDiagnostics.record('sync.error', source: 'sync', error: error.toString());
    } finally {
      if (identical(_syncInFlight, task)) _syncInFlight = null;
    }
  }

  Future<void> signIn(String nickname, String password) async {
    state = state.copyWith(clearError: true);
    try {
      await AccountService.signIn(nickname: nickname, password: password);
    } on AccountException catch (error) {
      state = state.copyWith(errorKind: error.kind);
      return;
    }
    state = AccountState(
      stage: AccountStage.signedIn,
      nickname: AccountService.currentNickname,
      configured: state.configured,
    );
    _startEngine(initialPull: true);
  }

  Future<void> signUp(String nickname, String password) async {
    state = state.copyWith(clearError: true);
    try {
      await AccountService.signUp(nickname: nickname, password: password);
    } on AccountException catch (error) {
      state = state.copyWith(errorKind: error.kind);
      return;
    }
    state = AccountState(
      stage: AccountStage.signedIn,
      nickname: AccountService.currentNickname,
      configured: state.configured,
    );
    _startEngine(initialPull: true);
  }

  Future<void> signOut() async {
    _pushDebounce?.cancel();
    _pushDebounce = null;
    try {
      await AccountService.signOut();
    } on AccountException {
      // Signing out must always succeed locally.
    }
    _engine = null;
    state = AccountState(configured: state.configured);
  }

  /// Manual "sync now": pull with merge, then a full push.
  Future<void> syncNow() async {
    final engine = _engine;
    if (engine == null) return;
    await _runSync(() async {
      await engine.pull();
      await engine.push();
    });
  }

  void _onStorageChanged(String key) {
    final engine = _engine;
    if (engine == null || engine.applyingRemote) return;
    engine.onChanged(key);
    _pushDebounce?.cancel();
    _pushDebounce = Timer(pushDebounce, () {
      unawaited(_runSync(() => engine.push()));
    });
  }

  /// Re-reads everything the UI shows from storage after a pull.
  void _refreshListeners() {
    _ref.read(favoritesProvider.notifier).refresh();
    _ref.read(historyProvider.notifier).refresh();
    _ref.read(playlistsProvider.notifier).refresh();
    _ref.read(searchHistoryProvider.notifier).refresh();
    _refreshTheme();
  }

  void _refreshTheme() {
    final storage = _storage;
    final custom = storage.getSavedCustomThemeJson();
    try {
      final themeNotifier = _ref.read(themeProvider.notifier);
      if (custom != null && custom.isNotEmpty) {
        themeNotifier.importJson(custom);
      } else {
        final themeId = storage.getSavedThemeId();
        if (themeId != null) themeNotifier.setTheme(themeId);
      }
    } catch (_) {
      // Theme application must never break sync.
    }
  }

  @override
  void dispose() {
    _changesSubscription?.cancel();
    _pushDebounce?.cancel();
    super.dispose();
  }
}

final accountProvider =
    StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier(ref);
});
