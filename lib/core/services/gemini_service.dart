import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../features/learn/models/lesson.dart';
import '../../features/onboarding/models/onboarding_state.dart';
import '../constants/api_constants.dart';

class GeminiService {
  const GeminiService();

  Uri _endpoint(String model) => Uri.parse(
        '${ApiConstants.geminiBaseUrl}/$model:generateContent'
        '?key=${ApiConstants.geminiApiKey}',
      );

  Future<Map<String, dynamic>> _post(
    String model,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .post(
          _endpoint(model),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(
          Duration(seconds: ApiConstants.lessonGenerationTimeoutSeconds),
        );
    if (response.statusCode != 200) {
      throw Exception('Gemini ${response.statusCode}: ${response.body}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  String _extractText(Map<String, dynamic> json) {
    final candidates = json['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) return '';
    final parts =
        candidates[0]['content']['parts'] as List? ?? [];
    if (parts.isEmpty) return '';
    return (parts[0]['text'] as String? ?? '').trim();
  }

  // ── Lesson Generation ────────────────────────────────────────────────────────

  Future<Lesson> generateLesson(OnboardingState context) async {
    final prompt = '''
You are Verba's AI language tutor. Generate a structured speaking lesson.

Context:
- User's native language: English
- Target language: ${context.targetLanguage}
- Current level: ${context.level}
- Goal: ${context.goalCategory}
- Lesson theme: Daily conversational practice

Generate a JSON lesson with exactly 7 speaking turns. Return ONLY valid JSON, no markdown.

Format:
{
  "title": "Lesson title",
  "theme": "Brief theme description",
  "turns": [
    {
      "ai_prompt_text": "What the AI tutor says to the user (in English)",
      "target_phrase": "Phrase user should say in ${context.targetLanguage}",
      "phonetic_guide": "Readable phonetic spelling",
      "evaluation_focus": "What to evaluate",
      "success_feedback": "Encouraging message on success",
      "correction_hint": "Helpful hint on failure"
    }
  ]
}''';

    try {
      final json = await _post(ApiConstants.geminiModel, {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 1024,
          'responseMimeType': 'application/json',
        },
      });

      final text = _extractText(json);
      final lessonJson = jsonDecode(text) as Map<String, dynamic>;
      return _parseLesson(lessonJson);
    } catch (_) {
      return _fallbackLesson(context.targetLanguage, context.goalCategory);
    }
  }

  Lesson _parseLesson(Map<String, dynamic> json) {
    final turns = (json['turns'] as List? ?? []).map((t) {
      final turn = t as Map<String, dynamic>;
      return LessonTurn(
        prompt: turn['ai_prompt_text'] as String? ?? '',
        targetPhrase: turn['target_phrase'] as String? ?? '',
        phoneticGuide: turn['phonetic_guide'] as String? ?? '',
        evaluationFocus: turn['evaluation_focus'] as String? ?? '',
        successFeedback: turn['success_feedback'] as String? ?? 'Well done!',
        correctionHint:
            turn['correction_hint'] as String? ?? 'Try once more.',
      );
    }).toList();

    return Lesson(
      id: const Uuid().v4(),
      title: json['title'] as String? ?? 'Speaking Lesson',
      theme: json['theme'] as String? ?? 'Daily practice',
      turns: turns,
    );
  }

  // ── Speech Evaluation ────────────────────────────────────────────────────────

  Future<SpeechFeedback> evaluateSpeech(
    LessonTurn turn,
    String transcription,
  ) async {
    final prompt = '''
Evaluate this language learner's pronunciation attempt.

Target phrase: "${turn.targetPhrase}"
Phonetic target: "${turn.phoneticGuide}"
User's transcribed speech: "${transcription.isEmpty ? '[no speech detected]' : transcription}"
Evaluation focus: ${turn.evaluationFocus}

Rate on:
1. accuracy (0-100): Did they say the right words?
2. pronunciation (0-100): Were phonemes correct?
3. fluency (0-100): Was speech natural?

Return ONLY valid JSON, no markdown:
{"accuracy": INT, "pronunciation": INT, "fluency": INT, "feedback_type": "success"|"warning"|"error", "feedback_message": STRING}

Rules: success = accuracy>=85, warning = accuracy 60-84, error = accuracy<60''';

    try {
      final json = await _post(ApiConstants.geminiModel, {
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 256,
          'responseMimeType': 'application/json',
        },
      });

      final text = _extractText(json);
      final evalJson = jsonDecode(text) as Map<String, dynamic>;
      return _parseFeedback(evalJson, turn);
    } catch (_) {
      return SpeechFeedback(
        accuracy: 75,
        pronunciation: 72,
        fluency: 78,
        type: FeedbackType.warning,
        message: 'Almost there. ${turn.correctionHint}',
      );
    }
  }

  SpeechFeedback _parseFeedback(
    Map<String, dynamic> json,
    LessonTurn turn,
  ) {
    final accuracy = (json['accuracy'] as num?)?.toInt() ?? 70;
    final pronunciation = (json['pronunciation'] as num?)?.toInt() ?? 70;
    final fluency = (json['fluency'] as num?)?.toInt() ?? 70;
    final typeStr = json['feedback_type'] as String? ?? 'warning';
    final message = json['feedback_message'] as String? ?? turn.correctionHint;

    final type = switch (typeStr) {
      'success' => FeedbackType.success,
      'error' => FeedbackType.error,
      _ => FeedbackType.warning,
    };

    return SpeechFeedback(
      accuracy: accuracy,
      pronunciation: pronunciation,
      fluency: fluency,
      type: type,
      message: message,
    );
  }

  // ── Audio Transcription (Gemini multimodal) ──────────────────────────────────

  Future<String> transcribeAudio(File audioFile, String languageHint) async {
    try {
      final bytes = await audioFile.readAsBytes();
      final base64Audio = base64Encode(bytes);

      final json = await _post(ApiConstants.geminiModel, {
        'contents': [
          {
            'parts': [
              {
                'text':
                    'Transcribe the spoken words in this audio exactly. '
                    'Language: $languageHint. '
                    'Return only the transcription, no other text.',
              },
              {
                'inline_data': {
                  'mime_type': 'audio/wav',
                  'data': base64Audio,
                },
              },
            ],
          },
        ],
        'generationConfig': {
          'temperature': 0.0,
          'maxOutputTokens': 256,
        },
      });

      return _extractText(json);
    } catch (_) {
      return '';
    }
  }

  // ── Fallback lesson (offline / API key not set) ───────────────────────────────

  Lesson _fallbackLesson(String language, String goal) {
    return Lesson(
      id: const Uuid().v4(),
      title: 'Everyday $language — $goal',
      theme: 'Daily spoken practice',
      turns: [
        LessonTurn(
          prompt: 'Start with a warm greeting.',
          targetPhrase: _fallbackPhrase(language, 'greeting'),
          phoneticGuide: _fallbackPhonetic(language, 'greeting'),
          evaluationFocus: 'Clear vowels and confident tone',
          successFeedback: 'Perfect! Your greeting sounds natural.',
          correctionHint: 'Give the first syllable more emphasis.',
        ),
        LessonTurn(
          prompt: 'Ask how someone is doing.',
          targetPhrase: _fallbackPhrase(language, 'howAreYou'),
          phoneticGuide: _fallbackPhonetic(language, 'howAreYou'),
          evaluationFocus: 'Rising intonation on the question',
          successFeedback: 'Great! That sounded very natural.',
          correctionHint: 'Lift your voice slightly at the end.',
        ),
        LessonTurn(
          prompt: 'Introduce yourself.',
          targetPhrase: _fallbackPhrase(language, 'myNameIs'),
          phoneticGuide: _fallbackPhonetic(language, 'myNameIs'),
          evaluationFocus: 'Steady pace and clear name pronunciation',
          successFeedback: 'Well done! Clear and confident.',
          correctionHint: 'Speak a bit slower and clearly.',
        ),
        LessonTurn(
          prompt: 'Say you are pleased to meet someone.',
          targetPhrase: _fallbackPhrase(language, 'niceToMeet'),
          phoneticGuide: _fallbackPhonetic(language, 'niceToMeet'),
          evaluationFocus: 'Warm and friendly tone',
          successFeedback: 'Excellent! That sounded very polite.',
          correctionHint: 'Try to sound warmer and more relaxed.',
        ),
        LessonTurn(
          prompt: 'Ask where something is.',
          targetPhrase: _fallbackPhrase(language, 'whereIs'),
          phoneticGuide: _fallbackPhonetic(language, 'whereIs'),
          evaluationFocus: 'Question intonation and clarity',
          successFeedback: 'Spot on! Very clear question.',
          correctionHint: 'Make it sound like a question.',
        ),
        LessonTurn(
          prompt: 'Express thanks.',
          targetPhrase: _fallbackPhrase(language, 'thankYou'),
          phoneticGuide: _fallbackPhonetic(language, 'thankYou'),
          evaluationFocus: 'Pronunciation accuracy',
          successFeedback: 'Beautiful! Perfectly said.',
          correctionHint: 'Try once more at a relaxed pace.',
        ),
        LessonTurn(
          prompt: 'Say goodbye.',
          targetPhrase: _fallbackPhrase(language, 'goodbye'),
          phoneticGuide: _fallbackPhonetic(language, 'goodbye'),
          evaluationFocus: 'Clear and friendly farewell',
          successFeedback: 'Wonderful! You sound like a native.',
          correctionHint: 'Keep it natural and friendly.',
        ),
      ],
    );
  }

  static const _phrases = {
    'German': {
      'greeting': 'Guten Morgen',
      'howAreYou': 'Wie geht es Ihnen?',
      'myNameIs': 'Mein Name ist ...',
      'niceToMeet': 'Schön, Sie kennenzulernen.',
      'whereIs': 'Wo ist das?',
      'thankYou': 'Danke schön',
      'goodbye': 'Auf Wiedersehen',
    },
    'Spanish': {
      'greeting': 'Buenos días',
      'howAreYou': '¿Cómo está usted?',
      'myNameIs': 'Me llamo ...',
      'niceToMeet': 'Mucho gusto.',
      'whereIs': '¿Dónde está?',
      'thankYou': 'Muchas gracias',
      'goodbye': 'Hasta luego',
    },
    'French': {
      'greeting': 'Bonjour',
      'howAreYou': 'Comment allez-vous?',
      'myNameIs': 'Je m\'appelle ...',
      'niceToMeet': 'Enchanté de vous rencontrer.',
      'whereIs': 'Où est-ce?',
      'thankYou': 'Merci beaucoup',
      'goodbye': 'Au revoir',
    },
    'Italian': {
      'greeting': 'Buongiorno',
      'howAreYou': 'Come sta?',
      'myNameIs': 'Mi chiamo ...',
      'niceToMeet': 'Piacere di conoscerla.',
      'whereIs': 'Dov\'è?',
      'thankYou': 'Grazie mille',
      'goodbye': 'Arrivederci',
    },
    'Japanese': {
      'greeting': 'おはようございます',
      'howAreYou': 'お元気ですか？',
      'myNameIs': '私の名前は...です',
      'niceToMeet': 'はじめまして。',
      'whereIs': 'どこですか？',
      'thankYou': 'ありがとうございます',
      'goodbye': 'さようなら',
    },
    'Korean': {
      'greeting': '안녕하세요',
      'howAreYou': '어떻게 지내세요?',
      'myNameIs': '제 이름은 ...입니다',
      'niceToMeet': '만나서 반갑습니다.',
      'whereIs': '어디에 있어요?',
      'thankYou': '감사합니다',
      'goodbye': '안녕히 계세요',
    },
  };

  static const _phonetics = {
    'German': {
      'greeting': 'GOO-ten MOR-gen',
      'howAreYou': 'vee gayt es EE-nen',
      'myNameIs': 'mine NAH-meh ist',
      'niceToMeet': 'shern zee KEN-en-zu-ler-nen',
      'whereIs': 'voh ist das',
      'thankYou': 'DAN-keh shern',
      'goodbye': 'owf VEE-der-zay-en',
    },
    'Spanish': {
      'greeting': 'BWEH-nos DEE-as',
      'howAreYou': 'KOH-moh es-TAH oos-TED',
      'myNameIs': 'meh YAH-moh',
      'niceToMeet': 'MOO-choh GOOS-toh',
      'whereIs': 'DON-deh es-TAH',
      'thankYou': 'MOO-chas GRAH-syas',
      'goodbye': 'AS-tah LWEH-goh',
    },
    'French': {
      'greeting': 'bohn-ZHOOR',
      'howAreYou': 'koh-MAH tah-lay VOO',
      'myNameIs': 'zhuh mah-PEL',
      'niceToMeet': 'ohn-shohn-TAY duh voo rohn-KOHN-tray',
      'whereIs': 'oo eh-SEH',
      'thankYou': 'mehr-SEE boh-KOO',
      'goodbye': 'oh ruh-VWAR',
    },
    'Italian': {
      'greeting': 'bwon-JOR-no',
      'howAreYou': 'KOH-meh STAH',
      'myNameIs': 'mee KYAH-moh',
      'niceToMeet': 'pyah-CHEH-reh dee ko-NOSH-er-la',
      'whereIs': 'DOH-veh',
      'thankYou': 'GRAH-tsyeh MIL-leh',
      'goodbye': 'ar-ree-veh-DER-chee',
    },
    'Japanese': {
      'greeting': 'o-ha-YO go-ZAI-mas',
      'howAreYou': 'o-GEN-ki des-KA',
      'myNameIs': 'wa-ta-SHI no na-MA-eh wa ... des',
      'niceToMeet': 'ha-ji-ME-ma-SHI-teh',
      'whereIs': 'DO-ko des-KA',
      'thankYou': 'a-ri-ga-TO go-ZAI-mas',
      'goodbye': 'sa-YO-na-ra',
    },
    'Korean': {
      'greeting': 'an-NYONG-ha-SE-yo',
      'howAreYou': 'o-TOH-keh ji-NAE-se-yo',
      'myNameIs': 'jeh i-REUM-eun ... im-ni-DA',
      'niceToMeet': 'man-na-seo ban-GAP-sum-ni-da',
      'whereIs': 'o-DI-eh it-SEO-yo',
      'thankYou': 'gam-sa-ham-NI-da',
      'goodbye': 'an-NYONG-hi gye-SE-yo',
    },
  };

  String _fallbackPhrase(String language, String key) =>
      _phrases[language]?[key] ?? key;

  String _fallbackPhonetic(String language, String key) =>
      _phonetics[language]?[key] ?? key;
}
