import 'package:equatable/equatable.dart';

abstract class TicketEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsTicket extends TicketEvent {
  @override
  String toString() => 'GetPrefsTicket';
}

class GetListTicketLocal extends TicketEvent{
  @override
  String toString() => 'GetListTicketLocal {}';
}

class GetListTicket extends TicketEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? idCustomer;
  final String? idCheckIn;
  final String? idTypeTicket;
  GetListTicket({this.isRefresh = false, this.isLoadMore = false,this.idCustomer,this.idCheckIn, this.idTypeTicket});

  @override
  String toString() => 'GetListTicket {}';
}

class GetCameraEvent extends TicketEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}

class AddNewTicketEvent extends TicketEvent {

  final String idCustomer ;
  final String idTicketType;
  final String nameTicketType;
  final String idCheckIn;
  final String comment;
  final bool addNew;
  final String? idIncrement;

  AddNewTicketEvent({
    required this.idCustomer,required  this.idTicketType,required this.nameTicketType,required  this.idCheckIn,required  this.comment,
    required this.addNew, this.idIncrement
  });

  @override
  String toString() {
    return 'AddNewTicketEvent{}';
  }
}

class DeleteOrUpdateTicketEvent extends TicketEvent {

  final String customerCode;
  final int idIncrement ;
  final String idTicketType;
  final String nameTicketType;
  final int idCheckIn;
  final String comment;
  final String filePath;
  final bool deleteAction;

  DeleteOrUpdateTicketEvent({
    required this.customerCode,
    required this.idIncrement,required  this.idTicketType,required this.nameTicketType,required  this.idCheckIn,required  this.comment,
    required this.filePath, required this.deleteAction
  });

  @override
  String toString() {
    return 'DeleteOrUpdateTicketEvent{}';
  }
}

class PickAlbumTicket extends TicketEvent {

  final String idAlbumTicket;
  final String nameAlbumTicket;final String idCheckIn;
  // final bool isToday;

  PickAlbumTicket({required this.idAlbumTicket,required this.nameAlbumTicket, required this.idCheckIn });

  @override
  String toString() {
    return 'PickAlbumTicket{ idAlbumTicket: $idAlbumTicket,nameAlbumTicket: $nameAlbumTicket}';
  }
}