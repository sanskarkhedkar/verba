import 'dart:io';

import 'package:speech_to_text/speech_to_text.dart';

import 'gemini_service.dart';

class SttService {
  const SttService(this._gemini);

  final GeminiService _gemini;

  /// Transcribes [audioFile] (WAV, 16kHz mono) using Gemini multimodal API.
  /// Falls back to native STT if Gemini fails or returns empty.
  Future<String> transcribeAudio(File audioFile, String languageHint) async {
    final geminiResult = await _gemini.transcribeAudio(audioFile, languageHint);
    if (geminiResult.isNotEmpty) return geminiResult;
    return _transcribeNative(languageHint);
  }

  Future<String> _transcribeNative(String language) async {
    final stt = SpeechToText();
    final available = await stt.initialize();
    if (!available) return '';

    final localeId = _localeFor(language);
    var result = '';

    await stt.listen(
      onResult: (r) => result = r.recognizedWords,
      localeId: localeId,
      listenFor: const Duration(seconds: 5),
      pauseFor: const Duration(seconds: 2),
    );

    // Wait for listening to complete
    await Future<void>.delayed(const Duration(seconds: 6));
    await stt.stop();
    return result;
  }

  String _localeFor(String language) {
    const locales = {
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
    };
    return locales[language] ?? 'en-US';
  }
}
