import 'package:equatable/equatable.dart';

abstract class NewStoreApprovalDetailEvent extends Equatable {
  const NewStoreApprovalDetailEvent();

  @override
  List<Object?> get props => [];
}

class NewStoreApprovalDetailFetched extends NewStoreApprovalDetailEvent {
  final String idLead;

  const NewStoreApprovalDetailFetched(this.idLead);

  @override
  List<Object?> get props => [idLead];
}

class NewStoreApprovalSubmitted extends NewStoreApprovalDetailEvent {
  final String sttRec;
  final int action;
  final int phanCap;

  const NewStoreApprovalSubmitted({
    required this.sttRec,
    required this.action,
    required this.phanCap,
  });

  @override
  List<Object?> get props => [sttRec, action, phanCap];
}

