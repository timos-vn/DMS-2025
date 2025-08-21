import 'package:equatable/equatable.dart';

abstract class KPIState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialKPIState extends KPIState {

  @override
  String toString() {
    return 'InitialKPIState{}';
  }
}

class GetPrefsSuccess extends KPIState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetKPISummarySuccess extends KPIState{

  @override
  String toString() {
    return 'GetKPISummarySuccess{}';
  }
}

class KPILoading extends KPIState {

  @override
  String toString() => 'KPILoading';
}

class KPIFailure extends KPIState {

  final String error;

  KPIFailure(this.error);

  @override
  String toString() => 'KPIFailure';
}
