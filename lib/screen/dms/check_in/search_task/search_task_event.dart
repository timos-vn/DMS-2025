import 'package:equatable/equatable.dart';

abstract class SearchTaskEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSearchTask extends SearchTaskEvent {
  @override
  String toString() => 'GetPrefsTask';
}

class GetListTaskEvent extends SearchTaskEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String searchKey;
  final String dateTime;
  GetListTaskEvent({this.isRefresh = false, this.isLoadMore = false,required this.searchKey, required this.dateTime});

  @override
  String toString() => 'GetListTaskEvent {}';
}

class CheckShowCloseEvent extends SearchTaskEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}

class SearchCustomerCheckInEvent extends SearchTaskEvent {

  final String keysText;

  SearchCustomerCheckInEvent(this.keysText);

  @override
  String toString() {
    return 'SearchCustomerCheckInEvent{keysText: $keysText}';
  }
}
