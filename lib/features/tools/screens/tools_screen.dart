import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/verba_button.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class ToolsScreen extends ConsumerStatefulWidget {
  const ToolsScreen({super.key});

  @override
  ConsumerState<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends ConsumerState<ToolsScreen> {
  final _controller =
      TextEditingController(text: 'Good morning, how are you?');
  String _result = 'Guten Morgen, wie geht es Ihnen?';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _quickTranslate() {
    setState(() {
      _result = 'Guten Morgen, wie geht es Ihnen?'; // stub
    });
  }

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    final lang = onboarding.targetLanguage.isEmpty
        ? 'German'
        : onboarding.targetLanguage;

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

        // Quick translate inline
        Row(
          children: [
            Text('Quick Translate', style: AppTypography.heading3),
            const Spacer(),
            Text('English → $lang',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) {},
                decoration: const InputDecoration(
                  hintText: 'Type here…',
                  border: InputBorder.none,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _quickTranslate,
                  child: const Text('Translate →'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(lang,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              Text(_result, style: AppTypography.heading3),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.volume_up_rounded,
                        color: AppColors.textAccent),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.copy_rounded,
                        color: AppColors.textSecondary),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border_rounded,
                        color: AppColors.textSecondary),
                  ),
                ],
              ),
              VerbaButton(
                label: 'Practice this phrase',
                icon: Icons.record_voice_over_rounded,
                onPressed: () => context.push(RouteConstants.lesson),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Phrasebook
        Text('Saved Phrases', style: AppTypography.heading3),
        const SizedBox(height: AppSpacing.md),
        ...const [
          _PhraseRow(phrase: 'Guten Morgen', translation: 'Good morning'),
          _PhraseRow(phrase: 'Danke schön', translation: 'Thank you'),
          _PhraseRow(phrase: 'Wie geht es Ihnen?', translation: 'How are you?'),
        ],
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
  const _PhraseRow({required this.phrase, required this.translation});
  final String phrase;
  final String translation;

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
            onPressed: () {},
            icon: const Icon(Icons.volume_up_rounded,
                color: AppColors.textAccent, size: 20),
          ),
        ],
      ),
    );
  }
}
