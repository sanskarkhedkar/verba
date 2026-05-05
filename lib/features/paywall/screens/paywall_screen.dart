import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../core/services/service_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/verba_button.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _present());
  }

  Future<void> _present() async {
    if (!mounted) return;

    if (kIsWeb) {
      if (mounted) _showWebFallback();
      return;
    }

    final rcService = ref.read(revenueCatServiceProvider);
    if (!rcService.isInitialized) {
      if (mounted) _showWebFallback();
      return;
    }

    Offering? offering;
    try {
      offering = await rcService.getCurrentOffering();
    } catch (_) {}

    if (!mounted) return;

    if (offering == null) {
      _showNoOfferingDialog();
      return;
    }

    try {
      final result = await RevenueCatUI.presentPaywall(offering: offering);
      if (!mounted) return;
      if (result == PaywallResult.purchased || result == PaywallResult.restored) {
        await _syncPremium();
        if (mounted) context.pop();
      } else {
        context.pop();
      }
      return;
    } catch (_) {}

    if (mounted) context.pop();
  }

  /// Mark premium → write Firestore → force provider recompute.
  Future<void> _syncPremium() async {
    // 1. Trust PaywallResult.purchased directly; getCustomerInfo() can return
    //    stale data immediately after a native paywall purchase.
    final rcService = ref.read(revenueCatServiceProvider);
    if (rcService.isInitialized) {
      rcService.markPremium();
      rcService.refreshPremium(); // background sync, don't await
    }
    // 2. Write to Firestore (set+merge so it works even if document is missing)
    final uid = ref.read(authServiceProvider).currentUser?.uid;
    if (uid != null) {
      await ref
          .read(firestoreServiceProvider)
          .updateSubscription(uid, isPremium: true)
          .catchError((_) {});
    }
    // 3. Force premiumStatusProvider to recompute with fresh RC + Firestore data
    if (mounted) ref.invalidate(premiumStatusProvider);
  }

  void _showWebFallback() {
    // Replace this route with the web fallback screen directly.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => _FallbackScreen(
          message: 'Subscriptions are managed through the iOS or Android app.',
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  void _showNoOfferingDialog() {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSurface,
        title: Text('Could not load plans', style: AppTypography.heading3),
        content: Text(
          'No subscription plans are available right now. Check your connection and try again.',
          style: AppTypography.bodyM.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _present();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Shows briefly while presentPaywall() is loading.
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

class _FallbackScreen extends StatelessWidget {
  const _FallbackScreen({required this.message, required this.onClose});
  final String message;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.workspace_premium_rounded,
                color: AppColors.textAccent,
                size: 56,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Verba Premium', style: AppTypography.displayL),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppTypography.bodyM
                    .copyWith(color: AppColors.textSecondary),
              ),
              const Spacer(),
              VerbaButton(label: 'Close', onPressed: onClose),
            ],
          ),
        ),
      ),
    );
  }
}
