import 'package:equatable/equatable.dart';

abstract class ManagerCustomerAllState extends Equatable {
  @override
  List<Object> get props => [];
}

class ManagerCustomerAllInitial extends ManagerCustomerAllState {

  @override
  String toString() => 'ManagerCustomerAllInitial';
}

class ManagerCustomerAllFailure extends ManagerCustomerAllState {
  final String error;

  ManagerCustomerAllFailure(this.error);

  @override
  String toString() => 'ManagerCustomerAllFailure { error: $error }';
}

class ManagerCustomerAllLoading extends ManagerCustomerAllState {
  @override
  String toString() => 'ManagerCustomerAllLoading';
}

class GetLisCustomerAllSuccess extends ManagerCustomerAllState {
  @override
  String toString() => 'GetLisCustomerAllSuccess';
}
class GetLisCustomerAllEmpty extends ManagerCustomerAllState {

  @override
  String toString() {
    return 'GetLisCustomerAllEmpty{}';
  }
}
class GetPrefsSuccess extends ManagerCustomerAllState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
