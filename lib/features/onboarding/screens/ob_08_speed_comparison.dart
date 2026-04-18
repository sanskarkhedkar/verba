import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class Ob08SpeedComparison extends StatefulWidget {
  const Ob08SpeedComparison({super.key});
  @override
  State<Ob08SpeedComparison> createState() => _Ob08SpeedComparisonState();
}

class _Ob08SpeedComparisonState extends State<Ob08SpeedComparison>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<int> _counter;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..forward();
    _counter = IntTween(begin: 1, end: 10).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 8,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learn languages\nfaster than ever',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our AI adapts to you in real time — no wasted lessons.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const Spacer(),
            // Big animated counter
            Center(
              child: Column(
                children: [
                  AnimatedBuilder(
                    animation: _counter,
                    builder: (_, __) => ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        '${_counter.value}x',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 120,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    'faster than traditional methods',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            // Comparison cards
            _CompareRow(
              emoji: '📚',
              label: 'Textbooks & classes',
              months: '18–24 months',
              isVerba: false,
            ),
            const SizedBox(height: 12),
            _CompareRow(
              emoji: '⚡',
              label: 'Verba AI',
              months: '2–3 months',
              isVerba: true,
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: GradientButton(
                label: 'I\'m ready to learn faster!',
                onPressed: () => context.go('/onboarding/loader'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String months;
  final bool isVerba;

  const _CompareRow({
    required this.emoji,
    required this.label,
    required this.months,
    required this.isVerba,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isVerba
            ? AppColors.primary.withOpacity(0.12)
            : AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerba ? AppColors.primary.withOpacity(0.5) : AppColors.borderColor,
          width: isVerba ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      color: isVerba
                          ? AppColors.primaryLight
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    )),
                Text('To conversational fluency',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isVerba
                  ? AppColors.primary
                  : AppColors.bgCardHighlight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              months,
              style: TextStyle(
                color: isVerba ? Colors.white : AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
