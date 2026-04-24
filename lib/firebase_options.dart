import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) return null;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return null;
    }
  }

  static FirebaseOptions? get android {
    final apiKey = dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    return FirebaseOptions(
      apiKey: apiKey,
      appId: '1:411659663243:android:b7af093d428d7293ee218e',
      messagingSenderId: '411659663243',
      projectId: 'verba-translation-app',
      storageBucket: 'verba-translation-app.firebasestorage.app',
    );
  }

  static FirebaseOptions? get ios {
    final apiKey = dotenv.env['FIREBASE_IOS_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    return FirebaseOptions(
      apiKey: apiKey,
      appId: '1:411659663243:ios:8c9f41f7ad7d60ebee218e',
      messagingSenderId: '411659663243',
      projectId: 'verba-translation-app',
      storageBucket: 'verba-translation-app.firebasestorage.app',
      iosBundleId: 'com.verba.apple',
    );
  }
}
