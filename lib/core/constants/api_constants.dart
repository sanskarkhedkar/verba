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

  // Google Translate API
  static String get googleTranslateApiKey =>
      dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? '';
  static const googleTranslateUrl =
      'https://translation.googleapis.com/language/translate/v2';

  // ElevenLabs voice IDs by language (all used with eleven_multilingual_v2)
  static const voiceIds = {
    'English': 'EXAVITQu4vr4xnSDxMaL',
    'German': 'pNInz6obpgDQGcFmaJgB',
    'Spanish': 'ErXwobaYiN019PkySvjV',
    'French': 'MF3mGyEYCl7XYWbV9V6O',
    'Italian': 'AZnzlk1XvdvUeBnXmlld',
    'Japanese': 'jBpfuIE2acCJs8JXaw8Y',
    'Korean': 'XB0fDUnXU5powFXDhCwa',
    'Portuguese': 'onwK4e9ZLuTAKqWW03F9',
    'Mandarin': 'XB0fDUnXU5powFXDhCwa',
    'Arabic': 'zcAOhNBS3c14rBihAFp1',
    'Hindi': 'SOYHLrjzK2X1ezoPC6cr',
    'Turkish': 'IKne3meq5aSn9XLyUdCD',
    'Dutch': 'TxGEqnHWrfWFTfGW9XjX',
    'Polish': 'ZQe5CZNOzWyzPSCn5a3c',
    'Russian': '29vD33N1CtxCmqQRPOHJ',
    'Swedish': 'pMsXgVXv3BLzUgSXRplE',
  };

  // Timeouts
  static const apiTimeoutSeconds = 30;
  static const lessonGenerationTimeoutSeconds = 45;
}
