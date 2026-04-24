import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  // Gemini
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const geminiModel = 'gemini-2.0-flash';
  static const geminiProModel = 'gemini-2.0-flash';
  static const geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';

  // ElevenLabs
  static String get elevenLabsApiKey => dotenv.env['ELEVENLABS_API_KEY'] ?? '';
  static const elevenLabsBaseUrl = 'https://api.elevenlabs.io/v1';
  static const elevenLabsTtsEndpoint = '/text-to-speech';

  // RevenueCat
  static String get revenueCatApiKeyIos =>
      dotenv.env['REVENUECAT_API_KEY_IOS'] ?? '';
  static String get revenueCatApiKeyAndroid =>
      dotenv.env['REVENUECAT_API_KEY_ANDROID'] ?? '';

  // ElevenLabs voice IDs by language
  static const voiceIds = {
    'German': 'pNInz6obpgDQGcFmaJgB',
    'Spanish': 'EXAVITQu4vr4xnSDxMaL',
    'French': 'MF3mGyEYCl7XYWbV9V6O',
    'Italian': 'AZnzlk1XvdvUeBnXmlld',
    'Japanese': 'jBpfuIE2acCJs8JXaw8Y',
    'Korean': 'XB0fDUnXU5powFXDhCwa',
    'English': 'EXAVITQu4vr4xnSDxMaL',
  };

  // Timeouts
  static const apiTimeoutSeconds = 30;
  static const lessonGenerationTimeoutSeconds = 45;
}
