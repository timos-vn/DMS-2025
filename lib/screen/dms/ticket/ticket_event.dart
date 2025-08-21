import 'package:equatable/equatable.dart';

abstract class TicketHistoryEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsTicketHistoryEvent extends TicketHistoryEvent {
  @override
  String toString() => 'GetPrefsTicketEvent';
}

class GetListTicketHistoryEvent extends TicketHistoryEvent {

  final String dateFrom;
  final String dateTo;
  final int status;
  final String? idCustomer; final String? employeeCode;
  final int pageIndex;

  GetListTicketHistoryEvent({required this.status, required this.dateFrom, required this.dateTo, this.idCustomer, this.employeeCode,required this.pageIndex});

  @override
  String toString() => 'GetListTicketHistoryEvent {}';
}


class GetDetailTicketHistoryEvent extends TicketHistoryEvent {

  final String idTicketEvent;

  GetDetailTicketHistoryEvent(this.idTicketEvent);

  @override
  String toString() {
    return 'GetDetailTicketEvent{}';
  }
}