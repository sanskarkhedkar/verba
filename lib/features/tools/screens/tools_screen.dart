import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phrasesAsync = ref.watch(savedPhrasesStreamProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        GradientText('Translation Tools', style: AppTypography.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Translate first. Practice next.',
          style: AppTypography.bodyM
              .copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Tool grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          children: [
            _ToolTile(
              icon: Icons.translate_rounded,
              label: 'Text',
              subtitle: 'Type & translate',
              color: AppColors.primaryStart,
              onTap: () => context.push(RouteConstants.textTranslation),
            ),
            _ToolTile(
              icon: Icons.mic_rounded,
              label: 'Voice',
              subtitle: 'Speak & translate',
              color: AppColors.primaryEnd,
              onTap: () => context.push(RouteConstants.voiceTranslation),
            ),
            _ToolTile(
              icon: Icons.photo_camera_rounded,
              label: 'Image',
              subtitle: 'Point & translate',
              color: const Color(0xFF059669),
              onTap: () => context.push(RouteConstants.imageTranslation),
            ),
            _ToolTile(
              icon: Icons.groups_rounded,
              label: 'Face-to-Face',
              subtitle: 'Two speakers',
              color: const Color(0xFFD97706),
              onTap: () => context.push(RouteConstants.faceToFace),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Phrasebook
        Row(
          children: [
            Expanded(
              child: Text('Saved Phrases', style: AppTypography.heading3),
            ),
            phrasesAsync.maybeWhen(
              data: (phrases) => phrases.length > 5
                  ? TextButton(
                      onPressed: () =>
                          context.push(RouteConstants.savedPhrases),
                      child: const Text('View all'),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Builder(builder: (_) {
          final phrases = phrasesAsync.maybeWhen(
            data: (p) => p,
            orElse: () => const <SavedPhrase>[],
          );
          if (phrasesAsync.isLoading && phrases.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (phrases.isEmpty) {
            return Text(
              'No saved phrases yet. Tap the bookmark on any translation to save it here.',
              style: AppTypography.bodyS
                  .copyWith(color: AppColors.textSecondary),
            );
          }
          final preview = phrases.take(5).toList();
          return Column(
            children: [
              for (final p in preview)
                _PhraseRow(
                  phrase: p.phrase,
                  translation: p.translation,
                  onListen: () => ref
                      .read(elevenLabsServiceProvider)
                      .speak(p.phrase, p.targetLang),
                ),
            ],
          );
        }),
      ],
    );
  }
}

class _ToolTile extends StatelessWidget {
  const _ToolTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const Spacer(),
          Text(label, style: AppTypography.bodyM),
          Text(subtitle,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PhraseRow extends StatelessWidget {
  const _PhraseRow({
    required this.phrase,
    required this.translation,
    required this.onListen,
  });
  final String phrase;
  final String translation;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phrase, style: AppTypography.bodyM),
                Text(translation,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: onListen,
            icon: const Icon(Icons.volume_up_rounded,
                color: AppColors.textAccent, size: 20),
          ),
        ],
      ),
    );
  }
}
