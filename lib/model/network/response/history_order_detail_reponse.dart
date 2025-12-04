import 'dart:ui';

class HistoryOrderDetailResponse {
  HistoryOrderDetailResponseData? data;
  int? statusCode;
  String? message;

  HistoryOrderDetailResponse({this.data, this.statusCode, this.message});

  HistoryOrderDetailResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ?  HistoryOrderDetailResponseData.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class HistoryOrderDetailResponseData {
  Master? master;
  List<LineItems>? lineItems;
  InfoPayment? infoPayment;

  HistoryOrderDetailResponseData({this.master, this.lineItems, this.infoPayment});

  HistoryOrderDetailResponseData.fromJson(Map<String, dynamic> json) {
    master =
    json['master'] != null ?  Master.fromJson(json['master']) : null;
    if (json['line_items'] != null) {
      lineItems = <LineItems>[];
      json['line_items'].forEach((v) {
        lineItems!.add( LineItems.fromJson(v));
      });
    }
    infoPayment = json['infoPayment'] != null
        ?  InfoPayment.fromJson(json['infoPayment'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (master != null) {
      data['master'] = master!.toJson();
    }
    if (lineItems != null) {
      data['line_items'] = lineItems!.map((v) => v.toJson()).toList();
    }
    if (infoPayment != null) {
      data['infoPayment'] = infoPayment!.toJson();
    }
    return data;
  }
}

class Master {
  String? sttRec;
  String? soCt;
  String? ngayCt;
  String? maKh;
  String? tenKh;
  int? status;
  String? maKho;
  Ck? ck;
  String? hTTT;
  String? hanTT;
  String? maGD;
  String? tenGD;
  String? tenDL;
  String? maDL;
  String? typeDiscount;
  String? description;
  int? isHD;

  Master(
      {this.sttRec,
        this.soCt,
        this.ngayCt,
        this.maKh,
        this.tenKh,
        this.status,
        this.maKho,
        this.ck,
        this.hTTT,
        this.hanTT,
        this.maGD,
        this.tenGD,
        this.tenDL,this.maDL,this.typeDiscount,this.description,this.isHD
      });

  Master.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soCt = json['so_ct'];
    ngayCt = json['ngay_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    status = json['status'];
    maKho = json['ma_kho'];
    ck = json['ck'] != null ?  Ck.fromJson(json['ck']) : null;
    hTTT = json['httt'];
    hanTT = json['han_tt'];
    maGD = json['ma_gd'];
    tenGD = json['ten_gd'];
    tenDL = json['ten_daily'];
    maDL = json['ma_daily'];
    typeDiscount = json['kieu_kh'];
    description = json['dien_giai'];
    isHD = json['isHD'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['so_ct'] = soCt;
    data['ngay_ct'] = ngayCt;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['status'] = status;
    data['ma_kho'] = maKho;
    if (ck != null) {
      data['ck'] = ck!.toJson();
    }
    data['httt'] = hTTT;
    data['han_tt'] = hanTT;
    data['ma_gd'] = maGD;
    data['ten_gd'] = tenGD;
    data['ten_daily'] = tenDL;
    data['ma_daily'] = maDL;
    data['kieu_kh'] = typeDiscount;
    data['dien_giai'] = description;
    data['isHD'] = isHD;
    return data;
  }
}

class Ck {
  String? maCk;
  String? tenCk;
  String? tenNs;
  double? gtCl;
  String? loaiCt;

  Ck({this.maCk, this.tenCk, this.tenNs, this.gtCl, this.loaiCt});

  Ck.fromJson(Map<String, dynamic> json) {
    maCk = json['ma_ck'];
    tenCk = json['ten_ck'];
    tenNs = json['ten_ns'];
    gtCl = json['gt_cl'];
    loaiCt = json['loai_ct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_ck'] = maCk;
    data['ten_ck'] = tenCk;
    data['ten_ns'] = tenNs;
    data['gt_cl'] = gtCl;
    data['loai_ct'] = loaiCt;
    return data;
  }
}

class LineItems {
  String? maVt;
  String? tenVt;
  int? kmYn;
  double? soLuong;
  double? soLuongKD;
  double? soLuongDapUng;
  double? price = 0;
  double? ckNt;
  String? maCk;
  String? tenCk;
  double? tlCk;
  double? tienNt;
  String? name2;
  String? dvt;
  double? discountPercent;
  String? imageUrl;
  double? priceAfter = 0;
  double? stockAmount;
  Color? kColorFormatAlphaB;
  String? codeStore;
  String? nameStore;
  String? maVV;
  String? tenVV;
  String? tenHD;
  String? maHD;
  String? maThue;
  String? maKho;
  String? tenKho;
  double? giaMin = 0;
  double? giaNet = 0;


  LineItems(
      {this.maVt,
        this.tenVt,
        this.kmYn,
        this.soLuong,
        this.soLuongKD = 0,
        this.soLuongDapUng,
        this.price = 0,
        this.ckNt,
        this.maCk,
        this.tenCk,
        this.tlCk,
        this.tienNt,
        this.name2,
        this.dvt,
        this.discountPercent,
        this.imageUrl,
        this.priceAfter = 0,
        this.stockAmount,
        this.kColorFormatAlphaB, this.codeStore,this.nameStore, this.tenHD, this.tenVV, this.maVV, this.maHD, this.maThue,
        this.maKho,this.tenKho, this.giaMin, this.giaNet
        });

  LineItems.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    kmYn = json['km_yn'];
    soLuong = json['so_luong'] != null ? double.tryParse(json['so_luong'].toString()) : null;
    soLuongKD = json['sl_khadung'] != null ? double.tryParse(json['sl_khadung'].toString()) : null;
    soLuongDapUng = json['sl_dap_ung'] != null ? double.tryParse(json['sl_dap_ung'].toString()) : null;
    price = json['gia'];
    ckNt = json['ck_nt'];
    maCk = json['ma_ck'];
    tenCk = json['ten_ck'];
    tlCk = json['tl_ck'];
    tienNt = json['tien_nt'];
    name2 = json['name2'];
    dvt = json['dvt'];
    discountPercent = json['discountPercent'];
    imageUrl = json['imageUrl'];
    priceAfter = json['priceAfter'];
    stockAmount = json['stockAmount'];
    codeStore = json['ma_kho'];
    nameStore = json['ten_kho'];
    maVV = json['ma_vv'];
    maHD = json['ma_hd'];
    tenVV = json['ten_vv'];
    tenHD = json['ten_hd'];
    maThue = json['ma_thue'];
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
    giaMin = json['gia_min'];
    giaNet = json['gia_net'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['km_yn'] = kmYn;
    data['so_luong'] = soLuong;
    data['sl_khadung'] = soLuongKD;
    data['sl_dap_ung'] = soLuongDapUng;
    data['gia'] = price;
    data['ck_nt'] = ckNt;
    data['ma_ck'] = maCk;
    data['ten_ck'] = tenCk;
    data['tl_ck'] = tlCk;
    data['tien_nt'] = tienNt;
    data['name2'] = name2;
    data['dvt'] = dvt;
    data['discountPercent'] = discountPercent;
    data['imageUrl'] = imageUrl;
    data['priceAfter'] = priceAfter;
    data['stockAmount'] = stockAmount;
    data['ma_kho'] = codeStore;
    data['ten_kho'] = nameStore;
    data['ma_vv'] = maVV;
    data['ma_hd'] = maHD;
    data['ten_vv'] = tenVV;
    data['ten_hd'] = tenHD;
    data['ma_thue'] = maThue;
    data['ma_kho'] = maKho;
    data['ten_kho'] = tenKho;
    data['gia_min'] = giaMin;
    data['gia_net'] = giaNet;
    return data;
  }
}

class InfoPayment {
  double? tTien = 0;
  double? tCkTtNt = 0;
  double? tTtNt = 0;
  double? tThueNt = 0;

  InfoPayment({this.tTien = 0, this.tCkTtNt = 0, this.tTtNt = 0, this.tThueNt = 0});

  InfoPayment.fromJson(Map<String, dynamic> json) {
    tTien = json['t_tien'];
    tCkTtNt = json['t_ck_tt_nt'];
    tTtNt = json['t_tt_nt'];
    tThueNt = json['t_thue_nt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['t_tien'] = tTien;
    data['t_ck_tt_nt'] = tCkTtNt;
    data['t_tt_nt'] = tTtNt;
    data['t_thue_nt'] = tThueNt;
    return data;
  }
}

