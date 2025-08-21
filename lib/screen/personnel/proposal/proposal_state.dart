part of 'proposal_bloc.dart';



abstract class ProposalState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends ProposalState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class GetListProposalSuccess extends ProposalState{

  @override
  String toString() {
    return 'GetListProposalSuccess{}';
  }
}class GetFormDynamicSuccess extends ProposalState{

  @override
  String toString() {
    return 'GetFormDynamicSuccess{}';
  }
}class ActionDynamicSuccess extends ProposalState{
  final String values;

  ActionDynamicSuccess({required this.values});
  @override
  String toString() {
    return 'ActionDynamicSuccess{}';
  }
}class ActionUploadFileSuccess extends ProposalState{

  @override
  String toString() {
    return 'ActionUploadFileSuccess{}';
  }
}class LookUpDynamicFormSuccess extends ProposalState{

  @override
  String toString() {
    return 'LookUpDynamicFormSuccess{}';
  }
}
class ProposalInitial extends ProposalState {
  @override
  String toString() => 'ProposalInitial';
}


class ProposalLoading extends ProposalState {
  @override
  String toString() => 'ProposalLoading';
}

class GetListProposalEmpty extends ProposalState {
  @override
  String toString() => 'GetListProposalEmpty';
}
class LookUpDynamicFormEmpty extends ProposalState {
  @override
  String toString() => 'LookUpDynamicFormEmpty';
}


class ProposalFailure extends ProposalState {
  final String error;

  ProposalFailure(this.error);

  @override
  String toString() => 'ProposalFailure{error: $error}';
}
class GetListReportLayoutSuccess extends ProposalState {

  @override
  String toString() => 'GetListReportLayoutSuccess{ }';
}
