import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final profileData = ref.watch(userProfileStreamProvider).valueOrNull;
    final isPremium = ref.watch(premiumStatusProvider);

    final xp = (profileData?['xp'] as int?) ?? 0;
    final streak = (profileData?['streak'] as int?) ?? 0;
    final words = (profileData?['wordsLearned'] as int?) ?? 0;
    final lessons = (profileData?['lessonsCompleted'] as int?) ?? 0;
    final displayName = (profileData?['displayName'] as String?)
        ?.isNotEmpty == true
        ? profileData!['displayName'] as String
        : onboarding.displayName.isNotEmpty
            ? onboarding.displayName
            : 'Verba Learner';
    final lang = onboarding.targetLanguage.isEmpty
        ? 'Language'
        : onboarding.targetLanguage;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        GradientText('Profile', style: AppTypography.heading1),
        const SizedBox(height: AppSpacing.lg),

        // Avatar + name card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryStart, AppColors.primaryEnd],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_rounded,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(displayName, style: AppTypography.heading3),
                    Text(
                      '$lang · ${Helpers.xpLevelLabel(xp)}',
                      style: AppTypography.bodyS
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    XpProgressBar(
                        value: Helpers.xpProgress(xp), height: 4),
                    const SizedBox(height: 4),
                    Text(
                      '$xp XP · ${Helpers.xpToNextLevel(xp)} XP to next level',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Quick stats row
        Row(
          children: [
            _StatChip(
                label: 'Streak',
                value: '$streak ${streak == 1 ? "day" : "days"}',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning),
            const SizedBox(width: AppSpacing.md),
            _StatChip(label: 'Words', value: '$words',
                icon: Icons.translate_rounded,
                color: AppColors.textAccent),
            const SizedBox(width: AppSpacing.md),
            _StatChip(label: 'Lessons', value: '$lessons',
                icon: Icons.menu_book_rounded,
                color: AppColors.success),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Navigation tiles
        _NavTile(
          icon: Icons.bar_chart_rounded,
          label: 'Detailed progress',
          subtitle: 'XP, accuracy, 7-day chart',
          onTap: () => context.push(RouteConstants.progress),
        ),
        const SizedBox(height: AppSpacing.sm),
        _NavTile(
          icon: Icons.emoji_events_rounded,
          label: 'Achievements',
          subtitle: '1 / 8 unlocked',
          onTap: () => context.push(RouteConstants.achievements),
        ),
        const SizedBox(height: AppSpacing.sm),
        _NavTile(
          icon: Icons.settings_rounded,
          label: 'Settings',
          subtitle: 'Notifications, language, account',
          onTap: () => context.push(RouteConstants.settings),
        ),
        if (!isPremium) ...[
          const SizedBox(height: AppSpacing.sm),
          _NavTile(
            icon: Icons.workspace_premium_rounded,
            label: 'Upgrade to Premium',
            subtitle: 'Unlimited lessons & tools',
            onTap: () => context.push(RouteConstants.paywall),
            accent: true,
          ),
        ],
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value,
                style: AppTypography.bodyS
                    .copyWith(fontWeight: FontWeight.w600)),
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon,
              color: accent ? AppColors.textAccent : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.bodyM.copyWith(
                      color: accent
                          ? AppColors.textAccent
                          : AppColors.textPrimary,
                    )),
                Text(subtitle,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}
