import 'package:equatable/equatable.dart';

import '../../../../model/network/response/new_store_approval_detail_response.dart';

abstract class NewStoreApprovalDetailState extends Equatable {
  const NewStoreApprovalDetailState();

  @override
  List<Object?> get props => [];
}

class NewStoreApprovalDetailInitial extends NewStoreApprovalDetailState {}

class NewStoreApprovalDetailLoading extends NewStoreApprovalDetailState {}

class NewStoreApprovalDetailLoaded extends NewStoreApprovalDetailState {
  final NewStoreApprovalDetailData detail;

  const NewStoreApprovalDetailLoaded(this.detail);

  @override
  List<Object?> get props => [detail];
}

class NewStoreApprovalDetailFailure extends NewStoreApprovalDetailState {
  final String message;

  const NewStoreApprovalDetailFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class NewStoreApprovalActionSuccess extends NewStoreApprovalDetailState {
  final String message;

  const NewStoreApprovalActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

