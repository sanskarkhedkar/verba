import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../services/app_config.dart';
import '../../../services/translation_service.dart';
import '../../../shared/widgets/gradient_button.dart';

const _languages = [
  ('auto', 'Auto'),
  ('en', 'English'),
  ('es', 'Spanish'),
  ('fr', 'French'),
  ('de', 'German'),
  ('it', 'Italian'),
  ('pt', 'Portuguese'),
  ('ja', 'Japanese'),
  ('ko', 'Korean'),
];

/// Text translation utility screen powered by TranslationService.
class TextTranslateScreen extends ConsumerStatefulWidget {
  const TextTranslateScreen({super.key});

  @override
  ConsumerState<TextTranslateScreen> createState() => _TextTranslateScreenState();
}

class _TextTranslateScreenState extends ConsumerState<TextTranslateScreen> {
  final _inputCtrl = TextEditingController();
  TranslationResult? _result;
  bool _loading = false;
  String _sourceLang = 'auto';
  String _targetLang = 'es';

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  Future<void> _translate() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type something to translate.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    final service = ref.read(translationServiceProvider);
    try {
      final res = await service.translate(
        text: text,
        targetLang: _targetLang,
        sourceLang: _sourceLang,
      );
      setState(() => _result = res);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Text Translate',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _LanguageRow(
                  sourceLang: _sourceLang,
                  targetLang: _targetLang,
                  onSwap: () => setState(() {
                    final tmp = _sourceLang;
                    _sourceLang = _targetLang;
                    _targetLang = tmp == 'auto' ? 'en' : tmp;
                  }),
                  onChanged: (src, tgt) => setState(() {
                    _sourceLang = src;
                    _targetLang = tgt;
                  }),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: _inputCtrl,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                          ),
                          maxLines: 6,
                          decoration: const InputDecoration(
                            hintText: 'Type text to translate...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                        const Spacer(),
                        GradientButton(
                          label: 'Translate',
                          onPressed: _loading ? null : _translate,
                          loading: _loading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _result == null
                    ? const SizedBox.shrink()
                    : _TranslationCard(result: _result!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TranslationCard extends StatelessWidget {
  final TranslationResult result;
  const _TranslationCard({required this.result});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.originalText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              result.translatedText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Detected: ${result.detectedSourceLang.toUpperCase()}  →  ${result.targetLang.toUpperCase()}',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  final String sourceLang;
  final String targetLang;
  final VoidCallback onSwap;
  final void Function(String src, String tgt) onChanged;

  const _LanguageRow({
    required this.sourceLang,
    required this.targetLang,
    required this.onSwap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: sourceLang,
              dropdownColor: AppColors.bgSurface,
              iconEnabledColor: AppColors.textPrimary,
              decoration: const InputDecoration(
                labelText: 'From',
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              items: _buildItems(true),
              onChanged: (v) {
                if (v != null) onChanged(v, targetLang);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded,
                color: AppColors.primary),
            onPressed: onSwap,
          ),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: targetLang,
              dropdownColor: AppColors.bgSurface,
              iconEnabledColor: AppColors.textPrimary,
              decoration: const InputDecoration(
                labelText: 'To',
              ),
              style: const TextStyle(color: AppColors.textPrimary),
              items: _buildItems(false),
              onChanged: (v) {
                if (v != null) onChanged(sourceLang, v);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildItems(bool includeAuto) {
    final langs = _languages.where((l) => includeAuto || l.$1 != 'auto');
    return langs
        .map((l) => DropdownMenuItem(
              value: l.$1,
              child: Text(l.$2,
                  style: const TextStyle(color: AppColors.textPrimary)),
            ))
        .toList();
  }
}
