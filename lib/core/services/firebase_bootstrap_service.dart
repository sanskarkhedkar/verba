import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseBootstrapService {
  const FirebaseBootstrapService();

  Future<void> configure() async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setDefaults(const {
      'gemini_model_version': 'gemini-2.0-flash',
      'paywall_variant': 'A',
      'free_lesson_limit': 3,
      'onboarding_version': 'v1',
      'elevenlabs_enabled': true,
      'ocr_enabled': true,
      'bridge_cta_enabled': true,
      'max_retry_count': 3,
      'slow_playback_speed': 0.7,
    });
  }
}
