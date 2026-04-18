class AppConstants {
  AppConstants._();

  // Onboarding
  static const int totalOnboardingSteps = 15;

  // Languages
  static const List<Map<String, String>> languages = [
    {'name': 'Spanish',    'flag': '🇪🇸', 'code': 'es'},
    {'name': 'French',     'flag': '🇫🇷', 'code': 'fr'},
    {'name': 'German',     'flag': '🇩🇪', 'code': 'de'},
    {'name': 'Italian',    'flag': '🇮🇹', 'code': 'it'},
    {'name': 'Portuguese', 'flag': '🇧🇷', 'code': 'pt'},
    {'name': 'Japanese',   'flag': '🇯🇵', 'code': 'ja'},
    {'name': 'Korean',     'flag': '🇰🇷', 'code': 'ko'},
    {'name': 'Chinese',    'flag': '🇨🇳', 'code': 'zh'},
    {'name': 'Russian',    'flag': '🇷🇺', 'code': 'ru'},
    {'name': 'Arabic',     'flag': '🇸🇦', 'code': 'ar'},
    {'name': 'Hindi',      'flag': '🇮🇳', 'code': 'hi'},
    {'name': 'Turkish',    'flag': '🇹🇷', 'code': 'tr'},
  ];

  // Skill levels
  static const List<Map<String, String>> skillLevels = [
    {'label': 'Beginner',     'desc': 'Just starting out',          'emoji': '🌱'},
    {'label': 'Elementary',   'desc': 'Know some basics',           'emoji': '📚'},
    {'label': 'Intermediate', 'desc': 'Can hold conversations',     'emoji': '💬'},
    {'label': 'Advanced',     'desc': 'Nearly fluent',              'emoji': '🚀'},
    {'label': 'Fluent',       'desc': 'Near-native proficiency',    'emoji': '🏆'},
  ];

  // Motivations
  static const List<Map<String, String>> motivations = [
    {'label': 'Travel',         'emoji': '✈️'},
    {'label': 'Career',         'emoji': '💼'},
    {'label': 'Culture',        'emoji': '🎭'},
    {'label': 'Family',         'emoji': '👨‍👩‍👧'},
    {'label': 'Education',      'emoji': '🎓'},
    {'label': 'Just for fun',   'emoji': '😄'},
    {'label': 'Moving abroad',  'emoji': '🏠'},
    {'label': 'Romance',        'emoji': '❤️'},
  ];

  // Focus areas
  static const List<Map<String, String>> focusAreas = [
    {'label': 'Confidence',     'emoji': '💪'},
    {'label': 'Pronunciation',  'emoji': '🗣️'},
    {'label': 'Vocabulary',     'emoji': '📖'},
    {'label': 'Grammar',        'emoji': '✏️'},
    {'label': 'Listening',      'emoji': '👂'},
    {'label': 'Reading',        'emoji': '📄'},
    {'label': 'Writing',        'emoji': '✍️'},
    {'label': 'Conversation',   'emoji': '💬'},
  ];

  // Daily goals (minutes)
  static const List<int> dailyGoalOptions = [5, 10, 15, 20];

  // Testimonials
  static const List<Map<String, String>> testimonials = [
    {
      'name': 'Sarah M.',
      'location': 'New York, USA',
      'text': 'I went from zero to conversational in Spanish in just 2 months. The AI speaking practice is unreal!',
      'rating': '5',
      'avatar': 'S',
    },
    {
      'name': 'David K.',
      'location': 'London, UK',
      'text': 'Finally an app that actually helps me speak, not just memorize words. Game changer!',
      'rating': '5',
      'avatar': 'D',
    },
    {
      'name': 'Yuki T.',
      'location': 'Tokyo, Japan',
      'text': 'I needed French for work. Verba helped me pass my language test in record time.',
      'rating': '5',
      'avatar': 'Y',
    },
    {
      'name': 'Maria C.',
      'location': 'Barcelona, Spain',
      'text': 'The pronunciation feedback is incredibly accurate. My accent improved dramatically!',
      'rating': '5',
      'avatar': 'M',
    },
  ];
}
