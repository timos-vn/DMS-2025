
import '../response/delivery_plan_detail_response.dart';

class UpdatePlanDeliveryRequest {
  UpdatePlanDeliveryData? data;

  UpdatePlanDeliveryRequest({this.data});

  UpdatePlanDeliveryRequest.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ?  UpdatePlanDeliveryData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class UpdatePlanDeliveryData {
  String? sttRec;
  String? orderDate;
  String? ngayCt;
  String? soCt;
  List<DeliveryPlanDetailResponseData>? detail;

  UpdatePlanDeliveryData({this.sttRec, this.orderDate, this.ngayCt, this.soCt, this.detail});

  UpdatePlanDeliveryData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    orderDate = json['orderDate'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    if (json['detail'] != null) {
      detail = <DeliveryPlanDetailResponseData>[];
      json['detail'].forEach((v) {
        detail!.add( DeliveryPlanDetailResponseData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['stt_rec'] = this.sttRec;
    data['orderDate'] = this.orderDate;
    data['ngay_ct'] = this.ngayCt;
    data['so_ct'] = this.soCt;
    if (this.detail != null) {
      data['detail'] = this.detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}