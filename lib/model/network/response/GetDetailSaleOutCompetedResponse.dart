class GetDetailSaleOutCompletedResponse {
  List<GetDetailSaleOutCompletedResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetDetailSaleOutCompletedResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetDetailSaleOutCompletedResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetDetailSaleOutCompletedResponseData>[];
      json['data'].forEach((v) {
        data!.add( GetDetailSaleOutCompletedResponseData.fromJson(v));
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

class GetDetailSaleOutCompletedResponseData {
  String? sttRec;
  String? sttRec0;
  String? maVt;
  String? tenVt;
  double? soLuong;
  double? slTra;
  double? slCl;
  String? dvt;
  String? nameStore;
  String? codeStore;
  String? maLo;
  int? kmYn;
  double? giaNt2;
  double? tienNt2;
  String? maViTri;
  String? tkCPBH;
  String? maVV;
  String? maHD;
  bool isMark = false;
  double slSt = 0 ;
  String? sttRecDh;
  String? sttRec0Dh;
  String? hdSo;
  String? tkGV;
  String? tkVT;

  GetDetailSaleOutCompletedResponseData(
      {this.sttRec,
        this.sttRec0,
        this.maVt,
        this.tenVt,
        this.soLuong,
        this.slTra,
        this.slCl,
        this.dvt,
        this.codeStore,
        this.nameStore,
        this.maLo,
        this.kmYn,
        this.giaNt2,
        this.tienNt2,
        this.isMark = false, this.slSt = 0,
        this.maHD,this.maViTri,this.maVV,this.tkCPBH, this.hdSo, this.sttRecDh,this.sttRec0Dh,
        this.tkGV, this.tkVT
      });

  GetDetailSaleOutCompletedResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    soLuong = json['so_luong'];
    slTra = json['sl_tra'];
    slCl = json['sl_cl'];
    dvt = json['dvt'];
    nameStore = json['ten_kho'];
    codeStore = json['ma_kho'];
    maLo = json['ma_lo'];
    kmYn = json['km_yn'];
    giaNt2 = json['gia_nt2'];
    tienNt2 = json['tien_nt2'];

    maVV = json['ma_vv'];
    maHD = json['ma_hd'];
    maViTri = json['ma_vi_tri'];
    tkCPBH = json['tk_cpbh'];

    hdSo = json['hd_so'];
    sttRecDh = json['stt_rec_dh'];
    sttRec0Dh = json['stt_rec0dh'];
    tkGV = json['tk_gv'];
    tkVT = json['tk_vt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt_rec0'] = sttRec0;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['so_luong'] = soLuong;
    data['sl_tra'] = slTra;
    data['sl_cl'] = slCl;
    data['dvt'] = dvt;
    data['ten_kho'] = nameStore;
    data['ma_kho'] = codeStore;
    data['ma_lo'] = maLo;
    data['km_yn'] = kmYn;
    data['gia_nt2'] = giaNt2;
    data['tien_nt2'] = tienNt2;

    data['ma_vv'] = maVV;
    data['ma_hd'] = maHD;
    data['ma_vi_tri'] = maViTri;
    data['tk_cpbh'] = tkCPBH;

    data['hd_so'] = hdSo;
    data['stt_rec_dh'] = sttRecDh;
    data['stt_rec0dh'] = sttRec0Dh;
    data['tk_gv'] = tkGV;
    data['tk_vt'] = tkVT;
    return data;
  }
}

