// import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissions {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> requestNotificationPermission() async {
    NotificationSettings notificationSettings =
    await messaging.requestPermission(alert: true, announcement: true, badge: true, carPlay: true, criticalAlert: true, provisional: true, sound: true);

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permission Granted');
    } else if (notificationSettings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Provisional Granted');
    } else {
      print('Permission Granted Failed ');
      // Future.delayed(Duration(seconds: 2), () {
      //   AppSettings.openAppSettings(type: AppSettingsType.notification);
      // });
    }
  }

  Future<String?> getDeviceToken() async {
    // NotificationSettings notificationSettings = await messaging.requestPermission(alert: true, badge: true, sound: true);
    String? token = await messaging.getToken();
    return token;
  }
}