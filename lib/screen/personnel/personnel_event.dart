import 'package:equatable/equatable.dart';

abstract class PersonnelEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListEmployeeEvent extends PersonnelEvent {

  final int pageIndex;
  final String? userId;
  final String? keySearch;
  final int typeAction;

  GetListEmployeeEvent({required this.pageIndex,this.userId, this.keySearch, required this.typeAction});

  @override
  String toString() => 'GetListEmployeeEvent';
}

class LoadingTimeKeeping extends PersonnelEvent {

  final String uId;

  LoadingTimeKeeping({required this.uId});

  @override
  String toString() {
    return 'LoadingTimeKeeping{}';
  }
}

class TimeKeepingFromUserEvent2 extends PersonnelEvent {
  final String datetime;
  final String qrCode;
  final String uId;

  TimeKeepingFromUserEvent2(this.datetime, this.qrCode,this.uId);

  @override
  String toString() {
    return 'TimeKeepingFromUserEvent{datetime: $datetime ,qrCode :$qrCode}';
  }
}

class CheckShowCloseEvent extends PersonnelEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}

class GetTotalUnreadNotificationEvent extends PersonnelEvent {
  @override
  String toString() {
    return 'GetTotalUnreadNotificationEvent{}';
  }
}