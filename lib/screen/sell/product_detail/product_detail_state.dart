import 'package:equatable/equatable.dart';

abstract class ProductDetailState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends ProductDetailState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class ProductDetailInitial extends ProductDetailState {

  @override
  String toString() => 'ProductDetailInitial';
}
class ProductDetailLoading extends ProductDetailState {

  @override
  String toString() => 'ProductDetailLoading';
}

class GetProductDetailSuccess extends ProductDetailState {

  @override
  String toString() => 'GetProductDetailSuccess';
}



class ProductDetailFailure extends ProductDetailState {
  final String error;

  ProductDetailFailure(this.error);

  @override
  String toString() => 'ProductDetailFailure { error: $error }';
}