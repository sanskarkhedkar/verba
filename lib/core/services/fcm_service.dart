import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Firebase Cloud Messaging service.
class FcmService {
  const FcmService();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  /// Request permission and return the FCM token if granted.
  Future<String?> requestPermissionAndGetToken() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return _fcm.getToken();
    }
    return null;
  }

  /// Get the current FCM token without requesting permission again.
  Future<String?> getToken() => _fcm.getToken();

  /// Subscribe to a topic (e.g. 'daily_reminder').
  Future<void> subscribeToTopic(String topic) =>
      _fcm.subscribeToTopic(topic);

  Future<void> unsubscribeFromTopic(String topic) =>
      _fcm.unsubscribeFromTopic(topic);

  /// Configure message handlers. Call this after Firebase.initializeApp().
  void configureHandlers({
    required void Function(RemoteMessage) onForegroundMessage,
    required void Function(RemoteMessage) onMessageOpenedApp,
  }) {
    FirebaseMessaging.onMessage.listen(onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(onMessageOpenedApp);
  }

  Stream<String> get onTokenRefresh => _fcm.onTokenRefresh;
}

/// Top-level handler for background FCM messages (must be registered in main).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) print('Background FCM: ${message.messageId}');
}
