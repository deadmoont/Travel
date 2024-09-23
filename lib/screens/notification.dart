import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  static const route = '/notification-screen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<RemoteMessage> notifications = [];

  @override
  void initState() {
    super.initState();

    // Initialize Firebase Messaging and handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message in the foreground!');

      setState(() {
        notifications.add(message);
      });

      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fetch the message passed via ModalRoute
    final String? message = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (message != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Message: $message',
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
          Expanded(
            child: notifications.isEmpty
                ? const Center(
              child: Text(
                'No Notifications',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                RemoteMessage notification = notifications[index];
                return ListTile(
                  leading: const Icon(Icons.notifications, color: Colors.blue),
                  title: Text(notification.notification?.title ?? 'No Title'),
                  subtitle: Text(notification.notification?.body ?? 'No Body'),
                  onTap: () {
                    // Handle notification tap, if needed
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
