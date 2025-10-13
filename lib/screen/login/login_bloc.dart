// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dms/driver_transfer/api/models/user_model.dart';
import 'package:dms/driver_transfer/helper/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../model/database/data_local.dart';
import '../../model/database/database_models.dart';
import '../../model/database/dbhelper.dart';
import '../../model/entity/info_login.dart';
import '../../model/network/request/login_request.dart';
import '../../model/network/response/get_list_slider_image_response.dart';
import '../../model/network/response/login_response.dart';
import '../../model/network/services/host.dart';
import '../../model/network/services/network_factory.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'login_event.dart';
import 'login_state.dart';


class LoginBloc extends Bloc<LoginEvent,LoginState>{

  NetWorkFactory? _networkFactory;
  BuildContext context;

  String userName = '';
  String? _accessToken;
  String? get accessToken => _accessToken;
  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  DatabaseHelper db = DatabaseHelper();

  final box = GetStorage();

  List<InfoLogin> infoLoginSt = <InfoLogin>[];

  HostSingleton? hostSingleton;

  late bool loginSuccess = false;

  List<Widget> listMenu = <Widget>[];
  List<PersistentBottomNavBarItem> listNavItem =<PersistentBottomNavBarItem>[];

  QuerySnapshot? snapshotVersionApp;
  QuerySnapshot? snapshotListNews;
  String? versionGoLiveApp;
  String? versionLastUpdate;
  String? contentUpdate;

  LoginBloc(this.context) : super(InitialLoginState()){
    _networkFactory = NetWorkFactory(context);
    db = DatabaseHelper();
    db.init();
    on<GetPrefsLoginEvent>(_getPrefs,);
    on<GetVersionApp>(_getVersionApp);
    on<UpdateVersionApp>(_updateVersionApp);
    on<GetListNews>(_getListNews);
  }

  void _getPrefs(GetPrefsLoginEvent event, Emitter<LoginState> emitter)async{
    emitter(LoginLoading());

    emitter(GetPrefsLoginSuccess());
  }

  void _getVersionApp(GetVersionApp event, Emitter<LoginState> emitter)async{
    emitter(LoginLoading());
    FirebaseFirestore.instance.collection('SSE-DMS').doc('Version_App').get()
        .then((DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      if(Platform.isIOS) {
        versionGoLiveApp = data['goLiveIOS'];
      }else if(Platform.isAndroid){
        versionGoLiveApp = data['goLiveAndroid'];
      }
      contentUpdate = data['contentUpdate'];
      versionLastUpdate = Const.versionApp;
      add(UpdateVersionApp());
    },
      onError: (e) => print(e),);

  }

