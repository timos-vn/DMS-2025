import 'package:equatable/equatable.dart';

abstract class RefundOrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsRefundOrderEvent extends RefundOrderEvent {

  final bool calculator;

  GetPrefsRefundOrderEvent({required this.calculator});

  @override
  String toString() => 'GetPrefsRefundOrderEvent';
}

class GetListRefundOrderEvent extends RefundOrderEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  final String? idCustomer;

  GetListRefundOrderEvent({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo,this.idCustomer});

  @override
  String toString() => 'GetListRefundOrderEvent {}';
}

class CalculatorEvent extends RefundOrderEvent {

  @override
  String toString() => 'CalculatorEvent {}';
}

class GetListHistoryRefundOrderEvent extends RefundOrderEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  final String? idCustomer;

  GetListHistoryRefundOrderEvent({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo,this.idCustomer});

  @override
  String toString() => 'GetListHistoryRefundOrderEvent {}';
}

class GetDetailRefundOrderEvent extends RefundOrderEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? sctRec;
  final String? invoiceDate;
  final bool allowAddOrDeleteInList;
  final bool addOrDeleteInList;

  GetDetailRefundOrderEvent({this.isRefresh = false, this.isLoadMore = false,this.sctRec,this.invoiceDate, required this.allowAddOrDeleteInList, required this.addOrDeleteInList});

  @override
  String toString() => 'GetDetailRefundOrderEvent {}';
}

class GetDetailHistoryRefundOrderEvent extends RefundOrderEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? sctRec;
  final String? invoiceDate;

  GetDetailHistoryRefundOrderEvent({this.isRefresh = false, this.isLoadMore = false,this.sctRec,this.invoiceDate});

  @override
  String toString() => 'GetDetailHistoryRefundOrderEvent {}';
}

class ChangeHeightListEvent extends RefundOrderEvent{

  final bool? expanded;

  ChangeHeightListEvent({this.expanded});

  @override
  String toString() => 'ChangeHeightListEvent {expanded: $expanded}';
}

class AddNote extends RefundOrderEvent{

  final String? note;

  AddNote({this.note});

  @override
  String toString() => 'AddNote {note: $note}';
}

class PickInfoCustomer extends RefundOrderEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}

class AddNewRefundOrderEvent extends RefundOrderEvent {

  final String idCustomer ;
  final String codeTax;
  final String phoneCustomer;
  final String addressCustomer;
  final String tk;

  AddNewRefundOrderEvent({
    required this.idCustomer,required this.codeTax,
    required this.addressCustomer,required this.phoneCustomer,required this.tk,
  });

  @override
  String toString() {
    return 'AddNewRefundOrderEvent{}';
  }
}