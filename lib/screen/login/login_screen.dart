import 'package:dms/route/custom_route.dart';
import 'package:dms/screen/info_cpn/info_cpn_screen.dart';
import 'package:dms/screen/login/login_bloc.dart';
import 'package:dms/utils/const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'component/custom_login.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/auth';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Duration get loginTime => Duration(milliseconds: timeDilation.ceil() * 5250);

  late LoginBloc _loginBloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loginBloc = LoginBloc(context);
    _loginBloc.add(GetPrefsLoginEvent());
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: BlocProvider(
        create: (context) => _loginBloc,
        child: BlocListener<LoginBloc, LoginState>(
          bloc: _loginBloc,
          listener: (context,state){
            if (state is LoginFailure) {
              Const.HOST_URL = '';
              Const.PORT_URL = 0;
            }
          },
          child: BlocBuilder<LoginBloc, LoginState>(
            bloc: _loginBloc,
            builder: (BuildContext context, LoginState state){
              return CustomLogin(
                logo: const AssetImage('assets/images/logo.png'),
                logoTag: Const.logoTag,
                titleTag: Const.titleTag,
                onLogin: (loginData) async{
                  bool? success;
                   success = await _loginBloc.login(
                       ('${!loginData.hotId.contains('https://')?'https://':''}${loginData.hotId}${!loginData.hotId.contains('-cloud.sse.net.vn') ? '-cloud.sse.net.vn':''}' ).toString().trim().replaceAll(' ', '').toLowerCase(),
                       loginData.username,
                       loginData.password,false);
                  // success = await _loginBloc.login("https://thienvuong-cloud.sse.net.vn", "dat", "123abc",false);
                  return success;
                },
                onSubmitAnimationCompleted: () {
                  Navigator.of(context).pushReplacement(FadePageRoute(
                    builder: (context) =>InfoCPNScreen(username: _loginBloc.userName.toString(),accessToken: _loginBloc.accessToken.toString(),),
                  ));
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
