import 'package:equatable/equatable.dart';

abstract class TimeKeepingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsTimeKeeping extends TimeKeepingEvent {
  @override
  String toString() => 'GetPrefsTimeKeeping';
}

class LoadingTimeKeeping extends TimeKeepingEvent {

  final String uId;

  LoadingTimeKeeping({required this.uId});

  @override
  String toString() {
    return 'LoadingTimeKeeping{}';
  }
}

class CheckLocationTimeKeepingEvent extends TimeKeepingEvent {

  @override
  String toString() {
    return 'CheckLocationTimeKeepingEvent{}';
  }
}

class TimeKeepingFromUserEvent extends TimeKeepingEvent {
  final String datetime;
  final String qrCode;
  final String uId;
  final String desc;
  final bool isWifi;
  final bool isMeetCustomer;
  final bool isUserVIP;

  TimeKeepingFromUserEvent({required this.isUserVIP,required  this.datetime, required this.qrCode,required this.uId,required this.desc,required this.isWifi,required this.isMeetCustomer});

  @override
  String toString() {
    return 'TimeKeepingFromUserEvent{datetime: $datetime ,qrCode :$qrCode}';
  }
}

class ListDataTimeKeepingFromUserEvent extends TimeKeepingEvent {
  final String datetime;

  ListDataTimeKeepingFromUserEvent({required this.datetime});

  @override
  String toString() {
    return 'ListDataTimeKeepingFromUserEvent{datetime: $datetime}';
  }
}