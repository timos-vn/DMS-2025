import 'package:equatable/equatable.dart';

abstract class ProductDetailEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetProductDetailEvent extends ProductDetailEvent {
  final String itemCode;
  final String currency;

  GetProductDetailEvent(this.itemCode, this.currency);
  @override
  String toString() => 'GetProductDetailEvent {itemCode: $itemCode, currency: $currency}';
}
class GetPrefs extends ProductDetailEvent {
  @override
  String toString() => 'GetPrefs';
}

