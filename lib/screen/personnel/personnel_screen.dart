import 'dart:io';

import 'package:dms/screen/notification/notification/notification_screen.dart';
import 'package:dms/screen/personnel/personnel_bloc.dart';
import 'package:dms/screen/personnel/personnel_event.dart';
import 'package:dms/screen/personnel/personnel_state.dart';
import 'package:dms/screen/personnel/proposal/proposal_screen.dart';
import 'package:dms/screen/personnel/suggestions/suggestions_screen.dart';
import 'package:dms/screen/personnel/time_keeping/time_keeping_screen.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import 'component/list_dnc.dart';
import 'component/list_history_leave_letter.dart';

class PersonnelScreen extends StatefulWidget {
  const PersonnelScreen({Key? key}) : super(key: key);

  @override
  _PersonnelScreenState createState() => _PersonnelScreenState();
}

class _PersonnelScreenState extends State<PersonnelScreen> {
  late PersonnelBloc _bloc;
  bool isDropdownOpen = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = PersonnelBloc(context);
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? Listener(
            onPointerMove: (event) {
              if (event.delta.dx > 0) {
                Navigator.pop(
                    context, Const.isEnableNotification ? ['Reload'] : null);
              }
            },
            child: buildScaffold(context),
          )
        : WillPopScope(
            onWillPop: () async {
              Navigator.pop(
                  context, Const.isEnableNotification ? ['Reload'] : null);
              return false;
            },
            child: buildScaffold(context),
          );
  }

  Scaffold buildScaffold(BuildContext context) {
    return Scaffold(
      body: BlocListener<PersonnelBloc, PersonnelState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is TimeKeepingSuccess) {
            Utils.showCustomToast(context, Icons.check_circle_outline,
                'Yeah, Đã ghi nhận thời gian chấm công');
          } else if (state is TimeKeepingFailure) {
            Utils.showCustomToast(
                context, Icons.warning_amber_outlined, state.error);
          }
        },
        child: BlocBuilder<PersonnelBloc, PersonnelState>(
          bloc: _bloc,
          builder: (BuildContext context, PersonnelState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is PersonnelLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  buildBody(BuildContext context, PersonnelState state) {
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
                buildTitle('Chấm công'),
                // InkWell(
                //   onTap: (){
                //     if(Const.timeKeeping == true){
                //       showDialog(
                //           context: context,
                //           builder: (context) {
                //             return WillPopScope(
                //               onWillPop: () async => false,
                //               child: CustomQuestionComponent(
                //                 showTwoButton: true,
                //                 iconData: Icons.warning_amber_outlined,
                //                 title: 'Bạn đang thực hiện chấm công!!!',
                //                 content: 'Thời gian chấm công: ${DateTime.now().hour}:${DateTime.now().minute < 10 ? ('0${DateTime.now().minute}') :DateTime.now().minute  }:${DateTime.now().second}',
                //               ),
                //             );
                //           }).then((value)async{
                //         if(value != null){
                //           if(!Utils.isEmpty(value) && value == 'Yeah'){
                //             _bloc.add(LoadingTimeKeeping(uId: Const.uId));
                //           }
                //         }
                //       });
                //     }else{
                //       Utils.showUpgradeAccount(context);
                //     }
                //   },
                //   child:  buildButton('Chấm công',MdiIcons.timetable, Const.timeKeeping == true? false : true),
                // ),
                InkWell(
                  onTap: () {
                    if (Const.tableTimeKeeping == true) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: const TimeKeepingScreen(), withNavBar: false);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },
                  child: buildButton('Bảng chấm công', MdiIcons.tableAccount,
                      Const.tableTimeKeeping == true ? false : true),
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    InkWell(
                        onTap: () {
                          setState(() {
                            isDropdownOpen = !isDropdownOpen;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.withOpacity(0.2)),
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 7, bottom: 7),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Đề nghị",
                                    style: const TextStyle(
                                        color: subColor, fontSize: 13),
                                  ),
                                  Icon(
                                    isDropdownOpen
                                        ? Icons.keyboard_arrow_up
                                        : Icons.keyboard_arrow_down,
                                    color: subColor,
                                  )
                                ],
                              )),
                        )),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: isDropdownOpen ? 280 : 0,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                if(Const.businessTrip == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'đề xuất đi công tác', controller: 'BusinessTrip',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton('Đề xuất đi công tác',
                                  MdiIcons.calendarAccountOutline, Const.businessTrip == true ? false : true),
                            ),
                            InkWell(
                              onTap: () {
                                if(Const.dayOff == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'xin nghỉ phép', controller: 'DayOff',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton(
                                  'Xin nghỉ phép', MdiIcons.accountOff, Const.dayOff == true ? false : true),
                            ),
                            InkWell(
                              onTap: () {
                                if(Const.overTime == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'Xin tăng ca', controller: 'OverTime',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton(
                                  'Xin tăng ca', MdiIcons.clock, Const.overTime == true ? false : true),
                            ),
                            InkWell(
                              onTap: () {
                                if(Const.advanceRequest == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'Tạm ứng', controller: 'AdvanceRequest',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton(
                                  'Tạm ứng', Icons.monetization_on_outlined, Const.advanceRequest == true ? false : true),
                            ),
                            InkWell(
                              onTap: () {
                                if(Const.checkInExPlan == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'Giải trình chấm công', controller: 'CheckinExplan',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton('Giải trình chấm công',
                                  MdiIcons.calendarClock, Const.checkInExPlan == true ? false : true),
                            ),
                            InkWell(
                              onTap: () {
                                if(Const.carRequest == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'Đăng kí xe', controller: 'CarRequest',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton(
                                  'Đăng kí xe', MdiIcons.truckFast, Const.carRequest == true ? false : true),
                            ),
                            InkWell(
                              onTap: () {
                                if(Const.meetingRoom == true){
                                  PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const ProposalScreen(
                                        title: 'Đăng kí phòng họp', controller: 'MeetingRoom',
                                      ),
                                      withNavBar: true);
                                }else{
                                  Utils.showUpgradeAccount(context);
                                }
                              },
                              child: buildButton('Đăng kí phòng họp',
                                  MdiIcons.officeBuilding, Const.meetingRoom == true ? false : true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // InkWell(
                //   onTap: (){
                //     if(Const.onLeave == true){
                //       PersistentNavBarNavigator.pushNewScreen(context, screen: const HistoryLeaveLetterScreen(),withNavBar: true);
                //     }else{
                //       Utils.showUpgradeAccount(context);
                //     }
                //   },
                //   child:  buildButton('Nghỉ phép / tăng ca / công tác',MdiIcons.calendarAccountOutline, Const.onLeave == true? false : true),
                // ),
                // InkWell(
                //   onTap: (){
                //     if(Const.recommendSpending == true){
                //       PersistentNavBarNavigator.pushNewScreen(context, screen: const ListDNC(),withNavBar: true);
                //     }else{
                //       Utils.showUpgradeAccount(context);
                //     }
                //   },
                //   child:  buildButton('Đề nghị chi / tạm ứng',Icons.monetization_on_outlined, Const.recommendSpending == true? false : true),
                // ),
                // InkWell(
                //   onTap: (){
                //     if(Const.articleCar == true){
                //       PersistentNavBarNavigator.pushNewScreen(context, screen: const SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                //     }else{
                //       Utils.showUpgradeAccount(context);
                //     }
                //   },
                //   child:  buildButton('Điều xe',MdiIcons.truckFast, Const.articleCar == true? false : true),
                // ),
                const SizedBox(
                  height: 10,
                ),
                buildTitle('Công việc'),
                InkWell(
                  onTap: () {
                    if (Const.createNewWork == true) {
                      //   pushNewScreen(context, screen: SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },
                  child: buildButton('Thêm mới công việc', Icons.note_add,
                      Const.createNewWork == true ? false : true),
                ),
                InkWell(
                  onTap: () {
                    if (Const.workAssigned == true) {
                      //   pushNewScreen(context, screen: SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },
                  child: buildButton(
                      'Công việc tôi giao',
                      MdiIcons.pencilBoxMultipleOutline,
                      Const.workAssigned == true ? false : true),
                ),
                InkWell(
                  onTap: () {
                    if (Const.myWork == true) {
                      //   pushNewScreen(context, screen: SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },
                  child: buildButton('Công việc của tôi', MdiIcons.timetable,
                      Const.myWork == true ? false : true),
                ),
                InkWell(
                  onTap: () {
                    if (Const.workInvolved == true) {
                      //   pushNewScreen(context, screen: SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                    } else {
                      Utils.showUpgradeAccount(context);
                    }
                  },
                  child: buildButton(
                      'Công việc tôi liên quan',
                      Icons.fact_check,
                      Const.workInvolved == true ? false : true),
                ),
                const SizedBox(
                  height: 10,
                ),
                buildTitle('Thông tin nhân sự & phòng ban'),
                InkWell(
                  onTap: () {
                    // if(Const.workInvolved == true){
                    //     pushNewScreen(context, screen: SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                    // }else{
                    //   Utils.showUpgradeAccount(context);
                    // }
                    Utils.showUpgradeAccount(context);
                  },
                  child: buildButton('Thông tin nhân viên',
                      MdiIcons.accountDetailsOutline, true),
                ),
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
            //onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=> NotificationPage())),
            onTap: () {
              if (Const.isEnableNotification == true) {
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
                  if (_bloc.totalUnreadNotification > 0 &&
                      Const.isEnableNotification == true)
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
                              _bloc.totalUnreadNotification > 99
                                  ? '99+'
                                  : _bloc.totalUnreadNotification.toString(),
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

  buildTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
        child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(color: subColor, fontSize: 13),
            )),
      ),
    );
  }

  buildButton(String title, IconData icons, bool lock) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Center(
            child: Icon(
              icons,
              size: 24,
              color: lock == false ? subColor : Colors.grey,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                  color: lock == false ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.normal),
            ),
          ),
          lock == false
              ? const Icon(Icons.navigate_next)
              : const Icon(
                  Icons.lock,
                  color: Colors.grey,
                ),
        ],
      ),
    );
  }
}
