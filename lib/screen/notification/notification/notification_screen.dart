// ignore_for_file: library_private_types_in_public_api

import 'package:dms/model/network/response/notification.dart';
import 'package:dms/screen/notification/detail_notfication/detail_notification_screen.dart';
import 'package:dms/screen/notification/notification/notification_bloc.dart';
import 'package:dms/screen/notification/notification/notification_event.dart';
import 'package:dms/screen/notification/notification/notification_state.dart';
import 'package:dms/themes/colors.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late NotificationBloc _bloc;
  int status = 10;
  int option = 1;
  int lastPage = 0;
  int selectedPage = 1;
  @override
  void initState() {
    super.initState();
    _bloc = NotificationBloc(context);
    _bloc.add(GetPrefsNotificationEvent());

    _bloc.add(GetListNotificationEvent(pageIndex: 1));
    _bloc.add(GetTotalUnreadNotificationEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocProvider(
        create: (context) => _bloc,
        child: BlocListener<NotificationBloc, NotificationState>(
          listener: (context, state) {
            if (state is NotificationFailure) {
              Utils.showCustomToast(
                  context, Icons.warning_amber_outlined, state.error);
            } else if (state is ReadAllNotificationSuccess) {
              _bloc.add(GetListNotificationEvent(pageIndex: selectedPage));
              Utils.showCustomToast(
                  context, Icons.check, 'Đã đọc tất cả thông báo');
            }
          },
          child: BlocBuilder<NotificationBloc, NotificationState>(
            bloc: _bloc,
            builder: (context, NotificationState state) {
              return Stack(
                children: [
                  buildBody(context, state, _bloc.notificationList.length),
                  Visibility(
                    visible: state is GetNotificationListEmpty,
                    child: const Center(
                      child: Text('Úi, Không có gì ở đây cả!!!',
                          style: TextStyle(color: Colors.blueGrey)),
                    ),
                  ),
                  Visibility(
                    visible: state is NotificationLoading,
                    child: const PendingAction(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget buildAppBar() {
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
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Navigator.pop(context, ['Reload']),
            child: const SizedBox(
              width: 40,
              height: 50,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 25,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Danh sách thông báo",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          // const SizedBox(
          //   height: 50,
          //   child: Icon(
          //     Icons.check,
          //     size: 25,
          //     color: Colors.red,
          //   ),
          // )
          InkWell(
            onTap: () {
              if (_bloc.totalUnreadNotification > 0) {
                _bloc.add(RealAllNotificationEvent());
              }
            },
            child: Align(
              alignment: AlignmentDirectional.center,
              child: FaIcon(
                FontAwesomeIcons.checkDouble,
                color: _bloc.totalUnreadNotification > 0
                    ? Colors.white
                    : Colors.grey.shade500,
                size: 20,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context, NotificationState state, int length) {
    return Column(
      children: [
        buildAppBar(),
        const SizedBox(height: 10),
        Expanded(
          child: RefreshIndicator(
            color: mainColor,
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 2));
              _bloc.add(GetListNotificationEvent(pageIndex: selectedPage));
              _bloc.add(GetTotalUnreadNotificationEvent());
            },
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _bloc.notificationList.length,
              itemBuilder: (context, index) {
                return _notificationItem(
                  notification: _bloc.notificationList[index],
                );
              },
            ),
          ),
        ),
        _bloc.totalMyPager > 1 ? _getDataPager() : Container(),
        const SizedBox(
          height: 55,
        )
      ],
    );
  }

  Widget _notificationItem({
    required NotificationResponseData notification,
  }) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailNotificationScreen(
                  title: notification.title ?? '',
                  htmlData: '',
                  code: notification.code ?? '',
                  sttRec: notification.sttRec ?? '',
                  idApproval: notification.loaiDuyet ?? '',
                  linkDetail: notification.linkDetail ?? '',
                  type: notification.type ?? '',
                ),
              ),
            ).then((value) {
              if (value != null && value[0] == 'Reload') {
                _bloc.add(GetListNotificationEvent(pageIndex: selectedPage));
                _bloc.add(GetTotalUnreadNotificationEvent());
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                notification.type == "0"
                    ? const FaIcon(FontAwesomeIcons.bullhorn,
                        color: Color.fromARGB(255, 52, 129, 192), size: 20)
                    : Icon(
                        Icons.event_note_outlined,
                        color: Colors.green[500],
                        size: 25,
                      ),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10).copyWith(
                      bottom: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(.3),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title ?? '',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: notification.isRead == true
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          notification.title2 ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: notification.isRead == true
                                ? Colors.grey
                                : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          Utils.parseDateTToString(notification.datetime0 ?? '',
                              Const.DATE_TIME_FORMAT),
                          style: TextStyle(
                            fontSize: 12,
                            color: notification.isRead == true
                                ? Colors.grey
                                : Color.fromARGB(255, 18, 101, 204),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _getDataPager() {
    return Center(
      child: SizedBox(
        height: 57,
        width: double.infinity,
        child: Column(
          children: [
            const Divider(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = 1;
                          });
                          _bloc.add(GetListNotificationEvent(
                              pageIndex: selectedPage));
                        },
                        child: const Icon(Icons.skip_previous_outlined,
                            color: Colors.grey)),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          if (selectedPage > 1) {
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage - 1;
                            });
                            _bloc.add(GetListNotificationEvent(
                                pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(
                          Icons.navigate_before_outlined,
                          color: Colors.grey,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  lastPage = selectedPage;
                                  selectedPage = index + 1;
                                });
                                _bloc.add(GetListNotificationEvent(
                                    pageIndex: selectedPage));
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: selectedPage == (index + 1)
                                        ? Colors.orange
                                        : Colors.white,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(48))),
                                child: Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                        color: selectedPage == (index + 1)
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) =>
                              Container(
                                width: 6,
                              ),
                          itemCount: _bloc.totalMyPager),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          if (selectedPage < _bloc.totalMyPager) {
                            setState(() {
                              lastPage = selectedPage;
                              selectedPage = selectedPage + 1;
                            });
                            _bloc.add(GetListNotificationEvent(
                                pageIndex: selectedPage));
                          }
                        },
                        child: const Icon(Icons.navigate_next_outlined,
                            color: Colors.grey)),
                    const SizedBox(
                      width: 10,
                    ),
                    InkWell(
                        onTap: () {
                          setState(() {
                            lastPage = selectedPage;
                            selectedPage = _bloc.totalMyPager;
                          });
                          _bloc.add(GetListNotificationEvent(
                              pageIndex: selectedPage));
                        },
                        child: const Icon(Icons.skip_next_outlined,
                            color: Colors.grey)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
