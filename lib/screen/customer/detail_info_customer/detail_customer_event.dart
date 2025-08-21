import 'package:equatable/equatable.dart';

abstract class DetailCustomerEvent extends Equatable {
  @override
  List<Object> get props => [];
}


class GetPrefs extends DetailCustomerEvent {
  @override
  String toString() => 'GetPrefs';
}

class GetDetailCustomerEvent extends DetailCustomerEvent {

  final String idCustomer;

  GetDetailCustomerEvent(this.idCustomer);

  @override
  String toString() => 'GetDetailCustomerEvent {idCustomer: $idCustomer}';
}

class CreateTaskFromCustomerEvent extends DetailCustomerEvent {

  final String idCustomer;

  CreateTaskFromCustomerEvent({required this.idCustomer});

  @override
  String toString() => 'CreateTaskFromCustomerEvent {idCustomer: $idCustomer}';
}

class GetDetailCheckInOnlineEvent extends DetailCustomerEvent {
  final int idCheckIn;
  final String idCustomer;

  GetDetailCheckInOnlineEvent({required this.idCheckIn, required this.idCustomer});
  @override
  String toString() => 'GetDetailCheckInOnlineEvent: $idCheckIn';
}