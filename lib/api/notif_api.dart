import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:travel/main.dart';
import 'package:travel/screens/notification.dart';

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;


  final _androidchannel = const AndroidNotificationChannel(
    'high importance channel',
    'HIgh Importance Notifications',
    description:'This channel is used for notifcation',
    importance: Importance.defaultImportance,
  );

  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    String? fCMToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fCMToken\n\n\n\n\n");
    initPushNotifications();
    initLocalNotifications();

    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  }

  void handleMessage(RemoteMessage? message){
      if(message==null){
        return;
      }
      navigatorkey.currentState?.pushNamed(
        NotificationScreen.route,
        arguments: message,
      );
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final androidNotification = message.notification?.android;

      if (notification == null || androidNotification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidchannel.id, // Channel ID
            _androidchannel.name, // Channel name
            channelDescription: _androidchannel.description, // Channel description
            importance: Importance.max, // Set importance
            priority: Priority.high,   // Set priority
            icon: '@mipmap/ic_launcher', // Define app icon for notification
          ),
        ),
        payload: jsonEncode(message.toMap()),
      );
    });

    final platform = _localNotifications.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
    await platform?.createNotificationChannel(_androidchannel);
  }

  Future<void> initLocalNotifications() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        final payload = notificationResponse.payload;
        if (payload != null) {
          // Decode the payload string into a Map
          final Map<String, dynamic> data = jsonDecode(payload);
          // Convert Map to RemoteMessage if necessary
          final message = RemoteMessage.fromMap(data);
          handleMessage(message);
        }
      },
    );
  }

  // Background message handler
  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Payload: ${message.data}');
  }

}
