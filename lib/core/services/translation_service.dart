import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../utils/language_detector.dart';

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

  String _normalizeIso(String iso) =>
      iso.toLowerCase().replaceAll('_', '-').split('-').first;

  bool _isoMatches(String detectedIso, String expectedLang) {
    return _normalizeIso(detectedIso) == _normalizeIso(_toIso(expectedLang));
  }

  Future<String?> detectLanguage(String text) async {
    if (text.trim().isEmpty) return null;

    final apiKey = ApiConstants.googleTranslateApiKey;
    if (apiKey.isEmpty || apiKey == 'your_google_translate_api_key_here') {
      return null;
    }

    final url = Uri.parse(
      '${ApiConstants.googleTranslateUrl}/detect?key=$apiKey',
    );

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'q': text.trim()}),
        )
        .timeout(const Duration(seconds: ApiConstants.apiTimeoutSeconds));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final detections = data['data']?['detections'] as List?;
    final firstGroup = detections?.firstOrNull as List?;
    final detection = firstGroup?.firstOrNull as Map<String, dynamic>?;
    return detection?['language'] as String?;
  }

  Future<bool> matchesInputLanguage(String text, String sourceLang) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return true;

    try {
      final detectedIso = await detectLanguage(trimmed);
      if (detectedIso != null) return _isoMatches(detectedIso, sourceLang);
    } on Object {
      // Fall through to script-based detection.
    }

    return LanguageDetector.matchesLanguage(trimmed, sourceLang);
  }

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
      final translations = data['data']?['translations'] as List?;
      final firstTranslation =
          translations?.firstOrNull as Map<String, dynamic>?;
      final translated = firstTranslation?['translatedText'] as String? ?? text;
      final detectedLanguage =
          firstTranslation?['detectedSourceLanguage'] as String?;
      return TranslationResult(
        originalText: text,
        translatedText: translated,
        sourceLang: sourceLang,
        targetLang: targetLang,
        detectedLanguage: detectedLanguage,
      );
    }

    throw Exception(
        'Translation failed: ${response.statusCode} ${response.body}');
  }
}
