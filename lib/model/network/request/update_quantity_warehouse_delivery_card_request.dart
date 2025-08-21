class UpdateQuantityInWarehouseDeliveryCardRequest {
  UpdateQuantityInWarehouseDeliveryCardRequestData? data;

  UpdateQuantityInWarehouseDeliveryCardRequest({this.data});

  UpdateQuantityInWarehouseDeliveryCardRequest.fromJson(
      Map<String, dynamic> json) {
    data = json['Data'] != null ? UpdateQuantityInWarehouseDeliveryCardRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class UpdateQuantityInWarehouseDeliveryCardRequestData {
  String? licensePlates;
  List<UpdateQuantityInWarehouseDeliveryCardDetail>? detail;

  UpdateQuantityInWarehouseDeliveryCardRequestData({this.licensePlates, this.detail});

  UpdateQuantityInWarehouseDeliveryCardRequestData.fromJson(Map<String, dynamic> json) {
    licensePlates = json['licensePlates'];
    if (json['Detail'] != null) {
      detail = <UpdateQuantityInWarehouseDeliveryCardDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(UpdateQuantityInWarehouseDeliveryCardDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['licensePlates'] = licensePlates;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpdateQuantityInWarehouseDeliveryCardDetail {
  String? sttRec;
  String? sttRec0;
  double? count;
  String? codeProduction;

  UpdateQuantityInWarehouseDeliveryCardDetail({this.sttRec, this.sttRec0, this.count, this.codeProduction});

  UpdateQuantityInWarehouseDeliveryCardDetail.fromJson(Map<String, dynamic> json) {
    sttRec = json['sttRec'];
    sttRec0 = json['sttRec0'];
    count = json['count'];
    codeProduction = json['codeProduction'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sttRec'] = sttRec;
    data['sttRec0'] = sttRec0;
    data['count'] = count;
    data['codeProduction'] = codeProduction;
    return data;
  }
}

