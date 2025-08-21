class CartResponse {
  Data? data;
  int? statusCode;
  String? message;

  CartResponse({this.data, this.statusCode, this.message});

  CartResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class Data {
  Order? order;
  List<LineItem>? lineItem;
  List<GiftItem>? giftItem;

  Data({this.order, this.lineItem, this.giftItem});

  Data.fromJson(Map<String, dynamic> json) {
    order = json['order'] != null ? new Order.fromJson(json['order']) : null;
    if (json['line_item'] != null) {
      lineItem = <LineItem>[];
      json['line_item'].forEach((v) {
        lineItem!.add(new LineItem.fromJson(v));
      });
    }
    if (json['gift_item'] != null) {
      giftItem = <GiftItem>[];
      json['gift_item'].forEach((v) {
        giftItem!.add(new GiftItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.order != null) {
      data['order'] = this.order?.toJson();
    }
    if (this.lineItem != null) {
      data['line_item'] = this.lineItem!.map((v) => v.toJson()).toList();
    }
    if (this.giftItem != null) {
      data['gift_item'] = this.giftItem!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Order {
  double? ck;
  double? tTien;
  double? tTt;
  double? tCk;
  List<DsCk>? dsCk;


  Order({this.ck, this.tTien, this.tTt, this.tCk, this.dsCk});

  Order.fromJson(Map<String, dynamic> json) {
    ck = json['ck'];
    tTien = json['t_tien'];
    tTt = json['t_tt'];
    tCk = json['t_ck'];
    if (json['ds_ck'] != null) {
      dsCk = <DsCk>[];
      json['ds_ck'].forEach((v) {
        dsCk?.add(new DsCk.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ck'] = this.ck;
    data['t_tien'] = this.tTien;
    data['t_tt'] = this.tTt;
    data['t_ck'] = this.tCk;
    if (this.dsCk != null) {
      data['ds_ck'] = this.dsCk?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class DsCk {
  String? maCk;
  String? tenCk;
  String? tenNS;
  double? residualValue;
  String? unit;

  DsCk({this.maCk, this.tenCk,this.tenNS,this.residualValue,this.unit});

  DsCk.fromJson(Map<String, dynamic> json) {
    maCk = json['ma_ck'];
    tenCk = json['ten_ck'];
    tenNS = json['ten_ns'];
    residualValue = json['gt_cl'];
    unit = json['loai_ct'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_ck'] = this.maCk;
    data['ten_ck'] = this.tenCk;
    data['ten_ns'] = this.tenNS;
    data['gt_cl'] = this.residualValue;
    data['loai_ct'] = this.unit;
    return data;
  }
}

class LineItem {
  String? sttRecCk;
  String? maCk;
  String? tenCk;
  String? maVt;
  double? tlCk;
  double? gia2;
  double? ck;
  double? ckNt;
  int? lineNbr;
  String? discountProduct;
  String? discountProductCode;
  List<GiftItem>? giftItem;
  String? nganSach;
  String? nganSachSp;
  double? residualValue;
  String? unit;
  String? unitProduct;
  double? nganSachProduct;

  LineItem(
      {this.sttRecCk,
        this.maCk,
        this.tenCk,
        this.maVt,
        this.tlCk,
        this.gia2,
        this.ck,
        this.ckNt,
        this.lineNbr,this.discountProductCode,
        this.giftItem,this.discountProduct,this.nganSach,
        this.residualValue,this.unit,this.nganSachProduct,
        this.nganSachSp,this.unitProduct
      });

  LineItem.fromJson(Map<String, dynamic> json) {
    sttRecCk = json['stt_rec_ck'];
    maCk = json['ma_ck'];
    tenCk = json['ten_ck'];
    maVt = json['ma_vt'];
    tlCk = json['tl_ck'];
    gia2 = json['gia2'];
    ck = json['ck'];
    ckNt = json['ck_nt'];
    lineNbr = json['line_nbr'];
    discountProduct = json['discountProduct'];
    if (json['gift_item'] != null) {
      giftItem = <GiftItem>[];
      json['gift_item'].forEach((v) {
        giftItem?.add(new GiftItem.fromJson(v));
      });
    }
    nganSach = json['ten_ns'];residualValue = json['gt_cl'];unit = json['loai_ct'];
    discountProductCode = json['discountProductCode'];
    nganSachProduct = json['gt_cl_product'];
    nganSachSp = json['ten_ns_product'];
    unitProduct = json['loai_ct_product'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec_ck'] = this.sttRecCk;
    data['ma_ck'] = this.maCk;
    data['ten_ck'] = this.tenCk;
    data['ma_vt'] = this.maVt;
    data['tl_ck'] = this.tlCk;
    data['gia2'] = this.gia2;
    data['ck'] = this.ck;
    data['ck_nt'] = this.ckNt;
    data['line_nbr'] = this.lineNbr;data['discountProduct'] = this.discountProduct;
    if (this.giftItem != null) {
      data['gift_item'] = this.giftItem?.map((v) => v.toJson()).toList();
    }
    data['ten_ns'] = this.nganSach;data['gt_cl'] = this.residualValue;
    data['loai_ct'] = this.unit;
    data['discountProductCode'] = this.discountProductCode;
    data['gt_cl_product'] = this.nganSachProduct;

    data['ten_ns_product'] = this.nganSachSp;
    data['loai_ct_product'] = this.unitProduct;
    return data;
  }
}

class GiftItem {
  String? sttRecCk;
  String? maCk;
  String? maVt;
  String? tenVt;
  String? dvt;
  double? soLuong;
  String? kmYn;
  String? maKho;
  String? maViTri;
  String? maLo;
  int? heSo;
  double? giaTon;
  String? viTriYn;
  String? loYn;
  double? giaBanNt;
  double? giaNt2;
  double? ton13;

  GiftItem(
      {this.sttRecCk,
        this.maCk,
        this.maVt,
        this.tenVt,
        this.dvt,
        this.soLuong,
        this.kmYn,
        this.maKho,
        this.maViTri,
        this.maLo,
        this.heSo,
        this.giaTon,
        this.viTriYn,
        this.loYn,
        this.giaBanNt,
        this.giaNt2,
        this.ton13});

  GiftItem.fromJson(Map<String, dynamic> json) {
    sttRecCk = json['stt_rec_ck'];
    maCk = json['ma_ck'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    soLuong = json['so_luong'];
    kmYn = json['km_yn'];
    maKho = json['ma_kho'];
    maViTri = json['ma_vi_tri'];
    maLo = json['ma_lo'];
    heSo = json['he_so'];
    giaTon = json['gia_ton'];
    viTriYn = json['vi_tri_yn'];
    loYn = json['lo_yn'];
    giaBanNt = json['gia_ban_nt'];
    giaNt2 = json['gia_nt2'];
    ton13 = json['ton13'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec_ck'] = this.sttRecCk;
    data['ma_ck'] = this.maCk;
    data['ma_vt'] = this.maVt;
    data['ten_vt'] = this.tenVt;
    data['dvt'] = this.dvt;
    data['so_luong'] = this.soLuong;
    data['km_yn'] = this.kmYn;
    data['ma_kho'] = this.maKho;
    data['ma_vi_tri'] = this.maViTri;
    data['ma_lo'] = this.maLo;
    data['he_so'] = this.heSo;
    data['gia_ton'] = this.giaTon;
    data['vi_tri_yn'] = this.viTriYn;
    data['lo_yn'] = this.loYn;
    data['gia_ban_nt'] = this.giaBanNt;
    data['gia_nt2'] = this.giaNt2;
    data['ton13'] = this.ton13;
    return data;
  }
}

