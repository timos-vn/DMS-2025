import 'package:equatable/equatable.dart';

import '../../../../model/network/response/get_voucher_transaction_response.dart';
import '../../../../model/network/response/semi_product_response.dart';

abstract class StageStatisticEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetListStageStatistic extends StageStatisticEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String idStageStatistic;
  final String unitId;
  GetListStageStatistic({this.isRefresh = false, this.isLoadMore = false,required this.idStageStatistic,required this.unitId});

  @override
  String toString() => 'GetListStageStatistic {}';
}

class GetDetailStageStatistic extends StageStatisticEvent {
  final String soCt;
  GetDetailStageStatistic({required this.soCt});

  @override
  String toString() => 'GetDetailStageStatistic {}';
}
class GetListVoucherTransaction extends StageStatisticEvent {
  final String vcCode;
  final int type;
  GetListVoucherTransaction({required this.vcCode,required this.type});

  @override
  String toString() => 'GetListVoucherTransaction {}';
}
class GetItemMaterialsEvent extends StageStatisticEvent {
  final String item;
  final SemiProductionResponseData itemValues;
  GetItemMaterialsEvent({required this.item,required this.itemValues});

  @override
  String toString() => 'GetItemMaterialsEvent {}';
}

class GetPrefs extends StageStatisticEvent {
  @override
  String toString() => 'GetPrefs';
}
class CheckShowCloseEvent extends StageStatisticEvent {
  final String text;
  CheckShowCloseEvent(this.text);

  @override
  String toString() {
    // TODO: implement toString
    return 'CheckShowCloseEvent{}';
  }
}
class DeleteSemiItemEvent extends StageStatisticEvent {
  final SemiProductionResponseData item;
  DeleteSemiItemEvent({required this.item});

  @override
  String toString() {
    // TODO: implement toString
    return 'DeleteSemiItemEvent{}';
  }
}
class CreateManufacturingEvent extends StageStatisticEvent {
  final VoucherTransactionResponseData giaoDich;
  final String codePX;final String maLoTrinh;final String ghiChu;
  final String codeWorker;
  final String codeCa;
  final String codeLsx;
  final String codeCD;
  final String timeStart;final String timeEnd;final String quantityWorker;

  CreateManufacturingEvent({required this.giaoDich, required this.codePX,
    required this.maLoTrinh, required this.ghiChu, required this.codeWorker,
    required this.codeCa, required this.codeLsx, required this.codeCD, required this.quantityWorker,
    required this.timeStart, required this.timeEnd,});


  @override
  String toString() {
    // TODO: implement toString
    return 'CreateManufacturingEvent{}';
  }
}
class SearchSemiProduction extends StageStatisticEvent {
  final String lsx;
  final String section;
  final String searchText;
  final bool isLoadMore;
  final bool isRefresh;
  SearchSemiProduction({required this.lsx,required this.section,required this.searchText,this.isRefresh = false, this.isLoadMore = false});

  @override
  String toString() => 'SearchEveryThingEvent {}';
}
class RefreshUpdateItemBarCodeEvent extends StageStatisticEvent {

  @override
  String toString() => 'RefreshUpdateItemBarCodeEvent';
}
class GetListRequestSectionItemEvent extends StageStatisticEvent {
  final String request;
  final String route;
  final bool isLoadMore;
  final bool isRefresh;
  GetListRequestSectionItemEvent({required this.request,required this.route,required this.isLoadMore,required this.isRefresh});

  @override
  String toString() => 'GetListRequestSectionItemEvent {}';
}