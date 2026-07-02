// lib/services/notification/firebase_cloud_messaging_handler.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FcmHandler {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotificationLifecycle() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print(
      'FCM Notification permission status: ${settings.authorizationStatus}',
    );

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description:
          'This channel is used for important broker and chat updates.',
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    String? token = await _fcm.getToken();
    print('YOUR EMULATOR FCM TOKEN:');
    print('$token');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📥 Foreground message received: ${message.notification?.title}');
    });
  }
}
