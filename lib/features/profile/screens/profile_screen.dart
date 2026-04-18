import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 24),
                _buildProBanner(),
                const SizedBox(height: 24),
                _buildSettings(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 20)
                ],
              ),
              child: const Center(
                child: Text('S',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w800)),
              ),
            ),
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgDark, width: 2),
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text('Sanskar',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text('Learning Spanish · 7-day streak',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _QuickStat('12', 'Lessons'),
            _vertDiv(),
            _QuickStat('7🔥', 'Streak'),
            _vertDiv(),
            _QuickStat('1.2K', 'XP'),
            _vertDiv(),
            _QuickStat('340', 'Words'),
          ],
        ),
      ],
    );
  }

  Widget _vertDiv() =>
      Container(width: 1, height: 36, color: AppColors.borderColor);

  Widget _buildProBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.primary.withOpacity(0.2),
          AppColors.secondary.withOpacity(0.1),
        ]),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Text('⚡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verba Pro Trial',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                Text('5 days remaining in your trial',
                    style: TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('Upgrade',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    final sections = [
      (
        'LEARNING',
        [
          (Icons.language_rounded, 'My Languages', AppColors.primary),
          (Icons.trending_up_rounded, 'Daily Goal', AppColors.secondary),
          (Icons.notifications_rounded, 'Reminders', AppColors.warning),
        ]
      ),
      (
        'ACCOUNT',
        [
          (Icons.person_outline_rounded, 'Edit Profile', AppColors.primary),
          (Icons.card_membership_rounded, 'Subscription', AppColors.secondary),
          (Icons.share_rounded, 'Invite Friends', AppColors.warning),
        ]
      ),
      (
        'APP',
        [
          (Icons.dark_mode_rounded, 'Appearance', AppColors.textMuted),
          (Icons.help_outline_rounded, 'Help & Support', AppColors.textMuted),
          (Icons.logout_rounded, 'Sign Out', AppColors.error),
        ]
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sections.map((section) {
        final items = section.$2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(section.$1,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: items.asMap().entries.map((e) {
                  final item = e.value;
                  final isLast = e.key == items.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        leading: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: item.$3.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.$1, color: item.$3, size: 18),
                        ),
                        title: Text(item.$2,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        trailing: const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textMuted, size: 18),
                        onTap: () {},
                      ),
                      if (!isLast)
                        Divider(
                            height: 1, indent: 64, color: AppColors.borderColor),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String value;
  final String label;
  const _QuickStat(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
      ],
    );
  }
}
