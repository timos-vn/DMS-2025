import 'package:equatable/equatable.dart';

import '../../model/network/request/create_order_suggest_request.dart';
import '../../model/network/response/get_item_holder_detail_response.dart';

abstract class SellEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetSellPrefsEvent extends SellEvent {
  @override
  String toString() => 'GetSellPrefsEvent';
}
class AddNote extends SellEvent{

  final String? note;

  AddNote({this.note});

  @override
  String toString() => 'AddNote {note: $note}';
}

class PickStoreName extends SellEvent {

  final int storeIndex;
  final bool input;

  PickStoreName(this.storeIndex,{required this.input});

  @override
  String toString() {
    return 'PickStoreName{ storeIndex: $storeIndex}';
  }
}
class GetDetailOrderSuggest extends SellEvent {

  final String sttRec;

  GetDetailOrderSuggest({required this.sttRec});

  @override
  String toString() {
    return 'CreateOrderSuggestEvent{ sttRec: $sttRec}';
  }
}

class CreateOrderSuggestEvent extends SellEvent {

  final CreateOrderSuggestRequest request;

  CreateOrderSuggestEvent({required this.request});

  @override
  String toString() {
    return 'CreateOrderSuggestEvent{ request: $request}';
  }
}
class PickInfoCustomer extends SellEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}
class SearchListProductSuggestEvent extends SellEvent {
  final String searchText;
  final bool isLoadMore;
  final bool isRefresh;

  SearchListProductSuggestEvent(this.searchText,{this.isLoadMore = false, this.isRefresh = false});

  @override
  String toString() {
    return 'SearchListProductSuggestEvent{searchText: $searchText, isLoadMore: $isLoadMore, isRefresh: $isRefresh}';
  }
}
class SearchListProductNoSuggestEvent extends SellEvent {
  final String searchText;
  final bool isLoadMore;
  final bool isRefresh;

  SearchListProductNoSuggestEvent(this.searchText,{this.isLoadMore = false, this.isRefresh = false});

  @override
  String toString() {
    return 'SearchListProductNoSuggestEvent{searchText: $searchText, isLoadMore: $isLoadMore, isRefresh: $isRefresh}';
  }
}
class GetListStockEvent extends SellEvent {
  final String itemCode;
  final bool checkStockEmployee;

  GetListStockEvent({required this.itemCode,required this.checkStockEmployee});

  @override
  String toString() {
    return 'GetListStockEvent{ itemCode: $itemCode}';
  }
}

class GetListTax extends SellEvent {
  @override
  String toString() => 'GetListTax';
}
class CheckShowCloseEvent extends SellEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}
class GetListHistoryOrder extends SellEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final int status;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String userId;
  final String typeLetterId;

  GetListHistoryOrder({this.isRefresh = false, this.isLoadMore = false,required this.status,
    required this.dateFrom,required this.dateTo, required this.userId, required this.typeLetterId});

  @override
  String toString() => 'GetListHistoryOrder {}';
}

class GetListApproveOrder extends SellEvent {

  final String dateFrom;
  final String dateTo;
  final int pageIndex;

  GetListApproveOrder({required this.dateFrom, required this.pageIndex,required this.dateTo});

  @override
  String toString() => 'GetListApproveOrder {}';
}

class GetListStatusOrder extends SellEvent {

  @override
  String toString() => 'GetListStatusOrder {}';
}

class ChangePageViewEvent extends SellEvent {

  final int valueChange;

  ChangePageViewEvent(this.valueChange);

  @override
  String toString() => 'ChangePageViewEvent{valueChange:$valueChange}';
}

class DeleteEvent extends SellEvent {

  final String sttRec;

  DeleteEvent({required this.sttRec});

  @override
  String toString() {
    return 'DeleteEvent{sttRec:$sttRec}';
  }
}
class GetItemHolderDetailEvent extends SellEvent {

  final String sttRec;

  GetItemHolderDetailEvent({required this.sttRec});

  @override
  String toString() {
    return 'GetItemHolderDetailEvent{sttRec:$sttRec}';
  }
}
class DeleteItemHolderEvent extends SellEvent {

  final String sttRec;

  DeleteItemHolderEvent({required this.sttRec});

  @override
  String toString() {
    return 'DeleteItemHolderEvent{sttRec:$sttRec}';
  }
}
class CreateItemHolderEvent extends SellEvent {
  final String? sttRec;
  final String? comment;
  final String? expireDate;
  final List<ListItemHolderDetailResponse> listItemHolderCreate;

  CreateItemHolderEvent({required this.listItemHolderCreate, this.sttRec, this.comment, this.expireDate});

  @override
  String toString() {
    return 'CreateItemHolderEvent{listItemHolderCreate:$listItemHolderCreate}';
  }
}