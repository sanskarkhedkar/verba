import '../constants/api_constants.dart';
import '../utils/language_detector.dart';
import 'firebase_functions_service.dart';

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
  const TranslationService(
      [this._functions = const FirebaseFunctionsService()]);

  final FirebaseFunctionsService _functions;

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

    final data = await _functions.call(
      'detectLanguage',
      {'text': text.trim()},
      timeout: const Duration(seconds: ApiConstants.apiTimeoutSeconds),
    );
    return data['language'] as String?;
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
    final data = await _functions.call(
      'translateText',
      {
        'text': text,
        'sourceLang': sourceLang,
        'targetLang': targetLang,
      },
      timeout: const Duration(seconds: ApiConstants.apiTimeoutSeconds),
    );
    return TranslationResult(
      originalText: data['originalText'] as String? ?? text,
      translatedText: data['translatedText'] as String? ?? text,
      sourceLang: data['sourceLang'] as String? ?? sourceLang,
      targetLang: data['targetLang'] as String? ?? targetLang,
      detectedLanguage: data['detectedLanguage'] as String?,
    );
  }
}
