import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> init() async {
    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground notification: ${message.notification?.title}');
    });
  }

  Future<void> subscribeToNotifications(bool enable) async {
    if (enable) {
      await _messaging.subscribeToTopic("all");
    } else {
      await _messaging.unsubscribeFromTopic("all");
    }
  }

  Future<void> printToken() async {
  String? token = await _messaging.getToken();
  print("FCM TOKEN: $token");
}

}
