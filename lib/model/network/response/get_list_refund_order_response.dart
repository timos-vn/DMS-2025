class GetListRefundOrderResponse {
  List<GetListRefundOrderResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListRefundOrderResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListRefundOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListRefundOrderResponseData>[];
      json['data'].forEach((v) {
        data!.add( GetListRefundOrderResponseData.fromJson(v));
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

class GetListRefundOrderResponseData {
  String? sttRec;
  String? soCt;
  String? ngayCt;
  String? maKh;
  String? tenKh;
  String? ongBa;
  String? diaChi;
  String? dienThoai;
  double? tTienNt2;
  double? tCkNt;
  double? tTtNt;
  double? tSoLuong;
  double? tSlTra;
  String? maCkDl;
  double? ckDlNt;
  String? codeTax;
  double? percentTax;
  String? codeSell;
  String? tk;
  bool isMark = false;

  GetListRefundOrderResponseData(
      {this.sttRec,
        this.soCt,
        this.ngayCt,
        this.maKh,
        this.tenKh,
        this.diaChi,
        this.dienThoai,
        this.tTienNt2,
        this.tCkNt,
        this.tTtNt,
        this.tSoLuong,
        this.ongBa,
        this.tSlTra,
        this.maCkDl,
        this.ckDlNt, this.isMark = false, this.codeTax,this.percentTax, this.codeSell,this.tk});

  GetListRefundOrderResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    ngayCt = json['ngay_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    tTienNt2 = json['t_tien_nt2'];
    tCkNt = json['t_ck_nt'];
    tTtNt = json['t_tt_nt'];
    tSoLuong = json['t_so_luong'];
    tSlTra = json['t_sl_tra'];
    maCkDl = json['ma_ck_dl'];
    ckDlNt = json['ck_dl_nt'];
    codeTax = json['ma_thue'];
    codeSell = json['ma_nvbh'];
    percentTax = json['thue_suat'];
    soCt = json['so_ct'];
    tk = json['tk'];
    ongBa = json['ong_ba'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ngay_ct'] = ngayCt;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['dia_chi'] = diaChi;
    data['dien_thoai'] = dienThoai;
    data['t_tien_nt2'] = tTienNt2;
    data['t_ck_nt'] = tCkNt;
    data['t_tt_nt'] = tTtNt;
    data['t_so_luong'] = tSoLuong;
    data['t_sl_tra'] = tSlTra;
    data['ma_ck_dl'] = maCkDl;
    data['ck_dl_nt'] = ckDlNt;
    data['ma_thue'] = codeTax;
    data['ma_nvbh'] = codeSell;
    data['thue_suat'] = percentTax;
    data['so_ct'] = soCt;data['ong_ba'] = ongBa;
    data['tk'] = tk;
    return data;
  }
}

