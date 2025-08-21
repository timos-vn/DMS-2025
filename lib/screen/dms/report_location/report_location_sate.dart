import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ReportLocationState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialReportLocationState extends ReportLocationState {
  @override
  String toString() {
    // TODO: implement toString
    return 'InitialReportLocationState{}';
  }
}

class GetUserInfoSuccess extends ReportLocationState {

  @override
  String toString() {
    return 'GetUserInfoSuccess{}';
  }
}

class ReportLocationSuccess extends ReportLocationState {

  @override
  String toString() {
    return 'CheckInSuccess{}';
  }
}

class ReportLocationLoading extends ReportLocationState {

  @override
  String toString() {
    return 'ReportLocationLoading{}';
  }
}
class GetImageSuccess extends ReportLocationState {

  @override
  String toString() {
    return 'GetImageSuccess{}';
  }
}
class ReportLocationFailure extends ReportLocationState {

  final String error;

  ReportLocationFailure(this.error);

  @override
  String toString() {
    return 'ReportLocationFailure{error: $error}';
  }
}class GrantCameraPermission extends ReportLocationState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}
class EmployeeScanFailure extends ReportLocationState {
  final String error;

  EmployeeScanFailure(this.error);

  @override
  String toString() => 'EmployeeScanFailure { error: $error }';
}
class GetLocationSuccess extends ReportLocationState {

  @override
  String toString() {
    return 'GetLocationSuccess{}';
  }
}
class GetPrefsSuccess extends ReportLocationState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
