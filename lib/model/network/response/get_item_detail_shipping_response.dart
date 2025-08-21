class GetItemShippingResponse {
  GetItemShippingResponseData? data;
  int? statusCode;
  String? message;

  GetItemShippingResponse({this.data, this.statusCode, this.message});

  GetItemShippingResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? GetItemShippingResponseData.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class GetItemShippingResponseData {
  MasterDetailItemShipping? master;
  List<DettailItemShipping>? dettail;

  GetItemShippingResponseData({this.master, this.dettail});

  GetItemShippingResponseData.fromJson(Map<String, dynamic> json) {
    master =
    json['master'] != null ? MasterDetailItemShipping.fromJson(json['master']) : null;
    if (json['dettail'] != null) {
      dettail = <DettailItemShipping>[];
      json['dettail'].forEach((v) {
        dettail!.add(DettailItemShipping.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (master != null) {
      data['master'] = master?.toJson();
    }
    if (dettail != null) {
      data['dettail'] = dettail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MasterDetailItemShipping {
  String? sttRec;
  String? ngayCt;
  String? soCt;
  String? maKh;
  String? tenKh;
  double? tSoLuong;
  String? status;
  double? tTtNt;
  double? tTcTienNt2;
  double? tCkNt;
  String? latLong;
  int? qrYN;

  MasterDetailItemShipping(
      {this.sttRec,
        this.ngayCt,
        this.soCt,
        this.maKh,
        this.tenKh,
        this.tSoLuong,
        this.status,
        this.tTtNt,
        this.tTcTienNt2,
        this.qrYN,
        this.tCkNt,this.latLong});

  MasterDetailItemShipping.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    tSoLuong = json['t_so_luong'];
    status = json['status'];
    tTtNt = json['t_tt_nt'];
    tTcTienNt2 = json['t_tc_tien_nt2'];
    tCkNt = json['t_ck_nt'];
    latLong = json['latLong'];
    qrYN = json['qr_yn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ngay_ct'] = ngayCt;
    data['so_ct'] = soCt;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['t_so_luong'] = tSoLuong;
    data['status'] = status;
    data['t_tt_nt'] = tTtNt;
    data['t_tc_tien_nt2'] = tTcTienNt2;
    data['t_ck_nt'] = tCkNt;
    data['latLong'] = latLong;
    data['qr_yn'] = qrYN;
    return data;
  }
}

class DettailItemShipping {
  String? sttRec0;
  String? maVt;
  String? tenVt;
  String? dvt;
  String? maKho;
  String? tenKho;
  double? soLuong;
  double soLuongGiao = 0;
  double? soLuongThucGiao;
  double? soLuongDaGiao;
  double? giaNt2;
  double? tienNt2;
  double? tlCk;
  double? ckNt;

  DettailItemShipping(
      {this.sttRec0,
        this.maVt,
        this.tenVt,
        this.dvt,
        this.maKho,
        this.tenKho,
        this.soLuong,
        this.soLuongThucGiao,this.soLuongDaGiao,
        this.giaNt2,
        this.tienNt2,
        this.tlCk,
        this.ckNt,this.soLuongGiao = 0});

  DettailItemShipping.fromJson(Map<String, dynamic> json) {
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    maKho = json['ma_kho'];
    soLuong = json['so_luong'];soLuongDaGiao = json['sl_da_giao'];
    soLuongThucGiao = json['so_luong_tg'];
    giaNt2 = json['gia_nt2'];
    tienNt2 = json['tien_nt2'];
    tlCk = json['tl_ck'];
    ckNt = json['ck_nt'];
    tenKho = json['ten_kho'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec0'] = sttRec0;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['ma_kho'] = maKho;
    data['so_luong'] = soLuong;data['sl_da_giao'] = soLuongDaGiao;
    data['so_luong_tg'] = soLuongThucGiao;
    data['gia_nt2'] = giaNt2;
    data['tien_nt2'] = tienNt2;
    data['tl_ck'] = tlCk;
    data['ck_nt'] = ckNt;
    data['ten_kho'] = tenKho;
    return data;
  }
}
