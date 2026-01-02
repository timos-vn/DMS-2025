class ApplyDiscountResponse {
  List<ListCkTongDon>? listCkTongDon;
  List<ListCk>? listCk;
  List<ListCkMatHang>? listCkMatHang;
  TotalMoneyDiscount? totalMoneyDiscount;
  int? statusCode;
  String? message;

  ApplyDiscountResponse(
      {this.listCkTongDon,
        this.listCk,
        this.listCkMatHang,
        this.totalMoneyDiscount,
        this.statusCode,
        this.message});

  ApplyDiscountResponse.fromJson(Map<String, dynamic> json) {
    if (json['list_ck_tong_don'] != null) {
      listCkTongDon = <ListCkTongDon>[];
      json['list_ck_tong_don'].forEach((v) {
        listCkTongDon!.add( ListCkTongDon.fromJson(v));
      });
    }
    if (json['list_ck'] != null) {
      listCk = <ListCk>[];
      json['list_ck'].forEach((v) {
        listCk!.add( ListCk.fromJson(v));
      });
    }
    if (json['list_ck_mat_hang'] != null) {
      listCkMatHang = <ListCkMatHang>[];
      json['list_ck_mat_hang'].forEach((v) {
        listCkMatHang!.add( ListCkMatHang.fromJson(v));
      });
    }
    totalMoneyDiscount = json['totalMoneyDiscount'] != null
        ?  TotalMoneyDiscount.fromJson(json['totalMoneyDiscount'])
        : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (listCkTongDon != null) {
      data['list_ck_tong_don'] =
          listCkTongDon!.map((v) => v.toJson()).toList();
    }
    if (listCk != null) {
      data['list_ck'] = listCk!.map((v) => v.toJson()).toList();
    }
    if (listCkMatHang != null) {
      data['list_ck_mat_hang'] =
          listCkMatHang!.map((v) => v.toJson()).toList();
    }
    if (totalMoneyDiscount != null) {
      data['totalMoneyDiscount'] = totalMoneyDiscount!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListCkTongDon {
  String? sttRecCk;
  String? maCk;
  String? loaiCk;
  double? tlCkTt;
  double? tCkTt;
  double? tCkTtNt;
  double? gtVip;
  double? gtVipNt;
  String? soVoucher;
  String? gtVocher;
  double? tDiemSo;
  String? showGift;
  String? note;
  String? createvip;
  String? maLoai;
  double? gtVip2;
  double? gtVipNt2;
  int? capCk;
  String? kieuCK;
  int? isMark = 0;
  dynamic ck_dac_biet;

  ListCkTongDon(
      {this.sttRecCk,
        this.maCk,
        this.loaiCk,
        this.tlCkTt,
        this.tCkTt,
        this.tCkTtNt,
        this.gtVip,
        this.gtVipNt,
        this.soVoucher,
        this.gtVocher,
        this.tDiemSo,
        this.showGift,
        this.note,
        this.createvip,
        this.maLoai,
        this.gtVip2,
        this.gtVipNt2,
        this.capCk,
        this.kieuCK,this.isMark,this.ck_dac_biet});

  ListCkTongDon.fromJson(Map<String, dynamic> json) {
    sttRecCk = json['stt_rec_ck'];
    maCk = json['ma_ck'];
    loaiCk = json['loai_ck'];
    tlCkTt = json['tl_ck_tt'];
    tCkTt = json['t_ck_tt'];
    tCkTtNt = json['t_ck_tt_nt'];
    gtVip = json['gt_vip'];
    gtVipNt = json['gt_vip_nt'];
    soVoucher = json['so_voucher'];
    gtVocher = json['gt_vocher'];
    tDiemSo = json['t_diem_so'];
    showGift = json['showGift'];
    note = json['note'];
    createvip = json['createvip'];
    maLoai = json['ma_loai'];
    gtVip2 = json['gt_vip2'];
    gtVipNt2 = json['gt_vip_nt2'];
    capCk = json['cap_ck'];
    kieuCK = json['kieu_ck'];
    ck_dac_biet = json['ck_dac_biet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec_ck'] = sttRecCk;
    data['ma_ck'] = maCk;
    data['loai_ck'] = loaiCk;
    data['tl_ck_tt'] = tlCkTt;
    data['t_ck_tt'] = tCkTt;
    data['t_ck_tt_nt'] = tCkTtNt;
    data['gt_vip'] = gtVip;
    data['gt_vip_nt'] = gtVipNt;
    data['so_voucher'] = soVoucher;
    data['gt_vocher'] = gtVocher;
    data['t_diem_so'] = tDiemSo;
    data['showGift'] = showGift;
    data['note'] = note;
    data['createvip'] = createvip;
    data['ma_loai'] = maLoai;
    data['gt_vip2'] = gtVip2;
    data['gt_vip_nt2'] = gtVipNt2;
    data['cap_ck'] = capCk;
    data['kieu_ck'] = kieuCK;
    data['ck_dac_biet'] = ck_dac_biet;
    return data;
  }
}

class ListCk {
  String? sttRecCk;
  String? maVt;
  String? tenVt;
  String? maCk;
  String? tenCk;
  String? moTa;
  double? tlCk;
  double? giaGoc;
  double? giaSauCk;
  double? ck;
  double? ckNt;
  String? dvt;
  double? soLuong;
  int? kmYn;
  String? maKho;
  String? maViTri;
  String? maLo;
  double? heSo;
  int? giaTon;
  int? viTriYn;
  int? loYn;
  double? giaBanNt;
  double? giaNt2;
  double? ton13;
  String? kieuCk;
  int? capCk;
  int? isMark = 0;
  dynamic ck_dac_biet;

  ListCk(
      {this.sttRecCk,
        this.maVt,
        this.maCk,
        this.tenCk,
        this.moTa,
        this.tlCk,
        this.giaGoc,
        this.giaSauCk,
        this.ck,
        this.ckNt,
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
        this.ton13,
        this.kieuCk,
        this.capCk,this.isMark,this.ck_dac_biet});

  ListCk.fromJson(Map<String, dynamic> json) {
    sttRecCk = json['stt_rec_ck'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    maCk = json['ma_ck'];
    tenCk = json['ten_ck'];
    moTa = json['mo_ta'];
    tlCk = json['tl_ck'];
    giaGoc = json['gia_goc'];
    giaSauCk = json['gia_sau_ck'];
    ck = json['ck'];
    ckNt = json['ck_nt'];
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
    kieuCk = json['kieu_ck'];
    capCk = json['cap_ck'];
    ck_dac_biet = json['ck_dac_biet'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['stt_rec_ck'] = sttRecCk;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['ma_ck'] = maCk;
    data['ten_ck'] = tenCk;
    data['mo_ta'] = moTa;
    data['tl_ck'] = tlCk;
    data['gia_goc'] = giaGoc;
    data['gia_sau_ck'] = giaSauCk;
    data['ck'] = ck;
    data['ck_nt'] = ckNt;
    data['dvt'] = dvt;
    data['so_luong'] = soLuong;
    data['km_yn'] = kmYn;
    data['ma_kho'] = maKho;
    data['ma_vi_tri'] = maViTri;
    data['ma_lo'] = maLo;
    data['he_so'] = heSo;
    data['gia_ton'] = giaTon;
    data['vi_tri_yn'] = viTriYn;
    data['lo_yn'] = loYn;
    data['gia_ban_nt'] = giaBanNt;
    data['gia_nt2'] = giaNt2;
    data['ton13'] = ton13;
    data['kieu_ck'] = kieuCk;
    data['cap_ck'] = capCk;
    data['ck_dac_biet'] = ck_dac_biet;
    return data;
  }
}

class ListCkMatHang {
  String? sttRecCk;
  String? maCk;
  String? maVt;
  String? tenVt;
  String? maHangTang;
  String? tenHangTang;
  String? dvt;
  double? soLuong;
  String? kieuCK;
  dynamic group_dk;
  dynamic ten_ck;

  ListCkMatHang(
      {this.sttRecCk,
        this.maCk,
        this.maVt,
        this.tenVt,
        this.maHangTang,
        this.tenHangTang,
        this.dvt,
        this.soLuong, this.kieuCK, this.group_dk,this.ten_ck});

  ListCkMatHang.fromJson(Map<String, dynamic> json) {
    sttRecCk = json['stt_rec_ck'];
    maCk = json['ma_ck'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    maHangTang = json['ma_hang_tang'];
    tenHangTang = json['ten_hang_tang'];
    dvt = json['dvt'];
    soLuong = json['so_luong'];
    kieuCK = json['kieu_ck'];
    group_dk = json['group_dk'];
    ten_ck = json['ten_ck'];
  }

    Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec_ck'] = sttRecCk;
    data['ma_ck'] = maCk;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['ma_hang_tang'] = maHangTang;
    data['ten_hang_tang'] = tenHangTang;
    data['dvt'] = dvt;
    data['so_luong'] = soLuong;
    data['kieu_ck'] = kieuCK;
    data['group_dk'] = group_dk;
    data['ten_ck'] = ten_ck;
    return data;
  }
}

class TotalMoneyDiscount {
  double? tTien;
  double? tCk;
  double? tThanhToan;

  TotalMoneyDiscount({this.tTien, this.tCk, this.tThanhToan});

  TotalMoneyDiscount.fromJson(Map<String, dynamic> json) {
    tTien = json['t_tien'];
    tCk = json['t_ck'];
    tThanhToan = json['t_thanh_toan'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['t_tien'] = tTien;
    data['t_ck'] = tCk;
    data['t_thanh_toan'] = tThanhToan;
    return data;
  }
}

