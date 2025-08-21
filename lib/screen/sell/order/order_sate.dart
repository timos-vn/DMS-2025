import 'package:equatable/equatable.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class OrderInitialState extends OrderState {

  @override
  String toString() => 'OrderInitialState';
}
class OrderFailure extends OrderState {
  final String error;

  OrderFailure(this.error);

  @override
  String toString() => error;
}

class OrderLoading extends OrderState {
  @override
  String toString() => 'OrderLoading';
}

class GetListOrderSuccess extends OrderState {
  @override
  String toString() => 'GetOrderSuccess }';
}
class SearchItemGroupSuccess extends OrderState {

  @override
  String toString() {
    return 'SearchItemGroupSuccess{}';
  }
}
class PickCurrencyNameSuccess extends OrderState {

  final String codeCurrency;

  PickCurrencyNameSuccess(this.codeCurrency);

  @override
  String toString() {
    return 'PickCurrencyNameSuccess{codeCurrency: $codeCurrency}';
  }
}
class PickTypePriceNameSuccess extends OrderState {

  @override
  String toString() {
    return 'PickTypePriceNameSuccess{}';
  }
}
class EmptyDataState extends OrderState {
  @override
  String toString() {
    // TODO: implement toString
    return 'EmptyDataState{}';
  }
}

class LoadMoreFinish extends OrderState {
  @override
  String toString() {
    // TODO: implement toString
    return 'LoadMoreFinish{}';
  }
}
class GetListGroupProductSuccess extends OrderState {
  @override
  String toString() {
    // TODO: implement toString
    return 'GetListGroupProductSuccess{}';
  }
}
class GetInfoOrderSuccess extends OrderState {
  @override
  String toString() {
    // TODO: implement toString
    return 'GetInfoOrderSuccess{}';
  }
}

class PickupGroupProductSuccess extends OrderState {

  final int codeGroup;

  PickupGroupProductSuccess(this.codeGroup);

  @override
  String toString() {
    // TODO: implement toString
    return 'PickupGroupProductSuccess{}';
  }
}

class GetListItemGroupSuccess extends OrderState {
  @override
  String toString() => 'GetListItemGroupSuccess }';
}
class GetListItemProductSuccess extends OrderState {
  @override
  String toString() => 'GetListItemProductSuccess{}';
}

class AddCartSuccess extends OrderState {

  @override
  String toString() {
    return 'AddCartSuccess{}';
  }
}
class ItemScanSuccess extends OrderState {
  @override
  String toString() => 'ItemScanSuccess }';
}
class GetPrefsSuccess extends OrderState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListStockEventSuccess extends OrderState{

  @override
  String toString() {
    return 'GetListStockEventSuccess{}';
  }
}

class GetCountProductSuccess extends OrderState {

  final bool firstLoad;

  GetCountProductSuccess(this.firstLoad);

  @override
  String toString() {
    return 'GetCountProductSuccess{}';
  }
}

class InitializeDb extends OrderState{

  @override
  String toString() {
    return 'InitializeDb{}';
  }
}