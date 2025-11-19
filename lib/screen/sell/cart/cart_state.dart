import 'package:equatable/equatable.dart';

abstract class CartState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends CartState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListProductFromDBSuccess extends CartState{

  final bool reGetList;
  final bool getValuesTax;
  final String key;

  GetListProductFromDBSuccess(this.reGetList, this.getValuesTax, this.key);

  @override
  String toString() {
    return 'GetListProductFromDBSuccess{}';
  }
}

class CartInitial extends CartState {

  @override
  String toString() => 'CartInitial';
}

class CartFailure extends CartState {
  final String error;

  CartFailure(this.error);

  @override
  String toString() => 'CartFailure { error: $error }';
}class OrderCreateFailure extends CartState {
  final String error;

  OrderCreateFailure(this.error);

  @override
  String toString() => 'OrderCreateFailure { error: $error }';
}

class CartLoading extends CartState {
  @override
  String toString() => 'CartLoading';
}

class TotalMoneyUpdateOrderSuccess extends CartState {

  @override
  String toString() => 'TotalMoneyUpdateOrderSuccess{} }';
}

class TotalMoneyForServerSuccess extends CartState {
  @override
  String toString() => 'TotalMoneyForServerSuccess }';
}

class GetListItemUpdateOrderSuccess extends CartState {
  @override
  String toString() => 'GetListItemUpdateOrderSuccess }';
}

class GetListStockEventSuccess extends CartState{

  @override
  String toString() {
    return 'GetListStockEventSuccess{}';
  }
}

class CalculatorDiscountSuccess extends CartState {
  @override
  String toString() => 'CalculatorDiscountSuccess }';
}

class AddProductSaleOutSuccess extends CartState {

  @override
  String toString() {
    return 'AddProductSaleOutSuccess{}';
  }
}

/// search product
///
///

class AddCartSuccess extends CartState {

  @override
  String toString() {
    return 'AddCartSuccess{}';
  }
}

class AddProductToCartSuccess extends CartState {

  @override
  String toString() {
    return 'AddProductToCartSuccess{}';
  }
}

class DeleteProductInCartSuccess extends CartState {

  @override
  String toString() {
    return 'DeleteProductInCartSuccess{}';
  }
}

class SearchProductSuccess extends CartState {

  @override
  String toString() => 'SearchProductSuccess';
}
class EmptySearchProductState extends CartState {
  @override
  String toString() {
    // TODO: implement toString
    return 'EmptySearchProductState{}';
  }
}
class RequiredText extends CartState {
  @override
  String toString() {
    // TODO: implement toString
    return 'RequiredText{}';
  }
}

class LoadMoreFinish extends CartState {
  @override
  String toString() {
    // TODO: implement toString
    return 'LoadMoreFinish{}';
  }
}
class PickInfoCustomerSuccess extends CartState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}class CalculatorTaxForItemSuccess extends CartState {

  @override
  String toString() {
    return 'CalculatorTaxForItemSuccess{}';
  }
}
class AddNoteSuccess extends CartState {

  @override
  String toString() {
    return 'AddNoteSuccess{}';
  }
}
class CheckInTransferSuccess extends CartState {

  @override
  String toString() {
    return 'CheckInTransferSuccess{}';
  }
}
class CreateOrderFromCheckInSuccess extends CartState {

  @override
  String toString() {
    return 'CreateOrderFromCheckInSuccess{}';
  }
}
class CreateOrderSuccess extends CartState {

  @override
  String toString() {
    return 'CreateOrderSuccess{}';
  }
}

class ApplyDiscountSuccess extends CartState {

  final String keyLoad;

  ApplyDiscountSuccess(this.keyLoad);

  @override
  String toString() {
    return 'ApplyDiscountSuccess{}';
  }
}
class DeleteAllProductFromDBSuccess extends CartState {

  @override
  String toString() {
    return 'DeleteAllProductFromDBSuccess{}';
  }
}

class PickStoreNameSuccess extends CartState {

  @override
  String toString() {
    return 'PickStoreNameSuccess{}';
  }
}

class PickTaxAfterSuccess extends CartState {

  @override
  String toString() {
    return 'PickTaxAfterSuccess{}';
  }
}
class PickTaxBeforeSuccess extends CartState {

