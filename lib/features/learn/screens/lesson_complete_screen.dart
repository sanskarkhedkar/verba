import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/mascot_widget.dart';
import '../../../core/widgets/verba_button.dart';
import '../providers/lesson_provider.dart';

/// Lesson completion celebration screen shown after all turns pass.
class LessonCompleteScreen extends ConsumerWidget {
  const LessonCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(lessonProvider);
    final xp = state.xpEarned;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const MascotWidget(size: 180, state: MascotState.success),
              const SizedBox(height: AppSpacing.xl),
              GradientText(
                'Lesson Complete!',
                style: AppTypography.displayL,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'You crushed it today. Keep the streak alive!',
                textAlign: TextAlign.center,
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xl),
              _XpCard(xp: xp),
              const SizedBox(height: AppSpacing.lg),
              _StatsRow(state: state),
              const Spacer(),
              VerbaButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: AppSpacing.sm),
              VerbaButton(
                label: 'Practice again',
                secondary: true,
                icon: Icons.replay_rounded,
                onPressed: () {
                  ref.read(lessonProvider.notifier).loadLesson();
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XpCard extends StatefulWidget {
  const _XpCard({required this.xp});
  final int xp;

  @override
  State<_XpCard> createState() => _XpCardState();
}

class _XpCardState extends State<_XpCard> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Text('+${widget.xp} XP', style: AppTypography.displayXL.copyWith(
                color: AppColors.textAccent,
                fontWeight: FontWeight.w800,
              )),
              const SizedBox(height: AppSpacing.sm),
              Text('earned this lesson', style: AppTypography.bodyM.copyWith(
                color: AppColors.textSecondary,
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.state});
  final LessonState state;

  @override
  Widget build(BuildContext context) {
    final total = state.lesson?.turns.length ?? 0;
    final avgAccuracy = total > 0 ? 82 : 0; // TODO: compute from turnResults

    return Row(
      children: [
        _StatCell(label: 'Phrases', value: '$total'),
        _StatCell(label: 'Accuracy', value: '$avgAccuracy%'),
        _StatCell(
            label: 'XP earned', value: '${state.xpEarned}'),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: AppTypography.heading2
                  .copyWith(color: AppColors.textPrimary)),
          Text(label,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
