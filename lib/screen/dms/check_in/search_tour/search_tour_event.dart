import 'package:equatable/equatable.dart';

abstract class SearchTourEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSearchTour extends SearchTourEvent {
  @override
  String toString() => 'GetPrefsAlbum';
}

class GetListTourAndStateEvent extends SearchTourEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? searchKey;
  final bool isTour;
  GetListTourAndStateEvent({this.isRefresh = false, this.isLoadMore = false,this.searchKey,required this.isTour});

  @override
  String toString() => 'GetListStateEvent {}';
}

class CheckShowCloseEvent extends SearchTourEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}