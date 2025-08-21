import 'package:equatable/equatable.dart';

abstract class ConfirmOrderState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends ConfirmOrderState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class ConfirmOrderInitial extends ConfirmOrderState {

  @override
  String toString() => 'ConfirmOrderInitial';
}

class ConfirmOrderFailure extends ConfirmOrderState {
  final String error;

  ConfirmOrderFailure(this.error);

  @override
  String toString() => 'ConfirmOrderFailure { error: $error }';
}

class ConfirmOrderLoading extends ConfirmOrderState {
  @override
  String toString() => 'ConfirmOrderLoading';
}

class ValidateNameCustomerError extends ConfirmOrderState {
  final String error;

  ValidateNameCustomerError(this.error);

  @override
  String toString() => 'ValidateNameCustomerError { error: $error }';
}

class ValidatePhoneNumberError extends ConfirmOrderState {
  final String error;

  ValidatePhoneNumberError(this.error);

  @override
  String toString() => 'ValidatePhoneNumberError { error: $error }';
}

class ValidateAddressError extends ConfirmOrderState {
  final String error;

  ValidateAddressError(this.error);

  @override
  String toString() => 'ValidateAddressError { error: $error }';
}

class PickStoreNameSuccess extends ConfirmOrderState {

  @override
  String toString() {
    return 'PickStoreNameSuccess{}';
  }
}

class PickInfoCustomerSuccess extends ConfirmOrderState {

  @override
  String toString() {
    return 'PickInfoCustomerSuccess{}';
  }
}

class CalculatorMoneySuccess extends ConfirmOrderState {

  @override
  String toString() {
    return 'CalculatorMoneySuccess{}';
  }
}
class CreateOrderSuccess extends ConfirmOrderState {

  @override
  String toString() {
    return 'CreateOrderSuccess{}';
  }
}
class CreateOrderLoading extends ConfirmOrderState {

  @override
  String toString() {
    return 'CreateOrderLoading{}';
  }
}

class CreateOrderError extends ConfirmOrderState {
  final String error;

  CreateOrderError(this.error);

  @override
  String toString() => 'CreateOrderError { error: $error }';
}