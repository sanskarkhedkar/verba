import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'analytics_service.dart';
import 'auth_service.dart';
import 'elevenlabs_service.dart';
import 'fcm_service.dart';
import 'firestore_service.dart';
import 'gemini_service.dart';
import 'local_notifications_service.dart';
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

final localNotificationsServiceProvider =
    Provider<LocalNotificationsService>((ref) {
  return LocalNotificationsService();
});

final revenueCatServiceProvider = ChangeNotifierProvider<RevenueCatService>((ref) {
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

/// Sticky in-session override. Set to true after any confirmed purchase/restore.
/// Stays true for the life of the app session so UI never reverts.
final premiumOverrideProvider = StateProvider<bool>((ref) => false);

/// Single source of truth for premium status.
/// Priority: session override > Firestore > RC local cache.
final premiumStatusProvider = Provider<bool>((ref) {
  if (ref.watch(premiumOverrideProvider)) return true;
  final firestorePremium = ref.watch(userProfileStreamProvider).maybeWhen(
        data: (profile) => profile?['isPremium'] as bool? ?? false,
        orElse: () => false,
      );
  final rcPremium = ref.watch(revenueCatServiceProvider).isPremium;
  return firestorePremium || rcPremium;
});

final userProfileStreamProvider =
    StreamProvider<Map<String, dynamic>?>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  // Anonymous users get a profile doc on onboarding completion, so we stream
  // it the same as for permanent accounts.
  return ref
      .read(firestoreServiceProvider)
      .getUserStream(user.uid)
      .map((snap) => snap.data())
      .handleError((Object _) => null);
});

class SavedPhrase {
  const SavedPhrase({
    required this.id,
    required this.phrase,
    required this.translation,
    required this.sourceLang,
    required this.targetLang,
  });
  final String id;
  final String phrase;
  final String translation;
  final String sourceLang;
  final String targetLang;
}

final savedPhrasesStreamProvider =
    StreamProvider<List<SavedPhrase>>((ref) {
  final user = ref.watch(authUserProvider).valueOrNull;
  if (user == null) return Stream.value(const []);
  return ref
      .read(firestoreServiceProvider)
      .getPhrases(user.uid)
      .map(
        (snap) => snap.docs
            .map((d) => SavedPhrase(
                  id: d.id,
                  phrase: (d.data()['phrase'] as String?) ?? '',
                  translation: (d.data()['translation'] as String?) ?? '',
                  sourceLang: (d.data()['sourceLang'] as String?) ?? '',
                  targetLang: (d.data()['targetLang'] as String?) ?? '',
                ))
            .toList(),
      )
      .handleError((Object _) => const <SavedPhrase>[]);
});
