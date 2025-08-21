class GetItemMaterialsResponse {
  List<GetItemMaterialsResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetItemMaterialsResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetItemMaterialsResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetItemMaterialsResponseData>[];
      json['data'].forEach((v) {
        data!.add(GetItemMaterialsResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class GetItemMaterialsResponseData {
  String? maVtSemi;
  String? maVt;
  String? tenVt;
  double? soLuong;
  double soLuongBanDau = 0;
  String? dvt;
  String? ngayCt1;
  double soLuongTiepNhan = 0;
  double soLuongSuDung = 0;
  double soLuongConLai = 0;


  GetItemMaterialsResponseData({this.maVtSemi,this.maVt,this.soLuongBanDau = 0, this.tenVt, this.soLuong, this.dvt, this.ngayCt1, this.soLuongTiepNhan = 0, this.soLuongSuDung = 0, this.soLuongConLai = 0});

  GetItemMaterialsResponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    soLuong = json['so_luong'];
    dvt = json['dvt'];
    ngayCt1 = json['ngay_ct1'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['so_luong'] = soLuong;
    data['dvt'] = dvt;
    data['ngay_ct1'] = ngayCt1;
    return data;
  }
}