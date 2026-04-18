import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/elevenlabs_service.dart';
import '../../../services/openai_service.dart';
import '../../../services/app_config.dart';

enum SpeakSessionState { idle, listening, transcribing, thinking, speaking }

class SpeakMessage {
  final String text;
  final bool isAI;
  final String? translation;
  final String? correction;
  final PronunciationResult? pronunciation;

  const SpeakMessage({
    required this.text,
    required this.isAI,
    this.translation,
    this.correction,
    this.pronunciation,
  });
}

class SpeakSessionNotifier extends StateNotifier<SpeakSessionModel> {
  final ElevenLabsService _elevenlabs;
  final OpenAIService _openai;

  SpeakSessionNotifier(this._elevenlabs, this._openai)
      : super(const SpeakSessionModel());

  /// Called when user taps mic — starts recording stub.
  void startListening() {
    state = state.copyWith(sessionState: SpeakSessionState.listening);
  }

  /// Called with recorded audio bytes from the device microphone.
  Future<void> processAudio({
    required Uint8List audioBytes,
    required String targetLanguage,
    required String languageCode,
    required String skillLevel,
  }) async {
    // 1. Transcribe via ElevenLabs STT
    state = state.copyWith(sessionState: SpeakSessionState.transcribing);
    SttResult stt;
    try {
      stt = await _elevenlabs.speechToText(
        audioBytes: audioBytes,
        languageCode: languageCode,
      );
    } catch (e) {
      stt = const SttResult(
          text: '[Could not transcribe]', languageCode: 'en', confidence: 0);
    }

    // Add user message
    final userMsg = SpeakMessage(text: stt.text, isAI: false);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      sessionState: SpeakSessionState.thinking,
    );

    // 2. Get AI tutor response via OpenAI
    TutorResponse tutorResp;
    try {
      tutorResp = await _openai.chat(
        userMessage: stt.text,
        history: state.messages
            .map((m) => ChatMessage(
                  role: m.isAI ? 'assistant' : 'user',
                  content: m.text,
                ))
            .toList(),
        targetLanguage: targetLanguage,
        nativeLanguage: 'English',
        skillLevel: skillLevel,
      );
    } catch (_) {
      tutorResp = TutorResponse.mock;
    }

    // 3. Assess pronunciation (compare what user said vs what was expected)
    PronunciationResult? pronunciation;
    if (state.expectedPhrase != null && stt.text.isNotEmpty) {
      try {
        pronunciation = await _elevenlabs.assessPronunciation(
          spokenAudio: audioBytes,
          referenceText: state.expectedPhrase!,
          languageCode: languageCode,
        );
      } catch (_) {}
    }

    // Add AI reply to messages
    final aiMsg = SpeakMessage(
      text: tutorResp.message,
      isAI: true,
      translation: tutorResp.translation,
      correction: tutorResp.correction,
      pronunciation: pronunciation,
    );
    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      expectedPhrase: tutorResp.nextPrompt,
      sessionState: SpeakSessionState.speaking,
    );

    // 4. Speak AI response via ElevenLabs TTS
    try {
      final audioBytes = await _elevenlabs.textToSpeech(
        text: tutorResp.message,
        languageCode: languageCode,
      );
      state = state.copyWith(latestAudioBytes: audioBytes);
    } catch (_) {
      // TTS failed silently
    }

    state = state.copyWith(sessionState: SpeakSessionState.idle);
  }

  void stopListening() {
    state = state.copyWith(sessionState: SpeakSessionState.idle);
  }

  void resetSession() {
    state = const SpeakSessionModel();
  }
}

class SpeakSessionModel {
  final SpeakSessionState sessionState;
  final List<SpeakMessage> messages;
  final String? expectedPhrase;
  final Uint8List? latestAudioBytes;

  const SpeakSessionModel({
    this.sessionState = SpeakSessionState.idle,
    this.messages = const [],
    this.expectedPhrase,
    this.latestAudioBytes,
  });

  SpeakSessionModel copyWith({
    SpeakSessionState? sessionState,
    List<SpeakMessage>? messages,
    String? expectedPhrase,
    Uint8List? latestAudioBytes,
  }) {
    return SpeakSessionModel(
      sessionState: sessionState ?? this.sessionState,
      messages: messages ?? this.messages,
      expectedPhrase: expectedPhrase ?? this.expectedPhrase,
      latestAudioBytes: latestAudioBytes ?? this.latestAudioBytes,
    );
  }
}

final speakSessionProvider =
    StateNotifierProvider<SpeakSessionNotifier, SpeakSessionModel>((ref) {
  final elevenlabs = ref.read(elevenLabsServiceProvider);
  final openai = ref.read(openAIServiceProvider);
  return SpeakSessionNotifier(elevenlabs, openai);
});
