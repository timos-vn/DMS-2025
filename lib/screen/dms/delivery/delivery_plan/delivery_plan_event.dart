import 'package:equatable/equatable.dart';
import 'package:dms/model/network/response/delivery_plan_detail_response.dart';

abstract class DeliveryPlanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GetPrefsDeliveryPlan extends DeliveryPlanEvent {
  @override
  String toString() => 'GetPrefs';
}

class GetListDeliveryPlan extends DeliveryPlanEvent {

  final bool isRefresh;
  final bool isLoadMore;
  final String? dateFrom;
  final String? dateTo;
  GetListDeliveryPlan({this.isRefresh = false, this.isLoadMore = false,this.dateFrom,this.dateTo});

  @override
  String toString() => 'GetListDeliveryPlan {}';
}

class GetDetailDeliveryPlan extends DeliveryPlanEvent {
  final String? soCt;
  final String? ngayGiao;
  final String? maKH;
  final String? maVc;
  final String? nguoiGiao;
  GetDetailDeliveryPlan({this.soCt,this.maVc,this.maKH,this.ngayGiao,this.nguoiGiao});

  @override
  String toString() => 'GetDetailDeliveryPlan {}';
}

class UpdatePlanDeliveryDraft extends DeliveryPlanEvent {

  final String? sttRec;
  final List<DeliveryPlanDetailResponseData>? listDelivery;

  UpdatePlanDeliveryDraft({this.sttRec,this.listDelivery});

  @override
  String toString() => 'UpdatePlanDeliveryDraft {}';
}

class CreatePlanDelivery extends DeliveryPlanEvent {
  final String? sttRec;
  final String? soCt;
  final String? ngayCt;

  final List<DeliveryPlanDetailResponseData>? listDelivery;

  CreatePlanDelivery({this.sttRec,this.listDelivery,this.soCt,this.ngayCt});

  @override
  String toString() => 'CreatePlanDeliveryDraft {}';
}