import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../shared/widgets/onboarding_scaffold.dart';

class Ob15Paywall extends StatefulWidget {
  const Ob15Paywall({super.key});
  @override
  State<Ob15Paywall> createState() => _Ob15PaywallState();
}

class _Ob15PaywallState extends State<Ob15Paywall> {
  bool _isAnnual = true;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      step: 15,
      showBack: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          children: [
            // Hero badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFFFB830).withOpacity(0.2),
                  AppColors.primary.withOpacity(0.15),
                ]),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: const Color(0xFFFFB830).withOpacity(0.5)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🎁', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 8),
                  Text('7-Day Free Trial',
                      style: TextStyle(
                        color: Color(0xFFFFD066),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Unlock full access\nto Verba Pro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 20),
            // Features
            ..._features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child:
                              Text(f.$1, style: const TextStyle(fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(f.$2,
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ),
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 18),
                    ],
                  ),
                )),
            const SizedBox(height: 20),
            // Toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Row(
                children: [
                  _PlanTab(
                    label: 'Monthly',
                    price: '\$14.99/mo',
                    isSelected: !_isAnnual,
                    onTap: () => setState(() => _isAnnual = false),
                    badge: null,
                  ),
                  _PlanTab(
                    label: 'Annual',
                    price: '\$7.99/mo',
                    isSelected: _isAnnual,
                    onTap: () => setState(() => _isAnnual = true),
                    badge: 'SAVE 47%',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Price display
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _isAnnual
                  ? _PriceDisplay(
                      key: const ValueKey('annual'),
                      price: '\$95.88/year',
                      sub: 'Billed annually · \$7.99/mo',
                      original: '\$179.88',
                    )
                  : _PriceDisplay(
                      key: const ValueKey('monthly'),
                      price: '\$14.99/month',
                      sub: 'Billed monthly',
                    ),
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Start 7-Day Free Trial',
              onPressed: () => context.go('/home/learn'),
              icon: const Text('⚡', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 10),
            const Text(
              'Cancel anytime · No charge for 7 days',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () => context.go('/home/learn'),
              child: const Text(
                'Continue with free plan →',
                style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _features = [
    ('🤖', 'Unlimited AI speaking practice'),
    ('📚', 'Full lesson library (500+ lessons)'),
    ('🎙️', 'Advanced pronunciation feedback'),
    ('🌍', 'All 50+ languages unlocked'),
    ('📊', 'Detailed progress analytics'),
    ('🔄', 'Offline mode'),
  ];
}

class _PlanTab extends StatelessWidget {
  final String label;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  const _PlanTab({
    required this.label,
    required this.price,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Column(
            children: [
              if (badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB830),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badge!,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 4),
              ],
              Text(label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
              Text(price,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : AppColors.textMuted,
                    fontSize: 11,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceDisplay extends StatelessWidget {
  final String price;
  final String sub;
  final String? original;

  const _PriceDisplay({
    super.key,
    required this.price,
    required this.sub,
    this.original,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(price,
                  style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800)),
              if (original != null)
                Text(original!,
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough)),
              Text(sub,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
