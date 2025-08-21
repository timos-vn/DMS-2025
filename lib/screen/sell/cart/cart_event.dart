import 'package:equatable/equatable.dart';

import '../../../model/entity/product.dart';
import '../../../model/network/request/create_order_request.dart';
import '../../../model/network/request/update_order_request.dart';
import '../../../model/network/response/search_list_item_response.dart';
import '../../../model/network/response/setting_options_response.dart';

abstract class CartEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefs extends CartEvent {
  @override
  String toString() => 'GetPrefs';
}
class DownloadFileSuccessEvent extends CartEvent {
  @override
  String toString() => 'DownloadFileSuccessEvent';
}

class TotalDiscountAndMoneyForAppEvent extends CartEvent {

  final List<Product> listProduct;
  final bool viewUpdateOrder;
  final bool reCalculator;

  TotalDiscountAndMoneyForAppEvent({required this.listProduct,required this.viewUpdateOrder,required this.reCalculator});

  @override
  String toString() => 'TotalDiscountAndMoneyForAppEvent {listProduct: $listProduct,}';
}

class CheckDisCountWhenUpdateEvent extends CartEvent {

  final String sttRec;
  final bool viewUpdateOrder;
  final bool addNewItem;
  final String codeCustomer;
  final String codeStore;

  CheckDisCountWhenUpdateEvent(this.sttRec,this.viewUpdateOrder,
      {this.addNewItem = false,required this.codeCustomer,required this.codeStore,});

  @override
  String toString() => 'CheckDisCountWhenUpdateEvent {sttRec$sttRec}';
}

class PickTypeOrderName extends CartEvent {

  final int typeOrderIndex;
  final String typeOrderName;
  final String typeOrderCode;
  PickTypeOrderName(this.typeOrderName,this.typeOrderIndex,this.typeOrderCode,);

  @override
  String toString() => 'PickTypeOrderName {}';
}

class AddOrDeleteProductGiftEvent extends CartEvent {

  final bool addItem;
  final SearchItemResponseData item;

  AddOrDeleteProductGiftEvent(this.addItem,this.item);

  @override
  String toString() => 'AddOrDeleteProductGiftEvent {}';
}


class GetListItemUpdateOrderEvent extends CartEvent {

  final String sttRec;

  GetListItemUpdateOrderEvent(this.sttRec);

  @override
  String toString() => 'GetListItemUpdateOrderEvent {sttRec: $sttRec,}';
}

class GetListProductFromDB extends CartEvent {

  final bool addOrderFromCheckIn;
  final bool getValuesTax;
  final bool reloadAndCalculatorListProduct;
  final String key;

  GetListProductFromDB({required this.addOrderFromCheckIn,required this.getValuesTax, required this.key, this.reloadAndCalculatorListProduct = false});

  @override
  String toString() => 'GetListProductFromDB{}';
}

class DeleteProductFromDB extends CartEvent {
  final bool viewUpdateOrder;
  final int index;
  final String codeProduct;
  final String codeStock;

  DeleteProductFromDB(this.viewUpdateOrder,this.index,this.codeProduct, this.codeStock);

  @override
  String toString() => 'DeleteProductFromDB{}';
}

class UpdateProductCount extends CartEvent{
  final int index;
  final double count;
  final bool addOrderFromCheckIn;
  final Product product;
  final String? stockCodeOld;

  UpdateProductCount({required this.index,
    required this.count,required this.addOrderFromCheckIn, required this.product,
    this.stockCodeOld});
  @override
  String toString() {
    return 'UpdateProductCount{}';
  }
}

class Decrement extends CartEvent{
  final int index;
  Decrement(this.index);
  @override
  String toString() {
    return 'Decrement{}';
  }
}

class Increment extends CartEvent{
  final int index;
  Increment(this.index);
  @override
  String toString() {
    return 'Increment{}';
  }
}
class AddProductSaleOutEvent extends CartEvent {

  final Product? productItem;

  AddProductSaleOutEvent({this.productItem});

