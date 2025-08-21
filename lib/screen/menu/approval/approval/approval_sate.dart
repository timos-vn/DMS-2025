import 'package:equatable/equatable.dart';

abstract class ApprovalState extends Equatable {
  @override
  List<Object> get props => [];
}

class ApprovalInitial extends ApprovalState {

  @override
  String toString() => 'ApprovalInitial';
}

class ApprovalFailure extends ApprovalState {
  final String error;

  ApprovalFailure(this.error);

  @override
  String toString() => 'ApprovalFailure { error: $error }';
}

class ApprovalLoading extends ApprovalState {
  @override
  String toString() => 'ApprovalLoading';
}

class GetListApprovalSuccess extends ApprovalState {
  @override
  String toString() => 'ApprovalSuccess }';
}
class RefreshApprovalSuccess extends ApprovalState {

  @override
  String toString() {
    return 'RefreshApprovalSuccess{}';
  }
}

class GetListApprovalEmpty extends ApprovalState {

  @override
  String toString() {
    return 'GetListApprovalEmpty{}';
  }
}

class GetPrefsSuccess extends ApprovalState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}