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

/// Translation service using Gemini as the backend model.
/// Falls back to a stub table when the API key is absent.
class TranslationService {
  const TranslationService();

  static const _stubTranslations = {
    'Good morning': {
      'German': 'Guten Morgen',
      'Spanish': 'Buenos días',
      'French': 'Bonjour',
      'Italian': 'Buongiorno',
      'Japanese': 'おはようございます',
      'Korean': '좋은 아침이에요',
    },
    'Thank you': {
      'German': 'Danke schön',
      'Spanish': 'Gracias',
      'French': 'Merci',
      'Italian': 'Grazie',
      'Japanese': 'ありがとうございます',
      'Korean': '감사합니다',
    },
    'How are you?': {
      'German': 'Wie geht es Ihnen?',
      'Spanish': '¿Cómo estás?',
      'French': 'Comment allez-vous?',
      'Italian': 'Come stai?',
      'Japanese': 'お元気ですか？',
      'Korean': '어떻게 지내세요?',
    },
    'Good morning, how are you?': {
      'German': 'Guten Morgen, wie geht es Ihnen?',
      'Spanish': 'Buenos días, ¿cómo estás?',
      'French': 'Bonjour, comment allez-vous?',
      'Italian': 'Buongiorno, come stai?',
      'Japanese': 'おはようございます、お元気ですか？',
      'Korean': '좋은 아침이에요, 어떻게 지내세요?',
    },
  };

  Future<TranslationResult> translateText(
    String text, {
    required String sourceLang,
    required String targetLang,
  }) async {
    final apiKey = ApiConstants.geminiApiKey;
    if (apiKey.isNotEmpty) {
      return _translateWithGemini(text, sourceLang: sourceLang, targetLang: targetLang);
    }
    // Stub fallback
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final stub = _stubTranslations[text]?[targetLang];
    return TranslationResult(
      originalText: text,
      translatedText: stub ?? '[$targetLang: $text]',
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }

  Future<TranslationResult> _translateWithGemini(
    String text, {
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${ApiConstants.geminiApiKey}',
      );
      final prompt =
          'Translate the following text from $sourceLang to $targetLang. '
          'Return ONLY the translated text with no explanation, no quotes, no extra words.\n\n'
          'Text: $text';

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt}
                  ]
                }
              ],
              'generationConfig': {'maxOutputTokens': 256, 'temperature': 0.1},
            }),
          )
          .timeout(const Duration(seconds: ApiConstants.apiTimeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated =
            (data['candidates'] as List?)?.firstOrNull?['content']?['parts']
                    ?.firstOrNull?['text'] as String? ??
                text;
        return TranslationResult(
          originalText: text,
          translatedText: translated.trim(),
          sourceLang: sourceLang,
          targetLang: targetLang,
        );
      }
    } on Exception {
      // Fall through to stub
    }
    return TranslationResult(
      originalText: text,
      translatedText: '[$targetLang: $text]',
      sourceLang: sourceLang,
      targetLang: targetLang,
    );
  }
}