  @override
  String toString() {
    return 'AddProductSaleOutEvent{productItem: $productItem}';
  }
}

/// search product
///
///



class AddCartEvent extends CartEvent {

  final Product? productItem;

  AddCartEvent({this.productItem});

  @override
  String toString() {
    return 'AddCartEvent{productItem: $productItem}';
  }
}

class SearchProduct extends CartEvent {
  final String searchText;
  final List<String> listIdGroupProduct;
  final String selected;
  final bool isLoadMore;
  final bool isRefresh;
  final String idCustomer;
  final bool isCheckStock;

  SearchProduct(this.searchText, this.listIdGroupProduct,this.selected,this.idCustomer,this.isCheckStock,{this.isLoadMore = false, this.isRefresh = false});

  @override
  String toString() {
    return 'SearchProduct{searchText: $searchText, isLoadMore: $isLoadMore, isRefresh: $isRefresh}';
  }
}
class CheckShowCloseEvent extends CartEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}
class CheckInTransferEvent extends CartEvent{
  final int index;
  CheckInTransferEvent({required this.index});
  @override
  String toString() {
    return 'CheckInTransferEvent{index: $index}';
  }
}

class PickInfoCustomer extends CartEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}

class PickInfoAgency extends CartEvent{

  final String? typeDiscount;
  final String? codeAgency;
  final String? nameAgency;
  final bool cancelAgency;

  PickInfoAgency({this.typeDiscount, this.codeAgency,this.nameAgency, required this.cancelAgency});

  @override
  String toString() => 'PickInfoAgency {}';
}

class AddNote extends CartEvent{

  final String? note;

  AddNote({this.note});

  @override
  String toString() => 'AddNote {note: $note}';
}

class DeleteAllProductFromDB extends CartEvent {

  @override
  String toString() => 'DeleteAllProductFromDB{}';
}

class ChangeHeightListEvent extends CartEvent{

  final bool? expanded;

  ChangeHeightListEvent({this.expanded});

  @override
  String toString() => 'ChangeHeightListEvent {expanded: $expanded}';
}

class ChangeHeightListProductGiftEvent extends CartEvent{

  final bool? expandedProductGift;

  ChangeHeightListProductGiftEvent({this.expandedProductGift});

  @override
  String toString() => 'ChangeHeightListProductGiftEvent {expanded: $expandedProductGift}';
}

class PickStoreName extends CartEvent {

  final int storeIndex;

  PickStoreName(this.storeIndex);

  @override
  String toString() {
    return 'PickStoreName{ storeIndex: $storeIndex}';
  }
}

class PickTaxBefore extends CartEvent {

  final int taxIndex;
  final double taxValues;

  PickTaxBefore(this.taxIndex, this.taxValues);

  @override
  String toString() {
    return 'PickTaxBefore{ taxIndex: $taxIndex}';
  }
}
class PickTaxAfter extends CartEvent {

  final int taxIndex;
  final double taxValues;

  PickTaxAfter(this.taxIndex, this.taxValues);

  @override
  String toString() {
    return 'PickTaxAfter{ taxIndex: $taxIndex}';
  }
}

class PickTransactionName extends CartEvent {

  final int transactionIndex;
  final String transactionName;
  final int showSelectAgency;

  PickTransactionName(this.transactionIndex,this.transactionName,this.showSelectAgency);

  @override
  String toString() {
    return 'PickTransactionName{ transactionIndex: $transactionIndex}';
  }
}
class PickListTypeDeliveryEvent extends CartEvent {

  final ListTypeDelivery item;
  final int typeDeliveryIndex;

  PickListTypeDeliveryEvent(this.item,this.typeDeliveryIndex);

  @override
  String toString() {
    return 'PickListTypeDeliveryEvent{ item: $item}';
  }
}

class PickTypePayment extends CartEvent {

  final int typePaymentIndex;
  final String nameTypePayment;

  PickTypePayment(this.typePaymentIndex,this.nameTypePayment);

