import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/services/translation_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/verba_button.dart';
import '../widgets/language_selector.dart';

final _textTranslationProvider =
    StateNotifierProvider.autoDispose<_TextTranslationController,
        _TextTranslationState>((ref) {
  return _TextTranslationController(ref);
});

class _TextTranslationState {
  const _TextTranslationState({
    this.sourceLang = 'English',
    this.targetLang = 'German',
    this.result,
    this.isLoading = false,
    this.error,
  });
  final String sourceLang;
  final String targetLang;
  final TranslationResult? result;
  final bool isLoading;
  final String? error;

  _TextTranslationState copyWith({
    String? sourceLang,
    String? targetLang,
    TranslationResult? result,
    bool? isLoading,
    String? error,
    bool clearResult = false,
    bool clearError = false,
  }) =>
      _TextTranslationState(
        sourceLang: sourceLang ?? this.sourceLang,
        targetLang: targetLang ?? this.targetLang,
        result: clearResult ? null : result ?? this.result,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class _TextTranslationController
    extends StateNotifier<_TextTranslationState> {
  _TextTranslationController(this.ref) : super(const _TextTranslationState());
  final Ref ref;

  void setSourceLang(String lang) =>
      state = state.copyWith(sourceLang: lang, clearResult: true);

  void setTargetLang(String lang) =>
      state = state.copyWith(targetLang: lang, clearResult: true);

  void swap() => state = state.copyWith(
        sourceLang: state.targetLang,
        targetLang: state.sourceLang,
        clearResult: true,
      );

  Future<void> translate(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await ref.read(translationServiceProvider).translateText(
            text.trim(),
            sourceLang: state.sourceLang,
            targetLang: state.targetLang,
          );
      state = state.copyWith(result: result, isLoading: false);
      ref.read(analyticsServiceProvider).logTranslation(
            'text', state.sourceLang, state.targetLang);
    } on Exception catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(), clearResult: true);
    }
  }
}

class TextTranslationScreen extends ConsumerStatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  ConsumerState<TextTranslationScreen> createState() =>
      _TextTranslationScreenState();
}

class _TextTranslationScreenState
    extends ConsumerState<TextTranslationScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSameLangDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Same language selected', style: AppTypography.heading3),
        content: Text(
          'Source and target languages are the same. Please choose a different language for either the source or the target.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_textTranslationProvider);
    final controller = ref.read(_textTranslationProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text('Text Translation',
                        style: AppTypography.heading3,
                        textAlign: TextAlign.center),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            // Language selector row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: LanguageSelectorRow(
                sourceLang: state.sourceLang,
                targetLang: state.targetLang,
                onSourceChanged: controller.setSourceLang,
                onTargetChanged: controller.setTargetLang,
                onSwap: controller.swap,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  // Input card
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.sourceLang,
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _controller,
                          autofocus: true,
                          minLines: 3,
                          maxLines: 6,
                          style: AppTypography.bodyL,
                          decoration: const InputDecoration(
                            hintText: 'Type to translate...',
                            border: InputBorder.none,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              if (state.sourceLang == state.targetLang) {
                                _showSameLangDialog();
                                return;
                              }
                              controller.translate(_controller.text);
                            },
                            child: const Text('Translate →'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Result card
                  if (state.isLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(AppSpacing.xl),
                      child: CircularProgressIndicator(),
                    ))
                  else if (state.result != null)
                    _ResultCard(
                      result: state.result!,
                      onPractice: () =>
                          context.push(RouteConstants.lesson),
                      onListen: () => ref
                          .read(elevenLabsServiceProvider)
                          .speak(state.result!.translatedText,
                              state.result!.targetLang),
                    )
                  else if (state.error != null)
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Text('Error: ${state.error}',
                          style: AppTypography.bodyM
                              .copyWith(color: AppColors.error)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.result,
    required this.onPractice,
    required this.onListen,
  });
  final TranslationResult result;
  final VoidCallback onPractice;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(result.targetLang,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.sm),
          Text(result.translatedText, style: AppTypography.heading2),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              IconButton(
                tooltip: 'Listen',
                onPressed: onListen,
                icon: const Icon(Icons.volume_up_rounded,
                    color: AppColors.textAccent),
              ),
              IconButton(
                tooltip: 'Copy',
                onPressed: () {
                  Clipboard.setData(
                      ClipboardData(text: result.translatedText));
                },
                icon: const Icon(Icons.copy_rounded,
                    color: AppColors.textSecondary),
              ),
              IconButton(
                tooltip: 'Save phrase',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved to phrase book')),
                  );
                },
                icon: const Icon(Icons.bookmark_border_rounded,
                    color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          VerbaButton(
            label: 'Practice this phrase',
            icon: Icons.record_voice_over_rounded,
            onPressed: onPractice,
          ),
        ],
      ),
    );
  }
}
