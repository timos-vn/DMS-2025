// ignore_for_file: library_private_types_in_public_api

import 'package:dms/screen/info_cpn/info_cpn_bloc.dart';
import 'package:dms/screen/info_cpn/info_cpn_event.dart';
import 'package:dms/screen/main/main_screen.dart';
import 'package:dms/screen/notification/detail_notfication/detail_notification_bloc.dart';
import 'package:dms/screen/notification/detail_notfication/detail_notification_event.dart';
import 'package:dms/screen/notification/detail_notfication/detail_notification_state.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/widget/custom_confirm.dart';
import 'package:dms/widget/pending_action.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dms/utils/utils.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../../../themes/colors.dart';

class DetailNotificationScreen extends StatefulWidget {
  final String htmlData;

  final String sttRec;
  final String title;
  final String idApproval;
  final String? linkDetail;
  final String? type;
  final bool? isNotificationBackground;
  final String? code;
  const DetailNotificationScreen({
    key,
    required this.htmlData,
    required this.sttRec,
    required this.title,
    required this.idApproval,
    this.linkDetail = '',
    this.type = '0',
    this.isNotificationBackground = false,
    this.code = '',
  });

  @override
  _DetailNotificationScreenState createState() =>
      _DetailNotificationScreenState();
}

class _DetailNotificationScreenState extends State<DetailNotificationScreen> {
  late DetailNotificationBloc _bloc;
  late InfoCPNBloc _infoCPNBloc;
  final messaging = FirebaseMessaging.instance;
  @override
  void initState() {
    super.initState();
    _bloc = DetailNotificationBloc(context);
    _bloc.add(GetPrefsDetailNotificationEvent());
    _infoCPNBloc = InfoCPNBloc(context);
    _infoCPNBloc.add(GetPrefsInfoCPN());
    messaging.getToken().then((value) {
      if (widget.linkDetail != '') {
        _bloc.add(FetchHTMLDataEvent(
            linkDetail: widget.linkDetail!,
            code: widget.code!,
            sttRec: widget.sttRec,
            loaiDuyet: widget.idApproval,
            fcmToken: value!));
      }
      if (widget.code != '') {
        _bloc.add(FetchHTMLDataEvent(
            linkDetail: widget.htmlData,
            code: widget.code!,
            sttRec: widget.sttRec,
            loaiDuyet: widget.idApproval,
            fcmToken: value!));
        _bloc.add(ReadNotificationEvent(idNotification: widget.code!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocListener<DetailNotificationBloc, DetailNotificationState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is DetailNotificationFailure) {
          Utils.showCustomToast(
              context, Icons.warning_amber_outlined, 'Úi, ${state.error}');
        } else if (state is AcceptDetailApprovalSuccess) {
          Utils.showCustomToast(
              context, Icons.check_circle_outline, state.message.toString());
          if (widget.isNotificationBackground == true) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => MainScreen(
                  listMenu: _infoCPNBloc.listMenu,
                  listNavItem: _infoCPNBloc.listNavItem,
                  userName: _infoCPNBloc.userName,
                ),
              ),
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pop(context, ['Reload']);
          }
        }
      },
      child: BlocBuilder(
        bloc: _bloc,
        builder: (BuildContext context, DetailNotificationState state) {
          return Stack(
            children: [
              buildBody(context, state),
              Visibility(
                visible: state is DetailNotificationFailure,
                child: const Center(
                  child: Text('Úi, Không có gì ở đây cả!!!',
                      style: TextStyle(color: Colors.blueGrey)),
                ),
              ),
              Visibility(
                visible: state is DetailNotificationLoading,
                child: const PendingAction(),
              )
            ],
          );
        },
      ),
    ));
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
      padding: const EdgeInsets.fromLTRB(5, 35, 12, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              if (widget.isNotificationBackground == true) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => MainScreen(
                      listMenu: _infoCPNBloc.listMenu,
                      listNavItem: _infoCPNBloc.listNavItem,
                      userName: _infoCPNBloc.userName,
                    ),
                  ),
                  (Route<dynamic> route) => false,
                );
              } else {
                Navigator.pop(context, ['Reload']);
              }
            },
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
                widget.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          const SizedBox(
            height: 50,
            child: Icon(
              Icons.filter_alt_outlined,
              size: 25,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  buildBody(BuildContext context, DetailNotificationState state) {
    return SizedBox(
      height: double.infinity,
      width: double.infinity,
      child: Column(
        children: [
          buildAppBar(),
          Expanded(
            child: Container(
              height: double.infinity,
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 60),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      // child: HtmlWidget(
                      //   widget.htmlData != ''
                      //       ? widget.htmlData.replaceAll("\\\"", "\"")
                      //       : _bloc.htmlData,
                      // ),
                      child: HtmlWidget(
                        _bloc.htmlData,
                      ),
                    ),
                  ),
                  widget.type == '1' ? buildButton() : const SizedBox(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: const CustomConfirm(
                        title: 'Bạn đang thực hiện Duyệt phiếu!',
                        content: 'Hãy chắc chắn là bạn muốn duyệt phiếu này!',
                        type: 0,
                      ),
                    );
                  }).then((value) {
                if (!Utils.isEmpty(value) && value[0] == 'confirm') {
                  _bloc.add(AcceptDetailApprovalEvent(
                      actionType: 1,
                      idApproval: widget.idApproval,
                      note: value[2].toString(),
                      sttRec: widget.sttRec));
                  // if(!Utils.isEmpty(value[2])){
                  //
                  // }else{
                  //   Utils.showCustomToast(context, Icons.warning_amber_outlined, 'Úi, Bạn đã hãy nhập lý do đi.');
                  // }
                }
              });
            },
            child: const Row(
              children: [
                Icon(Icons.check, color: Colors.blue, size: 20),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Duyệt',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          InkWell(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: const CustomConfirm(
                        title: 'Bạn đang thực hiện Huỷ phiếu!',
                        content: 'Hãy chắc chắn là bạn muốn Huỷ phiếu này!',
                        type: 0,
                      ),
                    );
                  }).then((value) {
                if (!Utils.isEmpty(value) && value[0] == 'confirm') {
                  if (!Utils.isEmpty(value[2])) {
                    _bloc.add(AcceptDetailApprovalEvent(
                        actionType: 3,
                        idApproval: widget.idApproval,
                        note: value[2],
                        sttRec: widget.sttRec));
                  } else {
                    Utils.showCustomToast(context, Icons.warning_amber_outlined,
                        'Úi, Bạn đã hãy nhập lý do đi.');
                  }
                }
              });
            },
            child: const Row(
              children: [
                Icon(
                  Icons.close,
                  color: Colors.blue,
                  size: 20,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Huỷ',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 25,
          ),
          InkWell(
            onTap: () async {
              showDialog(
                  context: context,
                  builder: (context) {
                    return WillPopScope(
                      onWillPop: () async => false,
                      child: const CustomConfirm(
                        title: 'Bạn đang thực hiện Bỏ duyệt phiếu!',
                        content:
                            'Hãy chắc chắn là bạn muốn Bỏ duyệt phiếu này!',
                        type: 0,
                      ),
                    );
                  }).then((value) {
                if (!Utils.isEmpty(value) && value[0] == 'confirm') {
                  if (!Utils.isEmpty(value[2])) {
                    _bloc.add(AcceptDetailApprovalEvent(
                        actionType: 2,
                        idApproval: widget.idApproval,
                        note: value[2],
                        sttRec: widget.sttRec));
                  } else {
                    Utils.showCustomToast(context, Icons.warning_amber_outlined,
                        'Úi, Bạn đã hãy nhập lý do đi.');
                  }
                }
              });
            },
            child: const Row(
              children: [
                Icon(Icons.arrow_back_ios_rounded,
                    color: Colors.blue, size: 18),
                SizedBox(
                  width: 5,
                ),
                Text(
                  'Bỏ duyệt',
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
