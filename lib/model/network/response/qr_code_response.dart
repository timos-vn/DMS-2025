class QrcodeResponse {
  String? key;
  String? soCt;
  String? sttRec;
  String? maVt;

  QrcodeResponse({this.key, this.soCt, this.sttRec, this.maVt});

  QrcodeResponse.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    soCt = json['so_ct'];
    sttRec = json['stt_rec'];
    maVt = json['ma_vt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key'] = key;
    data['so_ct'] = soCt;
    data['stt_rec'] = sttRec;
    data['ma_vt'] = maVt;
    return data;
  }
}

class QrcodeGenerateResponse {
  String? barCode;
  String? kilogram;
  String? productionDate;
  String? expirationDate;

  QrcodeGenerateResponse({this.barCode, this.kilogram, this.productionDate, this.expirationDate});

  QrcodeGenerateResponse.fromJson(Map<String, dynamic> json) {
    barCode = json['barCode'];
    kilogram = json['kilogram'];
    productionDate = json['productionDate'];
    expirationDate = json['expirationDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['barCode'] = barCode;
    data['kilogram'] = kilogram;
    data['productionDate'] = productionDate;
    data['expirationDate'] = expirationDate;
    return data;
  }
}

class GetQuantityForTicketResponse {
  Data? data;
  int? statusCode;
  Null? message;

  GetQuantityForTicketResponse({this.data, this.statusCode, this.message});

  GetQuantityForTicketResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  double? soLuong;
  double? slGiao;

  Data({this.soLuong, this.slGiao});

  Data.fromJson(Map<String, dynamic> json) {
    soLuong = json['so_luong'];
    slGiao = json['sl_giao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['so_luong'] = this.soLuong;
    data['sl_giao'] = this.slGiao;
    return data;
  }
}
