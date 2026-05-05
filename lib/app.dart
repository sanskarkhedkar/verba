import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/route_constants.dart';
import 'core/services/service_providers.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_spacing.dart';
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

class VerbaApp extends ConsumerStatefulWidget {
  const VerbaApp({super.key, this.initialRoute = RouteConstants.onboarding});

  final String initialRoute;

  @override
  ConsumerState<VerbaApp> createState() => _VerbaAppState();
}

class _VerbaAppState extends ConsumerState<VerbaApp> {
  late final GoRouter _router;
  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _tapSub;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<User?>? _premiumSyncSub;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: widget.initialRoute,
      routes: [
        // ── Onboarding ────────────────────────────────────────────────────────
        GoRoute(
          path: RouteConstants.onboarding,
          builder: (context, state) => const OnboardingFlowScreen(),
        ),

        // ── Main shell ────────────────────────────────────────────────────────
        GoRoute(
          path: RouteConstants.home,
          builder: (context, state) => const HomeScreen(),
        ),

        // ── Learn ─────────────────────────────────────────────────────────────
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

        // ── Tools ─────────────────────────────────────────────────────────────
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

        // ── Speak ─────────────────────────────────────────────────────────────
        GoRoute(
          path: RouteConstants.conversation,
          builder: (context, state) => const ConversationScreen(),
        ),

        // ── Profile sub-screens ───────────────────────────────────────────────
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

        // ── Paywall ───────────────────────────────────────────────────────────
        GoRoute(
          path: RouteConstants.paywall,
          builder: (context, state) => const PaywallScreen(),
        ),
      ],
    );

    _setupFcm();
    _schedulePremiumSync();
  }

  /// Listen for the first real (non-anonymous) auth state, then sync RC → Firestore.
  /// Uses the auth stream directly so it fires after Firebase resolves, not before.
  void _schedulePremiumSync() {
    _premiumSyncSub = ref
        .read(authServiceProvider)
        .authStateChanges
        .listen((user) async {
      if (user == null || user.isAnonymous) return;
      // One-shot: cancel once we have a real user
      await _premiumSyncSub?.cancel();
      _premiumSyncSub = null;

      try {
        final rcService = ref.read(revenueCatServiceProvider);
        if (!rcService.isInitialized) return;
        final isPremium = await rcService.refreshPremium();
        if (isPremium && mounted) {
          await ref
              .read(firestoreServiceProvider)
              .updateSubscription(user.uid, isPremium: true)
              .catchError((_) {});
          ref.invalidate(premiumStatusProvider);
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _foregroundSub?.cancel();
    _tapSub?.cancel();
    _tokenRefreshSub?.cancel();
    _premiumSyncSub?.cancel();
    super.dispose();
  }

  Future<void> _setupFcm() async {
    try {
      // iOS: show system notification even when app is in foreground
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Foreground → in-app banner
      _foregroundSub =
          FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // Background tap → navigate
      _tapSub = FirebaseMessaging.onMessageOpenedApp.listen(_onNotificationTap);

      // Terminated tap → navigate once the widget tree is ready
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null && mounted) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _onNotificationTap(initial));
      }

      // Subscribe to broadcast topics for server-side targeting
      await FirebaseMessaging.instance.subscribeToTopic('daily_reminder');
      await FirebaseMessaging.instance.subscribeToTopic('streak_updates');
      await FirebaseMessaging.instance.subscribeToTopic('all_users');

      // Keep Firestore token up to date when FCM rotates it
      _tokenRefreshSub =
          FirebaseMessaging.instance.onTokenRefresh.listen((token) {
        if (!mounted) return;
        final uid = ref.read(authServiceProvider).currentUser?.uid;
        if (uid != null) {
          ref
              .read(firestoreServiceProvider)
              .updateFcmToken(uid, token)
              .catchError((_) {});
        }
      });
    } catch (_) {
      // FCM unavailable (e.g. no google-services.json) — degrade gracefully
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    if (n == null) return;

    _scaffoldKey.currentState?.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (n.title != null)
              Text(
                n.title!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
            if (n.body != null)
              Text(n.body!,
                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ),
        action: SnackBarAction(
          label: 'Open',
          textColor: AppColors.textAccent,
          onPressed: () => _onNotificationTap(message),
        ),
        backgroundColor: AppColors.bgElevated,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(AppSpacing.md),
      ),
    );
  }

  void _onNotificationTap(RemoteMessage message) {
    _router.go(_routeFrom(message));
  }

  String _routeFrom(RemoteMessage message) {
    // Payload can include an explicit route to override type-based routing
    final payloadRoute = message.data['route'] as String?;
    if (payloadRoute != null && payloadRoute.isNotEmpty) return payloadRoute;

    return switch (message.data['type'] as String?) {
      'daily_reminder' ||
      'streak_at_risk' ||
      'lesson_ready' =>
        RouteConstants.lesson,
      'translation_tip' => RouteConstants.textTranslation,
      _ => RouteConstants.home,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      scaffoldMessengerKey: _scaffoldKey,
    );
  }
}
