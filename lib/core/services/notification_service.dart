import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:developer' as developer;
import 'package:dr_shine_app/bootstrap.dart';

class NotificationService {
  FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  Future<void> initialize() async {
    if (!isFirebaseInitialized) return;
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      developer.log('User granted permission');
    } else {
      developer.log('User declined or has not accepted permission');
    }

    // Get token
    String? token = await _fcm.getToken();
    developer.log('FCM Token: $token');

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      developer.log('Got a message whilst in the foreground!');
      developer.log('Message data: ${message.data}');

      if (message.notification != null) {
        developer.log('Message also contained a notification: ${message.notification}');
      }
    });
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    developer.log('Handling a background message: ${message.messageId}');
  }
}
