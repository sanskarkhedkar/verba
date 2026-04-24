import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

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
  if (firebaseOptions != null) {
    await Firebase.initializeApp(options: firebaseOptions);
    await const FirebaseBootstrapService().configure();
  }

  // Initialize RevenueCat (no-op when API keys are not set)
  try {
    await RevenueCatService().initialize();
  } on Object {
    // RevenueCat keys not configured yet — subscription features run in stub mode.
  }

  runApp(ProviderScope(child: VerbaApp()));
}
