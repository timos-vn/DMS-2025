class ItemLocationModifyRequest {
  ItemLocationModifyRequestData? data;

  ItemLocationModifyRequest({this.data});

  ItemLocationModifyRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? ItemLocationModifyRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class ItemLocationModifyRequestData {
  List<ItemLocationModifyRequestDetail>? detail;

  ItemLocationModifyRequestData({this.detail});

  ItemLocationModifyRequestData.fromJson(Map<String, dynamic> json) {
    if (json['Detail'] != null) {
      detail = <ItemLocationModifyRequestDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(ItemLocationModifyRequestDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ItemLocationModifyRequestDetail {
  String? teVt;
  String? maVt;
  String? maViTri;
  double? soLuong;
  int? nxt;
  String? qrCode;

  ItemLocationModifyRequestDetail({this.maVt, this.maViTri, this.soLuong, this.teVt, this.nxt,this.qrCode});

  ItemLocationModifyRequestDetail.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    maViTri = json['ma_vi_tri'];
    soLuong = json['so_luong'];
    nxt = json['nxt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ma_vi_tri'] = maViTri;
    data['so_luong'] = soLuong;
    data['nxt'] = nxt;
    return data;
  }
}