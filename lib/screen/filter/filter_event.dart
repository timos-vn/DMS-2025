import 'package:equatable/equatable.dart';
import '../../model/network/response/report_field_lookup_response.dart';

abstract class FilterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefs extends FilterEvent {
  @override
  String toString() => 'GetPrefs';
}

class ReportFieldLookup extends FilterEvent {
  @override
  String toString() => 'ReportFieldLookup {}';
}

class GetListFieldLookup extends FilterEvent {
  final String? searchTextCode;
  final String? searchTextName;
  final bool isRefresh;
  final bool isLoadMore;
  final String? controller;
  final String? listItem;

  GetListFieldLookup({this.searchTextCode,this.searchTextName,this.isRefresh = false, this.isLoadMore = false,this.controller,this.listItem});

  @override
  String toString() => 'GetListFieldLookup {searchTextCode: $searchTextCode,searchTextName: $searchTextName ,isRefresh $isRefresh & isLoadMore $isLoadMore, controller $controller, listItem: $listItem}';
}
class AddItemSelectedEvent extends FilterEvent {

  final ReportFieldLookupResponseData id;
  final bool checked;

  AddItemSelectedEvent(this.id,this.checked);

  @override
  String toString() => 'AddItemSelectedEvent {id: $id, checked: $checked}';
}
class SearchConditions extends FilterEvent {
  final String? searchTextCode;
  final String? searchTextName;
  final bool isLoadMore;
  final bool isRefresh;
  SearchConditions({this.searchTextCode,this.searchTextName,this.isLoadMore = false, this.isRefresh = false});

  @override
  String toString() {
    return 'SearchConditions{searchTextCode: $searchTextCode,searchTextName: $searchTextName isLoadMore: $isLoadMore, isRefresh: $isRefresh}';
  }
}


