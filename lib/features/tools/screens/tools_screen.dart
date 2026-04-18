import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Translation Tools',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 26,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      const Text('Translate anything, instantly',
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14)),
                      const SizedBox(height: 24),
                      // Quick translate bar
                      _QuickTranslateBar(onTapTranslate: () => context.push('/tools/text')),
                      const SizedBox(height: 24),
                      const Text('Tools',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      const _ToolsGrid(),
                      const SizedBox(height: 24),
                      const Text('Phrasebook',
                          style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 14),
                      _Phrasebook(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickTranslateBar extends StatelessWidget {
  final VoidCallback onTapTranslate;
  const _QuickTranslateBar({required this.onTapTranslate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _LangChip(lang: '🇺🇸 English'),
              const SizedBox(width: 8),
              Icon(Icons.swap_horiz_rounded,
                  color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              _LangChip(lang: '🇪🇸 Spanish'),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            style: const TextStyle(
                color: AppColors.textPrimary, fontSize: 15),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Type text to translate...',
              filled: true,
              fillColor: AppColors.bgSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              suffixIcon: GestureDetector(
                onTap: onTapTranslate,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.translate_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String lang;
  const _LangChip({required this.lang});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Text(lang,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w500)),
      ),
    );
  }
}

class _ToolsGrid extends StatelessWidget {
  const _ToolsGrid();

  static const _tools = [
    (Icons.mic_rounded, '🎙️', 'Voice Translate', AppColors.primary, '/tools/voice'),
    (Icons.text_fields_rounded, '📜', 'Text Translate', AppColors.secondary, '/tools/text'),
    (Icons.camera_alt_rounded, '📸', 'Image Translate', Color(0xFFFFB830), '/tools/image'),
    (Icons.people_rounded, '👥', 'Face-to-Face', Color(0xFFFF5271), '/home/tools'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: _tools.map((t) {
        return GestureDetector(
          onTap: () => context.push(t.$5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.$4.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: t.$4.withOpacity(0.25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: t.$4.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(t.$2, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const Spacer(),
                Text(
                  t.$3,
                  style: TextStyle(
                    color: t.$4,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _Phrasebook extends StatelessWidget {
  final _phrases = const [
    ('¿Dónde está el baño?', 'Where is the bathroom?', '🚻'),
    ('¿Cuánto cuesta esto?', 'How much does this cost?', '💰'),
    ('¿Puede hablar más despacio?', 'Can you speak more slowly?', '🗣️'),
    ('Una mesa para dos, por favor.', 'A table for two, please.', '🍽️'),
    ('La cuenta, por favor.', 'The bill, please.', '🧾'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _phrases.map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              Text(p.$3, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.$1,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    Text(p.$2,
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up_rounded,
                        color: AppColors.textMuted, size: 18),
                    onPressed: () {},
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Practice',
                          style: TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
