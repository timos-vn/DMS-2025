import 'package:equatable/equatable.dart';

abstract class DetailShippingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetLocationEvent extends DetailShippingEvent {

  @override
  String toString() {
    return 'GetLocationEvent{}';
  }
}class UpdateLocationAndImageEvent extends DetailShippingEvent {
  final String sstRec;

  UpdateLocationAndImageEvent({required this.sstRec});
  @override
  String toString() {
    return 'UpdateLocationAndImageEvent{}';
  }
}
class GetItemShippingEvent extends DetailShippingEvent {

  final String sstRec;

  GetItemShippingEvent(this.sstRec);

  @override
  String toString() => 'GetItemShippingEvent {}';
}

class ConfirmShippingEvent extends DetailShippingEvent {

  final String? sstRec;
  final int? typePayment;
  final int? status;
  final String? desc;
  final String? soPhieuXuat;

  ConfirmShippingEvent({this.sstRec,this.status,this.typePayment,this.desc,this.soPhieuXuat});

  @override
  String toString() => 'ConfirmShippingEvent {}';
}
class GetPrefs extends DetailShippingEvent {
  @override
  String toString() => 'GetPrefs';
}