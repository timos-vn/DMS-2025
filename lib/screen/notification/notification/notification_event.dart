import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsNotificationEvent extends NotificationEvent {
  @override
  String toString() => 'GetPrefsNotificationEvent';
}

class GetListNotificationEvent extends NotificationEvent {
  final int pageIndex;

  GetListNotificationEvent({required this.pageIndex});
  @override
  String toString() {
    return 'GetListNotification{page: $pageIndex}';
  }
}

class RealAllNotificationEvent extends NotificationEvent {
  RealAllNotificationEvent();
  @override
  String toString() => 'RealAllNotificationEvent ';
}

class GetTotalUnreadNotificationEvent extends NotificationEvent {
  GetTotalUnreadNotificationEvent();
  @override
  String toString() => 'GetTotalUnreadNotificationEvent';
}
