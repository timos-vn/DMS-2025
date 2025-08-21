import 'package:equatable/equatable.dart';

abstract class SellState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialSellState extends SellState {

  @override
  String toString() {
    return 'InitialSellState{}';
  }
}
class AddNoteSuccess extends SellState {

  @override
  String toString() {
    return 'AddNoteSuccess{}';
  }
}

class GetPrefsSuccess extends SellState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class SearchProductSuccess extends SellState {

  @override
  String toString() => 'SearchProductSuccess';
}
class EmptySearchProductState extends SellState {
  @override
  String toString() {
    // TODO: implement toString
    return 'EmptySearchProductState{}';
  }
}
class GetListStockEventSuccess extends SellState{

  @override
  String toString() {
    return 'GetListStockEventSuccess{}';
  }
}
class CreateOrderSuggestSuccess extends SellState{

  @override
  String toString() {
    return 'CreateOrderSuggestSuccess{}';
  }
}class DetailOrderSuggestSuccess extends SellState{

  @override
  String toString() {
    return 'DetailOrderSuggestSuccess{}';
  }
}
class SellLoading extends SellState {

  @override
  String toString() => 'SellLoading';
}

class GetListHistoryOrderEmpty extends SellState {

  @override
  String toString() {
    return 'GetListHistoryOrderEmpty{}';
  }
}

class GetListSuggestEmpty extends SellState {

  @override
  String toString() {
    return 'GetListSuggestEmpty{}';
  }
}


class DeleteOrderSuccess extends SellState {

  @override
  String toString() {
    return 'DeleteOrderSuccess{}';
  }
}
class CreateItemHolderSuccess extends SellState {

  @override
  String toString() {
    return 'CreateItemHolderSuccess{}';
  }
}class DeleteItemHolderSuccess extends SellState {

  @override
  String toString() {
    return 'DeleteItemHolderSuccess{}';
  }
}

class GetListStatusOrderSuccess extends SellState {

  @override
  String toString() {
    return 'GetListStatusOrderSuccess{}';
  }
}
class ItemHolderDetailSuccess extends SellState {

  @override
  String toString() {
    return 'ItemHolderDetailSuccess{}';
  }
}

class GetListStatusOrderEmpty extends SellState {

  @override
  String toString() {
    return 'GetListStatusOrderEmpty{}';
  }
}

class GetListHistoryOrderSuccess extends SellState {

  @override
  String toString() {
    return 'GetListHistoryOrderSuccess{}';
  }
}
class PickStoreNameSuccess extends SellState {

  @override
  String toString() {
    return 'PickStoreNameSuccess{}';
  }
}

class GetListSuggestSuccess extends SellState {

  @override
  String toString() {
    return 'GetListSuggestSuccess{}';
  }
}
class PickInfoCustomerSuccess extends SellState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}
// class GetListVvHdSuccess extends SellState {
//
//   @override
//   String toString() {
//     return 'GetListVvHdSuccess{}';
//   }
// }
class GetListTaxSuccess extends SellState {

  @override
  String toString() {
    return 'GetListTaxSuccess{}';
  }
}

class GetListApproveOrderEmpty extends SellState {

  @override
  String toString() {
    return 'GetListApproveOrderEmpty{}';
  }
}

class GetListApproveOrderSuccess extends SellState {

  @override
  String toString() {
    return 'GetListApproveOrderSuccess{}';
  }
}

class ChangePageViewSuccess extends SellState{

  final int valueChange;

  ChangePageViewSuccess(this.valueChange);

  @override
  String toString() {
    return 'ChangePageViewSuccess{valueChange:$valueChange}';
  }
}

class SellFailure extends SellState {
  final String error;

  SellFailure(this.error);

  @override
  String toString() => 'SellFailure { error: $error }';
}