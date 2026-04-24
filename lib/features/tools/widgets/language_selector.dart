import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';

/// Language pair selector row with source, swap button, and target.
class LanguageSelectorRow extends StatelessWidget {
  const LanguageSelectorRow({
    super.key,
    required this.sourceLang,
    required this.targetLang,
    required this.onSourceChanged,
    required this.onTargetChanged,
    required this.onSwap,
  });

  final String sourceLang;
  final String targetLang;
  final ValueChanged<String> onSourceChanged;
  final ValueChanged<String> onTargetChanged;
  final VoidCallback onSwap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LangChip(
            lang: sourceLang,
            onChanged: onSourceChanged,
          ),
        ),
        IconButton(
          onPressed: onSwap,
          icon: const Icon(Icons.swap_horiz_rounded,
              color: AppColors.textAccent),
        ),
        Expanded(
          child: _LangChip(
            lang: targetLang,
            onChanged: onTargetChanged,
          ),
        ),
      ],
    );
  }
}

class _LangChip extends StatelessWidget {
  const _LangChip({required this.lang, required this.onChanged});
  final String lang;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final emoji = AppConstants.languageEmojis[lang] ?? '🌍';
    return GlassCard(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      onTap: () => _showPicker(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji),
          const SizedBox(width: 6),
          Text(lang, style: AppTypography.bodyS),
          const SizedBox(width: 4),
          const Icon(Icons.expand_more_rounded,
              size: 16, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LanguagePicker(
        selected: lang,
        onSelected: (l) {
          onChanged(l);
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _LanguagePicker extends StatefulWidget {
  const _LanguagePicker({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  State<_LanguagePicker> createState() => _LanguagePickerState();
}

class _LanguagePickerState extends State<_LanguagePicker> {
  String _query = '';

  List<String> get _filtered => [
        'English',
        ...AppConstants.supportedLanguages
      ]
          .where(
              (l) => l.toLowerCase().contains(_query.toLowerCase()))
          .toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              hintText: 'Search languages...',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView.builder(
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final l = _filtered[i];
                final emoji = AppConstants.languageEmojis[l] ?? '🌍';
                final selected = l == widget.selected;
                return ListTile(
                  leading: Text(emoji,
                      style: const TextStyle(fontSize: 24)),
                  title: Text(l,
                      style: AppTypography.bodyM.copyWith(
                        color: selected
                            ? AppColors.textAccent
                            : AppColors.textPrimary,
                      )),
                  trailing: selected
                      ? const Icon(Icons.check_rounded,
                          color: AppColors.textAccent)
                      : null,
                  onTap: () => widget.onSelected(l),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
