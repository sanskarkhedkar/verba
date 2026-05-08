import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';

class _AchievementDef {
  const _AchievementDef({
    required this.title,
    required this.description,
    required this.icon,
    required this.xp,
    required this.isUnlocked,
  });
  final String title;
  final String description;
  final IconData icon;
  final int xp;
  final bool Function(Map<String, dynamic> profile) isUnlocked;
}

int _intField(Map<String, dynamic> p, String key) =>
    (p[key] as int?) ?? 0;

const _achievements = <_AchievementDef>[
  _AchievementDef(
    title: 'First Step',
    description: 'Complete your first lesson',
    icon: Icons.flag_rounded,
    xp: 25,
    isUnlocked: _firstStep,
  ),
  _AchievementDef(
    title: 'Quick Learner',
    description: 'Complete 5 lessons',
    icon: Icons.bolt_rounded,
    xp: 50,
    isUnlocked: _quickLearner,
  ),
  _AchievementDef(
    title: 'Streak Starter',
    description: 'Maintain a 3-day streak',
    icon: Icons.local_fire_department_rounded,
    xp: 75,
    isUnlocked: _streakStarter,
  ),
  _AchievementDef(
    title: 'Translator',
    description: 'Use translation tools 10 times',
    icon: Icons.translate_rounded,
    xp: 50,
    isUnlocked: _translator,
  ),
  _AchievementDef(
    title: 'Phrase Master',
    description: 'Learn 50 phrases',
    icon: Icons.menu_book_rounded,
    xp: 100,
    isUnlocked: _phraseMaster,
  ),
  _AchievementDef(
    title: 'Perfect Score',
    description: 'Get 100% accuracy on a lesson',
    icon: Icons.star_rounded,
    xp: 150,
    isUnlocked: _perfectScore,
  ),
  _AchievementDef(
    title: 'Conversationalist',
    description: 'Complete an AI conversation session',
    icon: Icons.chat_bubble_rounded,
    xp: 100,
    isUnlocked: _conversationalist,
  ),
  _AchievementDef(
    title: 'Committed',
    description: 'Practice for 30 consecutive days',
    icon: Icons.workspace_premium_rounded,
    xp: 500,
    isUnlocked: _committed,
  ),
];

bool _firstStep(Map<String, dynamic> p) => _intField(p, 'lessonsCompleted') >= 1;
bool _quickLearner(Map<String, dynamic> p) =>
    _intField(p, 'lessonsCompleted') >= 5;
bool _streakStarter(Map<String, dynamic> p) => _intField(p, 'streak') >= 3;
bool _translator(Map<String, dynamic> p) =>
    _intField(p, 'translationsCount') >= 10;
bool _phraseMaster(Map<String, dynamic> p) =>
    _intField(p, 'wordsLearned') >= 50;
bool _perfectScore(Map<String, dynamic> p) =>
    _intField(p, 'bestAccuracy') >= 100;
bool _conversationalist(Map<String, dynamic> p) =>
    _intField(p, 'conversationsCompleted') >= 1;
bool _committed(Map<String, dynamic> p) => _intField(p, 'streak') >= 30;

/// How many achievements are unlocked given a profile snapshot.
int unlockedAchievementCount(Map<String, dynamic>? profile) {
  if (profile == null) return 0;
  return _achievements.where((a) => a.isUnlocked(profile)).length;
}

int get totalAchievementCount => _achievements.length;

class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileStreamProvider).valueOrNull ?? const {};
    final unlocked = _achievements.where((a) => a.isUnlocked(profile)).length;

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
                  (ctx, i) {
                    final a = _achievements[i];
                    return _AchievementCard(
                      def: a,
                      unlocked: a.isUnlocked(profile),
                    );
                  },
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
  const _AchievementCard({required this.def, required this.unlocked});
  final _AchievementDef def;
  final bool unlocked;

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
                  gradient: unlocked
                      ? const LinearGradient(
                          colors: [AppColors.primaryStart, AppColors.primaryEnd],
                        )
                      : null,
                  color: unlocked ? null : AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  def.icon,
                  color: unlocked ? Colors.white : AppColors.textTertiary,
                  size: 22,
                ),
              ),
              if (!unlocked)
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
            def.title,
            style: AppTypography.bodyS.copyWith(
              fontWeight: FontWeight.w600,
              color: unlocked
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          Text(
            '+${def.xp} XP',
            style: AppTypography.caption.copyWith(
              color:
                  unlocked ? AppColors.textAccent : AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
