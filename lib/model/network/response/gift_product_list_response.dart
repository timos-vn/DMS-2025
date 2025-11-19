class GiftProductListResponse {
  GiftProductListData? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GiftProductListResponse({
    this.data,
    this.totalPage,
    this.statusCode,
    this.message,
  });

  GiftProductListResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? GiftProductListData.fromJson(json['data']) : null;
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class GiftProductListData {
  List<GiftProductItem>? danhSachHangTang;

  GiftProductListData({this.danhSachHangTang});

  GiftProductListData.fromJson(Map<String, dynamic> json) {
    if (json['DanhSachHangTang'] != null) {
      danhSachHangTang = <GiftProductItem>[];
      json['DanhSachHangTang'].forEach((v) {
        danhSachHangTang!.add(GiftProductItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (danhSachHangTang != null) {
      data['DanhSachHangTang'] = danhSachHangTang!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class GiftProductItem {
  String? maVt;
  String? tenVt;

  GiftProductItem({
    this.maVt,
    this.tenVt,
  });

  GiftProductItem.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    return data;
  }
}

