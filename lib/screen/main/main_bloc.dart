import 'dart:io';

import 'package:dms/model/database/data_local.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../utils/const.dart';
import '../../utils/utils.dart';
import '../login/login_screen.dart';
import 'main_event.dart';
import 'main_state.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // print( message.notification!.title.toString());
//   Utils.showForegroundNotification(contexts!, message.notification!.title.toString(), message.notification!.body.toString(), onTapNotification: () {
//   },);
// }
// BuildContext? contexts;

class MainBloc extends Bloc<MainEvent,MainState>{

  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  BuildContext? context;
  String? userName;
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;
  int indexBanner = 0;

  static final _messaging = FirebaseMessaging.instance;

  init(BuildContext context) {
    if (this.context == null) {
      this.context = context;
    }
    DataLocal.context ??= context;
    // _networkFactory = NetWorkFactory(context);
  }

  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    // print( message.notification!.title.toString());
    Utils.showForegroundNotification(context!, message.notification!.title.toString(), message.notification!.body.toString(), onTapNotification: ()=>  PersistentNavBarNavigator.pushNewScreen(context!,
        screen: const LoginScreen(), withNavBar: false),);
  }

  registerUpPushNotification() {
    //REGISTER REQUIRED FOR IOS
    if (Platform.isIOS) {
      _messaging.requestPermission();
    }else{
      _messaging.requestPermission();
    }
    _messaging.getToken().then((value) {
      if (value == null) return;
      print("FCM Token: $value");
    });
  }

  String savedMessageId  = "";

  _listenToPushNotifications() {
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(badge: true, alert: true, sound: true);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (savedMessageId != message.messageId) {
        savedMessageId  = message.messageId!;
      } else {
        return;
      }
      print("onMessage$savedMessageId");
      subscribeToTopic(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (savedMessageId != message.messageId) {
        savedMessageId  = message.messageId!;
      } else {
        return;
      }
      print("onMessageOpenedApp$savedMessageId");
      subscribeToTopic(message);
    });
  }

  void subscribeToTopic(RemoteMessage message){
    Utils.showForegroundNotification(context!, message.notification!.title.toString(), message.notification!.body.toString(), onTapNotification: () {},);
  }

  // void showNotification({String? title, String? body,})async {
  //   var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
  //
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //   AndroidNotificationDetails(
  //       'your channel id', 'your channel name',
  //       importance: Importance.max,
  //       priority: Priority.high,
  //       playSound: true,
  //       sound: RawResourceAndroidNotificationSound('arrive'),
  //       showWhen: true);
  //
  //   const NotificationDetails platformChannelSpecifics =
  //   NotificationDetails(android: androidPlatformChannelSpecifics);
  //
  //   await flutterLocalNotificationsPlugin.show(
  //       0, 'plain title', 'plain body', platformChannelSpecifics,
  //       payload: 'item x');
  // }

  MainBloc(this.context) : super(InitialMainState()){
    // registerUpPushNotification();
    // _listenToPushNotifications();
    on<GetPrefs>(_getPrefs);

  }

  final box = GetStorage();
  void _getPrefs(GetPrefs event, Emitter<MainState> emitter)async{
    emitter(InitialMainState());

    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    userName = box.read(Const.USER_NAME);
    emitter(GetPrefsSuccess());
  }
}


