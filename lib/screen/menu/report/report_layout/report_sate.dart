import 'package:equatable/equatable.dart';

abstract class ReportState extends Equatable {
  @override
  List<Object> get props => [];
}

class ReportInitial extends ReportState {

  @override
  String toString() => 'ReportInitial';
}
class LoadingReport extends ReportState {

  @override
  String toString() => 'LoadingReport';
}

class GetListReportSuccess extends ReportState {

  @override
  String toString() => 'GetListReportSuccess';
}

class GetListReportLayoutSuccess extends ReportState {

  final String idReport;
  final String titleReport;

  GetListReportLayoutSuccess(this.idReport,this.titleReport);

  @override
  String toString() => 'GetListReportLayoutSuccess{ idReport: $idReport,titleReport: $titleReport }';
}

class ReportFailure extends ReportState {
  final String error;

  ReportFailure(this.error);

  @override
  String toString() => 'ReportFailure { error: $error }';
}
class RefreshReportSuccess extends ReportState {

  @override
  String toString() {
    return 'RefreshReportSuccess{}';
  }
}

class GetPrefsSuccess extends ReportState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}