import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsMenuEvent extends MenuEvent {
  @override
  String toString() => 'GetPrefsMenuEvent';
}

class DeleteAccount extends MenuEvent {
  @override
  String toString() => 'DeleteAccount';
}

class LogOutAppEvent extends MenuEvent {
  @override
  String toString() => 'LogOutAppEvent';
}


class GetListHistoryActionEmployeeEvent extends MenuEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  final String? idCustomer;

  GetListHistoryActionEmployeeEvent({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo,this.idCustomer});

  @override
  String toString() => 'GetListHistoryActionEmployeeEvent {}';
}
class GetDynamicListVoucherEvent extends MenuEvent {

  final String voucherCode;
  final String status;
  final DateTime dateFrom;
  final DateTime dateTo;

  GetDynamicListVoucherEvent({required this.voucherCode,required this.status,
    required this.dateFrom,required this.dateTo});

  @override
  String toString() => 'GetDynamicListVoucherEvent {}';
}

class PickFilterEvent extends MenuEvent {

  final String statusCode;
  final String statusName;
  final String voucherCode;
  final String voucherName;

  PickFilterEvent({required this.statusCode,required this.statusName,required this.voucherCode,required this.voucherName});

  @override
  String toString() {
    return 'PickFilterEvent{ statusCode: $statusCode,statusName: $statusName}';
  }
}

class GetInformationCardEvent extends MenuEvent {

  final String idCard;
  final String key;
  final bool? updateLocation;

  GetInformationCardEvent({required this.idCard,required this.key,this.updateLocation});

  @override
  String toString() => 'GetInformationCardEvent: idCard $idCard';
}

class GetTotalUnreadNotificationEvent extends MenuEvent {
  @override
  String toString() => 'GetTotalUnreadNotificationEvent';
}


class ChangePassWord extends MenuEvent {
  final String oldPass;
  final String newPass;

  ChangePassWord({required this.oldPass,required this.newPass});

  @override
  String toString() => 'ChangePassWord';
}