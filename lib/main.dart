import 'dart:io';

// import 'package:camera/camera.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dms/screen/login/login_screen.dart';
import 'package:dms/services/base_state.dart';
import 'package:dms/services/notification_config.dart';
import 'package:dms/services/generate-key-server.dart';
import 'package:dms/services/notification_permissions.dart';
import 'package:dms/services/services_config.dart';
import 'package:dms/utils/auth/auth.dart';
import 'package:dms/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:firebase_core/firebase_core.dart';

import 'model/database/database_firebase.dart';
import 'model/database/dbhelper.dart';
import 'package:intl/date_symbol_data_local.dart';


class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true; }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  // Run independent initializations in parallel
  await Future.wait([
    initializeDateFormatting('vi_VN', null),
    GetStorage.init(),
  ]);

  // Ensure Firebase is ready before configuring notifications
  await Firebase.initializeApp();
  await NotificationConfig.initialize();

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final key = const ValueKey('my overlay');
  ServicesGeoLocation currentLocation = ServicesGeoLocation();
  late QuerySnapshot snapshotVersionApp;
  ServerKeyService  serverKeyService = ServerKeyService();
  NotificationPermissions notificationPermissions = NotificationPermissions();
  DatabaseHelper db = DatabaseHelper();
  final AppLifecycleService _lifecycleService = AppLifecycleService();


  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    // check();
    DatabaseMethods databaseMethods = DatabaseMethods();
    databaseMethods.getAccountVipMember();
    getCamera();
    db.fetchAllInfoLogin();
    Auth().getInfoAccountCache();
  }

  void check(){
    if (_lifecycleService.isAppInForeground()) {
      print("App đang ở foreground");
    } else if (_lifecycleService.isAppInBackground()) {
      print("App đang ở background");
    } else if (_lifecycleService.isAppInactive()) {
      print("App đang inactive");
    } else if (_lifecycleService.isAppDetached()) {
      print("App đang detached");
    }
  }
  Future<void> getValuesToken() async {
    await serverKeyService.getServiceKey();
    await notificationPermissions.getDeviceToken();
  }

  void getCamera()async{
    try {
      Const.cameras = await availableCameras();
    } on CameraException catch (e) {
      debugPrint('code: ${e.code}');
      debugPrint('description: ${e.description}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      key: key,
      child: OKToast(
        child: MaterialApp(
          navigatorKey: navigatorKey,
          // theme: ThemeData.light(useMaterial3: true),
          // darkTheme: ThemeData.dark(useMaterial3: true),
          // localizationsDelegates: const [
          //   GlobalMaterialLocalizations.delegate,
          //   GlobalWidgetsLocalizations.delegate,
          //   GlobalCupertinoLocalizations.delegate,
          // ],
          // supportedLocales:const [
          //   Locale('vi', 'VN'),
          //   // arabic, no country code
          // ],
          title: 'SSE DMS',
          theme: ThemeData(
            useMaterial3: false,
            visualDensity:  VisualDensity.adaptivePlatformDensity,
            primarySwatch: Colors.orange,
            // Lock app font to avoid being affected by device font changes
            fontFamily: 'Roboto',
          ),
          debugShowCheckedModeBanner: false,
          // initialRoute: RouterGenerator.routeIntro,
          home:const LoginScreen(),//InfoCPNScreen
          builder: (context, child) {
            return MediaQuery(
              /// chặn chữ phóng to
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        ),
      ),
    );
  }

}