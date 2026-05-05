import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  const AnalyticsService();

  FirebaseAnalytics get _fa => FirebaseAnalytics.instance;

  // ── Onboarding ────────────────────────────────────────────────────────────
  void logOnboardingStart() => _log('onboarding_start');

  void logOnboardingStep(String stepName, int index) =>
      _log('onboarding_step', params: {'step': stepName, 'index': index});

  void logOnboardingComplete(String language) =>
      _log('onboarding_complete', params: {'language': language});

  void logLanguageSelected(String language) =>
      _log('language_selected', params: {'language': language});

  void logAuthSkipped() => _log('auth_skipped');

  // ── Auth ──────────────────────────────────────────────────────────────────
  void logLogin(String method) {
    try {
      _fa.logLogin(loginMethod: method);
    } catch (_) {}
  }

  void logSignUp(String method) {
    try {
      _fa.logSignUp(signUpMethod: method);
    } catch (_) {}
  }

  // ── Paywall ───────────────────────────────────────────────────────────────
  void logPaywallShown() => _log('paywall_shown');
  void logPaywallPurchased() => _log('paywall_purchased');
  void logPaywallDismissed() => _log('paywall_dismissed');

  // ── Lessons ───────────────────────────────────────────────────────────────
  void logLessonStart(String language, String title) =>
      _log('lesson_start', params: {'language': language, 'title': title});

  void logLessonTurnResult(int turnIndex, String feedbackType) =>
      _log('lesson_turn', params: {'turn': turnIndex, 'result': feedbackType});

  void logLessonComplete(String language, int xpEarned, int turns) =>
      _log('lesson_complete', params: {
        'language': language,
        'xp_earned': xpEarned,
        'turns': turns,
      });

  // ── Tools ─────────────────────────────────────────────────────────────────
  void logTranslation(String type, String sourceLang, String targetLang) =>
      _log('translation_completed', params: {
        'type': type,
        'source': sourceLang,
        'target': targetLang,
      });

  // ── Home ──────────────────────────────────────────────────────────────────
  void logLanguageChanged(String language) =>
      _log('language_changed', params: {'language': language});

  // ── User ──────────────────────────────────────────────────────────────────
  void setUserId(String uid) {
    try {
      _fa.setUserId(id: uid);
    } catch (_) {}
  }

  // ── Internal ──────────────────────────────────────────────────────────────
  void _log(String name, {Map<String, Object>? params}) {
    try {
      _fa.logEvent(name: name, parameters: params);
    } catch (_) {}
  }
}
