import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/verba_button.dart';
import '../models/lesson.dart';

/// Animated feedback overlay shown after each speaking attempt.
class FeedbackOverlay extends StatefulWidget {
  const FeedbackOverlay({
    super.key,
    required this.feedback,
    required this.onRetry,
    required this.onNext,
    this.isLastTurn = false,
  });

  final SpeechFeedback feedback;
  final VoidCallback onRetry;
  final VoidCallback onNext;
  final bool isLastTurn;

  @override
  State<FeedbackOverlay> createState() => _FeedbackOverlayState();
}

class _FeedbackOverlayState extends State<FeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = switch (widget.feedback.type) {
      FeedbackType.success => AppColors.success,
      FeedbackType.warning => AppColors.warning,
      FeedbackType.error => AppColors.error,
    };

    final title = switch (widget.feedback.type) {
      FeedbackType.success => '🎉 Perfect!',
      FeedbackType.warning => '💪 Almost there',
      FeedbackType.error => '🔄 Try again',
    };

    final xpLabel = switch (widget.feedback.type) {
      FeedbackType.success => '+15 XP',
      FeedbackType.warning => '+7 XP',
      FeedbackType.error => '',
    };

    return SlideTransition(
      position: _slideAnim,
      child: FadeTransition(
        opacity: _fadeAnim,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: AppTypography.heading2.copyWith(color: color),
                  ),
                  const Spacer(),
                  if (xpLabel.isNotEmpty)
                    _XpBadge(label: xpLabel, color: color),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                widget.feedback.message,
                style: AppTypography.bodyM.copyWith(
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _ScorePill(
                      label: 'Accuracy',
                      value: widget.feedback.accuracy),
                  const SizedBox(width: AppSpacing.sm),
                  _ScorePill(
                      label: 'Pronounce',
                      value: widget.feedback.pronunciation),
                  const SizedBox(width: AppSpacing.sm),
                  _ScorePill(
                      label: 'Fluency',
                      value: widget.feedback.fluency),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  if (widget.feedback.type != FeedbackType.success) ...[
                    Expanded(
                      child: VerbaButton(
                        label: 'Retry',
                        secondary: true,
                        onPressed: widget.onRetry,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: VerbaButton(
                      label: widget.isLastTurn ? 'Finish' : 'Next',
                      icon: widget.isLastTurn
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                      onPressed: widget.onNext,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _XpBadge extends StatelessWidget {
  const _XpBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});
  final String label;
  final int value;

  Color get _color {
    if (value >= 85) return AppColors.success;
    if (value >= 65) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              '$value%',
              style: AppTypography.bodyS
                  .copyWith(color: _color, fontWeight: FontWeight.w700),
            ),
            Text(
              label,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
