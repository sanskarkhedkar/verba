import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

import '../../../core/services/service_providers.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../models/lesson.dart';

final lessonProvider = StateNotifierProvider<LessonController, LessonState>(
  LessonController.new,
);

class LessonState {
  const LessonState({
    this.lesson,
    this.currentTurn = 0,
    this.micState = MicState.idle,
    this.feedback,
    this.xpEarned = 0,
    this.attempts = 0,
    this.loading = false,
    this.errorMessage,
    this.totalAccuracy = 0,
    this.turnsScored = 0,
  });

  final Lesson? lesson;
  final int currentTurn;
  final MicState micState;
  final SpeechFeedback? feedback;
  final int xpEarned;
  final int attempts;
  final bool loading;
  final String? errorMessage;
  final int totalAccuracy;
  final int turnsScored;

  bool get isComplete => lesson != null && currentTurn >= lesson!.turns.length;
  LessonTurn? get activeTurn {
    if (lesson == null || isComplete) return null;
    return lesson!.turns[currentTurn];
  }

  LessonState copyWith({
    Lesson? lesson,
    int? currentTurn,
    MicState? micState,
    SpeechFeedback? feedback,
    bool clearFeedback = false,
    int? xpEarned,
    int? attempts,
    bool? loading,
    String? errorMessage,
    bool clearError = false,
    int? totalAccuracy,
    int? turnsScored,
  }) {
    return LessonState(
      lesson: lesson ?? this.lesson,
      currentTurn: currentTurn ?? this.currentTurn,
      micState: micState ?? this.micState,
      feedback: clearFeedback ? null : feedback ?? this.feedback,
      xpEarned: xpEarned ?? this.xpEarned,
      attempts: attempts ?? this.attempts,
      loading: loading ?? this.loading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      totalAccuracy: totalAccuracy ?? this.totalAccuracy,
      turnsScored: turnsScored ?? this.turnsScored,
    );
  }
}

enum MicState { idle, listening, processing, success, warning, error }

class LessonController extends StateNotifier<LessonState> {
  LessonController(this.ref) : super(const LessonState());

  final Ref ref;
  final AudioRecorder _recorder = AudioRecorder();
  Timer? _maxDurationTimer;
  Timer? _silenceTimer;
  StreamSubscription<Amplitude>? _amplitudeSub;
  bool _recordingStarted = false;

  @override
  void dispose() {
    _cancelTimers();
    _amplitudeSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // ── Lesson loading ────────────────────────────────────────────────────────────

  Future<void> loadLesson({String? practicePhrase}) async {
    state = state.copyWith(loading: true, clearFeedback: true, clearError: true);
    try {
      final context = ref.read(onboardingProvider);

      // ── Practice-phrase mode: instant single-turn drill ─────────────────────
      if (practicePhrase != null && practicePhrase.trim().isNotEmpty) {
        final phrase = practicePhrase.trim();
        // Ask Gemini for a phonetic guide — lightweight, fast call.
        String phonetic = '';
        try {
          final guide = await ref
              .read(geminiServiceProvider)
              .getPhoneticGuide(phrase, context.targetLanguage);
          phonetic = guide;
        } catch (_) {
          // Non-critical — leave phonetic empty if it fails.
        }

        final turn = LessonTurn(
          prompt: 'Say the phrase you just translated.',
          targetPhrase: phrase,
          phoneticGuide: phonetic,
          evaluationFocus: 'Accurate pronunciation of the translated phrase',
          successFeedback: 'Perfect! You nailed the pronunciation.',
          correctionHint: 'Focus on each syllable. Try once more.',
        );

        final lesson = Lesson(
          id: 'phrase_drill',
          title: 'Phrase Practice',
          theme: phrase,
          turns: [turn],
        );

        state = LessonState(lesson: lesson);
        ref.read(analyticsServiceProvider).logLessonStart(
              context.targetLanguage, 'Phrase Practice: $phrase');

        _preloadTurnAudio(turn, context.targetLanguage);
        return;
      }

      // ── Normal mode: full AI-generated lesson ────────────────────────────────
      final lesson =
          await ref.read(geminiServiceProvider).generateLesson(context);
      state = LessonState(lesson: lesson);

      ref.read(analyticsServiceProvider).logLessonStart(
            context.targetLanguage, lesson.title);

      // Pre-load ElevenLabs audio for first turn in background
      _preloadTurnAudio(lesson.turns.first, context.targetLanguage);
    } catch (e) {
      state = state.copyWith(loading: false, errorMessage: e.toString());
    }
  }

  Future<void> speakCurrentTurn() async {
    final turn = state.activeTurn;
    if (turn == null) return;
    final language = ref.read(onboardingProvider).targetLanguage;
    await ref.read(elevenLabsServiceProvider).speak(turn.targetPhrase, language);
  }

  void _preloadTurnAudio(LessonTurn turn, String language) {
    ref.read(elevenLabsServiceProvider).speak(turn.targetPhrase, language);
  }

  // ── Recording ────────────────────────────────────────────────────────────────

  Future<void> startRecording() async {
    if (state.micState == MicState.listening) return;

    // Check mic permission
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      state = state.copyWith(
        errorMessage: 'Microphone permission is required.',
      );
      return;
    }

    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) return;

