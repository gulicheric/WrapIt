import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  final _firebaseMessage = FirebaseMessaging.instance;

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print("Title: ${message.notification?.title}");
  }

  Future<void> initNotification() async {
    await _firebaseMessage.requestPermission();
    final fCMToken = await _firebaseMessage.getToken();
    print('FCM Token: $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
