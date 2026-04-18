import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import '../providers/onboarding_provider.dart';

class Ob10Outcome extends ConsumerWidget {
  const Ob10Outcome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingProvider);
    final lang = state.selectedLanguage ?? 'your language';
    final goal = state.dailyGoalMinutes;

    return OnboardingScaffold(
      step: 10,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Here\'s what you\'ll\nachieve in 3 months',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on $goal min/day practising $lang.',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 28),
            // Timeline cards
            _TimelineCard(
              month: 'Month 1',
              title: 'Foundation',
              points: const [
                '500+ key vocabulary words',
                'Basic sentence structures',
                'Pronunciation fundamentals',
              ],
              color: AppColors.primary,
              emoji: '🌱',
            ),
            const SizedBox(height: 14),
            _TimelineCard(
              month: 'Month 2',
              title: 'Conversation',
              points: const [
                'Hold 5-min conversations',
                'Express opinions & feelings',
                'Understand native speakers',
              ],
              color: AppColors.secondary,
              emoji: '💬',
            ),
            const SizedBox(height: 14),
            _TimelineCard(
              month: 'Month 3',
              title: 'Confidence',
              points: const [
                'Travel confidently',
                'B1 level proficiency',
                'Think in your new language',
              ],
              color: const Color(0xFFFFB830),
              emoji: '🏆',
            ),
            const SizedBox(height: 28),
            GradientButton(
              label: 'Let\'s do this!',
              onPressed: () => context.go('/onboarding/proof'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final String month;
  final String title;
  final List<String> points;
  final Color color;
  final String emoji;

  const _TimelineCard({
    required this.month,
    required this.title,
    required this.points,
    required this.color,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  month,
                  style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 16, color: color),
                    const SizedBox(width: 10),
                    Text(p,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
