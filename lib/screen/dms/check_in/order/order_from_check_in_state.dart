import 'package:equatable/equatable.dart';

abstract class OrderFromCheckInState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialOrderFromCheckInState extends OrderFromCheckInState {

  @override
  String toString() {
    return 'InitialOrderFromCheckInState{}';
  }
}

class GetPrefsSuccess extends OrderFromCheckInState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class DeleteProductInCartSuccess extends OrderFromCheckInState {

  @override
  String toString() {
    return 'DeleteProductInCartSuccess{}';
  }
}


class AddListItemProductSuccess extends OrderFromCheckInState{

  @override
  String toString() {
    return 'AddListItemProductSuccess{}';
  }
}

class GetListOrderFromCheckInSuccess extends OrderFromCheckInState{

  @override
  String toString() {
    return 'GetListOrderFromCheckInSuccess{}';
  }
}

class CreateOrderFromCheckInSuccess extends OrderFromCheckInState{

  @override
  String toString() {
    return 'CreateOrderFromCheckInSuccess{}';
  }
}


class OrderFromCheckInLoading extends OrderFromCheckInState {

  @override
  String toString() => 'OrderFromCheckInLoading';
}

class OrderFromCheckInFailure extends OrderFromCheckInState {
  final String error;

  OrderFromCheckInFailure(this.error);

  @override
  String toString() => 'OrderFromCheckInFailure { error: $error }';
}

class GetListOrderFromCheckInEmpty extends OrderFromCheckInState {

  @override
  String toString() {
    return 'GetListOrderFromCheckInEmpty{}';
  }
}

