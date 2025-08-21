class UpdateItemBarCodeRequest {
  UpdateItemBarCodeRequestData? data;

  UpdateItemBarCodeRequest({this.data});

  UpdateItemBarCodeRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? UpdateItemBarCodeRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class UpdateItemBarCodeRequestData {
  String? sttRec;
  int? action;
  List<UpdateItemBarCodeRequestDetail>? detail;

  UpdateItemBarCodeRequestData({this.sttRec,this.detail,this.action});

  UpdateItemBarCodeRequestData.fromJson(Map<String, dynamic> json) {
    sttRec = json["stt_rec"];
    action = json["action"];
    if (json['Detail'] != null) {
      detail = <UpdateItemBarCodeRequestDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(UpdateItemBarCodeRequestDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['action'] = action;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class UpdateItemBarCodeRequestDetail {
  String? sttRec;
  int? indexItem;
  String? maVt;
  String? barcode;
  String? maKho;
  String? maLo;
  String? soCan;
  String? hsd;

  UpdateItemBarCodeRequestDetail(
      {this.sttRec,this.maVt, this.barcode, this.maKho, this.maLo, this.soCan, this.hsd, this.indexItem});

  UpdateItemBarCodeRequestDetail.fromJson(Map<String, dynamic> json) {
    sttRec = json['sttRec']; maVt = json['ma_vt']; indexItem = json['index_item'];
    barcode = json['barcode'];
    maKho = json['ma_kho'];
    maLo = json['ma_lo'];
    soCan = json['so_can'];
    hsd = json['hsd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;  data['sttRec'] = sttRec; data['index_item'] = indexItem;
    data['barcode'] = barcode;
    data['ma_kho'] = maKho;
    data['ma_lo'] = maLo;
    data['so_can'] = soCan;
    data['hsd'] = hsd;
    return data;
  }
}