  @override
  String toString() {
    return 'PickTypePayment{ typePaymentIndex: $typePaymentIndex}';
  }
}

class UpdateOderEvent extends CartEvent {
  final String? sttRec;
  final String? code;
  final String? storeCode;
  final String? currencyCode;final String? dateOrder;
  final List<Product>? listOrder;
  final ItemTotalMoneyUpdateRequestData? totalMoney;
  final int? valuesStatus;
  final String dateEstDelivery;

  final String? nameCompany;
  final String? mstCompany;
  final String? addressCompany;
  final String? noteCompany;
  final String? sttRectHD;

  UpdateOderEvent({this.sttRec,this.code,this.storeCode,
    this.currencyCode,this.listOrder,this.totalMoney,this.dateOrder,this.valuesStatus,required this.dateEstDelivery,this.nameCompany, this.mstCompany,
    this.addressCompany, this.noteCompany, this.sttRectHD});

  @override
  String toString() => 'UpdateOderEvent';
}

class CreateOderEvent extends CartEvent {
  final String? code;
  final String? storeCode;
  final String? currencyCode;
  final List<Product>? listOrder;
  final ItemTotalMoneyRequestData? totalMoney;
  final String? comment;
  final String dateEstDelivery;
  final int? valuesStatus;

  final String? nameCompany;
  final String? mstCompany;
  final String? addressCompany;
  final String? noteCompany;
  final String? sttRectHD;

  CreateOderEvent({this.code,this.storeCode,this.currencyCode,this.listOrder,
    this.totalMoney, this.comment,required this.dateEstDelivery,this.valuesStatus, this.nameCompany, this.mstCompany,
    this.addressCompany, this.noteCompany,this.sttRectHD
  });

  @override
  String toString() => 'CreateOderEvent';
}
class DeleteEvent extends CartEvent {

  final String sttRec;

  DeleteEvent({required this.sttRec});

  @override
  String toString() {
    return 'DeleteEvent{sttRec:$sttRec}';
  }
}

class ApproveOrderEvent extends CartEvent {

  final String sttRec;

  ApproveOrderEvent({required this.sttRec});

  @override
  String toString() {
    return 'ApproveOrderEvent{sttRec:$sttRec}';
  }
}
// class CreateOderFromCheckInEvent extends CartEvent {
//   final String? code;
//   final String? storeCode;
//   final String? currencyCode;
//   final List<Product>? listOrder;
//   final ItemTotalMoneyRequestData? totalMoney;
//
//
//   CreateOderFromCheckInEvent({this.code,this.storeCode,this.currencyCode,this.listOrder,this.totalMoney});
//
//   @override
//   String toString() => 'CreateOderFromCheckInEvent';
// }

class UpdateProductCountInventory extends CartEvent{
  final SearchItemResponseData product;
  UpdateProductCountInventory({required this.product});
  @override
  String toString() {
    return 'UpdateProductCount{}';
  }
}

class UpdateProductCountOrderFromCheckIn extends CartEvent{
  final Product product;
  UpdateProductCountOrderFromCheckIn({required this.product});
  @override
  String toString() {
    return 'UpdateProductCountOrderFromCheckIn{}';
  }
}

class AddProductToCartEvent extends CartEvent{

  @override
  String toString() {
    return 'AddProductToCartEvent{}';
  }
}

class DeleteProductInCartEvent extends CartEvent{

  @override
  String toString() {
    return 'DeleteProductInCartEvent{}';
  }
}

class CalculatorDiscountEvent extends CartEvent{

  final SearchItemResponseData? product;
  final bool addOnProduct;
  final bool reLoad;
  final bool addTax;
  // final bool isUpdateOrder;

  CalculatorDiscountEvent({this.product,required this.addOnProduct,required this.reLoad, required this.addTax});

  @override
  String toString() {
    return 'CalculatorDiscountEvent{}';
  }
}

class GetListStockEvent extends CartEvent {

  final String itemCode;
  final bool getListGroup;
  final bool lockInputToCart;
  final bool checkStockEmployee;

