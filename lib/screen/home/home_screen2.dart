import 'package:dms/screen/home/component/progress_bar.dart';
import 'package:dms/screen/notification/notification/notification_screen.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../model/database/data_local.dart';
import '../../services/shore_bird/shorebird_utils.dart';
import '../dms/check_in/check_in_screen.dart';
import '../dms/component/request_open_store.dart';
import '../menu/approval/approval/approval_screen.dart';
import '../sell/order/order_sceen.dart';
import 'component/chart_spline.dart';
import 'component/home_slider.dart';
import 'component/kpi.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeScreen2 extends StatefulWidget {
  final String userName;
  const HomeScreen2({super.key, required this.userName});

  @override
  State<HomeScreen2> createState() => _HomeScreen2State();
}

class _HomeScreen2State extends State<HomeScreen2>  with WidgetsBindingObserver{
  final _reportList = ['DMS', 'Doanh thu', 'Doanh số'];
  late String _selectedReport = 'DMS';
  final _timeList = ['Tuần', 'Tháng', 'Quý', 'Năm'];
  late String _selectedTime = 'Tuần';
  int _indexReport = 0;

  double we = 0;
  double he = 0;

  late HomeBloc _bloc;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _bloc = HomeBloc(context);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ShorebirdUtils.instance.checkUpdateAndRestart(context);
    });
    _bloc.add(GetPrefsHomeEvent());
    if (Const.isEnableNotification == true) {
      _bloc.add(GetTotalUnreadNotificationEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    we = MediaQuery.of(context).size.width;
    he = MediaQuery.of(context).size.height;
    return Scaffold(
      body: BlocListener<HomeBloc, HomeState>(
          bloc: _bloc,
          listener: (context, state) {
            if (state is GetPrefsSuccess) {
              _bloc.add(GetDataDefault());
              if (DataLocal.listStatusToOrderCustom.isEmpty) {
                _bloc.add(GetListStatusOrder());
              }
            } else if (state is GetDefaultDataSuccess ||
                state is GetDataSuccess) {
              _bloc.add(GetListSliderImageEvent());
            } else if (state is GetListSliderImageSuccess) {}
          },
          child: BlocBuilder<HomeBloc, HomeState>(
            bloc: _bloc,
            builder: (BuildContext context, HomeState state) {
              return Stack(
                children: [
                  buildBody(context, state),
                  Visibility(
                    visible: state is HomeLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            },
          )),
    );
  }

  buildBody(BuildContext context, HomeState state) {
    return SizedBox(
      width: we,
      height: he,
      child: Container(
        margin: const EdgeInsets.only(left: 14, right: 14),
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 40),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "Hi, ${_bloc.userName.toString()}!",
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: subColor),
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.topLeft,
                        margin: const EdgeInsets.only(top: 5),
                        child: Text(
                          "What are you looking for to day?",
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.normal,
                              color: subColor.withOpacity(0.6)),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (Const.isEnableNotification == true) {
                        PersistentNavBarNavigator.pushNewScreen(context,
                                screen: const NotificationScreen(),
                                withNavBar: false)
                            .then((value) {
                          if (value != null && value[0] == 'Reload') {
                            _bloc.add(GetTotalUnreadNotificationEvent());
                          }
                        });
                      } else {
                        Utils.showUpgradeAccount(context);
                      }
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(40)),
                              color: Colors.white),
                          child:
                              const Icon(Icons.notifications_active_outlined),
                        ),
                        if (_bloc.totalUnreadNotification > 0 &&
                            Const.isEnableNotification == true)
                          Positioned(
                            top: 0,
                            right: -2,
                            child: ClipOval(
                              child: Container(
                                width: 18,
                                height: 15,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _bloc.totalUnreadNotification > 99
                                        ? '99+'
                                        : _bloc.totalUnreadNotification
                                            .toString(),
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
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16)),
                  border: Border.all(color: Colors.grey.withOpacity(0.4))),
              child: Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        EneftyIcons.search_normal_2_outline,
                        size: 18,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Bạn có thể tìm kiếm mọi thứ từ đây',
                        style: TextStyle(
                            color: subColor.withOpacity(0.5), fontSize: 12.5),
                      )
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    EneftyIcons.setting_4_outline,
                    size: 18,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: he * 0.01,
            ),
            Expanded(child: contentBody())
          ],
        ),
      ),
    );
  }

  contentBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          HomeSlider(
            onChange: (value) {},
            items: DataLocal.listSliderImageActive.isEmpty
                ? DataLocal.listSliderFirebase
                : DataLocal.listSliderImageActive,
          ),
          SizedBox(
            height: he * 0.03,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Dịch vụ tiện ích",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: subColor),
                ),
              ),
              const Spacer(),
              Container(
                alignment: Alignment.topRight,
                child: const Text(
                  "Cài đặt tiện ích",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                ),
              ),
              const Icon(
                Icons.navigate_next,
                color: Colors.white54,
              )
            ],
          ),
          SizedBox(
            height: he * 0.01,
          ),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 8,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                margin: const EdgeInsets.only(left: 14, right: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    itemControl(EneftyIcons.bag_2_outline, 'Đặt đơn', () {
                      if (Const.createNewOrder == true) {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: const OrderScreen(), withNavBar: false);
                      } else {
                        Utils.showUpgradeAccount(context);
                      }
                    }),
                    itemControl(EneftyIcons.location_outline, 'Gặp gỡ', () {
                      if (Const.checkIn == true) {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: CheckInScreen(
                              reloadData: false,
                              listCheckInToDay: const [],
                              listAlbumOffline: const [],
                              listAlbumTicketOffLine: const [],
                              userId: _bloc.userId,
                            ),
                            withNavBar: false);
                      } else {
                        Utils.showUpgradeAccount(context);
                      }
                    }),
                    itemControl(EneftyIcons.shop_add_outline, 'Mở mới', () {
                      if (Const.openStore == true) {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: const RequestOpenStoreScreen(),
                            withNavBar: true);
                      } else {
                        Utils.showUpgradeAccount(context);
                      }
                    }),
                    itemControl(EneftyIcons.chart_2_outline, 'Báo cáo', () {
                      if (Const.approval == true) {
                        PersistentNavBarNavigator.pushNewScreen(context,
                            screen: const ApprovalScreen(), withNavBar: true);
                      } else {
                        Utils.showUpgradeAccount(context);
                      }
                    })
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: he * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Tổng quan KPI",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.normal,
                      color: subColor),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => PersistentNavBarNavigator.pushNewScreen(context,
                    screen: const HomeKPIScreen()),
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.topRight,
                      child: const Text(
                        "Xem thêm",
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.normal,
                            color: Colors.blueGrey),
                      ),
                    ),
                    const Icon(
                      Icons.navigate_next,
                      color: Colors.blueGrey,
                    )
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: he * 0.01,
          ),
          viewReportByUser(),
          SizedBox(
            height: he * 0.02,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                alignment: Alignment.topLeft,
                child: const Text(
                  "Thông tin nổi bật",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: subColor),
                ),
              ),
              Container(
                alignment: Alignment.topRight,
                child: const Text(
                  "",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color: Colors.blueGrey),
                ),
              ),
            ],
          ),
          SizedBox(
            height: he * 0.01,
          ),
          SizedBox(
            height: 170,
            child: ListView.builder(
                itemCount: DataLocal.listNews.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: GestureDetector(
                      onTap: () async {
                        if (await canLaunch(
                            DataLocal.listNews[index].link.toString().trim())) {
                          await launch(
                              DataLocal.listNews[index].link.toString().trim());
                        } else {
                          throw 'Could not launch ${DataLocal.listNews[index].link.toString().trim()}';
                        }
                      },
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(18)),
                        child: Container(
                          height: double.infinity, width: 300,
                          // padding: const EdgeInsets.all(Const.defaultPadding),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                  DataLocal.listNews[index].image.toString()),
                            ),
                            color: primaryColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(child: Container()),
                              Container(
                                height: 45,
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    left: 10, right: 4, top: 8),
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(18),
                                        bottomRight: Radius.circular(18)),
                                    color: Colors.grey.withOpacity(0.6)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        DataLocal.listNews[index].title
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Text(
                                        DataLocal.listNews[index].subTitle
                                            .toString(),
                                        style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 11,
                                            fontWeight: FontWeight.normal),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
          const SizedBox(
            height: Const.defaultPadding * 5,
          )
        ],
      ),
    );
  }

  viewReportByUser() {
    return Container(
      padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.11),
          borderRadius: const BorderRadius.all(Radius.circular(10))),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, left: 4, right: 4),
        child: Column(
          children: [
            Row(
              children: [
                PopupMenuButton(
                  color: secondaryColor2,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context) => _reportList
                      .map((e) => PopupMenuItem(
                            value: e,
                            child: Text(
                              e.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                          ))
                      .toList(),
                  onSelected: (val) {
                    setState(() {
                      _selectedReport = val.toString();
                      if (_selectedReport == 'Doanh thu') {
                        _selectedReport = 'Doanh thu';
                        _indexReport = 0;
                      } else if (_selectedReport == 'DMS') {
                        _indexReport = 1;
                        _selectedReport = 'DMS';
                      } else {
                        _indexReport = 0;
                        _selectedReport = 'Doanh số';
                      }
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _selectedReport.toString(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  color: secondaryColor2,
                  padding: EdgeInsets.zero,
                  itemBuilder: (BuildContext context) => _timeList
                      .map((e) => PopupMenuItem(
                            child: Text(
                              e.toString(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            value: e,
                          ))
                      .toList(),
                  onSelected: (val) {
                    setState(() {
                      // _selectedTime = val;
                    });
                  },
                  child: Row(
                    children: [
                      Text(
                        _selectedTime.toString(),
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontWeight: FontWeight.w400),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(
                          Icons.arrow_drop_down,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: Const.defaultPadding / 2,
            ),
            const Divider(
              color: Colors.black,
            ),
            Expanded(
                child: _indexReport == 0
                    ? viewReportRevenue()
                    : viewReportProgressbar())
          ],
        ),
      ),
    );
  }

  viewReportProgressbar() {
    return const Column(
      children: [
        SizedBox(
          height: Const.defaultPadding / 2,
        ),
        ProgressBarCustom(
            title: 'Viếng thăm',
            value: '530',
            percent: 0.7,
            color: secondaryColor),
        SizedBox(
          height: Const.defaultPadding / 2,
        ),
        ProgressBarCustom(
            title: 'Mở mới',
            value: '478',
            percent: 0.6,
            color: secondaryColor2),
        SizedBox(
          height: Const.defaultPadding / 2,
        ),
        ProgressBarCustom(
            title: 'Sản phẩm HOHO',
            value: '52',
            percent: 0.3,
            color: Color(0xFF01DFFF)),
      ],
    );
  }

  viewReportRevenue() {
    return Container(
      padding: const EdgeInsets.only(
          top: Const.defaultPadding, bottom: Const.defaultPadding),
      height: 120,
      width: double.infinity,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Incoming',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black),
              ),
              Text(
                '\$ 850,58',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black),
              ),
              Row(
                children: [
                  Icon(
                    Icons.moving,
                    color: secondaryColor,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    '11% vs last week',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 12),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            width: Const.defaultPadding,
          ),
          Expanded(child: ChartSpline())
        ],
      ),
    );
  }

  itemControl(
      IconData icons, String nameControl, VoidCallback onTapNotification) {
    return GestureDetector(
      onTap: onTapNotification,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(
                      color: Colors.grey.withOpacity(0.7), width: 0.8)),
              child: Icon(
                icons,
                size: 22,
                color: accent,
              )),
          const SizedBox(
            height: 10,
          ),
          Text(
            nameControl.toString(),
            style: TextStyle(
              color: Colors.black.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
