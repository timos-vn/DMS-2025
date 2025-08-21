import 'package:equatable/equatable.dart';

abstract class ManagerCustomerAllEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class GetListCustomerAll extends ManagerCustomerAllEvent{
  final bool isRefresh;
  final bool isLoadMore;

  GetListCustomerAll({this.isRefresh = false, this.isLoadMore = false});
  @override
  String toString() {
    return 'GetListCustomerAll{isRefresh: $isRefresh, isLoadMore: $isLoadMore}';
  }
}

class GetPrefs extends ManagerCustomerAllEvent {
  @override
  String toString() => 'GetPrefs';
}
