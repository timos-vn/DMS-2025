import 'package:equatable/equatable.dart';

import '../../../../model/network/response/new_store_approval_list_response.dart';

abstract class NewStoreApprovalListState extends Equatable {
  const NewStoreApprovalListState();

  @override
  List<Object?> get props => [];
}

class NewStoreApprovalListInitial extends NewStoreApprovalListState {}

class NewStoreApprovalListLoading extends NewStoreApprovalListState {
  final bool isRefresh;

  const NewStoreApprovalListLoading({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class NewStoreApprovalListSuccess extends NewStoreApprovalListState {
  final List<NewStoreApprovalItem> items;
  final bool canLoadMore;
  final bool isRefresh;

  const NewStoreApprovalListSuccess({
    required this.items,
    required this.canLoadMore,
    this.isRefresh = false,
  });

  @override
  List<Object?> get props => [items, canLoadMore, isRefresh];
}

class NewStoreApprovalListEmpty extends NewStoreApprovalListState {}

class NewStoreApprovalListFailure extends NewStoreApprovalListState {
  final String message;

  const NewStoreApprovalListFailure(this.message);

  @override
  List<Object?> get props => [message];
}

