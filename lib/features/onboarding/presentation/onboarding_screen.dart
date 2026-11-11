import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/ui/hook_tokens.dart';

import '../../../core/localization/locale_provider.dart';
import '../../../core/localization/supported_languages.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../audio_player/presentation/player_state_provider.dart';
import '../../theme_engine/domain/hook_theme.dart';
import '../../theme_engine/presentation/dynamic_shader_background.dart';
import '../../youtube_account/data/youtube_account_service.dart';
import '../onboarding_provider.dart';
import '../../../core/ui/hook_icons.dart';

const _microgReleasesUrl = 'https://github.com/microg/GmsCore/releases';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectLanguage(String code) {
    ref.read(localeProvider.notifier).select(code);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    await ref.read(onboardingProvider.notifier).complete();
  }

  Future<void> _openMicrog() async {
    final url = Uri.parse(_microgReleasesUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    return Theme(
      data: theme.toThemeData(),
      child: Scaffold(
        backgroundColor: theme.colors.background,
        body: DynamicShaderBackground(
          theme: theme,
          child: SafeArea(
            child: Stack(
              children: [
                PageView(
                  controller: _pageController,
                  children: [
                    _LanguagePage(
                      theme: theme,
                      selectedCode: ref.watch(localeProvider)?.languageCode,
                      onSelect: _selectLanguage,
                      onSkip: _finish,
                    ),
                    // MicroG setup is an Android story; desktop builds skip
                    // straight to the end of onboarding.
                    if (defaultTargetPlatform == TargetPlatform.android)
                      _MicrogPage(
                        theme: theme,
                        onFinish: _finish,
                        onDownload: _openMicrog,
                      ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: _SkipButton(theme: theme, onSkip: _finish),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipButton extends StatelessWidget {
  const _SkipButton({required this.theme, required this.onSkip});

  final HookTheme theme;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return TextButton(
      key: const ValueKey('onboarding-skip'),
      onPressed: onSkip,
      style: TextButton.styleFrom(foregroundColor: theme.colors.textSecondary),
      child: Text(strings.onboardingSkip),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage({
    required this.theme,
    required this.selectedCode,
    required this.onSelect,
    required this.onSkip,
  });

  final HookTheme theme;
  final String? selectedCode;
  final ValueChanged<String> onSelect;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      children: [
        Image.asset('assets/icons/app_mark.png', height: 76),
        const SizedBox(height: 20),
        Text(
          strings.onboardingWelcomeTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          strings.onboardingWelcomeCaption,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: HookType.body,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          key: const ValueKey('onboarding-language-grid'),
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (final (code, name) in supportedLanguages)
              _LanguageChip(
                theme: theme,
                code: code,
                name: name,
                selected: selectedCode == code,
                onSelect: () => onSelect(code),
              ),
          ],
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  const _LanguageChip({
    required this.theme,
    required this.code,
    required this.name,
    required this.selected,
    required this.onSelect,
  });

  final HookTheme theme;
  final String code;
  final String name;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = theme.colors;
    return ChoiceChip(
      key: ValueKey('onboarding-language-$code'),
      label: Text(name),
      selected: selected,
      showCheckmark: false,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      onSelected: (_) => onSelect(),
      selectedColor: colors.accent,
      backgroundColor: colors.surface,
      side: BorderSide(
        color: selected ? colors.accent : colors.accent.withValues(alpha: 0.3),
      ),
      labelStyle: TextStyle(
        color: selected ? colors.onAccent : colors.textPrimary,
        fontSize: HookType.body,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

class _MicrogPage extends ConsumerWidget {
  const _MicrogPage({
    required this.theme,
    required this.onFinish,
    required this.onDownload,
  });

  final HookTheme theme;
  final VoidCallback onFinish;
  final Future<void> Function() onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context);
    final colors = theme.colors;
    final status = ref.watch(_microgStatusProvider);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 72, 24, 32),
      children: [
        Container(
          width: 76,
          height: 76,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.accent.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(HookIcons.shield, color: colors.accent, size: 38),
        ),
        const SizedBox(height: 20),
        Text(
          strings.onboardingMicrogTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.onboardingMicrogBody,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: HookType.body,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        Material(
          color: colors.surface,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
            ),
            child: status.when(
              loading: () => Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      strings.onboardingMicrogStatusChecking,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: HookType.bodySmall,
                      ),
                    ),
                  ),
                ],
              ),
              error: (_, _) => _statusText(
                colors.textSecondary,
                strings.onboardingMicrogStatusMissing,
              ),
              data: (value) => value.systemServicesAvailable
                  ? _statusText(
                      colors.textPrimary,
                      strings.onboardingMicrogStatusOk(
                        value.systemServicesVersion ?? '?',
                      ),
                    )
                  : value.revancedGmsCoreVersion != null
                  ? _statusText(
                      colors.textPrimary,
                      strings.onboardingMicrogStatusReVanced(
                        value.revancedGmsCoreVersion!,
                      ),
                    )
                  : _statusText(
                      colors.textSecondary,
                      strings.onboardingMicrogStatusMissing,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          strings.onboardingMicrogNote,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: HookType.label,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton(
          key: const ValueKey('onboarding-microg-download'),
          onPressed: () => onDownload(),
          style: FilledButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.onAccent,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            strings.onboardingMicrogDownload,
            style: const TextStyle(fontSize: HookType.body, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          key: const ValueKey('onboarding-finish'),
          onPressed: onFinish,
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.textPrimary,
            side: BorderSide(color: colors.accent.withValues(alpha: 0.5)),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            strings.onboardingStart,
            style: const TextStyle(fontSize: HookType.body, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _statusText(Color color, String text) => Text(
    text,
    style: TextStyle(color: color, fontSize: HookType.bodySmall, height: 1.4),
  );
}

/// Device capability check for the onboarding card; read-only and cached.
final _microgStatusProvider = FutureProvider<YouTubeAccountStatus>((ref) {
  return ref.watch(youtubeAccountServiceProvider).status();
});
