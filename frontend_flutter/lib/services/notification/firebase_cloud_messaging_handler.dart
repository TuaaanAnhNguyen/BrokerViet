// lib/services/notification/firebase_cloud_messaging_handler.dart

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../navigation_service.dart';

class FcmHandler {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final _supabase = Supabase.instance.client;

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final response = await _supabase.functions.invoke(
        'update-fcm-token',
        body: {'token': token},
      );

      print("FCM Token Sync Response: ${response.data}");
    } catch (e) {
      print("Failed syncing FCM token: $e");
    }
  }

  Future<void> registerCurrentDevice() async {
    final token = await _fcm.getToken();

    if (token == null) {
      print("No FCM token available.");
      return;
    }

    print("Registering FCM Token: $token");

    await _sendTokenToBackend(token);
  }

  Future<void> initNotificationLifecycle() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print("FCM Permission: ${settings.authorizationStatus}");

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      "high_importance_channel",
      "High Importance Notifications",
      description:
          "This channel is used for important broker and chat updates.",
      importance: Importance.max,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    await registerCurrentDevice();

    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final android = message.notification?.android;

      print("Foreground Notification: ${notification?.title}");

      if (notification != null && android != null) {
        _localNotifications.show(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              "high_importance_channel",
              "High Importance Notifications",
              channelDescription:
                  "This channel is used for chat updates.",
              importance: Importance.max,
              priority: Priority.high,
              icon: "@mipmap/ic_launcher",
            ),
          ),
          payload: message.data.toString(),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) async {
      print("Notification clicked.");

      await NavigationService.handleNotification(message.data);
    });

    final initialMessage = await _fcm.getInitialMessage();

    if (initialMessage != null) {
      print("Opened from terminated state.");

      await NavigationService.handleNotification(initialMessage.data);
    }

    _fcm.onTokenRefresh.listen((newToken) async {
      print("Token refreshed.");

      await _sendTokenToBackend(newToken);
    });
  }
}
