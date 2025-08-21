import 'package:equatable/equatable.dart';

abstract class ShippingState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends ShippingState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class ShippingInitial extends ShippingState {
  @override
  String toString() => 'ShippingInitial';
}
class ShippingLoading extends ShippingState {
  @override
  String toString() => 'ShippingLoading';
}

class GetListShippingSuccess extends ShippingState {

  @override
  String toString() {
    return 'GetListShippingSuccess{}';
  }
}
class GetListShippingEmpty extends ShippingState {

  @override
  String toString() {
    return 'GetListShippingEmpty{}';
  }
}
class GetListShippingFailure extends ShippingState {
  final String error;

  GetListShippingFailure(this.error);

  @override
  String toString() => 'GetListShippingFailure { error: $error }';
}