  GetListStockEvent({required this.itemCode, required this.getListGroup, required this.lockInputToCart, required this.checkStockEmployee});

  @override
  String toString() {
    return 'GetListStockEvent{ itemCode: $itemCode}';
  }
}

class AddProductCountFromCheckIn extends CartEvent{
  final SearchItemResponseData product;
  AddProductCountFromCheckIn({required this.product});
  @override
  String toString() {
    return 'AddProductCountFromCheckIn{}';
  }
}

class GetCameraEvent extends CartEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}

class GetListItemApplyDiscountEvent extends CartEvent {
  final String listCKVT;
  final String listPromotion;
  final String listItem;
  final String listQty;
  final String listPrice;
  final String listMoney;
  final String warehouseId;
  final String customerId;

  final String keyLoad;

  GetListItemApplyDiscountEvent({required this.listCKVT,required this.listPromotion,required this.listItem,required this.listQty,required this.listPrice,required this.listMoney,required this.warehouseId,required this.customerId,required this.keyLoad});

  @override
  String toString() {
    return 'GetListItemApplyDiscountEvent{}';
  }
}

class SearchItemVvEvent extends CartEvent {

  final String keysText;

  SearchItemVvEvent(this.keysText);

  @override
  String toString() {
    return 'SearchItemVvEvent{keysText: $keysText}';
  }
}

class SearchItemHdEvent extends CartEvent {

  final String keysText;

  SearchItemHdEvent(this.keysText);

  @override
  String toString() {
    return 'SearchItemHdEvent{keysText: $keysText}';
  }
}
class CheckIsMarkProductEvent extends CartEvent {

  final bool isMark;
  final Product production;
  final SearchItemResponseData item;

  CheckIsMarkProductEvent(this.isMark, this.production,this.item);

  @override
  String toString() {
    return 'CheckIsMarkProductEvent{isMark: $isMark}';
  }
}
class CheckAllProductEvent extends CartEvent {

  final bool isMark;
  CheckAllProductEvent(this.isMark,);

  @override
  String toString() {
    return 'CheckAllProductEvent{isMark: $isMark}';
  }
}
class AddDiscountForProductEvent extends CartEvent {

  final double discountValues;
  AddDiscountForProductEvent({required this.discountValues});

  @override
  String toString() {
    return 'AddDiscountForProductEvent{discountValues: $discountValues}';
  }
}
class DeleteAllProductEvent extends CartEvent {

  @override
  String toString() {
    return 'DeleteAllProductEvent{}';
  }
}
class AddAllHDVVProductEvent extends CartEvent {

  final String? idVv;
  final String? idHd;
  final String? nameVv;
  final String? nameHd;
  final String? idHdForVv;

  AddAllHDVVProductEvent({this.idVv, this.idHd, this.nameVv, this.nameHd, this.idHdForVv});

  @override
  String toString() {
    return 'AddAllHDVVProductEvent{}';
  }
}
class AutoDiscountEvent extends CartEvent {

  @override
  String toString() {
    return 'AutoDiscountEvent{}';
  }
}
class GetListVVHD extends CartEvent {

  @override
  String toString() => 'GetListVVHD';
}
class DownloadFileEvent extends CartEvent {

  final String sttRec;

  DownloadFileEvent({required this.sttRec});

  @override
  String toString() => 'DownloadFileEvent';
}
class SearchItemInOrderEvent extends CartEvent {

  final int typeSearch;
  final String customerID;
  final String keySearch;
  final int pageIndex;

  SearchItemInOrderEvent( {required this.typeSearch,required this.customerID,required this.keySearch,required this.pageIndex,});

  @override
  String toString() => 'SearchItemInOrderEvent';
}
class CalculatorTaxForItemEvent extends CartEvent {
  @override
  String toString() => 'CalculatorTaxForItemEvent';
}
class UpdateListOrder extends CartEvent {
  @override
  String toString() => 'UpdateListOrder';
}