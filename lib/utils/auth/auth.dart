import 'package:dms/model/models/login_data.dart';
import 'package:dms/utils/const.dart';
import 'package:flutter/material.dart';

import '../../model/database/data_local.dart';
import '../../model/database/dbhelper.dart';
import '../../model/entity/info_login.dart';
import '../../model/models/info_cpn_data.dart';
import '../utils.dart';

enum AuthMode {hintStore,showStore }

/// The callback triggered after login
/// The result is an error message, callback successes if message is null
typedef LoginCallback = Future<bool?>? Function(LoginData);

typedef InfoCPNCallback = Future<bool?>? Function(InfoCPNData);

class Auth with ChangeNotifier {

  DatabaseHelper db = DatabaseHelper();
  List<InfoLogin> infoAccountCache =  <InfoLogin>[];


  Auth(
      {
        String hotId = '',
        String username = '',
        String password = '',
        String confirmPassword = '',
        this.onLogin,
        this.onInfoCPN,
        AuthMode initialAuthMode = AuthMode.hintStore,
      })
      : _username = username,
        _password = password,
        _mode = initialAuthMode;

  final LoginCallback? onLogin;
  final InfoCPNCallback? onInfoCPN;

  // bool get isLogin => _mode == AuthMode.login;
  bool get isInfoCPN => _mode == AuthMode.hintStore;

  AuthMode _mode = AuthMode.hintStore;
  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.hintStore) {
      mode = AuthMode.showStore;
    } else if (mode == AuthMode.showStore) {
      mode = AuthMode.hintStore;
    }
    return mode;
  }

  String _hotId = '';
  String get hotId => _hotId;
  set hotId(String hotId) {
    _hotId = hotId.toString().trim().replaceAll('https://', '').replaceAll('-cloud.sse.net.vn', '');
    notifyListeners();
  }

  String _username = '';
  String get username => _username;
  set username(String username) {
    _username = username;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  AuthMode opposite() {
    return AuthMode.hintStore;
  }

  Future<List<InfoLogin>?> getInfoAccountCache() async {
    infoAccountCache = await db.fetchAllInfoLogin();
    if (!Utils.isEmpty(infoAccountCache)) {
      DataLocal.hotIdName = infoAccountCache[0].hotURL;
      DataLocal.accountName = infoAccountCache[0].id;
      DataLocal.passwordAccount = infoAccountCache[0].pass;
      DataLocal.dateLogin = infoAccountCache[0].dateLogin;

      DataLocal.userId = infoAccountCache[0].userId;
      DataLocal.userName = infoAccountCache[0].userName;
      DataLocal.fullName = infoAccountCache[0].fullName;

      Const.isWoPrice = infoAccountCache[0].woPrice == 1 ? true : false;
      Const.autoAddDiscount = infoAccountCache[0].autoAddDiscount == 1 ? true : false;
      Const.addProductFollowStore = infoAccountCache[0].addProductFollowStore == 1 ? true : false;
      Const.allowViewPriceAndTotalPriceProductGift = infoAccountCache[0].allowViewPriceAndTotalPriceProductGift == 1 ? true : false;
      return infoAccountCache;
    }else{
      return null;
    }
  }

  Future<List<InfoLogin>> getInfoAccountCacheFromDb() {
    return db.fetchAllInfoLogin();
  }
}