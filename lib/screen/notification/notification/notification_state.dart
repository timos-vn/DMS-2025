// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

abstract class NotificationState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialNotificationState extends NotificationState {
  @override
  String toString() {
    return 'InitialNotificationState{}';
  }
}

class GetPrefsSuccess extends NotificationState {
  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class NotificationFailure extends NotificationState {
  final String error;

  NotificationFailure(this.error);

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'NotificationFailure { error: $error }';
}

class NotificationLoading extends NotificationState {
  @override
  String toString() => 'NotificationLoading';
}

class GetNotificationListSuccess extends NotificationState {
  @override
  String toString() => 'GetNotificationListSuccess';
}

class GetNotificationListEmpty extends NotificationState {
  @override
  String toString() => 'GetNotificationListEmpty{}';
}

class NotificationPrefsSuccess extends NotificationState {
  @override
  String toString() => 'NotificationPrefsSuccess{}';
}

class ReadAllNotificationSuccess extends NotificationState {
  @override
  String toString() => 'ReadAllNotificationSuccess{}';
}

class GetTotalUnreadNotificationSuccess extends NotificationState {
  @override
  String toString() => 'GetTotalUnreadNotificationSuccess ';
}
