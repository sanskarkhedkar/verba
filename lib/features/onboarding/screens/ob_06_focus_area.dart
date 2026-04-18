import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import '../providers/onboarding_provider.dart';

class Ob06FocusArea extends ConsumerWidget {
  const Ob06FocusArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return OnboardingScaffold(
      step: 6,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What do you want\nto focus on?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select up to 3 areas to build a focused plan.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.7,
                ),
                itemCount: AppConstants.focusAreas.length,
                itemBuilder: (context, i) {
                  final area = AppConstants.focusAreas[i];
                  final isSelected =
                      state.selectedFocusAreas.contains(area['label']);
                  final canSelect = state.selectedFocusAreas.length < 3;

                  return GestureDetector(
                    onTap: () {
                      if (isSelected || canSelect) {
                        notifier.toggleFocusArea(area['label']!);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : (!canSelect
                                ? AppColors.bgCard.withOpacity(0.5)
                                : AppColors.bgCard),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderColor,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(area['emoji']!,
                              style: TextStyle(
                                  fontSize: 28,
                                  color: (!canSelect && !isSelected)
                                      ? Colors.white24
                                      : null)),
                          const SizedBox(height: 6),
                          Text(
                            area['label']!,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primaryLight
                                  : (!canSelect && !isSelected)
                                      ? AppColors.textMuted.withOpacity(0.4)
                                      : AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.primary, size: 16),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Counter
            Center(
              child: Text(
                '${state.selectedFocusAreas.length}/3 selected',
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28, top: 16),
              child: GradientButton(
                label: 'Continue',
                onPressed: state.selectedFocusAreas.isEmpty
                    ? null
                    : () => context.go('/onboarding/graph'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
