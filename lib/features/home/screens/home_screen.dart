import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/route_constants.dart';
import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/verba_button.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../../profile/screens/profile_screen.dart';
import '../../speak/screens/speak_home_screen.dart';
import '../../tools/screens/tools_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _LearnTab(),
      const SpeakHomeScreen(),
      const ToolsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_tab]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: (value) => setState(() => _tab = value),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public_rounded),
            label: 'Tools',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

const _langCode = {
  'English': 'EN',
  'German': 'DE',
  'Spanish': 'ES',
  'French': 'FR',
  'Italian': 'IT',
  'Japanese': 'JA',
  'Korean': 'KO',
  'Portuguese': 'PT',
  'Mandarin': 'ZH',
  'Arabic': 'AR',
  'Hindi': 'HI',
  'Turkish': 'TR',
  'Dutch': 'NL',
  'Polish': 'PL',
  'Russian': 'RU',
  'Swedish': 'SV',
};

class _LearnTab extends ConsumerWidget {
  const _LearnTab();

  void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentLang) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.bgElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListView(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xl),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Text('Learning language', style: AppTypography.heading3),
          ),
          ...AppConstants.supportedLanguages.map((lang) {
            final emoji = AppConstants.languageEmojis[lang] ?? '🌐';
            final code = _langCode[lang] ?? lang.substring(0, 2).toUpperCase();
            final isSelected = lang == currentLang;
            return ListTile(
              leading: Text(emoji, style: const TextStyle(fontSize: 24)),
              title: Text(lang, style: AppTypography.bodyM),
              trailing: Text(
                code,
                style: AppTypography.bodyS.copyWith(
                  color: isSelected
                      ? AppColors.textAccent
                      : AppColors.textSecondary,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedTileColor: AppColors.glassBorder.withValues(alpha: 0.3),
              onTap: () {
                ref
                    .read(onboardingProvider.notifier)
                    .setTargetLanguage(lang);
                ref.read(analyticsServiceProvider).logLanguageChanged(lang);
                Navigator.pop(ctx);
              },
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final name =
        onboarding.displayName.isEmpty ? 'there' : onboarding.displayName;
    final currentLang = onboarding.targetLanguage.isEmpty
        ? 'German'
        : onboarding.targetLanguage;
    final emoji = AppConstants.languageEmojis[currentLang] ?? '🌐';
    final code = _langCode[currentLang] ?? currentLang.substring(0, 2).toUpperCase();
    final isPremium = ref.watch(premiumStatusProvider);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => _showLanguagePicker(context, ref, currentLang),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      code,
                      style: AppTypography.bodyS.copyWith(
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 14, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            const Spacer(),
            GradientText('Verba', style: AppTypography.heading2),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Good evening, $name', style: AppTypography.heading1),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Your ${onboarding.targetLanguage} speaking plan is ready.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.local_fire_department_rounded,
                      color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text('1 day streak', style: AppTypography.heading3),
                  const Spacer(),
                  Text('75 XP', style: AppTypography.bodyS),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const XpProgressBar(value: 0.15),
              const SizedBox(height: AppSpacing.sm),
              Text(
                '425 XP to A2',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        GlassCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s spoken lesson', style: AppTypography.heading2),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Three quick turns built from your onboarding goal.',
                style: AppTypography.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              VerbaButton(
                label: 'Start lesson',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.push(RouteConstants.lesson),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Learn more', style: AppTypography.heading3),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _MiniLessonCard(
                title: 'Travel basics',
                icon: Icons.flight_rounded,
                locked: !isPremium,
                onTap: () => isPremium
                    ? context.push(RouteConstants.lesson)
                    : context.push(RouteConstants.paywall),
              ),
              _MiniLessonCard(
                title: 'Restaurant phrases',
                icon: Icons.restaurant_rounded,
                locked: !isPremium,
                onTap: () => isPremium
                    ? context.push(RouteConstants.lesson)
                    : context.push(RouteConstants.paywall),
              ),
              _MiniLessonCard(
                title: 'Pronunciation drill',
                icon: Icons.record_voice_over_rounded,
                locked: !isPremium,
                onTap: () => isPremium
                    ? context.push(RouteConstants.lesson)
                    : context.push(RouteConstants.paywall),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniLessonCard extends StatelessWidget {
  const _MiniLessonCard({
    required this.title,
    required this.icon,
    required this.onTap,
    this.locked = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: GlassCard(
        margin: const EdgeInsets.only(right: AppSpacing.md),
        onTap: onTap,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon,
                    color: locked
                        ? AppColors.textSecondary
                        : AppColors.textAccent),
                const Spacer(),
                Text(title,
                    style: AppTypography.bodyM.copyWith(
                      color: locked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    )),
              ],
            ),
            if (locked)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.lock_rounded,
                    size: 16, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
