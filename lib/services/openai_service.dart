import 'dart:convert';
import 'package:dio/dio.dart';

/// OpenAI service — powers the AI tutor conversation.
/// Uses GPT-4o with a language-learning system prompt.
class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1';
  static const String _model = 'gpt-4o';

  late final Dio _dio;
  String _apiKey;

  OpenAIService({required String apiKey}) : _apiKey = apiKey {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 45),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ));
  }

  void updateApiKey(String key) {
    _apiKey = key;
    _dio.options.headers['Authorization'] = 'Bearer $key';
  }

  // ── Chat Completion ────────────────────────────────────────────────────────

  /// Send a conversational turn and get the AI tutor's reply.
  Future<TutorResponse> chat({
    required String userMessage,
    required List<ChatMessage> history,
    required String targetLanguage,
    required String nativeLanguage,
    required String skillLevel,
    String? scenarioContext,
  }) async {
    final messages = [
      {
        'role': 'system',
        'content': _buildSystemPrompt(
          targetLanguage: targetLanguage,
          nativeLanguage: nativeLanguage,
          skillLevel: skillLevel,
          scenario: scenarioContext,
        ),
      },
      ...history.map((m) => {'role': m.role, 'content': m.content}),
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 400,
          'temperature': 0.8,
          'response_format': {'type': 'json_object'},
        }),
      );

      final raw = response.data!;
      final content = raw['choices'][0]['message']['content'] as String;
      return TutorResponse.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw OpenAIException(e.response?.statusCode, e.message ?? 'Unknown error');
    }
  }

  /// Evaluate pronunciation / grammar of a user's spoken sentence.
  Future<EvaluationResult> evaluate({
    required String userText,
    required String expectedText,
    required String targetLanguage,
  }) async {
    const prompt = '''
You are a language teacher. Compare the user's spoken sentence to the expected sentence.
Return JSON:
{
  "score": <0-100>,
  "pronunciation_note": "<short note on pronunciation>",
  "grammar_note": "<short note on grammar if any>",
  "corrected": "<corrected version of user sentence>",
  "encouragement": "<short positive message>"
}
''';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/chat/completions',
        data: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': prompt},
            {
              'role': 'user',
              'content':
                  'Target language: $targetLanguage\nExpected: "$expectedText"\nUser said: "$userText"'
            },
          ],
          'max_tokens': 200,
          'temperature': 0.3,
          'response_format': {'type': 'json_object'},
        }),
      );
      final content =
          response.data!['choices'][0]['message']['content'] as String;
      return EvaluationResult.fromJson(
          jsonDecode(content) as Map<String, dynamic>);
    } on DioException catch (e) {
      throw OpenAIException(e.response?.statusCode, e.message ?? 'Unknown error');
    }
  }

  String _buildSystemPrompt({
    required String targetLanguage,
    required String nativeLanguage,
    required String skillLevel,
    String? scenario,
  }) {
    return '''
You are an expert AI language tutor helping a $skillLevel student learn $targetLanguage.
Their native language is $nativeLanguage.
${scenario != null ? 'Current scenario: $scenario' : ''}

Rules:
- Speak primarily in $targetLanguage with brief $nativeLanguage translations.
- Keep sentences appropriate for $skillLevel level.
- After each user reply, provide gentle correction if needed.
- Keep responses concise (2-3 sentences max).
- Always end with a prompt encouraging the user to speak.

Respond ONLY in this JSON format:
{
  "message": "<your response in $targetLanguage>",
  "translation": "<$nativeLanguage translation>",
  "correction": "<null or correction of user's mistake>",
  "next_prompt": "<what you want the user to say next>"
}
''';
  }
}

// ── Models ─────────────────────────────────────────────────────────────────

class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String content;
  const ChatMessage({required this.role, required this.content});
}

class TutorResponse {
  final String message;
  final String translation;
  final String? correction;
  final String? nextPrompt;

  const TutorResponse({
    required this.message,
    required this.translation,
    this.correction,
    this.nextPrompt,
  });

  factory TutorResponse.fromJson(Map<String, dynamic> json) {
    return TutorResponse(
      message: json['message'] as String? ?? '',
      translation: json['translation'] as String? ?? '',
      correction: json['correction'] as String?,
      nextPrompt: json['next_prompt'] as String?,
    );
  }

  // Fallback mock for when API key is not configured
  static TutorResponse get mock => const TutorResponse(
        message: '¡Muy bien! Ahora diga: "¿Cuánto cuesta esto?"',
        translation: 'Very good! Now say: "How much does this cost?"',
        correction: null,
        nextPrompt: '¿Cuánto cuesta esto?',
      );
}

class EvaluationResult {
  final int score;
  final String pronunciationNote;
  final String? grammarNote;
  final String corrected;
  final String encouragement;

  const EvaluationResult({
    required this.score,
    required this.pronunciationNote,
    this.grammarNote,
    required this.corrected,
    required this.encouragement,
  });

  factory EvaluationResult.fromJson(Map<String, dynamic> json) {
    return EvaluationResult(
      score: (json['score'] as num?)?.toInt() ?? 0,
      pronunciationNote: json['pronunciation_note'] as String? ?? '',
      grammarNote: json['grammar_note'] as String?,
      corrected: json['corrected'] as String? ?? '',
      encouragement: json['encouragement'] as String? ?? 'Keep going!',
    );
  }

  static EvaluationResult get mock => const EvaluationResult(
        score: 85,
        pronunciationNote: 'Great accent! Watch the rolling "r".',
        grammarNote: null,
        corrected: 'Buenos días, una mesa para dos, por favor.',
        encouragement: 'You\'re doing great! 🎉',
      );
}

class OpenAIException implements Exception {
  final int? statusCode;
  final String message;
  const OpenAIException(this.statusCode, this.message);

  @override
  String toString() => 'OpenAIException $statusCode: $message';
}
