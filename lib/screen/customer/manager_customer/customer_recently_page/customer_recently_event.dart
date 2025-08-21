import 'package:equatable/equatable.dart';

abstract class CustomerRecentlyEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class GetListCustomerRecently extends CustomerRecentlyEvent{
  final bool isRefresh;
  final bool isLoadMore;

  GetListCustomerRecently({this.isRefresh = false, this.isLoadMore = false});
  @override
  String toString() {
    return 'GetListCustomerRecently{isRefresh: $isRefresh, isLoadMore: $isLoadMore}';
  }
}
class GetPrefs extends CustomerRecentlyEvent {
  @override
  String toString() => 'GetPrefs';
}
