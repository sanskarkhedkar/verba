import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/gradient_text.dart';
import '../../../core/widgets/verba_button.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Map<String, dynamic>> _offerings = [];
  String _selectedId = 'annual';
  bool _loading = true;
  bool _purchasing = false;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    final offerings =
        await ref.read(revenueCatServiceProvider).getOfferings();
    if (mounted) {
      setState(() {
        _offerings = offerings;
        _loading = false;
      });
    }
  }

  Future<void> _purchase() async {
    setState(() => _purchasing = true);
    final offering = _offerings.firstWhere(
      (o) => o['identifier'] == _selectedId,
      orElse: () => _offerings.first,
    );

    final success = await ref
        .read(revenueCatServiceProvider)
        .purchasePackage(_selectedId, offering['_package']);

    if (success && mounted) {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null) {
        await ref
            .read(firestoreServiceProvider)
            .updateSubscription(uid, isPremium: true);
      }
      if (mounted) context.pop();
    }

    if (mounted) setState(() => _purchasing = false);
  }

  Future<void> _restore() async {
    setState(() => _purchasing = true);
    final restored =
        await ref.read(revenueCatServiceProvider).restorePurchases();
    if (restored && mounted) {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid != null) {
        await ref
            .read(firestoreServiceProvider)
            .updateSubscription(uid, isPremium: true);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Purchases restored.')),
        );
        context.pop();
      }
    }
    if (mounted) setState(() => _purchasing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            GradientText('Verba Premium', style: AppTypography.displayL),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Unlimited lessons, detailed pronunciation feedback, OCR, and conversation mode.',
              style: AppTypography.bodyM
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else
              for (final offering in _offerings)
                _PlanCard(
                  title: offering['title'] as String,
                  price: offering['price'] as String,
                  label: offering['label'] as String?,
                  highlighted: offering['identifier'] == _selectedId,
                  onTap: () =>
                      setState(() => _selectedId = offering['identifier'] as String),
                ),
            const SizedBox(height: AppSpacing.lg),
            VerbaButton(
              label: _purchasing ? 'Processing...' : 'Start premium',
              icon: Icons.workspace_premium_rounded,
              onPressed: (_loading || _purchasing) ? null : _purchase,
            ),
            const SizedBox(height: AppSpacing.sm),
            VerbaButton(
              label: 'Restore purchases',
              secondary: true,
              onPressed: (_loading || _purchasing) ? null : _restore,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'Cancel anytime. Prices shown in local currency.',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.highlighted,
    required this.onTap,
    this.label,
  });

  final String title;
  final String price;
  final String? label;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            highlighted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked,
            color: highlighted
                ? AppColors.textAccent
                : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTypography.heading3),
                    if (label != null && label!.isNotEmpty) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        label!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ],
                ),
                Text(
                  price,
                  style: AppTypography.bodyS
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
