import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class Ob12Notifications extends StatelessWidget {
  const Ob12Notifications({super.key});

  Future<void> _requestPermission(BuildContext context) async {
    await Permission.notification.request();
    if (context.mounted) context.go('/onboarding/name');
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 12,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Bell illustration
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.primary.withOpacity(0.2),
                  Colors.transparent,
                ]),
              ),
              child: const Center(
                child: Text('🔔', style: TextStyle(fontSize: 72)),
              ),
            ),
            const SizedBox(height: 36),
            const Text(
              'Stay on track with\ndaily reminders',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Learners who enable reminders are\n3x more likely to reach their goals.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.5),
            ),
            const SizedBox(height: 32),
            // Feature list
            ...[
              ('⏰', 'Custom reminder times'),
              ('📊', 'Weekly progress updates'),
              ('🔥', 'Streak alerts'),
            ].map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        Text(item.$1,
                            style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Text(item.$2,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                )),
            const Spacer(flex: 3),
            GradientButton(
              label: 'Enable Notifications',
              onPressed: () => _requestPermission(context),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.go('/onboarding/name'),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Not now',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                      decoration: TextDecoration.underline),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
