import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'elevenlabs_service.dart';
import 'openai_service.dart';
import 'translation_service.dart';

/// Central service locator — all API keys flow through here.
/// Replace placeholder keys with real ones before shipping.
class AppConfig {
  AppConfig._();

  // ── API Keys (replace with real keys) ─────────────────────────────────────
  static String elevenLabsApiKey = const String.fromEnvironment(
    'ELEVENLABS_API_KEY',
    defaultValue: '', // Set via --dart-define or .env
  );

  static String openAiApiKey = const String.fromEnvironment(
    'OPENAI_API_KEY',
    defaultValue: '',
  );

  static String googleTranslateApiKey = const String.fromEnvironment(
    'GOOGLE_TRANSLATE_API_KEY',
    defaultValue: '',
  );
}

// ── Service Providers ─────────────────────────────────────────────────────

final elevenLabsServiceProvider = Provider<ElevenLabsService>((ref) {
  return ElevenLabsService(apiKey: AppConfig.elevenLabsApiKey);
});

final openAIServiceProvider = Provider<OpenAIService>((ref) {
  return OpenAIService(apiKey: AppConfig.openAiApiKey);
});

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService(apiKey: AppConfig.googleTranslateApiKey);
});

// ── Audio Player Provider ──────────────────────────────────────────────────

/// Plays TTS audio bytes returned from ElevenLabs.
final audioPlayerProvider = Provider<VerbaAudioPlayer>((ref) {
  return VerbaAudioPlayer();
});

class VerbaAudioPlayer {
  // just_audio integration — plays raw bytes via temp file or memory source
  Future<void> playBytes(Uint8List bytes) async {
    // TODO: integrate just_audio StreamAudioSource
    // For now this is a stub that logs the byte length
    // ignore: avoid_print
    print('[VerbaAudioPlayer] Playing ${bytes.length} bytes of audio');
  }

  Future<void> stop() async {}
  Future<void> pause() async {}
}
