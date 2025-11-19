// ignore_for_file: library_private_types_in_public_api

import 'package:dms/screen/menu/report/report_layout/report_screen.dart';
import 'package:dms/screen/menu/setting/about_sse_company.dart';
import 'package:dms/screen/menu/stage/component/stage_statistic_v2_screen.dart';
import 'package:dms/screen/menu/stage/stage_statistic/stage_statistic_screen.dart';
import 'package:dms/screen/menu/support/help_center.dart';
import 'package:dms/screen/notification/notification/notification_screen.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/custom_widget.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import '../login/login_screen.dart';
import '../personnel/personnel_screen.dart';
import '../sell/component/list_approve_order.dart';
import 'approval/approval/approval_screen.dart';
import 'approval/new_store/new_store_approval_list_screen.dart';
import 'component/history_action_employee_screen.dart';
import 'component/layout_voucher_screen.dart';
import 'menu_event.dart';
import 'support/support_center.dart';
import 'setting/profile.dart';
import 'menu_bloc.dart';
import 'menu_state.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late MenuBloc _bloc;

  late Animation<double> fadeAnimation;
  late AnimationController fadeController;
  late Animation<double> editAnimation;
  late AnimationController editController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = MenuBloc(context);
    editController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    editAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: editController,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeIn,
        ),
      ),
    );
    fadeController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
        parent: fadeController,
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeOut,
        )));

    fadeController.forward();
  }

  @override
  void dispose() {
    fadeController.dispose();
    editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<MenuBloc, MenuState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is LogOutAppSuccess) {
            PersistentNavBarNavigator.pushNewScreen(context,
                screen: const LoginScreen(), withNavBar: false);
          }
        },
        child: BlocBuilder<MenuBloc, MenuState>(
          bloc: _bloc,
          builder: (BuildContext context, MenuState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is MenuLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context, MenuState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70),
      child: Column(
        children: [
          buildAppBar(),
          const Divider(
            height: 1,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildTitle('Nhân sự tổng hợp'),
                buildButton(title: 'Nhân sự - Chấm công - Nghỉ phép',icons: EneftyIcons.personalcard_outline,lock:  Const.hrm  == true ? false : true,onTap: () {
                  if (Const.hrm == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const PersonnelScreen(), withNavBar: false).then((value) {
                      if (value != null && value[0] == 'Reload') {
                        _bloc.add(GetTotalUnreadNotificationEvent());
                      }
                    });
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },),
                buildTitle('Báo cáo & Phiếu'),
                buildButton(title: 'Báo cáo tổng hợp',icons:  MdiIcons.chartBar, lock:  Const.report == true ? false : true, onTap: () {
                    if (Const.report == true) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const ReportScreen(), withNavBar: false);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                buildButton(title: 'Phiếu tổng hợp', icons:  EneftyIcons.stickynote_outline, lock:   Const.listVoucher == true ? false : true, onTap: () {
                    if (Const.listVoucher == true) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const LayOutVoucherScreen(),
                          withNavBar: false);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                buildButton(title: 'Duyệt phiếu tổng hợp', icons:  MdiIcons.calendarCheckOutline, lock:  Const.approval == true ? false : true,onTap: () {
                  if (Const.approval == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ApprovalScreen(), withNavBar: true);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },),
                buildButton(title: 'Duyệt đơn hàng',icons:  Icons.app_registration, lock:  Const.approveOrder == true ? false : true,  onTap: () {
                  if (Const.approveOrder == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ListApproveOrderScreen(),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },),
                buildButton(title: 'Duyệt điểm bán mở mới', icons:  MdiIcons.storeCheckOutline, lock:  Const.approveNewStore == true ? false : true, onTap: () {
                  if (Const.approveNewStore == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const NewStoreApprovalListScreen(),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },),
                const SizedBox(height: 10,),
                buildTitle('Sản xuất'),
                buildButton(title: 'Thống kê công đoạn',icons:  MdiIcons.widgets, lock:  Const.stageStatistic == true ? false : true, onTap: () {
                    if (Const.stageStatistic == true) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: StageStatisticScreen(
                            unitId: Const.unitId,
                          ),
                          withNavBar: true);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                buildButton(title: 'Thống kê công đoạn v2',icons:  MdiIcons.widgets, lock: Const.stageStatisticV2 == true ? false : true,onTap: () {
                    if (Const.stageStatisticV2 == true) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const StageStatisticV2Screen(),
                          withNavBar: true);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                const SizedBox(height: 10,),
                buildTitle('Cá nhân'),
                buildButton(title: 'Lịch sử hoạt động', icons:  MdiIcons.odnoklassniki, lock: Const.historyAction == true ? false : true, onTap: () {
                    if (Const.historyAction == true) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const HistoryActionEmployeeScreen(),
                          withNavBar: false);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },),
                const SizedBox(height: 10,),
                buildTitle('Cài đặt & Phản hồi dịch vụ'),
                buildButton(title: 'Cài đặt',icons:  Icons.settings_outlined,lock:  false, onTap: ()=> PersistentNavBarNavigator.pushNewScreen(context, screen: const ProfileScreen(), withNavBar: false)),
                buildButton(title: 'Hỗ trợ',icons:  MdiIcons.headset,lock: false,  onTap: () => PersistentNavBarNavigator.pushNewScreen(context, screen: const SupportCenterScreen(), withNavBar: false),),
                buildButton(title: 'Trung tâm trợ giúp' ,icons:  Icons.help_outline,lock:  false,  onTap: () => PersistentNavBarNavigator.pushNewScreen(context, screen: const HelpCenterScreen(), withNavBar: false),),
                buildButton(title:  'Chính sách bảo hành',icons:  Icons.description,lock:  false,onTap: () async {
                  const url =
                      'https://sse.net.vn/dich-vu/dich-vu/chinh-sach-bao-hanh.html';
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },),
                const SizedBox(height: 2,),
                buildButton(title: 'About SSE Company',icons:  MdiIcons.tie,lock:  false,  onTap: () async {
                  PersistentNavBarNavigator.pushNewScreen(context,
                      screen: const AboutSSECompanyScreen(),
                      withNavBar: false);
                },),
                const SizedBox(height: 6,),
                Container(height: 6, width: double.infinity, color: Colors.grey.withOpacity(0.2)),
                Padding(
                  padding: const EdgeInsets.only(left: 14, top: 15),
                  child: Text(
                    'Phiên bản: ${Const.versionApp}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
                buildButtonLogOut(),
                const SizedBox(
                  height: 20,
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  buildAppBar() {
    return Container(
      height: 83,
      width: double.infinity,
      decoration: BoxDecoration(
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: const Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [subColor, Color.fromARGB(255, 150, 185, 229)])),
      padding: const EdgeInsets.fromLTRB(16, 35, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Flexible(
                        flex: 2,
                        child: InkWell(
                          onTap: () {
                            // Utils.pushAndRemoveUtilKeepFirstPage(context, InfoCompanyPage(
                            //   username:  _mainBloc.userName,
                            //   listInfoUnitsID: _mainBloc.listInfoUnitsID,
                            //   listInfoUnitsName: _mainBloc.listInfoUnitsName,
                            //   currentCompanyName: _mainBloc.currentCompanyName,
                            //   currentCompanyID: _mainBloc.currentCompanyID,
                            //   getDF: true,
                            // ));
                          },
                          child: Text(
                            Const.companyName != ''
                                ? Const.companyName
                                : "Công ty ABC - Demo Công ty ABC - Demo Công ty ABC - Demo"
                                    .toUpperCase(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  Const.storeName != '' ? Const.storeName : Const.unitName,
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          InkWell(
            // onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=> NotificationScreen())),
            onTap: () {
              if(Const.isEnableNotification == true){
                PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const NotificationScreen(), withNavBar: false)
                    .then((value) {
                  if (value != null && value[0] == 'Reload') {
                    _bloc.add(GetTotalUnreadNotificationEvent());
                  }
                });
              } else { 
                Utils.showUpgradeAccount(context);
              } 
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: <Widget>[
                  Icon(
                    MdiIcons.bellOutline,
                    size: 25,
                    color: Colors.white,
                  ),
                  if (_bloc.totalUnreadNotification > 0 && Const.isEnableNotification == true)  
                  Positioned(
                    top: -4,
                    right: -8,
                    child: ClipOval(
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            _bloc.totalUnreadNotification > 99 ? '99+' : _bloc.totalUnreadNotification.toString(),
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Visibility(
                  //   visible: !Utils.isEmpty(_mainBloc.countNotifyUnRead)
                  //       &&
                  //       _mainBloc.countNotifyUnRead > 0
                  //   ,
                  //   child: Positioned(
                  //     top: -7,
                  //     right: -5,
                  //     child: Container(
                  //       alignment: Alignment.center,
                  //       padding: EdgeInsets.all(2),
                  //       decoration: BoxDecoration(
                  //         color: blue,
                  //         borderRadius: BorderRadius.circular(9),
                  //       ),
                  //       constraints: BoxConstraints(
                  //         minWidth: 17,
                  //         minHeight: 17,
                  //       ),
                  //       child: Text(
                  //         !Utils.isEmpty(_mainBloc.countNotifyUnRead)
                  //             &&
                  //             _mainBloc.countNotifyUnRead > 0
                  //             ? _mainBloc.countNotifyUnRead.toString()
                  //             : "",
                  //         style: TextStyle(
                  //           color: Colors.white,
                  //           fontSize: 10,
                  //         ),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ),
                  // )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  buildButtonLogOut() {
    return Padding(
      padding: const EdgeInsets.only(left: 14, right: 14, top: 22, bottom: 50),
      child: GestureDetector(
        onTap: () {
          showDialog(
              context: context,
              builder: (context) {
                return WillPopScope(
                  onWillPop: () async => false,
                  child: const CustomQuestionComponent(
                    showTwoButton: true,
                    iconData: Icons.warning_amber_outlined,
                    title: 'Bạn sẽ đăng xuất khỏi ứng dụng?',
                    content: 'Hãy chắc chắn bạn muốn điều này xảy ra.',
                  ),
                );
              }).then((value) async {
            if (value != null) {
              if (!Utils.isEmpty(value) && value == 'Yeah') {
                _bloc.add(LogOutAppEvent());
              }
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: mainColor,
          ),
          height: 45,
          width: double.infinity,
          child: const Center(
            child: Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
