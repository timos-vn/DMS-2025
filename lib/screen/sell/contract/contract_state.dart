import 'package:equatable/equatable.dart';

abstract class ContractState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialContractState extends ContractState {

  @override
  String toString() {
    return 'InitialContractState{}';
  }
}

class GetPrefsSuccess extends ContractState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
class SearchProductSuccess extends ContractState {

  @override
  String toString() => 'SearchProductSuccess';
}
class EmptySearchProductState extends ContractState {
  @override
  String toString() {
    // TODO: implement toString
    return 'EmptySearchProductState{}';
  }
}
class ContractLoading extends ContractState {

  @override
  String toString() => 'ContractLoading';
}

class GetListContractEmpty extends ContractState {

  @override
  String toString() {
    return 'GetContractEmpty{}';
  }
}
class DeleteProductInCartSuccess extends ContractState {

  @override
  String toString() {
    return 'DeleteProductInCartSuccess{}';
  }
}
class AddCartSuccess extends ContractState {

  @override
  String toString() {
    return 'AddCartSuccess{}';
  }
}

class DeleteOrderSuccess extends ContractState {

  @override
  String toString() {
    return 'DeleteOrderSuccess{}';
  }
}

class GetListContractSuccess extends ContractState {

  @override
  String toString() {
    return 'GetListContractSuccess{}';
  }
}class GetDetailContractSuccess extends ContractState {

  @override
  String toString() {
    return 'GetDetailContractSuccess{}';
  }
}
class GetListOrderFormContractSuccess extends ContractState {

  @override
  String toString() {
    return 'GetListOrderFormContractSuccess{}';
  }
}

class ContractFailure extends ContractState {
  final String error;

  ContractFailure(this.error);

  @override
  String toString() => 'ContractFailure { error: $error }';
}

class GetCountProductSuccess extends ContractState {

  final bool isNextScreen;

  GetCountProductSuccess(this.isNextScreen);

  @override
  String toString() {
    return 'GetCountProductSuccess{}';
  }
}