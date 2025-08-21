import 'package:equatable/equatable.dart';

import '../../model/network/response/info_store_response.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsHomeEvent extends HomeEvent {
  @override
  String toString() => 'GetPrefsHomeEvent';
}

class GetListStatusOrder extends HomeEvent {

  @override
  String toString() => 'GetListStatusOrder {}';
}

class SetStateEvent extends HomeEvent {
  @override
  String toString() => 'SetStateEvent';
}

class GetDataDefault extends HomeEvent {
  @override
  String toString() => 'GetDataDefault {}';
}
class GetListSliderImageEvent extends HomeEvent {
  @override
  String toString() => 'GetListSliderImageEvent {}';
}
class PickStoreEvent extends HomeEvent {

  final int storeIndex;
  final InfoStoreResponseData item;
  PickStoreEvent(this.storeIndex,this.item);

  @override
  String toString() {
    return 'PickStoreEvent{ storeIndex: $storeIndex}';
  }
}
class ChangeValueTime extends HomeEvent {
  final String timeId;

  ChangeValueTime({required this.timeId});
  @override
  String toString() => 'ChangeValueTime {timeId:$timeId}';
}
class GetKPIEvent extends HomeEvent {
  final String dateType;
  final String storeId;

  GetKPIEvent({required this.dateType,required this.storeId});
  @override
  String toString() => 'GetKPIEvent {dateType:$dateType}';
}

class GetReportData extends HomeEvent {

  final String reportId;
  final String timeId;
  final String? unitId;
  final String? storeId;

  GetReportData({required this.reportId, required this.timeId, this.unitId, this.storeId});

  @override
  String toString() => 'GetReportData {reportId: {$reportId}, timeId: {$timeId},unitId: {$unitId},storeId: {$storeId},}';
}


class GetTotalUnreadNotificationEvent extends HomeEvent {
  GetTotalUnreadNotificationEvent();
  @override
  String toString() => 'GetTotalUnreadNotificationEvent';
}
