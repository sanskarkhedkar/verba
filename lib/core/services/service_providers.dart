import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_service.dart';
import 'elevenlabs_service.dart';
import 'fcm_service.dart';
import 'firestore_service.dart';
import 'gemini_service.dart';
import 'mlkit_ocr_service.dart';
import 'revenuecat_service.dart';
import 'stt_service.dart';
import 'translation_service.dart';

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
