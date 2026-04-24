import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/api_constants.dart';

class RevenueCatService {
  RevenueCatService();

  bool _initialized = false;
  bool _isPremium = false;

  bool get isPremium => _isPremium;

  Future<void> initialize() async {
    final apiKey = Platform.isIOS
        ? ApiConstants.revenueCatApiKeyIos
        : ApiConstants.revenueCatApiKeyAndroid;

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
      _isPremium = info.entitlements.active.containsKey('premium');
    } catch (_) {}
  }

  Future<void> setUserId(String uid) async {
    if (!_initialized) return;
    try {
      await Purchases.logIn(uid);
    } catch (_) {}
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
                  ? 'Best Value • Save 60%'
                  : '',
              'isTrial': pkg.packageType == PackageType.annual,
              'trialLabel':
                  pkg.packageType == PackageType.annual ? '7-day free trial' : '',
              '_package': pkg,
            };
          }).toList();
        }
      } catch (_) {}
    }
    // Stub fallback when SDK is not initialized or offerings fail
    return [
      {
        'identifier': 'annual',
        'title': 'Annual',
        'price': '₹4,999/year',
        'pricePerMonth': '~₹417/month',
        'label': 'Best Value • Save 60%',
        'isTrial': true,
        'trialLabel': '7-day free trial',
      },
      {
        'identifier': 'monthly',
        'title': 'Monthly',
        'price': '₹799/month',
        'pricePerMonth': '₹799/month',
        'label': '',
        'isTrial': false,
        'trialLabel': '',
      },
      {
        'identifier': 'lifetime',
        'title': 'Lifetime',
        'price': '₹12,999 once',
        'pricePerMonth': 'One-time purchase',
        'label': '',
        'isTrial': false,
        'trialLabel': '',
      },
    ];
  }

  Future<bool> purchasePackage(String identifier,
      [Package? package]) async {
    if (_initialized && package != null) {
      try {
        final result = await Purchases.purchasePackage(package);
        _isPremium = result.entitlements.active.containsKey('premium');
        return _isPremium;
      } catch (e) {
        if (e is PurchasesErrorCode) {
          if (e == PurchasesErrorCode.purchaseCancelledError) return false;
        }
        return false;
      }
    }
    // Stub: simulate successful purchase
    _isPremium = true;
    return true;
  }

  Future<bool> restorePurchases() async {
    if (_initialized) {
      try {
        final info = await Purchases.restorePurchases();
        _isPremium = info.entitlements.active.containsKey('premium');
        return _isPremium;
      } catch (_) {}
    }
    return _isPremium;
  }
}
