import 'package:dio/dio.dart';

/// Translation service — uses Google Translate REST API (free tier compatible).
/// Swap for DeepL by changing [_provider] and the endpoint logic.
class TranslationService {
  // Use 'google' or 'deepl'
  static const String _provider = 'google';

  static const String _googleUrl =
      'https://translation.googleapis.com/language/translate/v2';
  static const String _deeplUrl =
      'https://api-free.deepl.com/v2/translate';

  late final Dio _dio;
  String _apiKey;

  TranslationService({required String apiKey}) : _apiKey = apiKey {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  void updateApiKey(String key) => _apiKey = key;

  /// Translate [text] from [sourceLang] to [targetLang].
  /// Pass 'auto' for [sourceLang] to auto-detect.
  Future<TranslationResult> translate({
    required String text,
    required String targetLang,
    String sourceLang = 'auto',
  }) async {
    if (_apiKey.isEmpty || _apiKey == 'YOUR_KEY') {
      return TranslationResult.mock(text: text, targetLang: targetLang);
    }

    try {
      if (_provider == 'google') {
        return await _googleTranslate(text, sourceLang, targetLang);
      } else {
        return await _deeplTranslate(text, sourceLang, targetLang);
      }
    } on DioException catch (e) {
      // Fallback to mock on error so UI doesn't break
      return TranslationResult.mock(text: text, targetLang: targetLang);
    }
  }

  Future<TranslationResult> _googleTranslate(
      String text, String source, String target) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _googleUrl,
      queryParameters: {'key': _apiKey},
      data: {
        'q': text,
        'target': target,
        if (source != 'auto') 'source': source,
        'format': 'text',
      },
    );
    final data = response.data!['data']['translations'][0];
    return TranslationResult(
      originalText: text,
      translatedText: data['translatedText'] as String,
      detectedSourceLang:
          data['detectedSourceLanguage'] as String? ?? source,
      targetLang: target,
    );
  }

  Future<TranslationResult> _deeplTranslate(
      String text, String source, String target) async {
    final response = await _dio.post<Map<String, dynamic>>(
      _deeplUrl,
      data: {
        'text': [text],
        'target_lang': target.toUpperCase(),
        if (source != 'auto') 'source_lang': source.toUpperCase(),
        'auth_key': _apiKey,
      },
      options: Options(contentType: 'application/x-www-form-urlencoded'),
    );
    final translation = response.data!['translations'][0];
    return TranslationResult(
      originalText: text,
      translatedText: translation['text'] as String,
      detectedSourceLang:
          (translation['detected_source_language'] as String?)?.toLowerCase() ??
              source,
      targetLang: target,
    );
  }

  /// Detect the language of [text].
  Future<String> detectLanguage(String text) async {
    if (_apiKey.isEmpty) return 'en';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_googleUrl/detect',
        queryParameters: {'key': _apiKey},
        data: {'q': text},
      );
      return response.data!['data']['detections'][0][0]['language'] as String;
    } catch (_) {
      return 'en';
    }
  }
}

// ── Models ─────────────────────────────────────────────────────────────────

class TranslationResult {
  final String originalText;
  final String translatedText;
  final String detectedSourceLang;
  final String targetLang;

  const TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.detectedSourceLang,
    required this.targetLang,
  });

  factory TranslationResult.mock(
      {required String text, required String targetLang}) {
    // Simple mock translations for UI testing without API key
    const mockMap = {
      'es': 'Hola, esto es una traducción de ejemplo.',
      'fr': 'Bonjour, ceci est une traduction exemple.',
      'de': 'Hallo, dies ist eine Beispielübersetzung.',
      'ja': 'こんにちは、これはサンプルの翻訳です。',
      'ko': '안녕하세요, 이것은 샘플 번역입니다.',
    };
    return TranslationResult(
      originalText: text,
      translatedText: mockMap[targetLang] ?? '[Translation]',
      detectedSourceLang: 'en',
      targetLang: targetLang,
    );
  }
}
