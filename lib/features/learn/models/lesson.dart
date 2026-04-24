class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.theme,
    required this.turns,
  });

  final String id;
  final String title;
  final String theme;
  final List<LessonTurn> turns;
}

class LessonTurn {
  const LessonTurn({
    required this.prompt,
    required this.targetPhrase,
    required this.phoneticGuide,
    required this.evaluationFocus,
    required this.successFeedback,
    required this.correctionHint,
  });

  final String prompt;
  final String targetPhrase;
  final String phoneticGuide;
  final String evaluationFocus;
  final String successFeedback;
  final String correctionHint;
}

class SpeechFeedback {
  const SpeechFeedback({
    required this.accuracy,
    required this.pronunciation,
    required this.fluency,
    required this.type,
    required this.message,
  });

  final int accuracy;
  final int pronunciation;
  final int fluency;
  final FeedbackType type;
  final String message;
}

enum FeedbackType { success, warning, error }
