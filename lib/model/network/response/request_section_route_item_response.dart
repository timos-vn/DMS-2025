class RequestSectionRouteItemResponse {
  List<RequestSectionRouteItemResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  RequestSectionRouteItemResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  RequestSectionRouteItemResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <RequestSectionRouteItemResponseData>[];
      json['data'].forEach((v) {
        data!.add(RequestSectionRouteItemResponseData.fromJson(v));
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

class RequestSectionRouteItemResponseData {
  String? maCd;
  String? tenCd;
  String? maLsx;
  String? tenLsx;
  String? ngayCt;
  String? maLoTrinh;

  RequestSectionRouteItemResponseData(
      {this.maCd,
        this.tenCd,
        this.maLsx,
        this.tenLsx,
        this.ngayCt,
        this.maLoTrinh});

  RequestSectionRouteItemResponseData.fromJson(Map<String, dynamic> json) {
    maCd = json['ma_cd'];
    tenCd = json['ten_cd'];
    maLsx = json['ma_lsx'];
    tenLsx = json['ten_lsx'];
    ngayCt = json['ngay_ct'];
    maLoTrinh = json['ma_lo_trinh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_cd'] = maCd;
    data['ten_cd'] = tenCd;
    data['ma_lsx'] = maLsx;
    data['ten_lsx'] = tenLsx;
    data['ngay_ct'] = ngayCt;
    data['ma_lo_trinh'] = maLoTrinh;
    return data;
  }
}