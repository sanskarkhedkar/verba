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
            icon: Icon(Icons.mic_rounded),
            label: 'Speak',
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

class _LearnTab extends ConsumerWidget {
  const _LearnTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboarding = ref.watch(onboardingProvider);
    final name =
        onboarding.displayName.isEmpty ? 'there' : onboarding.displayName;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        GradientText('Verba', style: AppTypography.heading2),
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
        Text('Continue learning', style: AppTypography.heading3),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _MiniLessonCard(
                  title: 'Travel basics', icon: Icons.flight_rounded),
              _MiniLessonCard(
                  title: 'Restaurant phrases', icon: Icons.restaurant_rounded),
              _MiniLessonCard(
                  title: 'Pronunciation drill',
                  icon: Icons.record_voice_over_rounded),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniLessonCard extends StatelessWidget {
  const _MiniLessonCard({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: GlassCard(
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.textAccent),
            const Spacer(),
            Text(title, style: AppTypography.bodyM),
          ],
        ),
      ),
    );
  }
}
