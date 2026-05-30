import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

typedef NotificationTapCallback = void Function(RemoteMessage message);

class NotificationHandler {
  static NotificationTapCallback? onTap;

  static Future<void> initialize({NotificationTapCallback? onNotificationTap}) async {
    onTap = onNotificationTap;

    final messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground notification: ${message.notification?.title}');
  }

  static Future<void> _handleNotificationOpenedApp(RemoteMessage message) async {
    _handleNotificationTap(message);
  }

  static void _handleNotificationTap(RemoteMessage message) {
    onTap?.call(message);
  }

  @pragma('vm:entry-point')
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Background notification: ${message.notification?.title}');
  }
}
