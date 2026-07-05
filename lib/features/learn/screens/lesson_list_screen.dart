import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/verba_button.dart';
import '../../onboarding/providers/onboarding_provider.dart';

/// Lesson library screen showing available lesson categories.
class LessonListScreen extends ConsumerWidget {
  const LessonListScreen({super.key});

  static const _categories = [
    _LessonCategory(
        title: 'Greetings',
        subtitle: '7 phrases · 8 min',
        icon: Icons.waving_hand_rounded,
        tag: 'everyday'),
    _LessonCategory(
        title: 'Travel Basics',
        subtitle: '10 phrases · 12 min',
        icon: Icons.flight_rounded,
        tag: 'travel'),
    _LessonCategory(
        title: 'Restaurant & Food',
        subtitle: '9 phrases · 10 min',
        icon: Icons.restaurant_rounded,
        tag: 'restaurant'),
    _LessonCategory(
        title: 'Shopping',
        subtitle: '8 phrases · 9 min',
        icon: Icons.shopping_bag_rounded,
        tag: 'shopping'),
    _LessonCategory(
        title: 'Numbers & Time',
        subtitle: '10 phrases · 11 min',
        icon: Icons.schedule_rounded,
        tag: 'everyday'),
    _LessonCategory(
        title: 'Directions',
        subtitle: '8 phrases · 9 min',
        icon: Icons.map_rounded,
        tag: 'travel'),
    _LessonCategory(
        title: 'Work & Business',
        subtitle: '12 phrases · 14 min',
        icon: Icons.work_rounded,
        tag: 'work'),
    _LessonCategory(
        title: 'Pronunciation Drill',
        subtitle: '5 phrases · 6 min',
        icon: Icons.record_voice_over_rounded,
        tag: 'pronunciation'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final lang = onboarding.targetLanguage;

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
                    GradientText('$lang Lessons',
                        style: AppTypography.heading1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${_categories.length} lesson packs available',
                      style: AppTypography.bodyM
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    VerbaButton(
                      label: 'Today\'s lesson',
                      icon: Icons.play_arrow_rounded,
                      onPressed: () =>
                          context.push(RouteConstants.lesson),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final cat = _categories[i];
                    return _CategoryCard(
                      category: cat,
                      onTap: () => context.push(
                        RouteConstants.lesson,
                        extra: {'moduleCategory': cat.tag},
                      ),
                    );
                  },
                  childCount: _categories.length,
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});
  final _LessonCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryStart, AppColors.primaryEnd],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(category.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category.title, style: AppTypography.heading3),
                Text(
                  category.subtitle,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _LessonCategory {
  const _LessonCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tag,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final String tag;
}
