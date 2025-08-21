import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class NewCustomerState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialNewCustomerState extends NewCustomerState {}

class NewCustomerLoading extends NewCustomerState {
  @override
  String toString() => 'NewCustomerLoading';
}

class GetPrefsSuccess extends NewCustomerState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class AddNewCustomerSuccess extends NewCustomerState {

  @override
  String toString() => 'AddNewCustomerSuccess';
}

class NewCustomerFailure extends NewCustomerState {
  final String error;

  NewCustomerFailure(this.error);

  @override
  String toString() => 'NewCustomerFailure { error: $error }';
}
class PickAvatarSuccess extends NewCustomerState {

  PickAvatarSuccess();

  @override
  String toString() {
    return 'PickAvatarSuccess{}';
  }
}

class ValidatePhoneNumberError extends NewCustomerState {
  final String error;

  ValidatePhoneNumberError(this.error);

  @override
  String toString() => 'ValidatePhoneNumberError { error: $error }';
}
class ValidateAddressError extends NewCustomerState {
  final String error;

  ValidateAddressError(this.error);

  @override
  String toString() => 'ValidateAddressError { error: $error }';
}
class ValidateEmailError extends NewCustomerState {
  final String error;

  ValidateEmailError(this.error);

  @override
  String toString() => 'ValidateEmailError { error: $error }';
}

class PickContactSuccess extends NewCustomerState {

  @override
  String toString() {
    return 'PickContactSuccess{}';
  }
}

class PickDateSuccess extends NewCustomerState {
  @override
  String toString() => 'PickDateSuccess';
}

class PickGenderSuccess extends NewCustomerState {
  @override
  String toString() => 'PickGenderSuccess';
}

class PhoneNumberInputSuccess extends NewCustomerState {
  final String otp;

  PhoneNumberInputSuccess(this.otp);

  @override
  String toString() {
    return 'PhoneNumberInputSuccess{otp: $otp}';
  }
}

class FocusName extends NewCustomerState {

  @override
  String toString() {
    return 'FocusName{}';
  }
}

class FocusAddress extends NewCustomerState {

  @override
  String toString() {
    return 'FocusAddress{}';
  }
}

class FocusEmail extends NewCustomerState {

  @override
  String toString() {
    return 'FocusEmail{}';
  }
}

class FocusPhoneNumber extends NewCustomerState {

  @override
  String toString() {
    return 'FocusPhoneNumber{}';
  }
}