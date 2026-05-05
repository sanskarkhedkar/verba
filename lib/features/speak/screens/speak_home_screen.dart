import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class SpeakHomeScreen extends ConsumerWidget {
  const SpeakHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final onboarding = ref.watch(onboardingProvider);

    final data = profileAsync.valueOrNull;
    final xp = (data?['xp'] as int?) ?? 0;
    final streak = (data?['streak'] as int?) ?? 0;
    final lessons = (data?['lessonsCompleted'] as int?) ?? 0;
    final words = (data?['wordsLearned'] as int?) ?? 0;
    final lang = onboarding.targetLanguage.isEmpty
        ? 'Language'
        : onboarding.targetLanguage;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        GradientText('Stats', style: AppTypography.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your $lang learning progress.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xl),

        // XP card with progress bar
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Total XP',
                      style: AppTypography.bodyS
                          .copyWith(color: AppColors.textSecondary)),
                  const Spacer(),
                  Text(
                    Helpers.xpLevelLabel(xp),
                    style: AppTypography.bodyS
                        .copyWith(color: AppColors.textAccent),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text('$xp XP', style: AppTypography.heading1),
              const SizedBox(height: AppSpacing.md),
              XpProgressBar(value: Helpers.xpProgress(xp)),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${Helpers.xpToNextLevel(xp)} XP to next level',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Streak + lessons row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Day streak',
                value: '$streak',
                icon: Icons.local_fire_department_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'Lessons done',
                value: '$lessons',
                icon: Icons.menu_book_rounded,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Words + language row
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Words learned',
                value: '$words',
                icon: Icons.translate_rounded,
                color: AppColors.textAccent,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'Language',
                value: lang,
                icon: Icons.language_rounded,
                color: AppColors.primaryStart,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Milestone card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Next milestone', style: AppTypography.heading3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _milestoneText(xp),
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _milestoneText(int xp) {
    if (xp < 500) return 'Reach A2 level with ${500 - xp} more XP.';
    if (xp < 2000) return 'Reach B1 level with ${2000 - xp} more XP.';
    if (xp < 5000) return 'Reach B2 level with ${5000 - xp} more XP.';
    if (xp < 10000) return 'Reach C1 level with ${10000 - xp} more XP.';
    return 'You have reached C1+ level!';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.heading3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
