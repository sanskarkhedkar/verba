import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/verba_button.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _soundEffects = true;
  double _speechSpeed = 1.0;

  // ── Display name ────────────────────────────────────────────────────────────
  void _editDisplayName() {
    final current = ref.read(onboardingProvider).displayName;
    final ctrl = TextEditingController(text: current);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Display name', style: AppTypography.heading3),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                ref.read(onboardingProvider.notifier).setDisplayName(name);
                final uid =
                    ref.read(authServiceProvider).currentUser?.uid;
                if (uid != null) {
                  ref
                      .read(firestoreServiceProvider)
                      .updateProfile(uid, {'displayName': name})
                      .catchError((_) {});
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Language picker ─────────────────────────────────────────────────────────
  void _editLanguage() {
    final current = ref.read(onboardingProvider).targetLanguage;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.only(
            top: AppSpacing.md, bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text('Learning language', style: AppTypography.heading3),
          ),
          ...AppConstants.supportedLanguages.map((lang) {
            final emoji =
                AppConstants.languageEmojis[lang] ?? '🌐';
            final isSelected = lang == current;
            return ListTile(
              leading:
                  Text(emoji, style: const TextStyle(fontSize: 24)),
              title: Text(lang, style: AppTypography.bodyM),
              selected: isSelected,
              selectedTileColor:
                  AppColors.glassBorder.withValues(alpha: 0.3),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.textAccent)
                  : null,
              onTap: () {
                ref
                    .read(onboardingProvider.notifier)
                    .setTargetLanguage(lang);
                final uid =
                    ref.read(authServiceProvider).currentUser?.uid;
                if (uid != null) {
                  ref
                      .read(firestoreServiceProvider)
                      .updateProfile(
                          uid, {'targetLanguage': lang})
                      .catchError((_) {});
                }
                Navigator.pop(ctx);
              },
            );
          }),
        ],
      ),
    );
  }

  // ── Reminder time ───────────────────────────────────────────────────────────
  Future<void> _editReminderTime() async {
    final current = ref.read(onboardingProvider).notificationTime;
    final parts = current.split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 19,
      minute: int.tryParse(parts[1]) ?? 0,
    );
    final time = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (time != null && mounted) {
      final formatted =
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      ref
          .read(onboardingProvider.notifier)
          .setNotificationTime(formatted);
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null) {
        ref
            .read(firestoreServiceProvider)
            .updateProfile(uid, {'notificationTime': formatted})
            .catchError((_) {});
      }
    }
  }

  // ── Legal sheets ────────────────────────────────────────────────────────────
  void _showLegalSheet(String title, String content) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollCtrl) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Row(
                children: [
                  Text(title, style: AppTypography.heading2),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppColors.glassBorder),
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  content,
                  style: AppTypography.bodyM
                      .copyWith(color: AppColors.textSecondary, height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy() => _showLegalSheet('Privacy Policy', '''Last updated: May 2026

1. Information We Collect
We collect information you provide directly to us, including your display name, email address, and language learning preferences. We also collect usage data such as lessons completed, XP earned, and learning progress.

2. How We Use Your Information
We use your information to provide and improve the Verba service, personalise your learning experience, track your progress, send reminders (with your permission), and communicate with you about your account.

3. Data Storage
Your data is stored securely using Google Firebase. We use industry-standard security measures to protect your personal information.

4. Third-Party Services
We use the following third-party services:
• Google Firebase — authentication and data storage
• Google Gemini — AI lesson generation and speech evaluation
• ElevenLabs — text-to-speech audio
• RevenueCat — subscription and payment management

5. Your Rights
You may access, update, or delete your account information at any time through Settings. You can request deletion of all your data by deleting your account.

6. Data Retention
We retain your data for as long as your account is active. Upon account deletion, your data is permanently removed within 30 days.

7. Children's Privacy
Verba is not intended for children under 13 years of age. We do not knowingly collect personal information from children under 13.

8. Changes to This Policy
We may update this privacy policy from time to time. We will notify you of significant changes via the app or email.

9. Contact Us
If you have questions about this privacy policy, please contact us at privacy@verba.app''');

  void _showTermsOfService() => _showLegalSheet('Terms of Service', '''Last updated: May 2026

1. Acceptance of Terms
By using Verba, you agree to these Terms of Service. If you do not agree, please do not use the app.

2. Eligibility
You must be at least 13 years old to use Verba. By using the app, you confirm that you meet this requirement.

3. Use of Service
Verba grants you a limited, non-exclusive, non-transferable licence to use the app for personal, non-commercial language learning purposes only.

4. Account Responsibilities
You are responsible for maintaining the security of your account credentials and for all activities that occur under your account. Notify us immediately of any unauthorised use.

5. Subscriptions and Payments
Some features require a Verba Premium subscription. Subscriptions are billed through the App Store (iOS) or Google Play (Android). All purchases are subject to the respective platform's terms and refund policies. Verba does not process payments directly.

6. Cancellation and Refunds
You may cancel your subscription at any time through your device's subscription management settings. Refund requests are handled by Apple or Google according to their policies.

7. Intellectual Property
All content in Verba — including AI-generated lessons, audio, and interface elements — is owned by or licensed to Verba and is protected by applicable intellectual property laws. You may not reproduce, distribute, or create derivative works without written permission.

8. AI-Generated Content
Lessons and translations are generated by AI and may occasionally contain errors. Verba is a language learning aid and should not be relied upon for professional, legal, or medical translation purposes.

9. Prohibited Conduct
You agree not to: misuse the service, attempt to reverse-engineer the app, use automated tools to access the service, or violate any applicable laws.

10. Limitation of Liability
Verba is provided "as is" without warranties of any kind. To the maximum extent permitted by law, we are not liable for any indirect, incidental, or consequential damages arising from your use of the app.

11. Termination
We reserve the right to suspend or terminate your account if you violate these terms or if we discontinue the service.

12. Changes to Terms
We may update these terms at any time. Continued use of Verba after changes constitutes acceptance of the updated terms. We will notify you of material changes via the app or email.

13. Governing Law
These terms are governed by the laws of India, without regard to conflict-of-law principles.

14. Contact
For questions about these terms, contact us at legal@verba.app''');

  // ── Restore purchases ────────────────────────────────────────────────────────
  Future<void> _restorePurchases() async {
    try {
      final rcService = ref.read(revenueCatServiceProvider);
      final restored = await rcService.restorePurchases();
      if (!mounted) return;
      if (restored) {
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid != null) {
          await ref
              .read(firestoreServiceProvider)
              .updateSubscription(uid, isPremium: true)
              .catchError((_) {});
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Purchases restored successfully!')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No purchases found to restore.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore failed. Please try again.')),
        );
      }
    }
  }

  // ── Logout ──────────────────────────────────────────────────────────────────
  Future<void> _logout() async {
    await ref.read(authServiceProvider).signOut();
    if (mounted) context.go(RouteConstants.onboarding);
  }

  // ── Delete account ──────────────────────────────────────────────────────────
  void _showDeleteDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Delete account?', style: AppTypography.heading3),
        content: Text(
          'This will permanently delete your profile, progress, and data. This cannot be undone.',
          style: AppTypography.bodyM
              .copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {},
            style:
                TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final reminderTime = onboarding.notificationTime;
    final profileAsync = ref.watch(userProfileStreamProvider);
    final isPremium =
        profileAsync.valueOrNull?['isPremium'] as bool? ?? false;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
                const SizedBox(width: AppSpacing.sm),
                GradientText('Settings', style: AppTypography.heading1),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // Account section
            _SectionHeader('Account'),
            GlassCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.person_rounded,
                    title: 'Display name',
                    trailing: Text(
                      onboarding.displayName.isEmpty
                          ? 'Not set'
                          : onboarding.displayName,
                      style: AppTypography.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    onTap: _editDisplayName,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.language_rounded,
                    title: 'Learning language',
                    trailing: Text(
                      onboarding.targetLanguage.isEmpty
                          ? 'Not set'
                          : '${AppConstants.languageEmojis[onboarding.targetLanguage] ?? ''} ${onboarding.targetLanguage}',
                      style: AppTypography.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    onTap: _editLanguage,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Subscription',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isPremium
                                ? AppColors.warning
                                : AppColors.textAccent)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPremium ? 'Premium' : 'Free',
                        style: AppTypography.caption.copyWith(
                          color: isPremium
                              ? AppColors.warning
                              : AppColors.textAccent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    onTap: isPremium
                        ? null
                        : () => context.push(RouteConstants.paywall),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Notifications section
            _SectionHeader('Notifications'),
            GlassCard(
              child: Column(
                children: [
                  _SwitchRow(
                    icon: Icons.notifications_rounded,
                    title: 'Daily reminders',
                    value: _notifications,
                    onChanged: (v) =>
                        setState(() => _notifications = v),
                  ),
                  if (_notifications) ...[
                    const Divider(
                        height: 1, color: AppColors.glassBorder),
                    _SettingRow(
                      icon: Icons.schedule_rounded,
                      title: 'Reminder time',
                      trailing: Text(
                        reminderTime,
                        style: AppTypography.bodyS
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      onTap: _editReminderTime,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Practice section
            _SectionHeader('Practice'),
            GlassCard(
              child: Column(
                children: [
                  _SwitchRow(
                    icon: Icons.volume_up_rounded,
                    title: 'Sound effects',
                    value: _soundEffects,
                    onChanged: (v) =>
                        setState(() => _soundEffects = v),
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed_rounded,
                                color: AppColors.textSecondary,
                                size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Text('Speech speed',
                                style: AppTypography.bodyM),
                            const Spacer(),
                            Text(
                                '${_speechSpeed.toStringAsFixed(1)}x',
                                style: AppTypography.bodyS.copyWith(
                                    color: AppColors.textSecondary)),
                          ],
                        ),
                        Slider(
                          value: _speechSpeed,
                          min: 0.5,
                          max: 2.0,
                          divisions: 6,
                          activeColor: AppColors.primaryStart,
                          onChanged: (v) =>
                              setState(() => _speechSpeed = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // App section
            _SectionHeader('App'),
            GlassCard(
              child: Column(
                children: [
                  _SettingRow(
                    icon: Icons.info_outline_rounded,
                    title: 'App version',
                    trailing: Text('1.0.0',
                        style: AppTypography.bodyS
                            .copyWith(color: AppColors.textSecondary)),
                    onTap: null,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy policy',
                    onTap: _showPrivacyPolicy,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    onTap: _showTermsOfService,
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.restore_rounded,
                    title: 'Restore purchases',
                    onTap: _restorePurchases,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Logout button
            VerbaButton(
              label: 'Log out',
              icon: Icons.logout_rounded,
              secondary: true,
              onPressed: _logout,
            ),
            const SizedBox(height: AppSpacing.md),

            // Delete account
            VerbaButton(
              label: 'Delete account',
              icon: Icons.delete_forever_rounded,
              secondary: true,
              onPressed: _showDeleteDialog,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 0),
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(title, style: AppTypography.bodyM),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing!,
          if (onTap != null)
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.textSecondary, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(title, style: AppTypography.bodyM),
      value: value,
      activeColor: AppColors.primaryStart,
      onChanged: onChanged,
    );
  }
}
