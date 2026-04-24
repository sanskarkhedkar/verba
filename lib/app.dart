import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/home/screens/home_screen.dart';
import 'features/learn/screens/lesson_complete_screen.dart';
import 'features/learn/screens/lesson_list_screen.dart';
import 'features/learn/screens/lesson_screen.dart';
import 'features/onboarding/screens/onboarding_flow_screen.dart';
import 'features/paywall/screens/paywall_screen.dart';
import 'features/profile/screens/achievements_screen.dart';
import 'features/profile/screens/progress_screen.dart';
import 'features/profile/screens/settings_screen.dart';
import 'features/speak/screens/conversation_screen.dart';
import 'features/tools/screens/face_to_face_screen.dart';
import 'features/tools/screens/image_translation_screen.dart';
import 'features/tools/screens/text_translation_screen.dart';
import 'features/tools/screens/voice_translation_screen.dart';

class VerbaApp extends StatelessWidget {
  VerbaApp({super.key});

  final GoRouter _router = GoRouter(
    initialLocation: RouteConstants.onboarding,
    routes: [
      // ── Onboarding ──────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.onboarding,
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // ── Main shell ──────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const HomeScreen(),
      ),

      // ── Learn ───────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.lesson,
        builder: (context, state) => const LessonScreen(),
      ),
      GoRoute(
        path: RouteConstants.lessonComplete,
        builder: (context, state) => const LessonCompleteScreen(),
      ),
      GoRoute(
        path: '/learn/list',
        builder: (context, state) => const LessonListScreen(),
      ),

      // ── Tools ───────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.textTranslation,
        builder: (context, state) => const TextTranslationScreen(),
      ),
      GoRoute(
        path: RouteConstants.voiceTranslation,
        builder: (context, state) => const VoiceTranslationScreen(),
      ),
      GoRoute(
        path: RouteConstants.imageTranslation,
        builder: (context, state) => const ImageTranslationScreen(),
      ),
      GoRoute(
        path: RouteConstants.faceToFace,
        builder: (context, state) => const FaceToFaceScreen(),
      ),

      // ── Speak ───────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.conversation,
        builder: (context, state) => const ConversationScreen(),
      ),

      // ── Profile sub-screens ─────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.progress,
        builder: (context, state) => const ProgressScreen(),
      ),
      GoRoute(
        path: RouteConstants.achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // ── Paywall ─────────────────────────────────────────────────────────────
      GoRoute(
        path: RouteConstants.paywall,
        builder: (context, state) => const PaywallScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}
