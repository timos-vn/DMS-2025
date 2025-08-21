import 'package:equatable/equatable.dart';

abstract class CustomerRecentlyState extends Equatable {
  @override
  List<Object> get props => [];
}

class CustomerRecentlyInitial extends CustomerRecentlyState {

  @override
  String toString() => 'CustomerRecentlyInitial';
}

class CustomerRecentlyFailure extends CustomerRecentlyState {
  final String error;

  CustomerRecentlyFailure(this.error);

  @override
  String toString() => 'CustomerRecentlyFailure { error: $error }';
}

class CustomerRecentlyLoading extends CustomerRecentlyState {
  @override
  String toString() => 'CustomerRecentlyLoading';
}

class GetLisCustomerRecentlySuccess extends CustomerRecentlyState {
  @override
  String toString() => 'GetLisCustomerRecentlySuccess';
}
class GetLisCustomerRecentlyEmpty extends CustomerRecentlyState {

  @override
  String toString() {
    return 'GetLisCustomerRecentlyEmpty{}';
  }
}

class GetPrefsSuccess extends CustomerRecentlyState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}
