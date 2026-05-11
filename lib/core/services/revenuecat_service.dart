import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../constants/api_constants.dart';

class RevenueCatService extends ChangeNotifier {
  factory RevenueCatService() => _instance;

  RevenueCatService._();

  static final RevenueCatService _instance = RevenueCatService._();
  static const _premiumEntitlementIds = {'pro'};

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
    
    // Listen for updates in real-time (e.g. from background sync or other devices)
    Purchases.addCustomerInfoUpdateListener((info) {
      final oldStatus = _isPremium;
      _isPremium = _hasPremiumEntitlement(info);
      if (oldStatus != _isPremium) notifyListeners();
    });

    _initialized = true;
    await _refreshPremiumStatus();
    notifyListeners();
  }

  Future<void> _refreshPremiumStatus() async {
    if (!_initialized) return;
    try {
      final info = await Purchases.getCustomerInfo();
      final oldStatus = _isPremium;
      _isPremium = _hasPremiumEntitlement(info);
      if (oldStatus != _isPremium) notifyListeners();
    } catch (_) {}
  }

  /// Refreshes premium status from RevenueCat and returns the result.
  Future<bool> refreshPremium() async {
    await _refreshPremiumStatus();
    return _isPremium;
  }

  /// Immediately marks the user as premium without a network round-trip.
  /// Use this when the purchase result is already confirmed (PaywallResult.purchased).
  void markPremium() {
    if (!_isPremium) {
      _isPremium = true;
      notifyListeners();
    }
  }

  bool _hasPremiumEntitlement(CustomerInfo info) {
    return _premiumEntitlementIds.any((id) => info.entitlements.active.containsKey(id));
  }

  Future<void> setUserId(String uid) async {
    if (!_initialized) return;
    try {
      final result = await Purchases.logIn(uid);
      final oldStatus = _isPremium;
      _isPremium = _hasPremiumEntitlement(result.customerInfo);
      if (oldStatus != _isPremium) notifyListeners();
    } catch (_) {}
  }

  static const _targetOffering = 'worldwide-default-variation-a';

  Future<Offering?> getCurrentOffering() async {
    if (!_initialized) return null;
    try {
      final offerings = await Purchases.getOfferings();
      return offerings.all[_targetOffering] ??
          offerings.current ??
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
        final oldStatus = _isPremium;
        _isPremium = _hasPremiumEntitlement(result);
        if (oldStatus != _isPremium) notifyListeners();
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
        final oldStatus = _isPremium;
        _isPremium = _hasPremiumEntitlement(info);
        if (oldStatus != _isPremium) notifyListeners();
        return _isPremium;
      } catch (_) {}
    }
    return _isPremium;
  }
}
