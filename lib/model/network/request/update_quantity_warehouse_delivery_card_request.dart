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
  int? action;
  List<UpdateQuantityInWarehouseDeliveryCardDetail>? detail;
  List<UpdateQuantityInWarehouseDeliveryCardDetail>? listBarcode;

  UpdateQuantityInWarehouseDeliveryCardRequestData({this.licensePlates, this.detail, this.listBarcode, this.action});

  UpdateQuantityInWarehouseDeliveryCardRequestData.fromJson(Map<String, dynamic> json) {
    action = json["action"];
    licensePlates = json['licensePlates'];
    if (json['Detail'] != null) {
      detail = <UpdateQuantityInWarehouseDeliveryCardDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(UpdateQuantityInWarehouseDeliveryCardDetail.fromJson(v));
      });
    }  if (json['listBarcode'] != null) {
      listBarcode = <UpdateQuantityInWarehouseDeliveryCardDetail>[];
      json['listBarcode'].forEach((v) {
        listBarcode!.add(UpdateQuantityInWarehouseDeliveryCardDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['licensePlates'] = licensePlates;
    data['action'] = action;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    } if (listBarcode != null) {
      data['listBarcode'] = listBarcode!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpdateQuantityInWarehouseDeliveryCardDetail {
  String? sttRec;
  String? sttRec0;
  double? soCan;
  double? soLuong;
  String? codeProduction;
  String? barcode;
  int? index;
  String? maLo; // Mã lô
  String? maKho; // Mã kho
  String? pallet; // Pallet
  String? timeScan; // Thời gian scan

  UpdateQuantityInWarehouseDeliveryCardDetail({
    this.sttRec, 
    this.sttRec0, 
    this.soCan, 
    this.soLuong, 
    this.codeProduction, 
    this.barcode,
    this.index,
    this.maLo,
    this.maKho,
    this.pallet,
    this.timeScan
  });

  UpdateQuantityInWarehouseDeliveryCardDetail.fromJson(Map<String, dynamic> json) {
    sttRec = json['sttRec'];
    sttRec0 = json['sttRec0'];
    soCan = json['soCan'];
    soLuong = json['soLuong'];
    codeProduction = json['codeProduction'];
    barcode = json['barcode'];
    index = json['index'];
    maLo = json['maLo'];
    maKho = json['maKho'];
    pallet = json['pallet'];
    timeScan = json['timeScan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sttRec'] = sttRec;
    data['sttRec0'] = sttRec0;
    data['soCan'] = soCan;
    data['soLuong'] = soLuong;
    data['codeProduction'] = codeProduction;
    data['barcode'] = barcode;
    data['index'] = index;
    data['maLo'] = maLo;
    data['maKho'] = maKho;
    data['pallet'] = pallet;
    data['timeScan'] = timeScan;
    return data;
  }
}

