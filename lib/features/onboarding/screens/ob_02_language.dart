import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';
import '../providers/onboarding_provider.dart';

class Ob02Language extends ConsumerStatefulWidget {
  const Ob02Language({super.key});
  @override
  ConsumerState<Ob02Language> createState() => _Ob02LanguageState();
}

class _Ob02LanguageState extends ConsumerState<Ob02Language> {
  String? _selected;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered {
    if (_query.isEmpty) return AppConstants.languages;
    return AppConstants.languages
        .where((l) => l['name']!.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What language do\nyou want to learn?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose the language you want to master.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 20),
            // Search
            TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v),
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search languages...',
                prefixIcon: const Icon(Icons.search_rounded,
                    color: AppColors.textMuted),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded,
                            color: AppColors.textMuted, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.4,
                ),
                itemCount: _filtered.length,
                itemBuilder: (context, i) {
                  final lang = _filtered[i];
                  final isSelected = _selected == lang['name'];
                  return GestureDetector(
                    onTap: () => setState(() => _selected = lang['name']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.borderColor,
                          width: isSelected ? 1.8 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Text(
                            lang['flag']!,
                            style: const TextStyle(fontSize: 26),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              lang['name']!,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primaryLight
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(Icons.check_circle_rounded,
                                  color: AppColors.primary, size: 18),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 28, top: 8),
              child: GradientButton(
                label: 'Continue',
                onPressed: _selected == null
                    ? null
                    : () {
                        final lang = AppConstants.languages
                            .firstWhere((l) => l['name'] == _selected);
                        ref.read(onboardingProvider.notifier).setLanguage(
                              lang['name']!,
                              lang['code']!,
                              lang['flag']!,
                            );
                        context.go('/onboarding/skill');
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
