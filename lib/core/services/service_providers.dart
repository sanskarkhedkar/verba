import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'auth_service.dart';
import 'elevenlabs_service.dart';
import 'fcm_service.dart';
import 'firestore_service.dart';
import 'gemini_service.dart';
import 'mlkit_ocr_service.dart';
import 'revenuecat_service.dart';
import 'stt_service.dart';
import 'translation_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return const AnalyticsService();
});

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return const GeminiService();
});


final elevenLabsServiceProvider = Provider<ElevenLabsService>((ref) {
  final service = ElevenLabsService();
  ref.onDispose(service.dispose);
  return service;
});

final sttServiceProvider = Provider<SttService>((ref) {
  return SttService(ref.read(geminiServiceProvider));
});

final translationServiceProvider = Provider<TranslationService>((ref) {
  return const TranslationService();
});

final authServiceProvider = Provider<AuthService>((ref) {
  return const AuthService();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return const FirestoreService();
});

final fcmServiceProvider = Provider<FcmService>((ref) {
  return const FcmService();
});

final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

final mlkitOcrServiceProvider = Provider<MlKitOcrService>((ref) {
  final service = MlKitOcrService();
  ref.onDispose(service.dispose);
  return service;
});

final authUserProvider = StreamProvider<User?>((ref) {
  return ref.read(authServiceProvider).authStateChanges;
});

/// Single source of truth for premium status.
/// Returns true if Firestore says premium OR RevenueCat local cache says premium.
final premiumStatusProvider = Provider<bool>((ref) {
  final firestorePremium = ref.watch(userProfileStreamProvider).maybeWhen(
        data: (profile) => profile?['isPremium'] as bool? ?? false,
        orElse: () => false,
      );
  final rcPremium = ref.read(revenueCatServiceProvider).isPremium;
  return firestorePremium || rcPremium;
});

final userProfileStreamProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null || user.isAnonymous) return const Stream.empty();
  return ref
      .read(firestoreServiceProvider)
      .getUserStream(user.uid)
      .map((snap) => snap.data());
});
