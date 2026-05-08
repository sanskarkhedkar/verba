import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';

class SavedPhrasesScreen extends ConsumerWidget {
  const SavedPhrasesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrasesAsync = ref.watch(savedPhrasesStreamProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GradientText('Saved Phrases',
                      style: AppTypography.heading2),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: phrasesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                    child: Text("Couldn't load phrases",
                        style: AppTypography.bodyM
                            .copyWith(color: AppColors.error)),
                  ),
                  data: (phrases) {
                    if (phrases.isEmpty) {
                      return Center(
                        child: Text(
                          'No saved phrases yet.\nTap the bookmark on any translation to save it here.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyM.copyWith(
                              color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: phrases.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) {
                        final p = phrases[i];
                        return GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(p.phrase,
                                        style: AppTypography.bodyM),
                                    Text(p.translation,
                                        style: AppTypography.caption
                                            .copyWith(
                                                color: AppColors
                                                    .textSecondary)),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () => ref
                                    .read(elevenLabsServiceProvider)
                                    .speak(p.phrase, p.targetLang),
                                icon: const Icon(Icons.volume_up_rounded,
                                    color: AppColors.textAccent, size: 20),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
