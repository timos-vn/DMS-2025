import 'package:equatable/equatable.dart';

abstract class SearchTaskState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialSearchTaskState extends SearchTaskState {

  @override
  String toString() {
    return 'InitialSearchTaskState{}';
  }
}

class GetPrefsSuccess extends SearchTaskState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListTaskSuccess extends SearchTaskState{

  @override
  String toString() {
    return 'GetListTaskSuccess{}';
  }
}


class SearchTaskLoading extends SearchTaskState {

  @override
  String toString() => 'SearchTourLoading';
}

class SearchTaskFailure extends SearchTaskState {
  final String error;

  SearchTaskFailure(this.error);

  @override
  String toString() => 'SearchTaskFailure { error: $error }';
}

class GetListTaskEmpty extends SearchTaskState {

  @override
  String toString() {
    return 'GetListTaskEmpty{}';
  }
}

class SearchCustomerCheckInSuccess extends SearchTaskState {

  @override
  String toString() {
    return 'SearchCustomerCheckInSuccess{}';
  }
}