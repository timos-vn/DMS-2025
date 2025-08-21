import 'package:equatable/equatable.dart';

abstract class SaleOutState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends SaleOutState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class PickTransactionSuccess extends SaleOutState {

  @override
  String toString() {
    return 'PickTransactionSuccess{}';
  }
}
class ChangeHeightListSuccess extends SaleOutState{

  @override
  String toString() {
    return 'ChangeHeightListSuccess{}';
  }
}

class GetListProductFromDBSuccess extends SaleOutState{

  final bool reGetList;

  GetListProductFromDBSuccess(this.reGetList);

  @override
  String toString() {
    return 'GetListProductFromDBSuccess{}';
  }
}

class SaleOutInitial extends SaleOutState {

  @override
  String toString() => 'SaleOutInitial';
}

class SaleOutFailure extends SaleOutState {
  final String error;

  SaleOutFailure(this.error);

  @override
  String toString() => 'SaleOutFailure { error: $error }';
}

class SaleOutLoading extends SaleOutState {
  @override
  String toString() => 'SaleOutLoading';
}


class AddNoteSuccess extends SaleOutState {

  @override
  String toString() {
    return 'AddNoteSuccess{}';
  }
}

class SaleOutSuccess extends SaleOutState {

  @override
  String toString() {
    return 'CreateOrderSuccess{}';
  }
}
class DeleteAllProductFromDBSuccess extends SaleOutState {

  @override
  String toString() {
    return 'DeleteAllProductFromDBSuccess{}';
  }
}

class DeleteProductFromDBSuccess extends SaleOutState {

  @override
  String toString() {
    return 'DeleteProductFromDBSuccess{}';
  }
}

class UpdateProductFromDBSuccess extends SaleOutState {

  @override
  String toString() {
    return 'UpdateProductFromDBSuccess{}';
  }
}

class PickStoreNameSuccess extends SaleOutState {

  @override
  String toString() {
    return 'PickStoreNameSuccess{}';
  }
}

class AddOrDeleteProductGiftSuccess extends SaleOutState{

  @override
  String toString() {
    return 'AddOrDeleteProductGiftSuccess{}';
  }
}

class UpdateProductCountInventorySuccess extends SaleOutState {

  @override
  String toString() {
    return 'UpdateProductCountInventorySuccess{}';
  }
}

class UpdateProductCountOrderFromCheckInSuccess extends SaleOutState {

  @override
  String toString() {
    return 'UpdateProductCountOrderFromCheckInSuccess{}';
  }
}

class AddProductCountFromCheckInSuccess extends SaleOutState {

  @override
  String toString() {
    return 'AddProductCountFromCheckInSuccess{}';
  }
}

class PickInfoCustomerSuccess extends SaleOutState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}

class PickInfoAgentSuccess extends SaleOutState {

  @override
  String toString() {
    return 'PickInfoAgentSuccess{}';
  }
}

class GetListStockEventSuccess extends SaleOutState{

  @override
  String toString() {
    return 'GetListStockEventSuccess{}';
  }
}

class GetListDetailSaleOutSuccess extends SaleOutState{

  @override
  String toString() {
    return 'GetListDetailSaleOutSuccess{}';
  }
}

class GetListHistorySaleOutSuccess extends SaleOutState{

  @override
  String toString() {
    return 'GetListHistorySaleOutSuccess{}';
  }
}

class GetListHistorySaleOutEmpty extends SaleOutState{

  @override
  String toString() {
    return 'GetListHistorySaleOutEmpty{}';
  }
}
