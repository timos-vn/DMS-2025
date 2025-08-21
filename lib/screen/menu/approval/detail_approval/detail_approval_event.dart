import 'package:equatable/equatable.dart';

abstract class DetailApprovalEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListDetailApprovalEvent extends DetailApprovalEvent {

  final String idApproval;
  final int status;
  final String option;
  final int pageIndex;

  GetListDetailApprovalEvent(this.idApproval,this.status,this.option,this.pageIndex);

  @override
  String toString() => 'GetListDetailApprovalEvent ';
}

class AcceptDetailApprovalEvent extends DetailApprovalEvent {
  final int actionType;
  final String idApproval;
  final String note;
  final String sttRec;

  AcceptDetailApprovalEvent({required this.actionType,required this.idApproval,required this.note,required this.sttRec});
  @override
  String toString() => 'GetListDetailApprovalEvent {actionType: $actionType, idApproval:$idApproval}';
}

class Accept2DetailApprovalEvent extends DetailApprovalEvent {
  final int actionType;

  Accept2DetailApprovalEvent(this.actionType);
  @override
  String toString() => 'GetListDetailApprovalEvent {actionType: $actionType}';
}

class NextPageResultReportEvent extends DetailApprovalEvent {
  final int pageIndex ;

  NextPageResultReportEvent(this.pageIndex);
  @override
  String toString() => 'NextPageResultReportEvent {pageIndex: $pageIndex}';
}

class PrevPageResultReportEvent extends DetailApprovalEvent {
  final int pageIndex ;

  PrevPageResultReportEvent(this.pageIndex);
  @override
  String toString() => 'PrevPageResultReportEvent {pageIndex: $pageIndex}';
}

class PickGenderStatus extends DetailApprovalEvent {

  final int status;

  PickGenderStatus(this.status);

  @override
  String toString() {
    return 'PickGenderStatus{status: $status}';
  }
}

class SeenApprovalEvent extends DetailApprovalEvent {

  final String sttRec;

  SeenApprovalEvent({required this.sttRec});

  @override
  String toString() => 'SeenApprovalEvent {}';
}

class GetPrefsDetailApproval extends DetailApprovalEvent {
  @override
  String toString() => 'GetPrefsDetailApproval';
}

class GetStatusApprovalEvent extends DetailApprovalEvent {

  final String idApproval;

  GetStatusApprovalEvent(this.idApproval);

  @override
  String toString() => 'GetStatusApprovalEvent {}';
}