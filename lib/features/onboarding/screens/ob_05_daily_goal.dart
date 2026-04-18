import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import '../providers/onboarding_provider.dart';

class Ob05DailyGoal extends ConsumerStatefulWidget {
  const Ob05DailyGoal({super.key});
  @override
  ConsumerState<Ob05DailyGoal> createState() => _Ob05DailyGoalState();
}

class _Ob05DailyGoalState extends ConsumerState<Ob05DailyGoal> {
  int _selectedMinutes = 10;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 5,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your daily\nlearning goal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Consistency beats intensity. Pick what fits your schedule.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const Spacer(),
            // Big animated timer display
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Text(
                              '$_selectedMinutes',
                              key: ValueKey(_selectedMinutes),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 64,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const Text(
                            'min / day',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            // Option chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppConstants.dailyGoalOptions.map((mins) {
                final isSelected = _selectedMinutes == mins;
                return GestureDetector(
                  onTap: () => setState(() => _selectedMinutes = mins),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.borderColor,
                        width: isSelected ? 1.8 : 1,
                      ),
                    ),
                    child: Text(
                      '$mins min',
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primaryLight
                            : AppColors.textSecondary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Motivational tip
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.secondary.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _tipFor(_selectedMinutes),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: GradientButton(
                label: 'Set My Goal',
                onPressed: () {
                  ref
                      .read(onboardingProvider.notifier)
                      .setDailyGoal(_selectedMinutes);
                  context.go('/onboarding/focus');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _tipFor(int mins) {
    switch (mins) {
      case 5:
        return 'Perfect for busy schedules. Even 5 min/day builds a strong habit!';
      case 10:
        return 'Most learners hit conversational fluency 2x faster at 10 min/day.';
      case 15:
        return 'Great choice! 15 min is the sweet spot for rapid progress.';
      case 20:
        return 'Ambitious! At 20 min/day you\'ll reach B1 level in record time.';
      default:
        return 'Consistency is key. Stick to your goal!';
    }
  }
}
