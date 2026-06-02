import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/mascot_widget.dart';
import '../../../core/widgets/verba_button.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../models/lesson.dart';
import '../providers/lesson_provider.dart';
import '../widgets/waveform_widget.dart';

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, this.practicePhrase});

  /// When set, the lesson is a focused single-phrase drill on this text
  /// (e.g. coming from a translation screen). When null, a full AI lesson
  /// is generated as usual.
  final String? practicePhrase;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref
          .read(lessonProvider.notifier)
          .loadLesson(practicePhrase: widget.practicePhrase),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lessonProvider);
    final controller = ref.read(lessonProvider.notifier);
    final lesson = state.lesson;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: state.loading || lesson == null
              ? const Center(child: CircularProgressIndicator())
              : state.isComplete
                  ? _CompletionView(xp: state.xpEarned)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LessonHeader(
                          current: state.currentTurn + 1,
                          total: lesson.turns.length,
                          onClose: () => context.pop(),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Expanded(
                          child: ListView(
                            children: [
                              Center(
                                child: MascotWidget(
                                  size: 150,
                                  state: _mascotFor(state.micState),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              _TurnCard(
                                turn: state.activeTurn!,
                                onListen: controller.speakCurrentTurn,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              Center(
                                child: WaveformWidget(
                                  active: state.micState == MicState.listening,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              _MicButton(
                                state: state.micState,
                                onTap: state.micState == MicState.listening
                                    ? controller.stopRecording
                                    : state.micState == MicState.processing
                                        ? null
                                        : controller.startRecording,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Center(
                                child: Text(
                                  _micLabel(state.micState),
                                  style: AppTypography.bodyS.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                              if (state.feedback != null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                _FeedbackCard(
                                  feedback: state.feedback!,
                                  onRetry: controller.retry,
                                  onNext: controller.nextTurn,
                                ),
                              ],
                              if (state.errorMessage != null &&
                                  state.feedback == null) ...[
                                const SizedBox(height: AppSpacing.lg),
                                GlassCard(
                                  padding:
                                      const EdgeInsets.all(AppSpacing.lg),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Something went wrong',
                                        style: AppTypography.heading3
                                            .copyWith(
                                                color: AppColors.error),
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.sm),
                                      Text(
                                        state.errorMessage!,
                                        style: AppTypography.bodyS
                                            .copyWith(
                                                color: AppColors
                                                    .textSecondary),
                                      ),
                                      const SizedBox(
                                          height: AppSpacing.lg),
                                      VerbaButton(
                                        label: 'Try again',
                                        icon: Icons.refresh_rounded,
                                        onPressed: controller.retry,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  MascotState _mascotFor(MicState state) {
    return switch (state) {
      MicState.listening => MascotState.listening,
      MicState.processing => MascotState.thinking,
      MicState.success => MascotState.success,
      MicState.warning => MascotState.warning,
      MicState.error => MascotState.error,
      MicState.idle => MascotState.idle,
    };
  }

  String _micLabel(MicState state) {
    return switch (state) {
      MicState.idle => 'Tap to speak',
      MicState.listening => 'Tap again to stop',
      MicState.processing => 'Evaluating your pronunciation',
      MicState.success => 'Great work',
      MicState.warning => 'Almost there',
      MicState.error => 'Try again',
    };
  }
}

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.current,
    required this.total,
    required this.onClose,
  });

  final int current;
  final int total;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
            ),
            const Spacer(),
            Text('$current/$total', style: AppTypography.bodyS),
          ],
        ),
        XpProgressBar(value: current / total, height: 6),
      ],
    );
  }
}

class _TurnCard extends StatelessWidget {
  const _TurnCard({required this.turn, required this.onListen});

  final LessonTurn turn;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'AI tutor says',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            turn.prompt,
            textAlign: TextAlign.center,
            style: AppTypography.bodyM,
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            turn.targetPhrase,
            textAlign: TextAlign.center,
            style: AppTypography.displayL,
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
          TextButton.icon(
            onPressed: onListen,
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('Listen again'),
          ),
        ],
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.state, required this.onTap});

  final MicState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      MicState.success => AppColors.success,
      MicState.warning => AppColors.warning,
      MicState.error => AppColors.error,
      MicState.processing => AppColors.primaryEnd,
      MicState.listening => AppColors.primaryStart,
      MicState.idle => AppColors.bgElevated,
    };
    final icon = switch (state) {
      MicState.success => Icons.check_rounded,
      MicState.warning => Icons.tips_and_updates_rounded,
      MicState.error => Icons.refresh_rounded,
      MicState.processing => Icons.more_horiz_rounded,
      MicState.listening => Icons.stop_rounded,
      MicState.idle => Icons.mic_rounded,
    };
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 28),
            ],
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: state == MicState.processing
              ? const Padding(
                  padding: EdgeInsets.all(26),
                  child: CircularProgressIndicator(strokeWidth: 3),
                )
              : Icon(icon, size: 34),
        ),
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  const _FeedbackCard({
    required this.feedback,
    required this.onRetry,
    required this.onNext,
  });

  final SpeechFeedback feedback;
  final VoidCallback onRetry;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final color = switch (feedback.type) {
      FeedbackType.success => AppColors.success,
      FeedbackType.warning => AppColors.warning,
      FeedbackType.error => AppColors.error,
    };
    final title = switch (feedback.type) {
      FeedbackType.success => 'Perfect',
      FeedbackType.warning => 'Almost there',
      FeedbackType.error => 'Let\'s try that again',
    };
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTypography.heading2.copyWith(color: color)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            feedback.message,
            style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Accuracy ${feedback.accuracy} - Pronunciation ${feedback.pronunciation} - Fluency ${feedback.fluency}',
            style:
                AppTypography.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: VerbaButton(
                  label: 'Retry',
                  secondary: true,
                  onPressed:
                      feedback.type == FeedbackType.success ? null : onRetry,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: VerbaButton(
                  label: 'Next',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionView extends StatelessWidget {
  const _CompletionView({required this.xp});

  final int xp;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const MascotWidget(size: 180, state: MascotState.success),
        const SizedBox(height: AppSpacing.xl),
        Text('Lesson complete', style: AppTypography.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '+$xp XP earned',
          style: AppTypography.heading3.copyWith(color: AppColors.textAccent),
        ),
        const SizedBox(height: AppSpacing.xl),
        VerbaButton(
          label: 'Back to home',
          icon: Icons.home_rounded,
          onPressed: () => context.pop(),
        ),
      ],
    );
  }
}
