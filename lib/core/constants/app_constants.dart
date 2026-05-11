abstract final class AppConstants {
  static const appName = 'Verba';
  static const packageName = 'com.verba.app';

  // XP values
  static const xpPerSuccessTurn = 15;
  static const xpPerWarningTurn = 7;
  static const xpPerLessonComplete = 25;
  static const xpPerTranslationBridge = 15;
  static const xpToA2 = 500;
  static const xpToB1 = 2000;
  static const xpToB2 = 5000;

  // Lesson limits (free tier)
  static const freeLessonLimitDefault = 3;
  static const freeVoiceTranslationsDailyDefault = 10;

  // Recording
  static const maxRecordingSeconds = 15;
  static const silenceDetectionSeconds = 3;
  static const waveformUpdateIntervalMs = 33; // ~30fps

  // Cache
  static const maxCachedLessons = 5;
  static const maxRecentTranslations = 20;
  static const maxRecentPhrases = 50;

  // Supported languages
  static const supportedLanguages = [
    'English',
    'German',
    'Spanish',
    'French',
    'Italian',
    'Japanese',
    'Korean',
    'Portuguese',
    'Mandarin',
    'Arabic',
    'Hindi',
    'Turkish',
    'Dutch',
    'Polish',
    'Russian',
    'Swedish',
  ];

  static const languageEmojis = {
    'English': '🇬🇧',
    'German': '🇩🇪',
    'Spanish': '🇪🇸',
    'French': '🇫🇷',
    'Italian': '🇮🇹',
    'Japanese': '🇯🇵',
    'Korean': '🇰🇷',
    'Portuguese': '🇵🇹',
    'Mandarin': '🇨🇳',
    'Arabic': '🇸🇦',
    'Hindi': '🇮🇳',
    'Turkish': '🇹🇷',
    'Dutch': '🇳🇱',
    'Polish': '🇵🇱',
    'Russian': '🇷🇺',
    'Swedish': '🇸🇪',
  };

  static const motivationEmojis = {
    'travel': '✈️',
    'business': '💼',
    'family': '❤️',
    'personal': '🧠',
    'academic': '🎓',
    'culture': '🌎',
    'moving abroad': '🤝',
  };
}
