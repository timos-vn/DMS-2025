
import 'package:equatable/equatable.dart';

abstract class ResultReportState extends Equatable{

  @override
  List<Object> get props => [];
}

class ResultReportInitial extends ResultReportState {

  @override
  String toString() => 'ResultReportInitial';
}
class ResultLoadingReport extends ResultReportState {

  @override
  String toString() => 'ResultLoadingReport';
}

class GetResultReportSuccess extends ResultReportState {

  @override
  String toString() => 'GetResultReportSuccess';
}

class GetResultReportEmpty extends ResultReportState {

  @override
  String toString() => 'GetResultReportEmpty';
}

class NextPageResultReportSuccess extends ResultReportState {

  @override
  String toString() => 'NextPageResultReportSuccess';
}

class PrevPageResultReportSuccess extends ResultReportState {

  @override
  String toString() => 'PrevPageResultReportSuccess';
}

class ResultReportFailure extends ResultReportState {
  final String error;

  ResultReportFailure(this.error);

  @override
  String toString() => 'ResultReportFailure { error: $error }';
}

class GetPrefsSuccess extends ResultReportState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}