import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'account_config.dart';

/// Why the auth attempt failed, in UI-actionable terms.
enum AccountErrorKind {
  nicknameTaken,
  invalidCredentials,
  weakPassword,
  needsEmailConfirmation,
  rateLimited,
  network,
  server,
  notConfigured,
}

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

  /// Cached answer to "can a signup produce a session by itself?".
  /// `null` = not asked yet / unreachable.
  static bool? _autoconfirm;

  /// Test seam: pretend the project's e-mail setting is known.
  static set autoconfirmForTesting(bool? value) => _autoconfirm = value;

  /// Whether the Supabase project auto-confirms sign-ups.
  ///
  /// Hook signs users up with a synthetic `<nickname>@hook.local` address and
  /// never sends mail, so it needs the project's "Confirm email" switch OFF.
  /// With it ON every signup tries to send a message to an address that
  /// cannot receive one, which burns the mailer quota and returns a bare
  /// `429 over_email_send_rate_limit` — the "registration just doesn't work"
  /// symptom. `/auth/v1/settings` is public, so we can ask before trying.
  static Future<bool?> emailAutoconfirmEnabled() async {
    if (!_configured) return null;
    if (_autoconfirm != null) return _autoconfirm;
    try {
      final response = await http
          .get(
            Uri.parse('${AccountConfig.supabaseUrl}/auth/v1/settings'),
            headers: {'apikey': AccountConfig.supabaseAnonKey},
          )
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body);
      if (body is! Map) return null;
      final value = body['mailer_autoconfirm'];
      if (value is bool) _autoconfirm = value;
      return _autoconfirm;
    } catch (_) {
      // Offline or blocked: let the signup attempt speak for itself.
      return null;
    }
  }

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
      // Ask first: with confirmation ON and no SMTP, Supabase tries to mail a
      // synthetic address that cannot exist. The user then sees an opaque
      // "email rate limit exceeded" instead of the actual misconfiguration.
      if (await emailAutoconfirmEnabled() == false) {
        throw const AccountException(
          AccountErrorKind.needsEmailConfirmation,
          'The Supabase project has "Confirm email" switched on. Hook signs '
          'up with a synthetic <nickname>@hook.local address and never sends '
          'mail, so sign-up can only work with confirmation OFF '
          '(Dashboard -> Authentication -> Sign In / Providers -> Email).',
        );
      }
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
      final network =
          message.contains('socketexception') ||
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
    if (code == 'user_already_exists' ||
        message.contains('already registered')) {
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
    // With "Confirm email" ON, every signup burns one mail attempt against a
    // synthetic address that cannot receive it. The API answers a bare
    // `429 email rate limit exceeded`, which reads like a server fault but is
    // really the project setting. Name it as the configuration problem.
    if (code == 'over_email_send_rate_limit' ||
        message.contains('email rate limit') ||
        message.contains('email rate limit exceeded')) {
      return AccountException(
        AccountErrorKind.needsEmailConfirmation,
        error.message,
      );
    }
    if (code == 'email_address_invalid' ||
        (message.contains('is invalid') && message.contains('email'))) {
      return AccountException(
        AccountErrorKind.needsEmailConfirmation,
        error.message,
      );
    }
    if (message.contains('confirm')) {
      return AccountException(
        AccountErrorKind.needsEmailConfirmation,
        error.message,
      );
    }
    if (code == 'over_request_rate_limit' || message.contains('rate limit')) {
      return AccountException(AccountErrorKind.rateLimited, error.message);
    }
    return AccountException(AccountErrorKind.server, error.message);
  }
}
