import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/service_providers.dart';
import '../models/onboarding_state.dart';

final onboardingProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>(
  OnboardingController.new,
);

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController(this.ref) : super(const OnboardingState());

  final Ref ref;

  void setTargetLanguage(String value) {
    state = state.copyWith(targetLanguage: value);
  }

  void setLevel(String value) {
    state = state.copyWith(level: value);
  }

  void setGoalCategory(String value) {
    state = state.copyWith(goalCategory: value);
  }

  void setDailyGoalMinutes(int value) {
    state = state.copyWith(dailyGoalMinutes: value);
  }

  void toggleFocusArea(String value) {
    final current = [...state.focusAreas];
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }
    state = state.copyWith(focusAreas: current);
  }

  void setDisplayName(String value) {
    state = state.copyWith(displayName: value.trim());
  }

  void setNotificationTime(String value) {
    state = state.copyWith(notificationTime: value);
  }

  void reset() {
    state = const OnboardingState();
  }
}

/// Single source of truth for the user's currently selected learning language.
/// Priority:
/// 1. In-memory session state (e.g. they just changed it from the Home picker)
/// 2. Persisted Firebase profile data (loaded on app start)
/// 3. Default fallback ('German')
final targetLanguageProvider = Provider<String>((ref) {
  final sessionLang = ref.watch(onboardingProvider).targetLanguage;
  if (sessionLang.isNotEmpty) return sessionLang;

  final profileData = ref.watch(userProfileStreamProvider).valueOrNull;
  final profileLang = (profileData?['targetLanguage'] as String?) ?? '';
  if (profileLang.isNotEmpty) return profileLang;

  return 'German';
});
