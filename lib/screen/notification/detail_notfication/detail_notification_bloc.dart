import 'package:dms/model/network/request/atccept_approval_request.dart';
import 'package:dms/model/network/services/network_factory.dart';
import 'package:dms/utils/const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

import 'detail_notification_event.dart';
import 'detail_notification_state.dart';

class DetailNotificationBloc
    extends Bloc<DetailNotificationEvent, DetailNotificationState> {
  NetWorkFactory? _networkFactory;
  BuildContext context;

  String? _accessToken;
  String? _refreshToken;
  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  String? _htmlData;
  String get htmlData => _htmlData ?? '';
  final box = GetStorage();

  DetailNotificationBloc(this.context)
      : super(InitialDetailNotificationState()) {
    _networkFactory = NetWorkFactory(context);

    on<GetPrefsDetailNotificationEvent>(_getPrefs);
    on<AcceptDetailApprovalEvent>(_acceptDetailApprovalEvent);
    on<FetchHTMLDataEvent>(_fetchHTMLData);
    on<ReadNotificationEvent>(_readNotification);
  }

  void _getPrefs(DetailNotificationEvent event,
      Emitter<DetailNotificationState> emitter) async {
    emitter(InitialDetailNotificationState());
    _accessToken = box.read(Const.ACCESS_TOKEN);
    _refreshToken = box.read(Const.ACCESS_TOKEN);

    emitter(GetPrefsSuccess());
  }

  void _acceptDetailApprovalEvent(AcceptDetailApprovalEvent event,
      Emitter<DetailNotificationState> emitter) async {
    emitter(DetailNotificationLoading());
    AcceptApprovalRequest request = AcceptApprovalRequest(
        loaiDuyet: event.idApproval,
        action: event.actionType.toString(),
        sttRec: event.sttRec,
        note: event.note);
    DetailNotificationState state = _handlerCallAPIApproval(
        await _networkFactory!.acceptApprovalApproval(
          request,
          _accessToken!,
        ),
        event.actionType.toString());
    emitter(state);
  }

  DetailNotificationState _handlerCallAPIApproval(Object data, String type) {
    if (data is String) return DetailNotificationFailure(data.toString());
    try {
      String message = type == "1"
          ? "Yeah, Duyệt phiếu thành công"
          : type == "3"
              ? "Yeah, Huỷ phiếu thành công"
              : "Yeah, Bỏ duyệt phiếu thành công";
      return AcceptDetailApprovalSuccess(message);
    } catch (e) {
      return DetailNotificationFailure(e.toString());
    }
  }

  void _fetchHTMLData(FetchHTMLDataEvent event,
      Emitter<DetailNotificationState> emitter) async {
    emitter(DetailNotificationLoading());

    try {
      Object data = await _networkFactory!.getDetailNotification(
        _accessToken!,
        event.linkDetail,
        event.code,
        event.sttRec,
        event.loaiDuyet,
        event.fcmToken,
      );

      if (data is Map<String, dynamic>) {
        if (data['data'] != null && data['data'] is String) {
          String htmlContent = data['data'];
          _htmlData = htmlContent;
          emitter(GetHTMLDataSuccess());
        } else {
          emitter(DetailNotificationFailure(''));
        }
      }
    } catch (e) {
      emitter(DetailNotificationFailure('Úi: ${e.toString()}'));
    }
  }

  void _readNotification(ReadNotificationEvent event,
      Emitter<DetailNotificationState> emitter) async {
    emitter(DetailNotificationLoading());

    Object data = await _networkFactory!.readOneNotification(
      _accessToken!,
      event.idNotification,
    );
    if (data is String) return emitter(DetailNotificationFailure(''));
    try {
      emitter(ReadOneNotificationSuccess());
    } catch (e) {
      emitter(DetailNotificationFailure('Úi: ${e.toString()}'));
    }
  }
}
