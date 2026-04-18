import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/onboarding/screens/ob_01_welcome.dart';
import '../../features/onboarding/screens/ob_02_language.dart';
import '../../features/onboarding/screens/ob_03_skill_level.dart';
import '../../features/onboarding/screens/ob_04_motivation.dart';
import '../../features/onboarding/screens/ob_05_daily_goal.dart';
import '../../features/onboarding/screens/ob_06_focus_area.dart';
import '../../features/onboarding/screens/ob_07_confidence_graph.dart';
import '../../features/onboarding/screens/ob_08_speed_comparison.dart';
import '../../features/onboarding/screens/ob_09_plan_loader.dart';
import '../../features/onboarding/screens/ob_10_outcome.dart';
import '../../features/onboarding/screens/ob_11_social_proof.dart';
import '../../features/onboarding/screens/ob_12_notifications.dart';
import '../../features/onboarding/screens/ob_13_name_input.dart';
import '../../features/onboarding/screens/ob_14_auth.dart';
import '../../features/onboarding/screens/ob_15_paywall.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/tools/screens/text_translate_screen.dart';
import '../../features/tools/screens/voice_translate_screen.dart';
import '../../features/tools/screens/image_translate_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/onboarding/welcome',
    debugLogDiagnostics: false,
    routes: [
      // ── Onboarding ──────────────────────────────────────────────────────
      GoRoute(path: '/onboarding/welcome',    builder: (_, __) => const Ob01Welcome()),
      GoRoute(path: '/onboarding/language',   builder: (_, __) => const Ob02Language()),
      GoRoute(path: '/onboarding/skill',      builder: (_, __) => const Ob03SkillLevel()),
      GoRoute(path: '/onboarding/motivation', builder: (_, __) => const Ob04Motivation()),
      GoRoute(path: '/onboarding/goal',       builder: (_, __) => const Ob05DailyGoal()),
      GoRoute(path: '/onboarding/focus',      builder: (_, __) => const Ob06FocusArea()),
      GoRoute(path: '/onboarding/graph',      builder: (_, __) => const Ob07ConfidenceGraph()),
      GoRoute(path: '/onboarding/speed',      builder: (_, __) => const Ob08SpeedComparison()),
      GoRoute(path: '/onboarding/loader',     builder: (_, __) => const Ob09PlanLoader()),
      GoRoute(path: '/onboarding/outcome',    builder: (_, __) => const Ob10Outcome()),
      GoRoute(path: '/onboarding/proof',      builder: (_, __) => const Ob11SocialProof()),
      GoRoute(path: '/onboarding/notify',     builder: (_, __) => const Ob12Notifications()),
      GoRoute(path: '/onboarding/name',       builder: (_, __) => const Ob13NameInput()),
      GoRoute(path: '/onboarding/auth',       builder: (_, __) => const Ob14Auth()),
      GoRoute(path: '/onboarding/paywall',    builder: (_, __) => const Ob15Paywall()),

      // ── Home tabs — HomeScreen manages its own IndexedStack ──────────────
      GoRoute(path: '/home/learn',    builder: (_, __) => const HomeScreen(initialTab: 0)),
      GoRoute(path: '/home/speak',    builder: (_, __) => const HomeScreen(initialTab: 1)),
      GoRoute(path: '/home/tools',    builder: (_, __) => const HomeScreen(initialTab: 2)),
      GoRoute(path: '/home/progress', builder: (_, __) => const HomeScreen(initialTab: 3)),
      GoRoute(path: '/home/profile',  builder: (_, __) => const HomeScreen(initialTab: 4)),

      // Tools detail routes
      GoRoute(path: '/tools/text',  builder: (_, __) => const TextTranslateScreen()),
      GoRoute(path: '/tools/voice', builder: (_, __) => const VoiceTranslateScreen()),
      GoRoute(path: '/tools/image', builder: (_, __) => const ImageTranslateScreen()),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
});