    try {
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      _recordingStarted = true;
      state = state.copyWith(micState: MicState.listening, clearFeedback: true);

      // 15-second hard limit
      _maxDurationTimer = Timer(const Duration(seconds: 15), () {
        if (state.micState == MicState.listening) stopRecording();
      });

      // Silence detection: 4s of true silence auto-stops recording
      final startTime = DateTime.now();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 200))
          .listen((amp) {
        if (!mounted) return;
        // Ignore first 1.5 seconds to avoid triggering on mic startup noise
        if (DateTime.now().difference(startTime) <
            const Duration(milliseconds: 1500)) {
          return;
        }
        if (amp.current < -50) {
          _silenceTimer ??= Timer(const Duration(seconds: 4), () {
            if (state.micState == MicState.listening) stopRecording();
          });
        } else {
          _silenceTimer?.cancel();
          _silenceTimer = null;
        }
      });
    } catch (e) {
      state = state.copyWith(errorMessage: 'Could not start recording.');
    }
  }

  Future<void> stopRecording() async {
    _cancelTimers();
    await _amplitudeSub?.cancel();
    _amplitudeSub = null;

    if (!_recordingStarted) return;
    _recordingStarted = false;

    final turn = state.activeTurn;
    if (turn == null) return;

    final attempt = state.attempts + 1;
    state = state.copyWith(micState: MicState.processing, attempts: attempt);

    try {
      final path = await _recorder.stop();
      final transcription = path != null
          ? await ref
              .read(sttServiceProvider)
              .transcribeAudio(
                File(path),
                ref.read(onboardingProvider).targetLanguage,
              )
          : '';

      final result = await ref
          .read(geminiServiceProvider)
          .evaluateSpeech(turn, transcription);

      final micState = switch (result.type) {
        FeedbackType.success => MicState.success,
        FeedbackType.warning => MicState.warning,
        FeedbackType.error => MicState.error,
      };
      state = state.copyWith(
        micState: micState,
        feedback: result,
        xpEarned:
            state.xpEarned + (result.type == FeedbackType.success ? 5 : 0),
        totalAccuracy: state.totalAccuracy + result.accuracy,
        turnsScored: state.turnsScored + 1,
      );

      ref.read(analyticsServiceProvider).logLessonTurnResult(
            state.currentTurn, result.type.name);

      // On error feedback, play correct pronunciation slowly
      if (result.type == FeedbackType.error) {
        final language = ref.read(onboardingProvider).targetLanguage;
        ref
            .read(elevenLabsServiceProvider)
            .speakSlow(turn.targetPhrase, language);
      }
    } catch (e) {
      await _recorder.stop();
      state = state.copyWith(
        micState: MicState.idle,
        errorMessage: 'Evaluation failed. Please try again.',
      );
    }
  }

  void retry() {
    state = state.copyWith(micState: MicState.idle, clearFeedback: true);
  }

  void nextTurn() {
    final next = state.currentTurn + 1;
    final lesson = state.lesson;

    state = state.copyWith(
      currentTurn: next,
      micState: MicState.idle,
      clearFeedback: true,
      attempts: 0,
    );

    // Pre-load audio for next turn
    if (lesson != null && next < lesson.turns.length) {
      final language = ref.read(onboardingProvider).targetLanguage;
      _preloadTurnAudio(lesson.turns[next], language);
    }

    // Persist lesson result when all turns are done
    if (lesson != null && next >= lesson.turns.length) {
      _persistLessonResult(lesson);
    }
  }

  Future<void> _persistLessonResult(Lesson lesson) async {
    final language = ref.read(onboardingProvider).targetLanguage;
    ref.read(analyticsServiceProvider).logLessonComplete(
          language, state.xpEarned, lesson.turns.length);
    try {
      final uid = ref.read(authServiceProvider).currentUser?.uid;
      if (uid == null) return;
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.recordLessonComplete(
            uid,
            state.xpEarned,
            lesson.turns.length,
          );
      if (state.turnsScored > 0) {
        final avg = (state.totalAccuracy / state.turnsScored).round();
        await firestore.recordLessonAccuracy(uid, avg);
      }
    } catch (_) {
      // Firestore write failure is non-critical; ignore.
    }
  }

  void _cancelTimers() {
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    _silenceTimer?.cancel();
    _silenceTimer = null;
  }
}
