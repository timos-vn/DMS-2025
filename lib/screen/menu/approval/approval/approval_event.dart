import 'package:equatable/equatable.dart';

abstract class ApprovalEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListApprovalEvent extends ApprovalEvent {
  final bool isRefresh;
  final bool isLoadMore;

  GetListApprovalEvent({this.isRefresh = false, this.isLoadMore = false});
  @override
  String toString() {
    return 'GetListApprovalEvent{isRefresh: $isRefresh, isLoadMore: $isLoadMore}';
  }
}
class RefreshApprovalEvent extends ApprovalEvent {
  @override
  String toString() {
    return 'RefreshApprovalEvent{}';
  }
}

class GetPrefs extends ApprovalEvent {
  @override
  String toString() => 'GetPrefs';
}