import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import '../providers/onboarding_provider.dart';

class Ob14Auth extends ConsumerWidget {
  const Ob14Auth({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(onboardingProvider).userName;
    final greeting = name.isNotEmpty ? 'Welcome,\n$name! 👋' : 'Create your\naccount';

    return OnboardingScaffold(
      step: 14,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(flex: 2),
            Text(
              greeting,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Sign in to save your progress and\nsync across all devices.',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
            ),
            const Spacer(flex: 2),
            // Google Sign In
            _AuthButton(
              icon: _GoogleIcon(),
              label: 'Continue with Google',
              bgColor: Colors.white,
              textColor: const Color(0xFF1A1A1A),
              onPressed: () => context.go('/onboarding/paywall'),
            ),
            const SizedBox(height: 14),
            // Apple Sign In
            _AuthButton(
              icon: const Icon(Icons.apple, color: Colors.white, size: 22),
              label: 'Continue with Apple',
              bgColor: Colors.black,
              textColor: Colors.white,
              border: Border.all(color: AppColors.borderColor),
              onPressed: () => context.go('/onboarding/paywall'),
            ),
            const SizedBox(height: 14),
            // Email
            OutlinedButton(
              onPressed: () => context.go('/onboarding/paywall'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: BorderSide(color: AppColors.borderColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text(
                'Continue with Email',
                style: TextStyle(
                    color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
            ),
            const Spacer(flex: 3),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'By continuing you agree to our ',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12),
                  children: [
                    TextSpan(
                      text: 'Terms',
                      style: const TextStyle(
                          color: AppColors.primaryLight,
                          decoration: TextDecoration.underline),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                          color: AppColors.primaryLight,
                          decoration: TextDecoration.underline),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _AuthButton extends StatelessWidget {
  final Widget icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final BoxBorder? border;
  final VoidCallback onPressed;

  const _AuthButton({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.onPressed,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: bgColor == Colors.white
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 24, height: 24, child: icon),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GooglePainter());
  }
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    // simplified G logo
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue arc
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        -0.25, 1.6, true, paint);
    // Green arc
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        1.35, 1.6, true, paint);
    // Yellow arc
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        2.95, 0.85, true, paint);
    // Red arc
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: center, radius: r),
        3.8, 0.75, true, paint);

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(center, r * 0.6, paint);
    // Blue right bar
    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(center.dx, center.dy - r * 0.2, r, r * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
