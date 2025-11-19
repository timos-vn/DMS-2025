import 'package:equatable/equatable.dart';

import '../../../model/network/response/list_checkin_response.dart';

abstract class DetailCustomerState extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsSuccess extends DetailCustomerState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class DetailCustomerInitial extends DetailCustomerState {

  @override
  String toString() => 'DetailCustomerInitial';
}

class DetailCustomerFailure extends DetailCustomerState {
  final String error;

  DetailCustomerFailure(this.error);

  @override
  String toString() => 'DetailCustomerFailure { error: $error }';
}

class DetailCustomerLoading extends DetailCustomerState {
  @override
  String toString() => 'DetailCustomerLoading';
}

class GetDetailCustomerSuccess extends DetailCustomerState {
  @override
  String toString() => 'GetDetailCustomerSuccess }';
}

class GetInfoTaskCustomerSuccess extends DetailCustomerState {

  final String idCustomer;
  final int idTask;

  GetInfoTaskCustomerSuccess({required this.idCustomer,required this.idTask});

  @override
  String toString() => 'GetInfoTaskCustomerSuccess }';
}

class DetailCustomerEmpty extends DetailCustomerState {

  @override
  String toString() {
    return 'DetailCustomerEmpty{}';
  }
}
class GetDetailCheckInEmpty extends DetailCustomerState {

  @override
  String toString() {
    return 'GetDetailCheckInEmpty{}';
  }
}
class GetDetailCheckInOnlineSuccess extends DetailCustomerState {

  final ListCheckIn itemSelect;

  GetDetailCheckInOnlineSuccess({required this.itemSelect});

  @override
  String toString() {
    return 'GetDetailCheckInOnlineSuccess{}';
  }
}

class CheckPendingCheckInSuccess extends DetailCustomerState {
  final bool hasPendingCheckIn;
  final dynamic pendingCheckInData;

  CheckPendingCheckInSuccess({required this.hasPendingCheckIn, this.pendingCheckInData});

  @override
  String toString() {
    return 'CheckPendingCheckInSuccess {hasPendingCheckIn: $hasPendingCheckIn}';
  }
}
