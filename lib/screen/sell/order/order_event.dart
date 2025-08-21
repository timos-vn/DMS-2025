import 'package:equatable/equatable.dart';

import '../../../model/entity/product.dart';

abstract class OrderEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefs extends OrderEvent {
  @override
  String toString() => 'GetPrefs';
}

class GetListOderEvent extends OrderEvent {
  final String? idCustomer;
  final String? searchValues;
  final String? codeCurrency;
  final List<String>? listCodeGroupProduct;
  final int? pageIndex;
  final bool? isRefresh;
  final bool? isLoadMore;
  final bool? isReLoad;
  final bool? isScroll;


  GetListOderEvent({this.idCustomer,this.searchValues,this.codeCurrency,required this.listCodeGroupProduct,this.pageIndex,this.isRefresh = false, this.isLoadMore = false,this.isReLoad,this.isScroll});

  @override
  String toString() => 'GetListOderEvent {idApproval: $searchValues,codeCurrency : $codeCurrency,listCodeGroupProduct: $listCodeGroupProduct,isLoadMore: $isLoadMore, isRefresh: $isRefresh, }';
}

class PickCurrencyName extends OrderEvent {

  final String currencyName;
  final String currencyCode;

  PickCurrencyName({required this.currencyName,required this.currencyCode});

  @override
  String toString() {
    return 'PickCurrencyName{ currencyName: $currencyName,currencyCode: $currencyCode}';
  }
}

class PickTypePriceName extends OrderEvent {

  final String typePriceName;
  final String typePriceCode;

  PickTypePriceName({required this.typePriceName,required this.typePriceCode});

  @override
  String toString() {
    return 'PickTypePriceName{ typePriceName: $typePriceName,typePriceCode: $typePriceCode}';
  }
}

class GetListStockEvent extends OrderEvent {
  final String itemCode;
  final bool checkStockEmployee;

  GetListStockEvent({required this.itemCode,required this.checkStockEmployee});

  @override
  String toString() {
    return 'GetListStockEvent{ itemCode: $itemCode}';
  }
}

class PickGroupProduct extends OrderEvent {

  final int codeGroupProduct;

  PickGroupProduct({required this.codeGroupProduct});

  @override
  String toString() {
    return 'PickGroupProduct{ codeGroupProduct: $codeGroupProduct}';
  }
}

class GetListGroupProductEvent extends OrderEvent {

  @override
  String toString() {
    return 'GetListGroupProductEvent{}';
  }
}

class GetListItemGroupEvent extends OrderEvent {

  final int? codeGroupProduct;
  final bool isRefresh;
  final bool isLoadMore;

  GetListItemGroupEvent({this.codeGroupProduct,this.isRefresh = false, this.isLoadMore = false});

  @override
  String toString() {
    return 'GetListItemGroupEvent{codeGroupProduct: $codeGroupProduct}';
  }
}

class AddCartEvent extends OrderEvent {

  final Product? productItem;

  AddCartEvent({this.productItem});

  @override
  String toString() {
    return 'AddCartEvent{productItem: $productItem}';
  }
}

class ScanItemEvent extends OrderEvent {

  final String codeItem;
  final String currencyCode;

  ScanItemEvent(this.codeItem,this.currencyCode);

  @override
  String toString() {
    return 'ScanItemEvent{codeItem: $codeItem, currencyCode:$currencyCode}';
  }
}
class SearchItemGroupEvent extends OrderEvent {

  final String keysText;

  SearchItemGroupEvent(this.keysText);

  @override
  String toString() {
    return 'SearchItemGroupEvent{keysText: $keysText}';
  }
}

class GetCountProductEvent extends OrderEvent{

  final bool firstLoad;

  GetCountProductEvent(this.firstLoad);

  @override
  String toString() {
    return 'GetCountProductEvent{}';
  }
}
class GetOrderInfoEvent extends OrderEvent{

  final String itemCode;
  final String listObjectJson;
  final bool updateValues;

  GetOrderInfoEvent(this.itemCode,this.listObjectJson, this.updateValues);

  @override
  String toString() {
    return 'GetOrderInfoEvent{}';
  }
}