import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  static const _achievements = [
    _Achievement(
      title: 'First Step',
      description: 'Complete your first lesson',
      icon: Icons.flag_rounded,
      unlocked: true,
      xp: 25,
    ),
    _Achievement(
      title: 'Quick Learner',
      description: 'Complete 5 lessons',
      icon: Icons.bolt_rounded,
      unlocked: false,
      xp: 50,
    ),
    _Achievement(
      title: 'Streak Starter',
      description: 'Maintain a 3-day streak',
      icon: Icons.local_fire_department_rounded,
      unlocked: false,
      xp: 75,
    ),
    _Achievement(
      title: 'Translator',
      description: 'Use translation tools 10 times',
      icon: Icons.translate_rounded,
      unlocked: false,
      xp: 50,
    ),
    _Achievement(
      title: 'Phrase Master',
      description: 'Learn 50 phrases',
      icon: Icons.menu_book_rounded,
      unlocked: false,
      xp: 100,
    ),
    _Achievement(
      title: 'Perfect Score',
      description: 'Get 100% accuracy on a lesson',
      icon: Icons.star_rounded,
      unlocked: false,
      xp: 150,
    ),
    _Achievement(
      title: 'Conversationalist',
      description: 'Complete an AI conversation session',
      icon: Icons.chat_bubble_rounded,
      unlocked: false,
      xp: 100,
    ),
    _Achievement(
      title: 'Committed',
      description: 'Practice for 30 consecutive days',
      icon: Icons.workspace_premium_rounded,
      unlocked: false,
      xp: 500,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final unlocked = _achievements.where((a) => a.unlocked).length;
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
                    GradientText('Achievements',
                        style: AppTypography.heading1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$unlocked / ${_achievements.length} unlocked',
                      style: AppTypography.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.1,
                  crossAxisSpacing: AppSpacing.md,
                  mainAxisSpacing: AppSpacing.md,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) =>
                      _AchievementCard(achievement: _achievements[i]),
                  childCount: _achievements.length,
                ),
              ),
            ),
            const SliverPadding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.achievement});
  final _Achievement achievement;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: achievement.unlocked
                      ? const LinearGradient(
                          colors: [AppColors.primaryStart, AppColors.primaryEnd],
                        )
                      : null,
                  color: achievement.unlocked ? null : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.unlocked
                      ? Colors.white
                      : AppColors.textTertiary,
                  size: 22,
                ),
              ),
              if (!achievement.unlocked)
                const Positioned(
                  right: 0,
                  bottom: 0,
                  child: Icon(Icons.lock_rounded,
                      size: 14, color: AppColors.textTertiary),
                ),
            ],
          ),
          const Spacer(),
          Text(
            achievement.title,
            style: AppTypography.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: achievement.unlocked
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            '+${achievement.xp} XP',
            style: AppTypography.caption.copyWith(
              color: achievement.unlocked
                  ? AppColors.textAccent
                  : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Achievement {
  const _Achievement({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.xp,
  });
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;
  final int xp;
}
