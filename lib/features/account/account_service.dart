import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_config.dart';

/// Why the auth attempt failed, in UI-actionable terms.
enum AccountErrorKind { nicknameTaken, invalidCredentials, weakPassword, needsEmailConfirmation, network, server, notConfigured }

class AccountException implements Exception {
  const AccountException(this.kind, this.message);

  final AccountErrorKind kind;
  final String message;

  @override
  String toString() => 'AccountException($kind, $message)';
}

/// Hook accounts are nickname + password, no email. Supabase auth is
/// email-based, so a nickname maps onto a synthetic, never-mailed address:
/// `{nickname}@hook.local`. Uniqueness of the address is uniqueness of the
/// nickname; with email autoconfirm enabled the provider never sends mail.
abstract final class AccountService {
  static const _emailDomain = 'hook.local';

  /// Supabase's default minimum password length.
  static const int minPasswordLength = 6;

  static String syntheticEmail(String nickname) =>
      '${nickname.toLowerCase()}@$_emailDomain';

  /// 3–20 chars: latin letters, digits, dot, underscore, dash. No leading
  /// or trailing dot. Returns null when the nickname is fine.
  static String? validateNickname(String nickname) {
    final nick = nickname.trim();
    if (nick.length < 3 || nick.length > 20) return 'length';
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(nick)) return 'characters';
    if (nick.startsWith('.') || nick.endsWith('.')) return 'characters';
    return null;
  }

  static bool _configured = AccountConfig.isConfigured;

  /// Test seam: false simulates a build without Supabase credentials.
  static set configuredForTesting(bool value) => _configured = value;

  static bool get isConfigured => _configured;

  /// Current signed-in user id, or null.
  static String? get currentUserId =>
      _configured ? Supabase.instance.client.auth.currentUser?.id : null;

  /// Nickname of the signed-in user (from the synthetic email), or null.
  static String? get currentNickname {
    if (!_configured) return null;
    final email = Supabase.instance.client.auth.currentUser?.email;
    if (email == null || !email.endsWith('@$_emailDomain')) return null;
    return email.substring(0, email.length - _emailDomain.length - 1);
  }

  static Future<void> ensureInitialized() async {
    if (!AccountConfig.isConfigured) return;
    await Supabase.initialize(
      url: AccountConfig.supabaseUrl,
      publishableKey: AccountConfig.supabaseAnonKey,
    );
  }

  static Future<void> signUp({
    required String nickname,
    required String password,
  }) async {
    await _guard(() async {
      final response = await Supabase.instance.client.auth.signUp(
        email: syntheticEmail(nickname),
        password: password,
      );
      // With confirmation enabled and no SMTP there is no session — the
      // account exists but nobody could ever verify it. Surface that as a
      // configuration error instead of a silent dead account.
      if (response.session == null) {
        throw const AccountException(
          AccountErrorKind.needsEmailConfirmation,
          'Sign-up requires email confirmation; autoconfirm is disabled.',
        );
      }
    });
  }

  static Future<void> signIn({
    required String nickname,
    required String password,
  }) async {
    await _guard(() async {
      await Supabase.instance.client.auth.signInWithPassword(
        email: syntheticEmail(nickname),
        password: password,
      );
    });
  }

  static Future<void> signOut() async {
    if (!isConfigured) return;
    await Supabase.instance.client.auth.signOut();
  }

  static Future<void> _guard(Future<void> Function() action) async {
    if (!isConfigured) {
      throw const AccountException(
        AccountErrorKind.notConfigured,
        'Supabase credentials are missing.',
      );
    }
    try {
      await action();
    } on AuthException catch (error) {
      throw _mapAuthException(error);
    } on AccountException {
      rethrow;
    } catch (error) {
      final message = error.toString().toLowerCase();
      final network = message.contains('socketexception') ||
          message.contains('clientexception') ||
          message.contains('failed host lookup') ||
          message.contains('connection');
      throw AccountException(
        network ? AccountErrorKind.network : AccountErrorKind.server,
        error.toString(),
      );
    }
  }

  static AccountException _mapAuthException(AuthException error) {
    final code = error.code;
    final message = error.message.toLowerCase();
    if (code == 'user_already_exists' || message.contains('already registered')) {
      return AccountException(AccountErrorKind.nicknameTaken, error.message);
    }
    if (code == 'invalid_credentials' ||
        message.contains('invalid login credentials')) {
      return AccountException(
        AccountErrorKind.invalidCredentials,
        error.message,
      );
    }
    if (code == 'weak_password' || message.contains('password should be')) {
      return AccountException(AccountErrorKind.weakPassword, error.message);
    }
    if (message.contains('confirm')) {
      return AccountException(
        AccountErrorKind.needsEmailConfirmation,
        error.message,
      );
    }
    if (code == 'over_request_rate_limit' ||
        message.contains('rate limit')) {
      return AccountException(AccountErrorKind.server, error.message);
    }
    return AccountException(AccountErrorKind.server, error.message);
  }
}
