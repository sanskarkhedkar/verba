import 'dart:async';
import 'dart:io';

import 'package:speech_to_text/speech_to_text.dart';

import 'gemini_service.dart';

class SttService {
  const SttService(this._gemini);

  final GeminiService _gemini;

  /// Transcribes [audioFile] (WAV, 16kHz mono) using Gemini multimodal API.
  /// Falls back to native STT if Gemini fails or returns empty.
  Future<String> transcribeAudio(File audioFile, String languageHint) async {
    try {
      final geminiResult =
          await _gemini.transcribeAudio(audioFile, languageHint);
      if (geminiResult.isNotEmpty) return geminiResult;
    } catch (_) {
      // Fall through to native STT
    }
    return _transcribeNative(languageHint);
  }

  Future<String> _transcribeNative(String language) async {
    final stt = SpeechToText();
    final available = await stt.initialize();
    if (!available) return '';

    final localeId = _localeFor(language);
    final completer = Completer<String>();
    var finalResult = '';

    await stt.listen(
      onResult: (r) {
        if (r.finalResult) {
          finalResult = r.recognizedWords;
          if (!completer.isCompleted) completer.complete(finalResult);
        } else {
          finalResult = r.recognizedWords;
        }
      },
      localeId: localeId,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      cancelOnError: true,
      partialResults: true,
    );

    // Wait for final result or timeout after 12s
    await Future.any([
      completer.future,
      Future<void>.delayed(const Duration(seconds: 12)),
    ]);

    await stt.stop();
    return finalResult;
  }

  String _localeFor(String language) {
    const locales = {
      'English': 'en-US',
      'German': 'de-DE',
      'Spanish': 'es-ES',
      'French': 'fr-FR',
      'Italian': 'it-IT',
      'Japanese': 'ja-JP',
      'Korean': 'ko-KR',
      'Mandarin': 'zh-CN',
      'Portuguese': 'pt-BR',
      'Hindi': 'hi-IN',
      'Arabic': 'ar-SA',
      'Turkish': 'tr-TR',
      'Dutch': 'nl-NL',
      'Polish': 'pl-PL',
      'Russian': 'ru-RU',
      'Swedish': 'sv-SE',
    };
    return locales[language] ?? 'en-US';
  }
}

