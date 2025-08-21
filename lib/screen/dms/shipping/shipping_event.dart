import 'package:equatable/equatable.dart';

abstract class ShippingEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListShippingEvent extends ShippingEvent {

  final DateTime dateFrom;
  final DateTime dateTo;

  GetListShippingEvent({required this.dateFrom,required this.dateTo});

  @override
  String toString() => 'GetListShippingEvent {}';
}

class GetPrefsShippingEvent extends ShippingEvent {
  @override
  String toString() => 'GetPrefsShippingEvent';
}