import 'package:equatable/equatable.dart';

abstract class CustomerCareEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsCustomerCareEvent extends CustomerCareEvent {
  @override
  String toString() => 'GetPrefsDMSEvent';
}

class AddNote extends CustomerCareEvent{

  final String? note;

  AddNote({this.note});

  @override
  String toString() => 'AddNote {note: $note}';
}


class CheckInTransferEvent extends CustomerCareEvent{
  final int index;
  CheckInTransferEvent({required this.index});
  @override
  String toString() {
    return 'CheckInTransferEvent{index: $index}';
  }
}

class PickInfoCustomer extends CustomerCareEvent{

  final String? customerName;
  final String? phone;
  final String? address;
  final String? codeCustomer;

  PickInfoCustomer({this.customerName, this.phone, this.address, this.codeCustomer});

  @override
  String toString() => 'PickInfoCustomer {}';
}

class GetListCustomerCareEvent extends CustomerCareEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  final String? idCustomer;

  GetListCustomerCareEvent({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo,this.idCustomer});

  @override
  String toString() => 'GetListCustomerCareEvent {}';
}
class GetCameraEvent extends CustomerCareEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}

class AddNewCustomerCareEvent extends CustomerCareEvent {

  final String idCustomer ;
  final String typeCare;
  final String description;
  final String feedback;
  final String otherTypeCare;

  AddNewCustomerCareEvent({
    required this.idCustomer,required  this.typeCare,required  this.description,required  this.feedback,required this.otherTypeCare
  });

  @override
  String toString() {
    return 'AddNewCustomerCareEvent{}';
  }
}