  @override
  String toString() {
    return 'PickTaxAfterSuccess{}';
  }
}
class PickTaxNameFail extends CartState {

  @override
  String toString() {
    return 'PickTaxNameFail{}';
  }
}
class DeleteOrderSuccess extends CartState {

  @override
  String toString() {
    return 'DeleteOrderSuccess{}';
  }
}class DownloadFileSuccess extends CartState {

  @override
  String toString() {
    return 'DownloadFileSuccess{}';
  }
}
class ApproveOrderSuccess extends CartState {

  @override
  String toString() {
    return 'ApproveOrderSuccess{}';
  }
}


class ChangeHeightListSuccess extends CartState{

  @override
  String toString() {
    return 'ChangeHeightListSuccess{}';
  }
}

class AddOrDeleteProductGiftSuccess extends CartState{

  @override
  String toString() {
    return 'AddOrDeleteProductGiftSuccess{}';
  }
}

class PickTransactionSuccess extends CartState {

  final bool showSelectAgency;

  PickTransactionSuccess(this.showSelectAgency);

  @override
  String toString() {
    return 'PickTransactionSuccess{}';
  }
}

class PickTypeOrderSuccess extends CartState {


  @override
  String toString() {
    return 'PickTransactionSuccess{}';
  }
}
class PickTypeDeliverySuccess extends CartState {
  @override
  String toString() {
    return 'PickTypeDeliverySuccess{}';
  }
}

class PickTypePaymentSuccess extends CartState {

  @override
  String toString() {
    return 'PickTypePaymentSuccess{}';
  }
}

class PickAgencySuccess extends CartState {

  @override
  String toString() {
    return 'PickAgencySuccess{}';
  }
}

class UpdateProductCountInventorySuccess extends CartState {

  @override
  String toString() {
    return 'UpdateProductCountInventorySuccess{}';
  }
}

class UpdateProductCountOrderFromCheckInSuccess extends CartState {

  @override
  String toString() {
    return 'UpdateProductCountOrderFromCheckInSuccess{}';
  }
}

class AddProductCountFromCheckInSuccess extends CartState {

  @override
  String toString() {
    return 'AddProductCountFromCheckInSuccess{}';
  }
}
class EmployeeScanFailure extends CartState {
  final String error;

  EmployeeScanFailure(this.error);

  @override
  String toString() => 'EmployeeScanFailure { error: $error }';
}

class GrantCameraPermission extends CartState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}

class SearchItemVvSuccess extends CartState {

  @override
  String toString() {
    return 'SearchItemVvSuccess{}';
  }
}

class SearchItemHdSuccess extends CartState {

  @override
  String toString() {
    return 'SearchItemHdSuccess{}';
  }
}
class CheckIsMarkProductSuccess extends CartState{

  @override
  String toString() {
    return 'CheckIsMarkProductSuccess{}';
  }
}
class CheckAllIsMarkProductSuccess extends CartState{

  final bool isMarkAll;

  CheckAllIsMarkProductSuccess(this.isMarkAll);

  @override
  String toString() {
    return 'CheckAllIsMarkProductSuccess{}';
  }
}
class AddAllHDVVProductEventSuccess extends CartState{

  @override
  String toString() {
    return 'AddAllHDVVProductEventSuccess{}';
  }
}
class AddDiscountForProductEventSuccess extends CartState{

  @override
  String toString() {
    return 'AddDiscountForProductEvent{}';
  }
}
class AutoDiscountEventSuccess extends CartState{

  @override
  String toString() {
    return 'AutoDiscountEventSuccess{}';
  }
}
class DeleteAllProductEventSuccess extends CartState{

  @override
  String toString() {
    return 'DeleteAllProductEventSuccess{}';
  }
}
class GetListVvHdSuccess extends CartState {

  @override
  String toString() {
    return 'GetListVvHdSuccess{}';
  }
}class SearchItemSuccess extends CartState {

  @override
  String toString() {
    return 'SearchItemSuccess{}';
  }
}

class GetGiftProductListSuccess extends CartState {
  @override
  String toString() {
    return 'GetGiftProductListSuccess{}';
  }
}