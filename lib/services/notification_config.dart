import 'dart:convert';

import 'package:dms/main.dart';
import 'package:dms/screen/notification/detail_notfication/detail_notification_screen.dart';
import 'package:dms/screen/personnel/time_keeping/component/baseState.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

import '../screen/login/login_screen.dart';
import '../utils/const.dart';
import 'base_state.dart';

class NotificationConfig extends BaseState{

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();




  static Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@drawable/ic_notification');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings =
        InitializationSettings(android: androidSettings, iOS: iosSettings);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
      onDidReceiveNotificationResponse: _notificationTapBackground,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    registerUpPushNotification();
    await initializeFCM();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {

      if (message != null && message.data['LinkDetail'] != null) {
        String title = message.data['title'] ?? '';
        String sttRec = message.data['stt_rec'] ?? '';
        String idApproval = message.data['loai_duyet'] ?? '';
        String html = message.data['dataContent'] ?? '';
        String type = message.data['type'] ?? '';
        String code = message.data['code'] ?? '';
        if (html.isNotEmpty) {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => DetailNotificationScreen(
                htmlData: html,
                sttRec: sttRec,
                title: title,
                type: type,
                idApproval: idApproval,
                isNotificationBackground: true,
                code: code,
              ),
            ),
          );
        }
      }
    });
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const androidNotificationDetails = AndroidNotificationDetails(
      "DMS",
      "DMS",
      channelDescription: 'Description',
      importance: Importance.high,
      priority: Priority.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    );
    const iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification.caf',
    );

    const platformDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: iOSPlatformChannelSpecifics);
    String payload = json.encode({
      'title': message.data['title'] ?? '',
      'stt_rec': message.data['stt_rec'] ?? '',
      'loai_duyet': message.data['loai_duyet'] ?? '',
      'dataContent': message.data['dataContent'] ?? '',
      'type': message.data['type'] ?? '',
      'code': message.data['code'] ?? '',
    });

    await flutterLocalNotificationsPlugin.show(
      0,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      platformDetails,
      payload: payload,
    );
  }

  static Future<void> initializeFCM() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (Platform.isAndroid) {
        if (message.notification != null && message.data.isNotEmpty) {
          await showNotification(
            message,
          );
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      String title = message.data['title'] ?? '';
      String sttRec = message.data['stt_rec'] ?? '';
      String idApproval = message.data['loai_duyet'] ?? '';
      String html = message.data['dataContent'] ?? '';
      String type = message.data['type'] ?? '';
      String code = message.data['code'] ?? '';

      if (html.isNotEmpty) {
        if(Const.appLifecycleStateChanged == AppLifecycleState.resumed || Const.appLifecycleStateChanged == AppLifecycleState.inactive){
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => DetailNotificationScreen(
                htmlData: html,
                sttRec: sttRec,
                title: title,
                idApproval: idApproval,
                type: type,
                isNotificationBackground: true,
                code: code,
              ),
            ),
          );
        }
        else{
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => LoginScreen(),
            ),
          );
        }
      }
    });

    if (Platform.isIOS) {
      FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }


  static void _notificationTapBackground(
      NotificationResponse notificationResponse) {
    if (notificationResponse.payload != null && (notificationResponse.payload ?? '').isNotEmpty) {
      Map<String, dynamic> payloadData =
          json.decode(notificationResponse.payload!);

      String htmlData = payloadData['dataContent'] ?? '';
      String title = payloadData['title'] ?? '';
      String sttRec = payloadData['stt_rec'] ?? '';
      String idApproval = payloadData['loai_duyet'] ?? '';
      String type = payloadData['type'] ?? '';
      String code = payloadData['code'] ?? '';

      if(Const.appLifecycleStateChanged == AppLifecycleState.resumed || Const.appLifecycleStateChanged == AppLifecycleState.inactive){
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => DetailNotificationScreen(
              htmlData: htmlData,
              sttRec: sttRec,
              title: title,
              type: type,
              idApproval: idApproval,
              isNotificationBackground: true,
              code: code,
            ),
          ),
        );
      }
      else{
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      }
    }
  }

  static void registerUpPushNotification() {
    final messaging = FirebaseMessaging.instance;

    messaging.requestPermission();

    messaging.getToken().then((value) {
      if (value == null) return;
      print("FCM Token: $value");
    });
  }
}
