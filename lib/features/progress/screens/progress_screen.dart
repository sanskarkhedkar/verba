import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your Progress',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 20),
                _buildWeeklyChart(),
                const SizedBox(height: 24),
                _buildStreakCalendar(),
                const SizedBox(height: 24),
                _buildAchievements(),
                const SizedBox(height: 24),
                _buildSkillBreakdown(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const values = [0.6, 1.0, 0.4, 0.8, 1.0, 0.3, 0.0];
    const today = 4;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('This Week',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const Spacer(),
              const Text('62 min total',
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final isToday = i == today;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: values[i] * 72,
                          decoration: BoxDecoration(
                            gradient: isToday
                                ? AppColors.primaryGradient
                                : LinearGradient(colors: [
                                    AppColors.primary.withOpacity(0.4),
                                    AppColors.primary.withOpacity(0.2),
                                  ]),
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(6)),
                            boxShadow: isToday
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withOpacity(0.35),
                                      blurRadius: 8,
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(days[i],
                            style: TextStyle(
                                color: isToday
                                    ? AppColors.primary
                                    : AppColors.textMuted,
                                fontSize: 10,
                                fontWeight: isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text('7-Day Streak',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              Spacer(),
              Text('Best: 14 days',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final isActive = i < 7;
              final isToday = i == 6;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? (isToday
                              ? AppColors.primaryGradient
                              : const LinearGradient(colors: [
                                  Color(0xFFFF6B35),
                                  Color(0xFFFFB830)
                                ]))
                          : null,
                      color: isActive ? null : AppColors.bgSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        isActive ? '🔥' : '○',
                        style: TextStyle(
                            fontSize: isActive ? 18 : 12,
                            color: AppColors.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                      style: TextStyle(
                          color: isActive
                              ? AppColors.textPrimary
                              : AppColors.textMuted,
                          fontSize: 10)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    const achievements = [
      ('🥇', 'First Lesson', 'Completed your first lesson', true),
      ('🔥', 'Week Warrior', '7-day learning streak', true),
      ('💬', 'Chatterbox', '10 AI conversations', true),
      ('🌍', 'Globetrotter', 'Try 3 languages', false),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Achievements',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: achievements.map((a) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: a.$4
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: a.$4
                      ? AppColors.primary.withOpacity(0.3)
                      : AppColors.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Text(a.$1,
                      style: TextStyle(
                          fontSize: 22,
                          color: a.$4 ? null : const Color(0x44FFFFFF))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(a.$2,
                            style: TextStyle(
                                color: a.$4
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillBreakdown() {
    const skills = [
      ('Speaking', 0.72, AppColors.primary),
      ('Listening', 0.58, AppColors.secondary),
      ('Vocabulary', 0.85, Color(0xFFFFB830)),
      ('Grammar', 0.44, Color(0xFFFF5271)),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Skill Breakdown',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          ...skills.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(s.$1,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13)),
                        const Spacer(),
                        Text('${(s.$2 * 100).round()}%',
                            style: TextStyle(
                                color: s.$3,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: s.$2,
                        backgroundColor:
                            s.$3.withOpacity(0.15),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(s.$3),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
