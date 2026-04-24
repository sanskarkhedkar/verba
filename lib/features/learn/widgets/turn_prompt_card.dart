import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../models/lesson.dart';

/// Displays the current turn's prompt, target phrase, and phonetic guide.
class TurnPromptCard extends StatelessWidget {
  const TurnPromptCard({
    super.key,
    required this.turn,
    required this.turnIndex,
    required this.totalTurns,
    this.onListenPressed,
    this.isPlayingAudio = false,
  });

  final LessonTurn turn;
  final int turnIndex;
  final int totalTurns;
  final VoidCallback? onListenPressed;
  final bool isPlayingAudio;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phrase ${turnIndex + 1} of $totalTurns',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                turn.evaluationFocus,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            turn.prompt,
            textAlign: TextAlign.center,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            turn.targetPhrase,
            textAlign: TextAlign.center,
            style: AppTypography.displayL.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            turn.phoneticGuide,
            textAlign: TextAlign.center,
            style: AppTypography.bodyM.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: onListenPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: isPlayingAudio
                    ? AppColors.primaryStart.withValues(alpha: 0.2)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.glassBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlayingAudio
                        ? Icons.pause_rounded
                        : Icons.volume_up_rounded,
                    color: AppColors.textAccent,
                    size: 18,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    isPlayingAudio ? 'Playing...' : 'Listen',
                    style: AppTypography.bodyS.copyWith(
                      color: AppColors.textAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
