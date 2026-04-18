import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class Ob09PlanLoader extends StatefulWidget {
  const Ob09PlanLoader({super.key});
  @override
  State<Ob09PlanLoader> createState() => _Ob09PlanLoaderState();
}

class _Ob09PlanLoaderState extends State<Ob09PlanLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _step = 0;

  final _steps = [
    'Analyzing your goals...',
    'Building vocabulary list...',
    'Calibrating AI speaking level...',
    'Personalizing lesson path...',
    'Finalizing your plan...',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _runSteps();
  }

  Future<void> _runSteps() async {
    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) setState(() => _step = i);
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) context.go('/onboarding/outcome');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_step + 1) / _steps.length;
    return OnboardingScaffold(
      step: 9,
      showBack: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            // Pulsing ring
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) {
                final pulse = 1.0 + _ctrl.value * 0.08;
                return Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.3),
                          AppColors.primary.withOpacity(0.05),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text('🤖', style: TextStyle(fontSize: 56)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            const Text(
              'Creating your\npersonalized plan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 32),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                height: 6,
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.bgCard,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Step list
            ..._steps.asMap().entries.map((e) {
              final isDone = e.key < _step;
              final isCurrent = e.key == _step;
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: e.key <= _step ? 1.0 : 0.3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone
                              ? AppColors.success
                              : isCurrent
                                  ? AppColors.primary
                                  : AppColors.bgCard,
                          border: Border.all(
                            color: isDone
                                ? AppColors.success
                                : isCurrent
                                    ? AppColors.primary
                                    : AppColors.borderColor,
                          ),
                        ),
                        child: Center(
                          child: isDone
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : isCurrent
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        e.value,
                        style: TextStyle(
                          color: isDone || isCurrent
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 14,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
