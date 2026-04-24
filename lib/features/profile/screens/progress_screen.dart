import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../../core/utils/helpers.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final onboarding = ref.watch(onboardingProvider); // available when needed
    const xp = 75; // TODO: connect to Firestore UserProfile state

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
                    // XP level card
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
                            '${Helpers.xpToNextLevel(xp)} XP to ${Helpers.xpLevelLabel(xp + 1)}',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Stats grid
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.local_fire_department_rounded,
                            label: 'Day streak',
                            value: '1',
                            color: AppColors.warning,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.translate_rounded,
                            label: 'Words learned',
                            value: '3',
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
                            value: '1',
                            color: AppColors.success,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.mic_rounded,
                            label: 'Avg accuracy',
                            value: '82%',
                            color: AppColors.primaryStart,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text('7-Day Activity',
                        style: AppTypography.heading3),
                    const SizedBox(height: AppSpacing.md),
                    _WeeklyChart(),
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

class _WeeklyChart extends StatelessWidget {
  final _days = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final _values = const [0.0, 0.6, 0.4, 1.0, 0.8, 0.3, 0.0];

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final active = _values[i] > 0;
          return Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 400 + i * 80),
                width: 28,
                height: 80 * _values[i],
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.primaryEnd, AppColors.primaryStart],
                        )
                      : null,
                  color: active ? null : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(height: 6),
              Text(_days[i],
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary)),
            ],
          );
        }),
      ),
    );
  }
}
