import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class Ob07ConfidenceGraph extends StatefulWidget {
  const Ob07ConfidenceGraph({super.key});
  @override
  State<Ob07ConfidenceGraph> createState() => _Ob07ConfidenceGraphState();
}

class _Ob07ConfidenceGraphState extends State<Ob07ConfidenceGraph>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _grow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..forward();
    _grow = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Learners using Verba\noutperform others',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Our AI-driven approach delivers measurably better results.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 36),
            // Animated bar chart
            AnimatedBuilder(
              animation: _grow,
              builder: (_, __) => _buildChart(_grow.value),
            ),
            const SizedBox(height: 32),
            // Key stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    value: '3x',
                    label: 'Faster fluency',
                    icon: '🚀',
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    value: '89%',
                    label: 'Retention rate',
                    icon: '🧠',
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: GradientButton(
                label: 'That\'s motivating!',
                onPressed: () => context.go('/onboarding/speed'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(double progress) {
    const bars = [
      {'label': 'Traditional\nApps', 'value': 0.35, 'color': 0xFF4A4A6A},
      {'label': 'Textbooks', 'value': 0.45, 'color': 0xFF5A4A8A},
      {'label': 'Tutors', 'value': 0.62, 'color': 0xFF6A5AAA},
      {'label': 'Verba\nAI', 'value': 0.92, 'isHighlight': true, 'color': 0xFF7C5CFC},
    ];

    return Container(
      height: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Confidence Score after 3 months',
            style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: bars.map((bar) {
                final value = (bar['value'] as double) * progress;
                final isHighlight = bar['isHighlight'] == true;
                final color = Color(bar['color'] as int);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isHighlight)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${((bar['value'] as double) * 100).round()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration.zero,
                          height: value * 120,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8)),
                            boxShadow: isHighlight
                                ? [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withOpacity(0.4),
                                      blurRadius: 12,
                                      offset: const Offset(0, -4),
                                    )
                                  ]
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bar['label'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isHighlight
                                ? AppColors.primaryLight
                                : AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: isHighlight
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String icon;
  final Color color;

  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: color,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11)),
            ],
          )
        ],
      ),
    );
  }
}
