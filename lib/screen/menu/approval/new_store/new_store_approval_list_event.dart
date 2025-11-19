import 'package:equatable/equatable.dart';

abstract class NewStoreApprovalListEvent extends Equatable {
  const NewStoreApprovalListEvent();

  @override
  List<Object?> get props => [];
}

class NewStoreApprovalListFetch extends NewStoreApprovalListEvent {
  final bool isRefresh;
  final bool isLoadMore;

  const NewStoreApprovalListFetch({this.isRefresh = false, this.isLoadMore = false});

  @override
  List<Object?> get props => [isRefresh, isLoadMore];
}

class NewStoreApprovalListUpdateFilter extends NewStoreApprovalListEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? status;

  const NewStoreApprovalListUpdateFilter({this.dateFrom, this.dateTo, this.status});

  @override
  List<Object?> get props => [dateFrom, dateTo, status];
}

class NewStoreApprovalListSearch extends NewStoreApprovalListEvent {
  final String keySearch;

  const NewStoreApprovalListSearch(this.keySearch);

  @override
  List<Object?> get props => [keySearch];
}

