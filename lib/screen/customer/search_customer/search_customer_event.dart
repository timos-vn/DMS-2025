import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class SearchCustomerEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefs extends SearchCustomerEvent {
  @override
  String toString() => 'GetPrefs';
}

class SearchCustomer extends SearchCustomerEvent {
  final String searchText;
  final bool isLoadMore;
  final bool isRefresh;
  final bool? typeName;
  SearchCustomer(this.searchText, this.typeName ,{this.isLoadMore = false, this.isRefresh = false});

  @override
  String toString() {
    return 'SearchCustomer{searchText: $searchText, isLoadMore: $isLoadMore, isRefresh: $isRefresh}';
  }
}



class CheckShowCloseEvent extends SearchCustomerEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}


