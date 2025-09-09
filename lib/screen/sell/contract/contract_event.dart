import 'package:dms/model/entity/product.dart';
import 'package:equatable/equatable.dart';

abstract class ContractEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetContractPrefsEvent extends ContractEvent {
  @override
  String toString() => 'GetContractPrefsEvent';
}

class GetListContractEvent extends ContractEvent {

  final String searchKey;
  final int pageIndex;

  GetListContractEvent({required this.searchKey,required this.pageIndex});

  @override
  String toString() => 'GetListContractEvent {}';
}
class GetDetailContractEvent extends ContractEvent {

  final String sttRec;
  final String date;
  final String searchKey;
  final int pageIndex;
  final bool isSearchItem;

  GetDetailContractEvent({required this.sttRec,required this.searchKey,required this.pageIndex,required this.date, required this.isSearchItem});

  @override
  String toString() => 'GetDetailContractEvent {}';
}
class AddCartEvent extends ContractEvent {

  final Product? productItem;

  AddCartEvent({this.productItem});

  @override
  String toString() {
    return 'AddCartEvent{productItem: $productItem}';
  }
}

class AddCartWithSttRec0ReplaceEvent extends ContractEvent {

  final Product? productItem;

  AddCartWithSttRec0ReplaceEvent({this.productItem});

  @override
  String toString() {
    return 'AddCartWithSttRec0ReplaceEvent{productItem: $productItem}';
  }
}
class DeleteProductInCartEvent extends ContractEvent{

  @override
  String toString() {
    return 'DeleteProductInCartEvent{}';
  }
}
class GetCountProductEvent extends ContractEvent{

  final bool isNextScreen;

  GetCountProductEvent({required this.isNextScreen});

  @override
  String toString() {
    return 'GetCountProductEvent{}';
  }
}
class GetListOrderFormContractEvent extends ContractEvent{

  final String soCt;

  GetListOrderFormContractEvent({required this.soCt});

  @override
  String toString() {
    return 'GetListOrderFormContractEvent{}';
  }
}