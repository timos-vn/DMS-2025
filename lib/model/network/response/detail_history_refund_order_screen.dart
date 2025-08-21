class GetDetailHistoryRefundOrderResponse {
  List<GetDetailHistoryRefundOrderResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetDetailHistoryRefundOrderResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetDetailHistoryRefundOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetDetailHistoryRefundOrderResponseData>[];
      json['data'].forEach((v) {
        data!.add(new GetDetailHistoryRefundOrderResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class GetDetailHistoryRefundOrderResponseData {
  String? sttRec;
  String? sttRec0;
  String? maVt;
  String? tenVt;
  double? soLuong;
  String? dvt;
  String? maKho;
  String? tenKho;
  String? maLo;
  int? kmYn;
  double? giaNt2;
  double? tienNt2;
  double? tlCk;
  double? ckNt;
  double? tlCkTt;
  double? ckTtNt;
  String? maVv;
  String? maHd;

  GetDetailHistoryRefundOrderResponseData(
      {this.sttRec,
        this.sttRec0,
        this.maVt,
        this.tenVt,
        this.soLuong,
        this.dvt,
        this.maKho,
        this.tenKho,
        this.maLo,
        this.kmYn,
        this.giaNt2,
        this.tienNt2,
        this.tlCk,
        this.ckNt,
        this.tlCkTt,
        this.ckTtNt,
        this.maVv,
        this.maHd});

  GetDetailHistoryRefundOrderResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    soLuong = json['so_luong'];
    dvt = json['dvt'];
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
    maLo = json['ma_lo'];
    kmYn = json['km_yn'];
    giaNt2 = json['gia_nt2'];
    tienNt2 = json['tien_nt2'];
    tlCk = json['tl_ck'];
    ckNt = json['ck_nt'];
    tlCkTt = json['tl_ck_tt'];
    ckTtNt = json['ck_tt_nt'];
    maVv = json['ma_vv'];
    maHd = json['ma_hd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['stt_rec0'] = this.sttRec0;
    data['ma_vt'] = this.maVt;
    data['ten_vt'] = this.tenVt;
    data['so_luong'] = this.soLuong;
    data['dvt'] = this.dvt;
    data['ma_kho'] = this.maKho;
    data['ten_kho'] = this.tenKho;
    data['ma_lo'] = this.maLo;
    data['km_yn'] = this.kmYn;
    data['gia_nt2'] = this.giaNt2;
    data['tien_nt2'] = this.tienNt2;
    data['tl_ck'] = this.tlCk;
    data['ck_nt'] = this.ckNt;
    data['tl_ck_tt'] = this.tlCkTt;
    data['ck_tt_nt'] = this.ckTtNt;
    data['ma_vv'] = this.maVv;
    data['ma_hd'] = this.maHd;
    return data;
  }
}

