import 'package:equatable/equatable.dart';

abstract class FilterState extends Equatable {
  @override
  List<Object> get props => [];
}


class GetPrefsSuccess extends FilterState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class FilterInitial extends FilterState {

  @override
  String toString() => 'FilterInitial';
}

class FilterFailure extends FilterState {
  final String error;

  FilterFailure(this.error);

  @override
  String toString() => 'FilterFailure { error: $error }';
}

class FilterLoading extends FilterState {
  @override
  String toString() => 'FilterLoading';
}

class FilterSuccess extends FilterState {
  @override
  String toString() => 'FilterSuccess }';
}

class FilterEmpty extends FilterState {

  @override
  String toString() {
    return 'FilterEmpty{}';
  }
}
class LoadMoreFinish extends FilterState {
  @override
  String toString() {
    // TODO: implement toString
    return 'LoadMoreFinish{}';
  }
}
class SelectedSuccess extends FilterState {
  @override
  String toString() => 'SelectedSuccess }';
}
