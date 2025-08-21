class DeliveryPlanDetailResponse {
  List<DeliveryPlanDetailResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  DeliveryPlanDetailResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  DeliveryPlanDetailResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DeliveryPlanDetailResponseData>[];
      json['data'].forEach((v) {
        data!.add( DeliveryPlanDetailResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class DeliveryPlanDetailResponseData {
  String? maVt;
  String? tenVt;
  String? dvt;
  double? slKh;
  double? slXtt;
  String? maVc;
  String? tenVc;
  String? maKh;
  String? tenKh;
  String? diaChi;
  String? gioCoMat;
  String? ngayGiao;
  String? maNvvc;
  String? tenNvvc;
  String? ghiChu;

  DeliveryPlanDetailResponseData(
      {this.maVt,
        this.tenVt,
        this.dvt,
        this.slKh,
        this.slXtt,
        this.maVc,
        this.tenVc,
        this.maKh,
        this.tenKh,
        this.diaChi,
        this.gioCoMat,this.ngayGiao,
        this.maNvvc,
        this.tenNvvc,this.ghiChu});

  DeliveryPlanDetailResponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    slKh = json['sl_kh'];
    slXtt = json['sl_xtt'];
    maVc = json['ma_vc'];
    tenVc = json['ten_vc'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    diaChi = json['dia_chi'];
    gioCoMat = json['gio_co_mat'];
    ngayGiao = json['ngay_giao'];
    maNvvc = json['ma_nvvc'];
    tenNvvc = json['ten_nvvc'];
    ghiChu = json['ghi_chu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['sl_kh'] = slKh;
    data['sl_xtt'] = slXtt;
    data['ma_vc'] = maVc;
    data['ten_vc'] = tenVc;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['dia_chi'] = diaChi;
    data['gio_co_mat'] = gioCoMat;
    data['ngay_giao'] = ngayGiao;
    data['ma_nvvc'] = maNvvc;
    data['ten_nvvc'] = tenNvvc;
    data['ghi_chu'] = ghiChu;
    return data;
  }
}

