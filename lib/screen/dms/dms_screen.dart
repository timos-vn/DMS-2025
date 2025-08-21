// ignore_for_file: library_private_types_in_public_api

import 'dart:io';

import 'package:dms/screen/dms/customer_care/customer_care_screen.dart';
import 'package:dms/screen/dms/refund_sale_out/component/list_history_refund_sale_out_screen.dart';
import 'package:dms/screen/dms/report_location/report_location_screen.dart';
import 'package:dms/screen/dms/sale_out/component/history_sale_out_screen.dart';
import 'package:dms/screen/dms/ticket/ticket_screen.dart';
import 'package:dms/screen/notification/notification/notification_screen.dart';
import 'package:dms/widget/custom_question.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:dms/screen/dms/shipping/shipping_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../driver_transfer/helper/location_service.dart';
import '../../driver_transfer/src/check_permission.dart';
import '../../driver_transfer/src/employee/employee_screen.dart';
import '../../driver_transfer/src/manager/manager_screen.dart';
import '../../model/database/data_local.dart';
import '../../themes/colors.dart';
import '../../utils/const.dart';
import '../../utils/utils.dart';
import '../customer/search_customer/search_customer_screen.dart';
import '../personnel/component/employee_screen.dart';
import 'check_in/check_in_screen.dart';
import 'check_in/component/syn_check_in.dart';
import 'component/list_customer_dms_screen.dart';
import 'component/request_open_store.dart';
import 'delivery/delivery_plan/delivery_plan_screen.dart';
import 'dms_bloc.dart';
import 'dms_event.dart';
import 'dms_state.dart';
import 'inventory/list_inventory_request_screen.dart';
import 'kpi/kpi_screen.dart';

class DMSScreen extends StatefulWidget {
  const DMSScreen({
    Key? key,
  }) : super(key: key);

  @override
  _DMSScreenState createState() => _DMSScreenState();
}

class _DMSScreenState extends State<DMSScreen> {
  late DMSBloc _bloc;

  bool reloadData = true;

