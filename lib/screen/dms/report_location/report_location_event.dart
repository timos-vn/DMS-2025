import 'package:equatable/equatable.dart';

abstract class ReportLocationEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetReportLocationPrefs extends ReportLocationEvent {
  @override
  String toString() => 'GetReportLocationPrefs';
}


class GetUserInfoEvent extends ReportLocationEvent {
  final String codeCustomer;
  final String nameCustomer;
  final String phoneCustomer;

  GetUserInfoEvent(this.codeCustomer, this.nameCustomer, this.phoneCustomer);
  @override
  String toString() {
    return 'GetUserInfoEvent{codeCustomer: $codeCustomer,nameCustomer: $nameCustomer, phoneCustomer: $phoneCustomer}';
  }
}
class GetImageEvent extends ReportLocationEvent {

  @override
  String toString() => 'GetImageEvent {}}';
}
class GetCameraEvent extends ReportLocationEvent {

  @override
  String toString() {
    return 'GetCameraEvent{}';
  }
}
class RefreshEvent extends ReportLocationEvent {

  @override
  String toString() {
    return 'RefreshEvent{}';
  }
}
class GetLocationEvent extends ReportLocationEvent {

  @override
  String toString() {
    return 'GetLocationEvent{}';
  }
}
class ReportLocationFromUserEvent extends ReportLocationEvent {
  final String datetime;
  final String customer;
  final String latLong;
  final String location;
  final String description;
  final String note;


  ReportLocationFromUserEvent(this.datetime, this.customer, this.latLong, this.location, this.description, this.note);

  @override
  String toString() {
    return 'ReportLocationFromUserEvent{datetime: $datetime , customer: $customer, latLong:$latLong, location:$location,description:$description, note: $note,image}';
  }
}