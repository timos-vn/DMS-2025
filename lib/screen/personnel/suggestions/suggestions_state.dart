import 'package:equatable/equatable.dart';

abstract class SuggestionsState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends SuggestionsState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class SuggestionsInitial extends SuggestionsState {
  @override
  String toString() => 'SuggestionsInitial';
}
class SuggestionsLoading extends SuggestionsState {
  @override
  String toString() => 'SuggestionsLoading';
}

class GetListDNCSuccess extends SuggestionsState {

  @override
  String toString() {
    return 'GetListDNCSuccess{}';
  }
}

class GetDetailDNCSuccess extends SuggestionsState {

  @override
  String toString() {
    return 'GetDetailDNCSuccess{}';
  }
}
class GetDetailDNCEmpty extends SuggestionsState {

  @override
  String toString() {
    return 'GetDetailDNCEmpty{}';
  }
}
class CreateDNCSuccess extends SuggestionsState {

  @override
  String toString() {
    return 'CreateDNCSuccess{}';
  }
}
class ConfirmDNCSuccess extends SuggestionsState {

  final String actionConfirm;

  ConfirmDNCSuccess(this.actionConfirm);

  @override
  String toString() {
    return 'CreateDNCSuccess{}';
  }
}

class CreateLeaveLetterSuccess extends SuggestionsState {

  @override
  String toString() {
    return 'CreateLeaveLetterSuccess{}';
  }
}
class DeleteLeaveLetterSuccess extends SuggestionsState {

  @override
  String toString() {
    return 'DeleteLeaveLetterSuccess{}';
  }
}
class SuggestionsFailure extends SuggestionsState {
  final String error;

  SuggestionsFailure(this.error);

  @override
  String toString() => 'SuggestionsFailure { error: $error }';
}

class ConfirmDNCFailure extends SuggestionsState {

  final String? actionConfirm;
  final String? error;

  ConfirmDNCFailure({this.actionConfirm,this.error});

  @override
  String toString() => 'ConfirmDNCFailure { error: $error }';
}


class CancelDNCSuccess extends SuggestionsState {

  @override
  String toString() {
    return 'CancelDNCSuccess{}';
  }
}

class GetListDNCEmpty extends SuggestionsState {

  @override
  String toString() {
    return 'GetListDNCEmpty{}';
  }
}
class GetListHistoryLeaveLetterEmpty extends SuggestionsState {

  @override
  String toString() {
    return 'GetListHistoryLeaveLetterEmpty{}';
  }
}
class AddOrRemoveCoreWaterSuccess extends SuggestionsState{

  @override
  String toString() {
    return 'AddOrRemoveCoreWaterSuccess{}';
  }
}