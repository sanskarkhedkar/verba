import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final String? selectedLanguage;
  final String? selectedLanguageCode;
  final String? selectedLanguageFlag;
  final int selectedSkillIndex;
  final List<String> selectedMotivations;
  final int dailyGoalMinutes;
  final List<String> selectedFocusAreas;
  final String userName;

  const OnboardingState({
    this.selectedLanguage,
    this.selectedLanguageCode,
    this.selectedLanguageFlag,
    this.selectedSkillIndex = 0,
    this.selectedMotivations = const [],
    this.dailyGoalMinutes = 10,
    this.selectedFocusAreas = const [],
    this.userName = '',
  });

  OnboardingState copyWith({
    String? selectedLanguage,
    String? selectedLanguageCode,
    String? selectedLanguageFlag,
    int? selectedSkillIndex,
    List<String>? selectedMotivations,
    int? dailyGoalMinutes,
    List<String>? selectedFocusAreas,
    String? userName,
  }) {
    return OnboardingState(
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedLanguageCode: selectedLanguageCode ?? this.selectedLanguageCode,
      selectedLanguageFlag: selectedLanguageFlag ?? this.selectedLanguageFlag,
      selectedSkillIndex: selectedSkillIndex ?? this.selectedSkillIndex,
      selectedMotivations: selectedMotivations ?? this.selectedMotivations,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      selectedFocusAreas: selectedFocusAreas ?? this.selectedFocusAreas,
      userName: userName ?? this.userName,
    );
  }
}

class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier() : super(const OnboardingState());

  void setLanguage(String name, String code, String flag) {
    state = state.copyWith(
      selectedLanguage: name,
      selectedLanguageCode: code,
      selectedLanguageFlag: flag,
    );
  }

  void setSkillLevel(int index) {
    state = state.copyWith(selectedSkillIndex: index);
  }

  void toggleMotivation(String motivation) {
    final current = List<String>.from(state.selectedMotivations);
    if (current.contains(motivation)) {
      current.remove(motivation);
    } else {
      current.add(motivation);
    }
    state = state.copyWith(selectedMotivations: current);
  }

  void setDailyGoal(int minutes) {
    state = state.copyWith(dailyGoalMinutes: minutes);
  }

  void toggleFocusArea(String area) {
    final current = List<String>.from(state.selectedFocusAreas);
    if (current.contains(area)) {
      current.remove(area);
    } else {
      current.add(area);
    }
    state = state.copyWith(selectedFocusAreas: current);
  }

  void setUserName(String name) {
    state = state.copyWith(userName: name);
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>(
  (ref) => OnboardingNotifier(),
);
