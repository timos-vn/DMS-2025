import 'package:dms/screen/main/main_screen.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

import '../../utils/const.dart';
import '../../route/custom_route.dart';
import 'component/custom_info_cpn.dart';
import 'info_cpn_bloc.dart';
import 'info_cpn_event.dart';

class InfoCPNScreen extends StatefulWidget {
  final String? username;
  final String accessToken;

  const InfoCPNScreen({Key? key,this.username, required this.accessToken}) : super(key: key);

  @override
  State<InfoCPNScreen> createState() => _InfoCPNScreenState();
}

class _InfoCPNScreenState extends State<InfoCPNScreen> {

  late InfoCPNBloc _bloc;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = InfoCPNBloc(context);
    _bloc.add(GetPrefsInfoCPN());
  }

  @override
  Widget build(BuildContext context) {
    return CustomInfoCPN(
      logo: const AssetImage('assets/images/logo.png'),
      logoTag: Const.logoTag,
      titleTag: Const.titleTag,
      username: widget.username,
      onInfoCPN: (infoCPNData)async {
        bool? success;
        Const.uId = infoCPNData.uId;
        success = await _bloc.getPermissionUser();
        if(success != true){
          Utils.showCustomToast(context, Icons.warning_amber, 'Bạn không có quyền truy cập vào app');
        }
        return success;
      },
      onSubmitAnimationCompleted: () {
        Navigator.of(context).pushReplacement(FadePageRoute(
          builder: (context) => MainScreen(listMenu: _bloc.listMenu,listNavItem: _bloc.listNavItem,userName: _bloc.userName,),
        ));
      },
    );
  }
}
