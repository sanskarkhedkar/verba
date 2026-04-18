import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildStreakBanner(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Continue Learning'),
                    const SizedBox(height: 12),
                    _buildCurrentLesson(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Practice Modules'),
                    const SizedBox(height: 12),
                    _buildPracticeGrid(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Your Progress'),
                    const SizedBox(height: 12),
                    _buildProgressCard(),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      title: Row(
        children: [
          const Text(
            '🇪🇸',
            style: TextStyle(fontSize: 22),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Spanish',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text('Beginner · Level 3',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
          const Spacer(),
          // XP badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: AppColors.warning.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Text('⚡', style: TextStyle(fontSize: 14)),
                SizedBox(width: 4),
                Text('1,240 XP',
                    style: TextStyle(
                        color: AppColors.warning,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          const Color(0xFFFF6B35).withOpacity(0.15),
          const Color(0xFFFFB830).withOpacity(0.1),
        ]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFFFF6B35).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('7-day streak!',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Text('Keep it going · 10 min left today',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right_rounded,
              color: AppColors.textMuted),
        ],
      ),
    );
  }

  Widget _buildCurrentLesson() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Lesson 12',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700)),
              ),
              const Spacer(),
              const Text('🎯', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Ordering Food\nat a Restaurant',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text('16 phrases · AI conversation practice',
              style: TextStyle(
                  color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          // Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.4,
                    backgroundColor: Colors.white24,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text('40%',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Resume Lesson',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeGrid() {
    const modules = [
      ('🗣️', 'Speaking', '5 exercises', AppColors.primary),
      ('👂', 'Listening', '8 exercises', AppColors.secondary),
      ('📝', 'Vocabulary', '120 words', Color(0xFFFFB830)),
      ('✏️', 'Grammar', '6 rules', Color(0xFFFF5271)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: modules.map((m) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: m.$4.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: m.$4.withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.$1, style: const TextStyle(fontSize: 26)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.$2,
                      style: TextStyle(
                          color: m.$4,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text(m.$3,
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProgressCard() {
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
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              _ProgressStat(value: '12', label: 'Lessons\nCompleted', emoji: '📚'),
              _ProgressStat(value: '7', label: 'Day\nStreak', emoji: '🔥'),
              _ProgressStat(value: '340', label: 'Words\nLearned', emoji: '📖'),
              _ProgressStat(value: '85%', label: 'Accuracy', emoji: '🎯'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700));
  }
}

class _ProgressStat extends StatelessWidget {
  final String value;
  final String label;
  final String emoji;
  const _ProgressStat(
      {required this.value, required this.label, required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: AppColors.textMuted, fontSize: 10, height: 1.3)),
      ],
    );
  }
}
