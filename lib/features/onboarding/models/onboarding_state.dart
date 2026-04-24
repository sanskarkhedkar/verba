class OnboardingState {
  const OnboardingState({
    this.targetLanguage = 'German',
    this.level = 'A1',
    this.goalCategory = 'travel',
    this.dailyGoalMinutes = 10,
    this.focusAreas = const ['speaking'],
    this.displayName = '',
    this.notificationTime = '19:00',
  });

  final String targetLanguage;
  final String level;
  final String goalCategory;
  final int dailyGoalMinutes;
  final List<String> focusAreas;
  final String displayName;
  final String notificationTime;

  OnboardingState copyWith({
    String? targetLanguage,
    String? level,
    String? goalCategory,
    int? dailyGoalMinutes,
    List<String>? focusAreas,
    String? displayName,
    String? notificationTime,
  }) {
    return OnboardingState(
      targetLanguage: targetLanguage ?? this.targetLanguage,
      level: level ?? this.level,
      goalCategory: goalCategory ?? this.goalCategory,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      focusAreas: focusAreas ?? this.focusAreas,
      displayName: displayName ?? this.displayName,
      notificationTime: notificationTime ?? this.notificationTime,
    );
  }

  Map<String, Object> toMap() => {
        'target_language': targetLanguage,
        'current_level': level,
        'goal_category': goalCategory,
        'daily_goal_minutes': dailyGoalMinutes,
        'focus_areas': focusAreas,
        'display_name': displayName,
        'notification_time': notificationTime,
      };
}
