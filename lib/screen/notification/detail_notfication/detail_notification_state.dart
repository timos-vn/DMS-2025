// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';

abstract class DetailNotificationState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialDetailNotificationState extends DetailNotificationState {
  @override
  String toString() {
    return 'InitialDetailNotificationState{}';
  }
}

class GetPrefsSuccess extends DetailNotificationState {
  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class DetailNotificationLoading extends DetailNotificationState {
  @override
  String toString() {
    return 'DetailNotificationLoading{}';
  }
}

class DetailNotificationFailure extends DetailNotificationState {
  final String error;

  DetailNotificationFailure(this.error);

  @override
  String toString() {
    return 'DetailNotificationFailure{error: $error}';
  }
}

class AcceptDetailApprovalSuccess extends DetailNotificationState {
  final String message;

  AcceptDetailApprovalSuccess(this.message);

  @override
  String toString() {
    return 'AcceptDetailApprovalSuccess{message: $message}';
  }
}

class GetHTMLDataSuccess extends DetailNotificationState {
  @override
  String toString() {
    return 'GetHTMLDataSuccess{}';
  }
}

class ReadOneNotificationSuccess extends DetailNotificationState {
  @override
  String toString() {
    return 'ReadOneNotificationSuccess{}';
  }
}