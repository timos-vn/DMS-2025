import 'package:equatable/equatable.dart';

abstract class DetailNotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsDetailNotificationEvent extends DetailNotificationEvent {
  @override
  String toString() => 'GetPrefsDetailNotificationEvent';
}

class AcceptDetailApprovalEvent extends DetailNotificationEvent {
  final int actionType;
  final String idApproval;
  final String note;
  final String sttRec;

  AcceptDetailApprovalEvent(
      {required this.actionType,
      required this.idApproval,
      required this.note,
      required this.sttRec});
  @override
  String toString() =>
      'GetListDetailApprovalEvent {actionType: $actionType, idApproval:$idApproval}';
}

class FetchHTMLDataEvent extends DetailNotificationEvent {
  final String linkDetail;
  final String code;
  final String sttRec;
  final String loaiDuyet;
  final String fcmToken;
  FetchHTMLDataEvent(
      {required this.linkDetail,
      required this.code,
      required this.sttRec,
      required this.loaiDuyet,
      required this.fcmToken});
  @override
  String toString() {
    return 'fetchHTMLData{html: $linkDetail}';
  }
}

class ReadNotificationEvent extends DetailNotificationEvent {
  final String idNotification;

  ReadNotificationEvent({required this.idNotification});
  @override
  String toString() {
    return 'ReadNotificationEvent{idNotification: $idNotification}';
  }
}
