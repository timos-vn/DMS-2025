import 'package:equatable/equatable.dart';

abstract class RefundSaleOutEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsRefundSaleOutEvent extends RefundSaleOutEvent {

  final bool calculator;

  GetPrefsRefundSaleOutEvent({required this.calculator});

  @override
  String toString() => 'GetPrefsRefundSaleOutEvent';
}

class GetListSaleOutCompletedEvent extends RefundSaleOutEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  final String? idAgency;

  GetListSaleOutCompletedEvent({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo,this.idAgency});

  @override
  String toString() => 'GetListSaleOutCompletedEvent {}';
}

class CalculatorEvent extends RefundSaleOutEvent {

  @override
  String toString() => 'CalculatorEvent {}';
}

class GetListHistoryRefundSaleOutEvent extends RefundSaleOutEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  final String? idCustomer;
  final int pageIndex;

  GetListHistoryRefundSaleOutEvent({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo,this.idCustomer,required this.pageIndex});

  @override
  String toString() => 'GetListHistoryRefundSaleOutEvent {}';
}

class GetDetailSaleOutCompletedEvent extends RefundSaleOutEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? sctRec;
  final String? invoiceDate;
  final bool allowAddOrDeleteInList;
  final bool addOrDeleteInList;

  GetDetailSaleOutCompletedEvent({this.isRefresh = false, this.isLoadMore = false,this.sctRec,this.invoiceDate, required this.allowAddOrDeleteInList, required this.addOrDeleteInList});

  @override
  String toString() => 'GetDetailSaleOutCompletedEvent {}';
}

class GetDetailHistoryRefundSaleOutEvent extends RefundSaleOutEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? sctRec;
  final String? invoiceDate;

  GetDetailHistoryRefundSaleOutEvent({this.isRefresh = false, this.isLoadMore = false,this.sctRec,this.invoiceDate});

  @override
  String toString() => 'GetDetailHistoryRefundSaleOutEvent {}';
}

class ChangeHeightListEvent extends RefundSaleOutEvent{

  final bool? expanded;

  ChangeHeightListEvent({this.expanded});

  @override
  String toString() => 'ChangeHeightListEvent {expanded: $expanded}';
}

class AddNote extends RefundSaleOutEvent{

  final String? note;

  AddNote({this.note});

  @override
  String toString() => 'AddNote {note: $note}';
}

class PickInfoCustomer extends RefundSaleOutEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}

class AddNewRefundSaleOutEvent extends RefundSaleOutEvent {

  final String idCustomer ;
  final String codeTax;
  final String phoneCustomer;
  final String addressCustomer;
  final String tk;
  final String idAgency;

  AddNewRefundSaleOutEvent({
    required this.idCustomer,required this.codeTax,
    required this.addressCustomer,required this.phoneCustomer,required this.tk,required this.idAgency
  });

  @override
  String toString() {
    return 'AddNewRefundSaleOutEvent{}';
  }
}