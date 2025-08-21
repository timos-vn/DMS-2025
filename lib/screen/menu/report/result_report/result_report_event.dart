import 'package:equatable/equatable.dart';

abstract class ResultReportEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetResultReportEvent extends ResultReportEvent {
  final String idReport;
  final List<dynamic> listRequest;

  GetResultReportEvent(this.idReport, this.listRequest);

  @override
  String toString() => 'GetResultReportEvent {idReport: $idReport, listRequest:}';
}

class NextPageResultReportEvent extends ResultReportEvent {}

class PrevPageResultReportEvent extends ResultReportEvent {}

class GetPrefs extends ResultReportEvent {
  @override
  String toString() => 'GetPrefs';
}