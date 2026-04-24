import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/verba_button.dart';

class SpeakHomeScreen extends StatefulWidget {
  const SpeakHomeScreen({super.key});

  @override
  State<SpeakHomeScreen> createState() => _SpeakHomeScreenState();
}

class _SpeakHomeScreenState extends State<SpeakHomeScreen> {
  final _practiceController = TextEditingController();
  bool _showPhraseInput = false;

  @override
  void dispose() {
    _practiceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        GradientText('Speaking Lab', style: AppTypography.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Practice aloud with real-time AI feedback.',
          style: AppTypography.bodyM
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Quick practice card
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [AppColors.primaryStart, AppColors.primaryEnd]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.mic_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quick Practice',
                            style: AppTypography.heading3),
                        Text('3-min AI speaking drill',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              VerbaButton(
                label: 'Start practice',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.push(RouteConstants.lesson),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Custom phrase practice
        Text('Or Practice a Phrase', style: AppTypography.heading3),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              TextField(
                controller: _practiceController,
                onChanged: (_) => setState(() => _showPhraseInput =
                    _practiceController.text.trim().isNotEmpty),
                decoration: const InputDecoration(
                  hintText: 'Type or paste any phrase…',
                  border: InputBorder.none,
                ),
              ),
              if (_showPhraseInput)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () =>
                        context.push(RouteConstants.lesson),
                    icon: const Icon(Icons.mic_rounded, size: 16),
                    label: const Text('Practice this phrase'),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Conversation mode (premium locked)
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.chat_bubble_rounded,
                        color: AppColors.textTertiary, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('AI Conversation',
                                style: AppTypography.heading3),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.textAccent
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('Premium',
                                  style: AppTypography.caption.copyWith(
                                      color: AppColors.textAccent)),
                            ),
                          ],
                        ),
                        Text('Multi-turn speaking simulation',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              VerbaButton(
                label: 'Try conversation mode',
                icon: Icons.arrow_forward_rounded,
                secondary: true,
                onPressed: () =>
                    context.push(RouteConstants.conversation),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Stats
        Text('Your Speaking Stats', style: AppTypography.heading3),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              _StatRow(
                  label: 'Accuracy average',
                  value: '82%',
                  icon: Icons.gps_fixed_rounded),
              const SizedBox(height: AppSpacing.md),
              _StatRow(
                  label: 'Best streak',
                  value: '1 day',
                  icon: Icons.local_fire_department_rounded),
              const SizedBox(height: AppSpacing.md),
              _StatRow(
                  label: 'Total practice',
                  value: '8 min',
                  icon: Icons.timer_rounded),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(
      {required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(label,
              style: AppTypography.bodyM
                  .copyWith(color: AppColors.textSecondary)),
        ),
        Text(value,
            style: AppTypography.bodyM
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