  final _controller = ValueNotifier<bool>(Const.checkInOnline);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = DMSBloc(context);
    _bloc.add(GetPrefsDMSEvent());
    _controller.addListener(() {
      if (_controller.value) {
        showDialog(
            context: context,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: const CustomQuestionComponent(
                  showTwoButton: false,
                  iconData: Icons.warning_amber_outlined,
                  title: 'Chế độ Online',
                  content:
                      'Hãy đảm bảo mạng internet: 3G,4G,wifi của bạn ổn định để thực hiện tính năng check-in này',
                ),
              );
            }).then((value) async {
          if (value != null) {
            if (!Utils.isEmpty(value) && value == 'Yeah') {
              Const.checkInOnline = true;
            }
          }
        });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return WillPopScope(
                onWillPop: () async => false,
                child: const CustomQuestionComponent(
                  showTwoButton: false,
                  iconData: Icons.warning_amber_outlined,
                  title: 'Chế độ Offline',
                  content:
                      'Chế độ này giúp bạn check-in ngay cả khi không có internet',
                ),
              );
            }).then((value) async {
          if (value != null) {
            if (!Utils.isEmpty(value) && value == 'Yeah') {
              if (_bloc.listCheckInOffline.isNotEmpty &&
                  _bloc.listItemAlbum.isNotEmpty &&
                  _bloc.listAlbumTicketOffLine.isNotEmpty) {
                Const.checkInOnline = false;
                PersistentNavBarNavigator.pushNewScreen(context,
                    screen: CheckInScreen(
                      reloadData: false,
                      listCheckInToDay: _bloc.listCheckInOffline,
                      listAlbumTicketOffLine: _bloc.listAlbumTicketOffLine,
                      listAlbumOffline: _bloc.listItemAlbum,
                      userId: _bloc.userId,
                    ),
                    withNavBar: false);
              } else {
                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    Const.checkInOnline = false;
                    // ignore: use_build_context_synchronously
                    showDialog(
                        context: context,
                        builder: (context) {
                          return WillPopScope(
                            onWillPop: () async => false,
                            child: const CustomQuestionComponent(
                              showTwoButton: false,
                              iconData: Icons.warning_amber_outlined,
                              title: 'Đồng bộ dữ liệu',
                              content:
                                  'Quá trình đồng bộ sẽ lấy dữ liệu để giúp bạn check-in ngay cả khi không có internet.',
                            ),
                          );
                        }).then((value) async {
                      if (value != null) {
                        if (!Utils.isEmpty(value) && value == 'Yeah') {
                          _bloc.add(GetListTaskOffLineEvent(nextScreen: 1));
                        }
                      }
                    });
                  }
                } on SocketException catch (_) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return WillPopScope(
                          onWillPop: () async => false,
                          child: const CustomQuestionComponent(
                            showTwoButton: false,
                            iconData: Icons.wifi_off,
                            title: 'No Internet',
                            content:
                                'Không thể đồng bộ dữ liệu. Vui lòng kiểm tra mạng 3G,4G,Wifi của bạn',
                          ),
                        );
                      }).then((value) => _controller.value = true);
                }
              }
            }
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<DMSBloc, DMSState>(
        bloc: _bloc,
        listener: (context, state) {
          if (state is GetPrefsSuccess) {
            _bloc.add(GetListStatusOrder(vcCode: 'DX2'));
            if (Const.useTax == true && DataLocal.listTax.isEmpty) {
              _bloc.add(GetListTax());
            }
            // if((Const.isVvHd == true || Const.isVv == true || Const.isHd == true) && (DataLocal.listVv.isEmpty || DataLocal.listHd.isEmpty)){
            //   _bloc.add(GetListVVHD());
            // }
          } else if (state is DMSFailure) {
            Utils.showCustomToast(
                context, Icons.warning_amber_outlined, state.error.toString());
          } else if (state is GetValuesClientSuccess) {
            checkInternet();
          } else if (state is GetListTaskOffLineSuccess) {
            if (state.nextScreen == 1) {
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: CheckInScreen(
                    reloadData: false,
                    listCheckInToDay: _bloc.listCheckInOffline,
                    listAlbumTicketOffLine: _bloc.listAlbumTicketOffLine,
                    listAlbumOffline: _bloc.listItemAlbum,
                    userId: _bloc.userId,
                  ),
                  withNavBar: false);
            } else {
              PersistentNavBarNavigator.pushNewScreen(context,
                  screen: SynCheckInScreen(
                    listAlbumTicketOffLine: _bloc.listAlbumTicketOffLine,
                    listAlbumOffline: _bloc.listItemAlbum,
                  ),
                  withNavBar: false);
            }
          }
        },
        child: BlocBuilder<DMSBloc, DMSState>(
          bloc: _bloc,
          builder: (BuildContext context, DMSState state) {
            return Stack(
              children: [
                buildBody(context, state),
                Visibility(
                  visible: state is DMSLoading,
                  child: const PendingAction(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void checkInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        reloadData = true;
        nextScreen();
      }
    } on SocketException catch (_) {
      reloadData = false;
      nextScreen();
    }
  }

  void nextScreen() {
    if (_bloc.listCheckInOffline.isNotEmpty &&
        _bloc.listItemAlbum.isNotEmpty &&
        _bloc.listAlbumTicketOffLine.isNotEmpty) {
      PersistentNavBarNavigator.pushNewScreen(context,
          screen: CheckInScreen(
            reloadData: reloadData,
            listCheckInToDay: _bloc.listCheckInOffline,
            listAlbumTicketOffLine: _bloc.listAlbumTicketOffLine,
            listAlbumOffline: _bloc.listItemAlbum,
            userId: _bloc.userId,
          ),
          withNavBar: false);
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return WillPopScope(
              onWillPop: () async => false,
              child: const CustomQuestionComponent(
                showTwoButton: true,
                iconData: Icons.warning_amber_outlined,
                title: 'Đồng bộ dữ liệu',
                content:
                    'Quá trình đồng bộ sẽ lấy dữ liệu để giúp bạn check-in ngay cả khi không có internet.',
              ),
            );
          }).then((value) async {
        if (value != null) {
          if (!Utils.isEmpty(value) && value == 'Yeah') {
            final result = await InternetAddress.lookup('google.com');
            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
              _bloc.add(GetListTaskOffLineEvent(nextScreen: 1));
            } else {
              // ignore: use_build_context_synchronously
              Utils.showCustomToast(context, Icons.warning_amber_outlined,
                  'Vui lòng kiểm tra Internet của bạn');
            }
          }
        }
      });
    }
  }

  buildBody(BuildContext context, DMSState state) {
    return Column(
      children: [
        buildAppBar(),
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              buildTitle('Check-in', true),
              InkWell(
                onTap: () async {
                  if (Const.checkIn == true) {
                    if (Const.checkInOnline == true) {
                      try {
                        final result =
                            await InternetAddress.lookup('google.com');
                        if (result.isNotEmpty &&
                            result[0].rawAddress.isNotEmpty) {
                          if (_bloc.listCheckInOffline.isNotEmpty &&
                              _bloc.listItemAlbum.isNotEmpty &&
                              _bloc.listAlbumTicketOffLine.isNotEmpty) {
                            if (Const.accessCode > 0) {
                              // ignore: use_build_context_synchronously
                              PersistentNavBarNavigator.pushNewScreen(context,
                                  screen: EmployeeScreen(
                                    typeView: 2,
                                    reloadData: false,
                                    listCheckInToDay: _bloc.listCheckInOffline,
                                    listAlbumTicketOffLine:
                                        _bloc.listAlbumTicketOffLine,
                                    listAlbumOffline: _bloc.listItemAlbum,
                                  ),
                                  withNavBar: true);
                            } else {
                              // ignore: use_build_context_synchronously
                              PersistentNavBarNavigator.pushNewScreen(context,
                                  screen: CheckInScreen(
                                    reloadData: false,
                                    listCheckInToDay: _bloc.listCheckInOffline,
                                    listAlbumTicketOffLine:
                                        _bloc.listAlbumTicketOffLine,
                                    listAlbumOffline: _bloc.listItemAlbum,
                                    userId: _bloc.userId,
                                  ),
                                  withNavBar: false);
                            }
                          } else {
                            if (Const.accessCode > 0) {
                              // ignore: use_build_context_synchronously
                              PersistentNavBarNavigator.pushNewScreen(context,
                                      screen: const EmployeeScreen(
                                        typeView: 2,
                                      ),
                                      withNavBar: true)
                                  .then((value) => _bloc.add(
                                      GetListTaskOffLineEvent(nextScreen: 1)));
                            } else {
                              _bloc.add(GetListTaskOffLineEvent(nextScreen: 1));
                            }
                          }
                        }
                      } on SocketException catch (_) {
                        Utils.showCustomToast(
                            context,
                            Icons.warning_amber_outlined,
                            'Vui lòng kiểm tra Internet của bạn');
                      }
                    } else {
                      _bloc.add(GetValuesClient());
                    }
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    Const.accessCode > 0
                        ? 'Quản lý nhân viên thị trường'
                        : 'Check-in khách hàng',
                    Const.accessCode > 0
                        ? MdiIcons.orderBoolAscendingVariant
                        : MdiIcons.tableAccount,
                    Const.checkIn == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.checkIn == true) {
                    if (_bloc.listCheckInOffline.isNotEmpty &&
                        _bloc.listItemAlbum.isNotEmpty &&
                        _bloc.listAlbumTicketOffLine.isNotEmpty) {
                      PersistentNavBarNavigator.pushNewScreen(context,
                          screen: SynCheckInScreen(
                            listAlbumTicketOffLine:
                                _bloc.listAlbumTicketOffLine,
                            listAlbumOffline: _bloc.listItemAlbum,
                          ),
                          withNavBar: false);
                    } else {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return WillPopScope(
                              onWillPop: () async => false,
                              child: const CustomQuestionComponent(
                                showTwoButton: true,
                                iconData: Icons.warning_amber_outlined,
                                title: 'Đồng bộ dữ liệu',
                                content:
                                    'Quá trình đồng bộ sẽ lấy dữ liệu để giúp bạn check-in ngay cả khi không có internet.',
                              ),
                            );
                          }).then((value) async {
                        if (value != null) {
                          if (!Utils.isEmpty(value) && value == 'Yeah') {
                            _bloc.add(GetListTaskOffLineEvent(nextScreen: 2));
                          }
                        }
                      });
                    }
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Đồng bộ dữ liệu check-in',
                    MdiIcons.cloudSyncOutline,
                    Const.checkIn == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.checkIn == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ReportLocationScreen(),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Báo cáo vị trí',
                    MdiIcons.mapMarkerRadiusOutline,
                    Const.checkIn == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.openStore == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const RequestOpenStoreScreen(),
                        withNavBar: true);
                    // pushNewScreen(context, screen: const TestCode(),withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Đề xuất mở điểm',
                    MdiIcons.garageOpenVariant,
                    Const.openStore == true ? false : true),
              ),
              const SizedBox(
                height: 10,
              ),
              buildTitle('Sale out & KPI', false),
              InkWell(
                onTap: () {
                  if (Const.pointOfSale == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: SearchCustomerScreen(
                          selected: false,
                          allowCustomerSearch: false,
                          inputQuantity: false,
                        ),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                  // Utils.showUpgradeAccount(context);
                },
                child: buildButton('Các điểm phân phối', Icons.store,
                    Const.pointOfSale == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.orderStatusPlace == true) {
                    // pushNewScreen(context, screen: SuggestionsScreen(keySuggestion: 3, title: 'Đề nghị điều xe',),withNavBar: true);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Trạng thái đơn hàng đã đặt',
                    Icons.local_grocery_store_outlined,
                    Const.orderStatusPlace == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.saleOut == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const HistorySaleOutScreen(),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('Sale Out', MdiIcons.fileCabinet,
                    Const.saleOut == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.refundOrderSaleOut == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ListHistoryRefundSaleOutScreen(),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('Lịch sử hàng trả lại Sale Out',
                    MdiIcons.history, Const.refundOrder == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.reportKPI == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const KPIScreen(), withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('KPI', MdiIcons.chartBar,
                    Const.reportKPI == true ? false : true),
              ),
              const SizedBox(
                height: 10,
              ),
              buildTitle('Khách hàng', false),
              InkWell(
                onTap: () {
                  if (Const.infoCustomerDMS == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ListCustomerDMSScreen(),
                        withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Thông tin Khách hàng',
                    Icons.account_box_outlined,
                    Const.infoCustomerDMS == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.careDiaryCustomerDMS == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const CustomerCareScreen(), withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('Lịch sử CSKH', MdiIcons.whatsapp,
                    Const.careDiaryCustomerDMS == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.ticket == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const TicketHistoryScreen(), withNavBar: false);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('Ticket', MdiIcons.calendarTextOutline,
                    Const.ticket == true ? false : true),
              ),
              const SizedBox(
                height: 10,
              ),
              buildTitle('Giao vận', false),
              InkWell(
                onTap: () {
                  if (Const.deliveryPlan == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const DeliveryPlanScreen(), withNavBar: true);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Kế hoạch giao hàng',
                    Icons.plagiarism_outlined,
                    Const.deliveryPlan == true ? false : true),
              ),
              InkWell(
                onTap: () {
                  if (Const.delivery == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ShippingScreen(), withNavBar: true);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('Giao hàng', MdiIcons.truckFast,
                    Const.delivery == true ? false : true),
              ),
              InkWell(
                onTap: () async{
                  // var ass = await Permission.locationWhenInUse.status;
                  // print(ass);
                  // if (ass == PermissionStatus.denied) {
                  //   ass = await Permission.locationWhenInUse.request().whenComplete((){
                  //     print("ass-> : $ass");
                  //   });
                  //   print('ass: 1 ${ass == PermissionStatus.granted}');
                  //   print('ass: 2 ${PermissionStatus.granted}');
                  //   print('ass: 3 ${ass}');
                  //
                  // }
                  if (Const.isDeliveryPhotoRange == true) {
                    isAccess().then((res) {
                      if (res) {
                        if (_bloc.roles == '0') {
                          PersistentNavBarNavigator.pushNewScreen(context,
                              screen: DriverScreen(networkFactory: _bloc.networkFactory!,), withNavBar: true);
                        } else {
                          PersistentNavBarNavigator.pushNewScreen(context,
                              screen: const ManagerScreen(), withNavBar: true);
                        }
                      }
                      else {
                          PersistentNavBarNavigator.pushNewScreen(context,
                              screen: CheckPermission(networkFactory: _bloc.networkFactory!,), withNavBar: true);
                      }
                    });
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton('Giám sát hành trình', MdiIcons.mapLegend,
                    Const.isDeliveryPhotoRange == true ? false : true),
              ),
              buildTitle('Kiểm kê', false),
              InkWell(
                onTap: () {
                  if (Const.inventory == true) {
                    PersistentNavBarNavigator.pushNewScreen(context,
                        screen: const ListInventoryRequestScreen(), withNavBar: true);
                  } else {
                    Utils.showUpgradeAccount(context);
                  }
                },
                child: buildButton(
                    'Kiểm kê hàng hoá',
                    Icons.inventory_2_outlined,
                    Const.inventory == true ? false : true),
              ),
              const SizedBox(
                height: 75,
              )
            ],
          ),
        ),
        const SizedBox(
          height: 40,
        )
      ],
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
            // onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (context)=> const NotificationScreen())),
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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
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
                    ],
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

  buildTitle(String title, bool viewSwitch) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2)),
        padding: const EdgeInsets.only(left: 10, right: 10, top: 7, bottom: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: const TextStyle(color: subColor, fontSize: 13),
                )),
            Visibility(
              visible: viewSwitch,
              child: AdvancedSwitch(
                controller: _controller,
                activeColor: subColor,
                inactiveColor: Colors.blueGrey,
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                width: 60,
                height: 20,
                enabled: true,
                activeChild: const Text(
                  'Online',
                  style: TextStyle(fontSize: 9.5, color: Colors.white),
                ),
                inactiveChild: const Text(
                  'Offline',
                  style: TextStyle(fontSize: 9.5, color: Colors.white),
                ),
                disabledOpacity: 0.3,
              ),
            ),
          ],
        ),
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
