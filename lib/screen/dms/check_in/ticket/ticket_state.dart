import 'package:equatable/equatable.dart';

import '../../../../model/entity/item_check_in.dart';

abstract class TicketState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialTicketState extends TicketState {

  @override
  String toString() {
    return 'InitialTicketState{}';
  }
}

class GetPrefsSuccess extends TicketState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}

class GetListTicketOffLineSuccess extends TicketState{

  final List<ItemListTicketOffLine> listTicketOffLine;

  GetListTicketOffLineSuccess({required this.listTicketOffLine});

  @override
  String toString() {
    return 'GetListTicketOffLineSuccess{}';
  }
}

class GetListAlbumTicketSuccess extends TicketState{

  @override
  String toString() {
    return 'GetListAlbumTicketSuccess{}';
  }
}

class PickAlbumTicketSuccess extends TicketState{

  @override
  String toString() {
    return 'PickAlbumTicketSuccess{}';
  }
}


class TicketLoading extends TicketState {

  @override
  String toString() => 'TicketLoading';
}

class TicketFailure extends TicketState {
  final String error;

  TicketFailure(this.error);

  @override
  String toString() => 'TicketFailure { error: $error }';
}

class GetListTicketEmpty extends TicketState {

  @override
  String toString() {
    return 'GetListTicketEmpty{}';
  }
}

class GetListTicketSuccess extends TicketState {

  @override
  String toString() {
    return 'GetListTicketSuccess{}';
  }
}

class AddNewTicketSuccess extends TicketState {

  @override
  String toString() {
    return 'AddNewTicketSuccess{ }';
  }
}

class DeleteTicketSuccess extends TicketState {

  @override
  String toString() {
    return 'DeleteTicketSuccess{ }';
  }
}
class UpdateTicketSuccess extends TicketState {

  @override
  String toString() {
    return 'UpdateTicketSuccess{ }';
  }
}


class EmployeeScanFailure extends TicketState {
  final String error;

  EmployeeScanFailure(this.error);

  @override
  String toString() => 'EmployeeScanFailure { error: $error }';
}

class GrantCameraPermission extends TicketState {

  @override
  String toString() {
    return 'GrantCameraPermission{}';
  }
}