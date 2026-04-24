import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
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
  String _reminderTime = '08:00 AM';

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);

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
                    onTap: () {},
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
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Subscription',
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.textAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Free',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textAccent)),
                    ),
                    onTap: () => context.push('/paywall'),
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
                    onChanged: (v) => setState(() => _notifications = v),
                  ),
                  if (_notifications) ...[
                    const Divider(height: 1, color: AppColors.glassBorder),
                    _SettingRow(
                      icon: Icons.schedule_rounded,
                      title: 'Reminder time',
                      trailing: Text(
                        _reminderTime,
                        style: AppTypography.bodyS
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: const TimeOfDay(hour: 8, minute: 0),
                        );
                        if (time != null) {
                          setState(() => _reminderTime =
                              time.format(context));
                        }
                      },
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
                    onChanged: (v) => setState(() => _soundEffects = v),
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
                                color: AppColors.textSecondary, size: 20),
                            const SizedBox(width: AppSpacing.md),
                            Text('Speech speed',
                                style: AppTypography.bodyM),
                            const Spacer(),
                            Text('${_speechSpeed.toStringAsFixed(1)}x',
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
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.description_outlined,
                    title: 'Terms of service',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppColors.glassBorder),
                  _SettingRow(
                    icon: Icons.restore_rounded,
                    title: 'Restore purchases',
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            VerbaButton(
              label: 'Delete account',
              icon: Icons.delete_forever_rounded,
              secondary: true,
              onPressed: () => _showDeleteDialog(context),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
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
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
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
      activeThumbColor: AppColors.primaryStart,
      onChanged: onChanged,
    );
  }
}
