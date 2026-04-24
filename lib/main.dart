import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/services/firebase_bootstrap_service.dart';
import 'core/services/revenuecat_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(ProviderScope(child: VerbaApp()));
}
