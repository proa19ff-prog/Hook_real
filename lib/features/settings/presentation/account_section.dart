import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../account/account_service.dart';
import '../../account/sync_provider.dart';

/// The account section in settings: sign in / create account when signed
/// out; nickname, sync status and controls when signed in.
class AccountSection extends ConsumerStatefulWidget {
  const AccountSection({super.key});

  @override
  ConsumerState<AccountSection> createState() => _AccountSectionState();
}

class _AccountSectionState extends ConsumerState<AccountSection> {
  bool _isSignUp = false;
  bool _obscure = true;
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);
    final state = ref.watch(accountProvider);
    final theme = Theme.of(context).textTheme;

    if (!state.configured) return const SizedBox.shrink();

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  state.stage == AccountStage.signedIn
                      ? Icons.cloud_sync_outlined
                      : Icons.person_outline,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strings.accountTitle,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              strings.accountCaption,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            if (state.stage == AccountStage.signedOut)
              _buildAuthForm(context, state, strings, colors, theme)
            else
              _buildSignedIn(context, state, strings, colors, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthForm(
    BuildContext context,
    AccountState state,
    AppLocalizations strings,
    ColorScheme colors,
    TextTheme theme,
  ) {
    final errorText = _errorText(state.errorKind, strings);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _nicknameController,
          autofillHints: const [AutofillHints.username],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            labelText: strings.nickname,
            helperText: strings.nicknameHint,
            helperMaxLines: 2,
            isDense: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: _obscure,
          autofillHints: const [AutofillHints.password],
          onSubmitted: (_) => _submit(strings),
          decoration: InputDecoration(
            labelText: strings.password,
            helperText: strings.passwordMinHint,
            isDense: true,
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            errorText,
            style: TextStyle(color: colors.error, fontSize: 12.5),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: FilledButton(
                key: const ValueKey('account-auth-button'),
                onPressed: _busy ? null : () => _submit(strings),
                child: _busy
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isSignUp ? strings.signUp : strings.signIn),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed:
                _busy ? null : () => setState(() => _isSignUp = !_isSignUp),
            child: Text(
              _isSignUp ? strings.haveAccountToggle : strings.noAccountToggle,
              style: TextStyle(fontSize: 12.5, color: colors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignedIn(
    BuildContext context,
    AccountState state,
    AppLocalizations strings,
    ColorScheme colors,
    TextTheme theme,
  ) {
    final status = state.syncing
        ? strings.syncing
        : state.lastSyncAt == null
            ? strings.neverSynced
            : strings.syncedAt(_formatTime(state.lastSyncAt!));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.nickname ?? '',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            if (state.syncing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const ValueKey('account-sync-button'),
                onPressed: state.syncing ? null : () {
                  ref.read(accountProvider.notifier).syncNow();
                },
                icon: const Icon(Icons.sync, size: 18),
                label: Text(strings.syncNow),
              ),
            ),
            const SizedBox(width: 10),
            TextButton(
              key: const ValueKey('account-signout-button'),
              onPressed:
                  state.syncing ? null : () {
                    ref.read(accountProvider.notifier).signOut();
                  },
              child: Text(strings.signOut),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _submit(AppLocalizations strings) async {
    final nickname = _nicknameController.text.trim();
    final password = _passwordController.text;
    final notifier = ref.read(accountProvider.notifier);

    setState(() => _busy = true);
    try {
      if (_isSignUp) {
        final problem = AccountService.validateNickname(nickname);
        if (problem != null) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(strings.errorNicknameInvalid)),
          );
          return;
        }
        await notifier.signUp(nickname, password);
      } else {
        await notifier.signIn(nickname, password);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _errorText(AccountErrorKind? kind, AppLocalizations strings) {
    switch (kind) {
      case AccountErrorKind.nicknameTaken:
        return strings.errorNicknameTaken;
      case AccountErrorKind.invalidCredentials:
        return strings.errorInvalidCredentials;
      case AccountErrorKind.weakPassword:
        return strings.errorWeakPassword;
      case AccountErrorKind.network:
        return strings.errorNetwork;
      case AccountErrorKind.server:
      case AccountErrorKind.needsEmailConfirmation:
        return strings.errorServer;
      case AccountErrorKind.notConfigured:
      case null:
        return null;
    }
  }

  String _formatTime(DateTime time) {
    final local = time.toLocal();
    String two(int value) => value.toString().padLeft(2, '0');
    return '${two(local.day)}.${two(local.month)} '
        '${two(local.hour)}:${two(local.minute)}';
  }
}
