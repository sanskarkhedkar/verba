import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

class TranslationResult {
  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    this.detectedLanguage,
  });

  final String originalText;
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final String? detectedLanguage;
}

class TranslationService {
  const TranslationService();

  static const _langToIso = {
    'English': 'en',
    'German': 'de',
    'Spanish': 'es',
    'French': 'fr',
    'Italian': 'it',
    'Japanese': 'ja',
    'Korean': 'ko',
    'Portuguese': 'pt',
    'Mandarin': 'zh',
    'Arabic': 'ar',
    'Hindi': 'hi',
    'Turkish': 'tr',
    'Dutch': 'nl',
    'Polish': 'pl',
    'Russian': 'ru',
    'Swedish': 'sv',
  };

  String _toIso(String displayName) =>
      _langToIso[displayName] ?? displayName.toLowerCase().substring(0, 2);

  Future<TranslationResult> translateText(
    String text, {
    required String sourceLang,
    required String targetLang,
  }) async {
    final apiKey = ApiConstants.googleTranslateApiKey;
    if (apiKey.isEmpty || apiKey == 'your_google_translate_api_key_here') {
      throw Exception('Google Translate API key not configured');
    }

    final url = Uri.parse(
      '${ApiConstants.googleTranslateUrl}?key=$apiKey',
    );

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': text,
            'source': _toIso(sourceLang),
            'target': _toIso(targetLang),
            'format': 'text',
          }),
        )
        .timeout(const Duration(seconds: ApiConstants.apiTimeoutSeconds));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final translated = (data['data']?['translations'] as List?)
              ?.firstOrNull?['translatedText'] as String? ??
          text;
      return TranslationResult(
        originalText: text,
        translatedText: translated,
        sourceLang: sourceLang,
        targetLang: targetLang,
      );
    }

    throw Exception(
        'Translation failed: ${response.statusCode} ${response.body}');
  }
}
