import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class Ob11SocialProof extends StatelessWidget {
  const Ob11SocialProof({super.key});

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 11,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Millions love\nlearning with Verba',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            // App store rating
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primary.withOpacity(0.15),
                  AppColors.secondary.withOpacity(0.08),
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _RatingBlock(value: '4.9', label: 'App Store', stars: 5),
                  Container(width: 1, height: 40, color: AppColors.borderColor),
                  _RatingBlock(value: '4.8', label: 'Google Play', stars: 5),
                  Container(width: 1, height: 40, color: AppColors.borderColor),
                  _RatingBlock(value: '2M+', label: 'Learners', stars: 0),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: AppConstants.testimonials.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final t = AppConstants.testimonials[i];
                  return _TestimonialCard(testimonial: t);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28, top: 16),
              child: GradientButton(
                label: 'Join the community',
                onPressed: () => context.go('/onboarding/notify'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBlock extends StatelessWidget {
  final String value;
  final String label;
  final int stars;
  const _RatingBlock(
      {required this.value, required this.label, required this.stars});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w800)),
        if (stars > 0)
          Row(
            children: List.generate(
              stars,
              (_) => const Icon(Icons.star_rounded,
                  color: Color(0xFFFFB830), size: 12),
            ),
          ),
        Text(label,
            style:
                const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}

class _TestimonialCard extends StatelessWidget {
  final Map<String, String> testimonial;
  const _TestimonialCard({required this.testimonial});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                child: Text(
                  testimonial['avatar']!,
                  style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(testimonial['name']!,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(testimonial['location']!,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  int.parse(testimonial['rating']!),
                  (_) => const Icon(Icons.star_rounded,
                      color: Color(0xFFFFB830), size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${testimonial['text']}"',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
