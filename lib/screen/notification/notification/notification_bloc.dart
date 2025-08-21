import 'package:dms/model/network/request/get_list_notification_request.dart';
import 'package:dms/model/network/response/notification.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:dms/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? _refreshToken;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;

  int totalMyPager = 0;
  int? _totalUnreadNotification;
  int get totalUnreadNotification => _totalUnreadNotification ?? 0;
  final box = GetStorage();
  List<NotificationResponseData> _notificationList = [];
  List<NotificationResponseData> get notificationList => _notificationList;
  NotificationBloc(this.context) : super(InitialNotificationState()) {
    _networkFactory = NetWorkFactory(context);

    on<GetPrefsNotificationEvent>(_getPrefs);
    on<GetListNotificationEvent>(_getListNotification);
    on<RealAllNotificationEvent>(_readAllNotification);
    on<GetTotalUnreadNotificationEvent>(_getTotalUnreadNotification);
  }

  void _getPrefs(
      NotificationEvent event, Emitter<NotificationState> emitter) async {
    emitter(InitialNotificationState());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);
    _totalUnreadNotification = box.read(Const.TOTAL_UNREAD_NOTIFICATION) ?? 0;
    emitter(GetPrefsSuccess());
  }

  void _getListNotification(GetListNotificationEvent event,
      Emitter<NotificationState> emitter) async {
    emitter(NotificationLoading());
    GetListNotificationRequest request = GetListNotificationRequest(
      pageIndex: event.pageIndex,
      pageSize: 10,
    );
    NotificationState state = _handleLoadList(
      await _networkFactory!.getListNotification(
        request,
        _accessToken!,
      ),
    );

    emitter(state);
  }

  NotificationState _handleLoadList(Object data) {
    if (data is String) return NotificationFailure(data);
    try {
      if (!Utils.isEmpty(_notificationList)) {
        _notificationList.clear();
      }
      NotificationResponse response =
          NotificationResponse.fromJson(data as Map<String, dynamic>);
      _notificationList = response.data!;
      totalMyPager = response.totalPage!;
      if (Utils.isEmpty(_notificationList)) {
        return GetNotificationListEmpty();
      } else {
        return NotificationPrefsSuccess();
      }
    } catch (e) {
      return NotificationFailure('Úi, ${e.toString()}');
    }
  }

  void _readAllNotification(
      NotificationEvent event, Emitter<NotificationState> emitter) async {
    emitter(NotificationLoading());
    Object data = await _networkFactory!.readAllNotification(
      _accessToken!,
    );
    if (data is String) return emitter(NotificationFailure(data.toString()));
    try {
      emitter(ReadAllNotificationSuccess());
    } catch (e) {
      emitter(NotificationFailure(e.toString()));
    }
  }

  void _getTotalUnreadNotification(GetTotalUnreadNotificationEvent event,
      Emitter<NotificationState> emitter) async {
    emitter(NotificationLoading());

    try {
      Object data = await _networkFactory!.getTotalUnreadNotification(
        _accessToken!,
      );

      if (data is Map<String, dynamic>) {
        if (data['recordUnRead'] != null && data['recordUnRead'] is int) {
          int recordUnRead = data['recordUnRead'];
          _totalUnreadNotification = recordUnRead;
          box.write(Const.TOTAL_UNREAD_NOTIFICATION, recordUnRead);
          emitter(GetTotalUnreadNotificationSuccess());
        } else {
          emitter(NotificationFailure(''));
        }
      }
    } catch (e) {
      emitter(NotificationFailure('Úi: ${e.toString()}'));
    }
  }
}
