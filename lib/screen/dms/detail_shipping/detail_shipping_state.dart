import 'package:equatable/equatable.dart';

abstract class DetailShippingState extends Equatable {
  @override
  List<Object> get props => [];
}

class DetailShippingInitial extends DetailShippingState {
  @override
  String toString() => 'DetailShippingInitial';
}
class DetailShippingLoading extends DetailShippingState {
  @override
  String toString() => 'DetailShippingLoading';
}
class GetLocationSuccess extends DetailShippingState {

  @override
  String toString() {
    return 'GetLocationSuccess{}';
  }
}
class GetItemShippingSuccess extends DetailShippingState {

  @override
  String toString() {
    return 'GetItemShippingSuccess{}';
  }
}

class GetListShippingEmpty extends DetailShippingState {

  @override
  String toString() {
    return 'GetListShippingEmpty{}';
  }
}

class ConfirmShippingSuccess extends DetailShippingState {

  @override
  String toString() {
    return 'ConfirmShippingSuccess{}';
  }
}
class DetailShippingFailure extends DetailShippingState {
  final String error;

  DetailShippingFailure(this.error);

  @override
  String toString() => 'DetailShippingFailure { error: $error }';
}

class GetPrefsSuccess extends DetailShippingState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}class UpdateLocationAndImageSuccess extends DetailShippingState{

  @override
  String toString() {
    return 'UpdateLocationAndImageSuccess{}';
  }
}