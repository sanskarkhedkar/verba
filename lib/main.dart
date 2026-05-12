import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/route_constants.dart';
import 'core/services/fcm_service.dart';
import 'core/services/firebase_bootstrap_service.dart';
import 'core/services/local_notifications_service.dart';
import 'core/services/revenuecat_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must be registered before runApp — top-level background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  try {
    await dotenv.load(fileName: '.env', mergeWith: const {});
  } on Object {
    // Local demo builds run without API keys until integrations are configured.
  }

  final firebaseOptions = DefaultFirebaseOptions.currentPlatform;
  String? currentUserId;
  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
    await const FirebaseBootstrapService().configure();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
  }

  try {
    final revenueCatService = RevenueCatService();
    await revenueCatService.initialize();
    if (currentUserId != null) {
      await revenueCatService.setUserId(currentUserId);
    }
  } on Object {
    // Subscription features run in preview mode if RevenueCat cannot initialize.
  }

  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;
  final authRequired = prefs.getBool('auth_required') ?? false;
  final initialRoute = authRequired || (onboardingDone && currentUserId == null)
      ? '${RouteConstants.onboarding}?step=auth'
      : onboardingDone
          ? RouteConstants.home
          : RouteConstants.onboarding;

  // Initialize local notifications and reschedule any saved daily reminder.
  try {
    final notifications = LocalNotificationsService();
    await notifications.initialize();
    final reminderEnabled = prefs.getBool('reminder_enabled') ?? false;
    final savedTime = prefs.getString('reminder_time');
    if (reminderEnabled && savedTime != null && savedTime.isNotEmpty) {
      await notifications.scheduleDailyReminder(savedTime);
    }
  } on Object {
    // Notifications are non-blocking — continue if scheduling fails.
  }

  runApp(ProviderScope(child: VerbaApp(initialRoute: initialRoute)));
}
