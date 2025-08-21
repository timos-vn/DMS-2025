import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListReports extends ReportEvent {

  final bool isRefresh;

  GetListReports({this.isRefresh = false});

  @override
  String toString() => 'GetListReports {isRefresh: $isRefresh}';
}
class GetListReportLayout extends ReportEvent {
  final String reportId;
  final String reportTitle;

  GetListReportLayout(this.reportId,this.reportTitle);

  @override
  String toString() => 'GetListReportLayout {reportId: $reportId,reportTitle: $reportTitle}';
}

class GetPrefs extends ReportEvent {
  @override
  String toString() => 'GetPrefs';
}