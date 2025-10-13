import 'package:equatable/equatable.dart';

import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/update_order_request.dart';
import '../../../model/network/response/search_list_item_response.dart';

abstract class SaleOutEvent extends Equatable {
  @override
  List<Object> get props => [];
}
class PickTransactionName extends SaleOutEvent {

  final int transactionIndex;
  final String transactionName;

  PickTransactionName(this.transactionIndex,this.transactionName);

  @override
  String toString() {
    return 'PickTransactionName{ transactionIndex: $transactionIndex}';
  }
}
class GetSaleOutPrefs extends SaleOutEvent {
  @override
  String toString() => 'SaleOutPrefs';
}

class ChangeHeightListProductGiftEvent extends SaleOutEvent{

  final bool? expandedProductGift;

  ChangeHeightListProductGiftEvent({this.expandedProductGift});

  @override
  String toString() => 'ChangeHeightListProductGiftEvent {expanded: $expandedProductGift}';
}

class GetListHistorySaleOutEvent extends SaleOutEvent {

  final String? dateFrom;
  final String? dateTo;
  final String? idCustomer;
  final int pageIndex;

  GetListHistorySaleOutEvent({this.dateFrom,this.dateTo, this.idCustomer,required this.pageIndex});

  @override
  String toString() => 'GetListOderEvent {dateFrom: $dateFrom,dateTo : $dateTo,idCustomer: $idCustomer}';
}

class GetDetailHistorySaleOutEvent extends SaleOutEvent {

  final String sttRec;
  final String invoiceDate;

  GetDetailHistorySaleOutEvent({required this.sttRec,required this.invoiceDate});

  @override
  String toString() => 'GetDetailHistorySaleOutEvent {sttRec: $sttRec,invoiceDate : $invoiceDate}';
}

class AddOrDeleteProductGiftEvent extends SaleOutEvent {

  final bool addItem;
  final SearchItemResponseData item;

  AddOrDeleteProductGiftEvent(this.addItem,this.item);

  @override
  String toString() => 'AddOrDeleteProductGiftEvent {}';
}


class GetListStockEvent extends SaleOutEvent {

  final String itemCode;
  final bool checkStockEmployee;

  GetListStockEvent({required this.itemCode,required this.checkStockEmployee});

  @override
  String toString() {
    return 'GetListStockEvent{ itemCode: $itemCode}';
  }
}


class GetListItemUpdateOrderEvent extends SaleOutEvent {

  final String sttRec;

  GetListItemUpdateOrderEvent(this.sttRec);

  @override
  String toString() => 'GetListItemUpdateOrderEvent {sttRec: $sttRec,}';
}

class GetListProductFromDB extends SaleOutEvent {

  @override
  String toString() => 'GetListProductFromDB{}';
}

class DeleteProductFromDB extends SaleOutEvent {
  final int index;
  final Product itemProduct;

  DeleteProductFromDB(this.index,this.itemProduct);

  @override
  String toString() => 'DeleteProductFromDB{}';
}

class UpdateProductCountEvent extends SaleOutEvent{
  final int index;
  final Product item;
  UpdateProductCountEvent({required this.index, required this.item});
  @override
  String toString() {
    return 'UpdateProductCount{}';
  }
}

/// search product
///
///

class PickInfoCustomer extends SaleOutEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}

class PickInfoAgent extends SaleOutEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoAgent({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoAgent {}';
}

class AddNote extends SaleOutEvent{

  final String? note;

  AddNote({this.note});

  @override
  String toString() => 'AddNote {note: $note}';
}

class ChangeHeightListEvent extends SaleOutEvent{

  final bool? expanded;

  ChangeHeightListEvent({this.expanded});

  @override
  String toString() => 'ChangeHeightListEvent {expanded: $expanded}';
}

class DeleteAllProductFromDB extends SaleOutEvent {

  @override
  String toString() => 'DeleteAllProductFromDB{}';
}

class UpdateSaleOutEvent extends SaleOutEvent {
  final String? codeCustomer;
  final List<Product> listOrder;
  final String dateTime;
  final String desc;
  final String dateEstDelivery;

  UpdateSaleOutEvent({this.codeCustomer,required this.listOrder,required this.dateTime, required this.desc,required this.dateEstDelivery});

  @override
  String toString() => 'UpdateSaleOutEvent';
}

/// Auto load agent by maNPP
class AutoLoadAgentByNPPEvent extends SaleOutEvent {
  final String maNPP;

  AutoLoadAgentByNPPEvent({required this.maNPP});

  @override
  String toString() => 'AutoLoadAgentByNPPEvent { maNPP: $maNPP }';
}