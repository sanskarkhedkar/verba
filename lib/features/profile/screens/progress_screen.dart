import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/helpers.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/xp_progress_bar.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileStreamProvider).valueOrNull;
    final xp = (profile?['xp'] as int?) ?? 0;
    final streak = (profile?['streak'] as int?) ?? 0;
    final words = (profile?['wordsLearned'] as int?) ?? 0;
    final lessons = (profile?['lessonsCompleted'] as int?) ?? 0;
    final accuracy = (profile?['bestAccuracy'] as int?) ?? 0;
    final nextLevelLabel =
        Helpers.xpLevelLabel(xp + Helpers.xpToNextLevel(xp));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GradientText('Your Progress',
                        style: AppTypography.heading1),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: AppColors.textAccent),
                              const SizedBox(width: AppSpacing.sm),
                              Text('Level ${Helpers.xpLevelLabel(xp)}',
                                  style: AppTypography.heading2),
                              const Spacer(),
                              Text('$xp XP',
                                  style: AppTypography.heading3.copyWith(
                                      color: AppColors.textAccent)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          XpProgressBar(value: Helpers.xpProgress(xp)),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            Helpers.xpToNextLevel(xp) == 0
                                ? 'Max level reached'
                                : '${Helpers.xpToNextLevel(xp)} XP to $nextLevelLabel',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Day streak',
                            value: '$streak',
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.translate_rounded,
                            label: 'Words learned',
                            value: '$words',
                            color: AppColors.textAccent,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.menu_book_rounded,
                            label: 'Lessons done',
                            value: '$lessons',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.mic_rounded,
                            label: 'Best accuracy',
                            value: accuracy > 0 ? '$accuracy%' : '—',
                            color: AppColors.primaryStart,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppSpacing.sm),
          Text(value,
              style: AppTypography.heading2
                  .copyWith(color: AppColors.textPrimary)),
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
