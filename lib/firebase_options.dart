import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC1drdIew4djhmRBBDXP1hhKFBBW1VO2N0',
    appId: '1:411659663243:android:b7af093d428d7293ee218e',
    messagingSenderId: '411659663243',
    projectId: 'verba-translation-app',
    storageBucket: 'verba-translation-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD_gbSw2P9VJTuiNw-oHXVB_Bqt8Nx11cU',
    appId: '1:411659663243:ios:8c9f41f7ad7d60ebee218e',
    messagingSenderId: '411659663243',
    projectId: 'verba-translation-app',
    storageBucket: 'verba-translation-app.firebasestorage.app',
    iosBundleId: 'com.verba.apple',
  );
}