  void _getListNews(GetListNews event, Emitter<LoginState> emitter)async{
    emitter(LoginLoading());
    FirebaseFirestore.instance.collection('SSE-DMS').doc('News').collection('List-News').get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        ModelNews item = ModelNews(
          image: docSnapshot.data()['Image'].toString(),
          title: docSnapshot.data()['Title'].toString(),
          subTitle: docSnapshot.data()['Sub-Title'].toString(),
          link: docSnapshot.data()['Link'].toString(),
        );
        DataLocal.listNews.add(item);
      }
    },
      onError: (e) => print(e),);

    FirebaseFirestore.instance.collection('SSE-DMS').doc('Slider-Home').collection('List-Item').get()
        .then((querySnapshot) {
      for (var docSnapshot in querySnapshot.docs) {
        ListSliderImage item = ListSliderImage(
          link: docSnapshot.data()['link'].toString(),
          hyperlink: docSnapshot.data()['hyperlink'].toString(),
        );
        DataLocal.listSliderFirebase.add(item);
      }
    },
      onError: (e) => print(e),);
    emitter(InitialLoginState());
  }

  void _updateVersionApp(UpdateVersionApp event, Emitter<LoginState> emitter)async{
    emitter(GetVersionGoLiveSuccess());
  }

  Future<bool> login(String hostURL, String username, String password, bool loginAgain)async{
    Const.HOST_URL = hostURL.trim();
    hostSingleton = HostSingleton();
    hostSingleton?.host = Const.HOST_URL;
    hostSingleton?.port = Const.PORT_URL;
    _networkFactory = NetWorkFactory(context);
    LoginRequest request = LoginRequest(
        hostId: hostURL,
        userName: username,
        password: password,
        devideToken: "",
        language: "V"
    );
    LoginState state = _handleLogin(await _networkFactory!.login(request),hostURL,username,password);
    if(state is LoginSuccess){
      return true;
    }else{
      return false;
    }
    // emitter(state);
  }

  LoginState _handleLogin(Object data,String hostURL,String username,String pass) {
    if (data is String){
      DataLocal.messageLogin = data;
      return LoginFailure(data);
    }
    try {
      LoginResponse response = LoginResponse.fromJson(data as Map<String,dynamic>);
      LoginResponseUser? loginResponseUser = response.user;

      DataLocal.hotIdName = hostURL;
      DataLocal.accountName = username;
      DataLocal.passwordAccount = pass;

      Const.token = response.accessToken.toString();

      _accessToken = response.accessToken;
      _refreshToken = response.refreshToken;

      box.write(Const.ACCESS_TOKEN, _accessToken.toString());
      box.write(Const.REFRESH_TOKEN, _refreshToken.toString());

      box.write(Const.USER_ID, loginResponseUser?.userId.toString());
      box.write(Const.USER_NAME, loginResponseUser?.fullName.toString());
      box.write(Const.PHONE_NUMBER, loginResponseUser?.phoneNumber.toString());
      box.write(Const.CODE, loginResponseUser?.code.toString());
      box.write(Const.CODE_NAME, loginResponseUser?.codeName.toString());
      box.write(Const.EMAIL, loginResponseUser?.email.toString());

      box.write(Const.CODE_EMPLOYEE_SALE, loginResponseUser?.codeEmployeeSale.toString());
      box.write(Const.CODE_DEPARTMENT, loginResponseUser?.codeDepartment.toString());
      box.write(Const.NAME_DEPARTMENT, loginResponseUser?.nameDepartment.toString());
      box.write(Const.REMAINING_DAYS_OFF, loginResponseUser?.remainingDaysOff.toString());
      box.write(Const.ROLES, loginResponseUser?.role.toString());

      UserModel _user = UserModel(
        dataUser: DataUser(
          id: loginResponseUser?.userId.toString(),
          firstName: loginResponseUser?.fullName.toString(),
          lastName: '',
          userName: loginResponseUser?.userName.toString(),
          isManager: loginResponseUser?.role == 2 ? true : false
        ),
        token: _accessToken.toString()
      );
      user  = _user;
      // Safe handling với giá trị mặc định
      userName = response.user?.userName ?? '';
      Const.userName = response.user?.userName ?? '';
      Const.userId = response.user?.userId ?? 0;
      Const.phepCL = response.user?.nghiCL ?? 0;
      Const.maNvbh = response.user?.maNvbh?.toString() ?? '';
      Const.maNPP = response.user?.maNPP?.toString() ?? '';
      // Utils.saveDataLogin(_prefs, loginResponseUser!,_accessToken!,_refreshToken!);
      pushService(
          hostURLPORT:hostURL.toString().trim().replaceAll('https://', '').replaceAll('-cloud.sse.net.vn', '')
          ,username:username,pass:pass,accessToken: _accessToken.toString(),refreshToken: _refreshToken.toString(),
      userId: (response.user?.userId ?? 0).toString(),
      userName: response.user?.userName ?? '',
      fullName: response.user?.fullName ?? '');

      return LoginSuccess();
    } catch (e) {
      loginSuccess = false;
      return LoginFailure('Úi, ${e.toString()}');
    }
  }

  void pushService({required String hostURLPORT,required String username,required  String pass,required String accessToken,
    required String refreshToken,
    required String userId,
    required String userName,required String fullName}) async{
    InfoLogin _infoLogin = InfoLogin(
        'vi',
        'Tiếng Việt',
        hostURLPORT,
        username,
        pass,
        DateTime.now().toString(),
        accessToken,refreshToken,userId,userName,fullName,
        Const.woPrice == true ? 1 : 0,
        Const.autoAddDiscount == true ? 1 : 0,
        Const.addProductFollowStore == true ? 1 : 0,
        Const.allowViewPriceAndTotalPriceProductGift == true ? 1 : 0,
    );

    await db.addInfoLogin(_infoLogin);
    infoLoginSt = await getListFromDb();
    if(!Utils.isEmpty(infoLoginSt)){
      db.updateInfoLogin(_infoLogin);
    }
  }

  Future<List<InfoLogin>> getListFromDb() {
    return db.fetchAllInfoLogin();
  }
}