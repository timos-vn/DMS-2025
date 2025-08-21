import 'package:equatable/equatable.dart';

import '../../../../model/entity/item_check_in.dart';

abstract class TicketHistoryState extends Equatable {
  @override
  List<Object> get props => [];
}

class InitialTicketHistoryState extends TicketHistoryState {

  @override
  String toString() {
    return 'InitialTicketState{}';
  }
}

class GetPrefsTicketHistorySuccess extends TicketHistoryState{

  @override
  String toString() {
    return 'GetPrefsSuccess{}';
  }
}


class PickAlbumTicketSuccess extends TicketHistoryState{

  @override
  String toString() {
    return 'PickAlbumTicketHistorySuccess{}';
  }
}
class GetTicketDetailHistorySuccess extends TicketHistoryState{

  @override
  String toString() {
    return 'GetTicketDetailHistorySuccess{}';
  }
}


class TicketHistoryLoading extends TicketHistoryState {

  @override
  String toString() => 'TicketLoading';
}

class TicketHistoryFailure extends TicketHistoryState {
  final String error;

  TicketHistoryFailure(this.error);

  @override
  String toString() => 'TicketHistoryFailure { error: $error }';
}

class GetListTicketHistoryEmpty extends TicketHistoryState {

  @override
  String toString() {
    return 'GetListTicketEmpty{}';
  }
}

class GetListTicketHistorySuccess extends TicketHistoryState {

  @override
  String toString() {
    return 'GetListTicketHistorySuccess{}';
  }
}

class AddNewTicketFeedbackSuccess extends TicketHistoryState {

  @override
  String toString() {
    return 'AddNewTicketSuccess{ }';
  }
}

class DeleteTicketFeedbackSuccess extends TicketHistoryState {

  @override
  String toString() {
    return 'DeleteTicketSuccess{ }';
  }
}
class UpdateTicketFeedbackSuccess extends TicketHistoryState {

  @override
  String toString() {
    return 'UpdateTicketSuccess{ }';
  }
}