# Premium Features Documentation

This document explains how premium entitlements are managed in this application and how to test or unlock them.

## Entitlement Management
Premium features in this app are managed via RevenueCat. The primary entitlement identifier used is `pro`.

The premium status is checked through the `RevenueCatService` (located in `lib/core/services/revenuecat_service.dart`).

## Unlocking Premium Features for Testing
To unlock all premium features without an actual subscription (for testing purposes or generating an unlocked APK), you can modify the `_hasPremiumEntitlement` method in `RevenueCatService` to unconditionally return `true`.

```dart
  bool _hasPremiumEntitlement(CustomerInfo info) {
    // Original implementation:
    // return _premiumEntitlementIds.any((id) => info.entitlements.active.containsKey(id));
    
    // Unlocked implementation:
    return true;
  }
```

This bypasses the RevenueCat entitlement check and exposes `isPremium` as `true` to the rest of the application via Riverpod providers (`premiumStatusProvider` / `revenueCatServiceProvider`).

## Reverting Changes
Make sure to revert `_hasPremiumEntitlement` back to its original implementation before building a production release meant for the app stores, so that proper subscription validation takes place.
