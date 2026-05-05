import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/api_constants.dart';

class RevenueCatService {
  factory RevenueCatService() => _instance;

  RevenueCatService._();

  static final RevenueCatService _instance = RevenueCatService._();
  static const _premiumEntitlementIds = {'premium_access', 'premium'};

  bool _initialized = false;
  bool _isPremium = false;

  bool get isPremium => _isPremium;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    final apiKey = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS =>
        ApiConstants.revenueCatApiKeyIos,
      TargetPlatform.android => ApiConstants.revenueCatApiKeyAndroid,
      _ => '',
    };

    if (apiKey.isEmpty) return;

    await Purchases.setLogLevel(LogLevel.debug);
    final config = PurchasesConfiguration(apiKey);
    await Purchases.configure(config);
    _initialized = true;
    await _refreshPremiumStatus();
  }

  Future<void> _refreshPremiumStatus() async {
    if (!_initialized) return;
    try {
      final info = await Purchases.getCustomerInfo();
      _isPremium = _hasPremiumEntitlement(info);
    } catch (_) {}
  }

  bool _hasPremiumEntitlement(CustomerInfo info) {
    return _premiumEntitlementIds.any(info.entitlements.active.containsKey);
  }

  Future<void> setUserId(String uid) async {
    if (!_initialized) return;
    try {
      await Purchases.logIn(uid);
    } catch (_) {}
  }

  Future<Offering?> getCurrentOffering() async {
    if (!_initialized) return null;
    try {
      final offerings = await Purchases.getOfferings();
      // Prefer the "current" offering; fall back to first available.
      return offerings.current ??
          (offerings.all.isNotEmpty ? offerings.all.values.first : null);
    } catch (_) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getOfferings() async {
    if (_initialized) {
      try {
        final offerings = await Purchases.getOfferings();
        final current = offerings.current;
        if (current != null) {
          return current.availablePackages.map((pkg) {
            return {
              'identifier': pkg.identifier,
              'title': pkg.storeProduct.title,
              'price': pkg.storeProduct.priceString,
              'pricePerMonth': pkg.storeProduct.priceString,
              'label': pkg.packageType == PackageType.annual
                  ? 'Best Value - Save 60%'
                  : '',
              'isTrial': pkg.packageType == PackageType.annual,
              'trialLabel': pkg.packageType == PackageType.annual
                  ? '7-day free trial'
                  : '',
              '_package': pkg,
            };
          }).toList();
        }
      } catch (_) {}
    }

    // Preview fallback when SDK is not initialized or offerings fail.
    return [
      {
        'identifier': 'annual',
        'title': 'Annual',
        'price': 'Rs 4,999/year',
        'pricePerMonth': '~Rs 417/month',
        'label': 'Best Value - Save 60%',
        'isTrial': true,
        'trialLabel': '7-day free trial',
      },
      {
        'identifier': 'monthly',
        'title': 'Monthly',
        'price': 'Rs 799/month',
        'pricePerMonth': 'Rs 799/month',
        'label': '',
        'isTrial': false,
        'trialLabel': '',
      },
      {
        'identifier': 'lifetime',
        'title': 'Lifetime',
        'price': 'Rs 12,999 once',
        'pricePerMonth': 'One-time purchase',
        'label': '',
        'isTrial': false,
        'trialLabel': '',
      },
    ];
  }

  Future<bool> purchasePackage(String identifier, [Package? package]) async {
    if (_initialized && package != null) {
      try {
        final result = await Purchases.purchasePackage(package);
        _isPremium = _hasPremiumEntitlement(result);
        return _isPremium;
      } catch (e) {
        if (e is PlatformException) {
          final code = PurchasesErrorHelper.getErrorCode(e);
          if (code == PurchasesErrorCode.purchaseCancelledError) return false;
        }
        return false;
      }
    }
    return false;
  }

  Future<bool> restorePurchases() async {
    if (_initialized) {
      try {
        final info = await Purchases.restorePurchases();
        _isPremium = _hasPremiumEntitlement(info);
        return _isPremium;
      } catch (_) {}
    }
    return _isPremium;
  }
}
