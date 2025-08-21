import 'package:equatable/equatable.dart';

abstract class KPIEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsKPIEvent extends KPIEvent {
  @override
  String toString() => 'GetPrefsKPIEvent';
}

class GetListKPISummary extends KPIEvent {

  final String dateFrom;
  final String dateTo;

  GetListKPISummary({required this.dateFrom,required this.dateTo});

  @override
  String toString() => 'GetListKPISummary{}';
}