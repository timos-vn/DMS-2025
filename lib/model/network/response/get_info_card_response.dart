class GetKeyBySttRecResponse {
  String? sttRec;
  String? valueKey;
  String? title;
  int? statusCode;
  String? message;

  GetKeyBySttRecResponse(
      {this.sttRec,
        this.valueKey,
        this.title,
        this.statusCode,
        this.message});

  GetKeyBySttRecResponse.fromJson(Map<String, dynamic> json) {

    sttRec = json['sttRec'];
    valueKey = json['valueKey'];
    title = json['title'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['sttRec'] = sttRec;
    data['valueKey'] = valueKey;
    data['title'] = title;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class GetInfoCardResponse {
  List<MasterInfoCard>? masterInfoCard;
  List<ListItem>? listItem;
  RuleActionInfoCard? ruleActionInfoCard;
  FormatProvider? formatProvider;
  int? statusCode;
  String? message;

  GetInfoCardResponse(
      {this.masterInfoCard,
        this.listItem,
        this.ruleActionInfoCard,
        this.formatProvider,
        this.statusCode,
        this.message});

  GetInfoCardResponse.fromJson(Map<String, dynamic> json) {
    if (json['master'] != null) {
      masterInfoCard = <MasterInfoCard>[];
      json['master'].forEach((v) {
        masterInfoCard!.add(MasterInfoCard.fromJson(v));
      });
    }
    if (json['listItem'] != null) {
      listItem = <ListItem>[];
      json['listItem'].forEach((v) {
        listItem!.add(ListItem.fromJson(v));
      });
    }
    ruleActionInfoCard = json['ruleActionInfoCard'] != null
        ? RuleActionInfoCard.fromJson(json['ruleActionInfoCard'])
        : null;
    formatProvider = json['formatProvider'] != null
        ? FormatProvider.fromJson(json['formatProvider'])
        : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (masterInfoCard != null) {
      data['master'] = masterInfoCard!.map((v) => v.toJson()).toList();
    }
    if (listItem != null) {
      data['listItem'] = listItem!.map((v) => v.toJson()).toList();
    }
    if (ruleActionInfoCard != null) {
      data['ruleActionInfoCard'] = ruleActionInfoCard!.toJson();
    }
    if (formatProvider != null) {
      data['formatProvider'] = formatProvider!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class MasterInfoCard {
  String? sttRec;
  String? maKh;  String? tenKh;
  String? maDvcs;
  String? maCt;
  String? ngayCt;
  String? soCt;
  String? maGd;
  String? maNcc;
  String? tenNcc;
  String? dienGiai;
  double? tSoLuong;
  double? tTien;
  double? tTT;
  double? tThue;
  double? tCK;
  String? status;
  String? statusname;
  int? maHtvc;
  String? tenHtvc;
  String? licensePlates;

  MasterInfoCard(
      {this.sttRec,this.maKh, this.tenKh,
        this.maDvcs,
        this.maCt,
        this.ngayCt,
        this.soCt,
        this.maGd,
        this.maNcc,
        this.tenNcc,
        this.dienGiai,
        this.tSoLuong,
        this.tTien,
        this.status,
        this.statusname,this.tTT,this.tCK,this.tThue,this.maHtvc, this.tenHtvc, this.licensePlates});

  MasterInfoCard.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];maKh = json['ma_kh'];tenKh = json['ten_kh'];
    maDvcs = json['ma_dvcs'];
    maCt = json['ma_ct'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    maGd = json['ma_gd'];
    maNcc = json['ma_ncc'];
    tenNcc = json['ten_ncc'];
    dienGiai = json['dien_giai'];
    tSoLuong = json['t_so_luong'];
    tTien = json['t_tien'];
    status = json['status'];
    statusname = json['statusname'];
    tTT = json['t_tt'];
    tCK = json['t_ck'];
    tThue = json['t_thue'];
    maHtvc = json['ma_htvc'];
    tenHtvc = json['ten_htvc'];
    licensePlates = json['license_plates'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;data['ma_kh'] = maKh;data['ten_kh'] = tenKh;
    data['ma_dvcs'] = maDvcs;
    data['ma_ct'] = maCt;
    data['ngay_ct'] = ngayCt;
    data['so_ct'] = soCt;
    data['ma_gd'] = maGd;
    data['ma_ncc'] = maNcc;
    data['ten_ncc'] = tenNcc;
    data['dien_giai'] = dienGiai;
    data['t_so_luong'] = tSoLuong;
    data['t_tien'] = tTien;
    data['status'] = status;
    data['statusname'] = statusname;
    data['t_tt'] = tTT;
    data['t_ck'] = tCK;
    data['t_thue'] = tThue;
    data['ma_htvc'] = maHtvc;
    data['ten_htvc'] = tenHtvc;
    data['license_plates'] = licensePlates;
    return data;
  }
}

class ListItem {
  String? sttRec;
  String? sttRec0;
  String? maVt;
  String? tenVt;
  String? dvt;
  String? tenDvt;
  String? maKho;
  String? tenKho;
  double? soLuong;
  double? soCan;
  double? qtyTotal;
  double? ck;
  double? tyLeCK;
  double? tyLeThue;
  double? tienThue;
  String? maViTri;
  String? maLo;
  String? tenLo; // Tên lô
  bool? qcYn;
  bool? serialYn;
  double? tien;
  int? cheBien;
  int? sanXuat;
  String? qrCode;
  String? expirationDate;
  String? productionDate;
  int? isMark = 0;
  int? kmYn = 0;
  String? pallet;
  double? actualQuantity; // Số lượng thực tế đã quét

  ListItem(
      {this.sttRec,
        this.sttRec0,
        this.maVt,
        this.tenVt,
        this.dvt,
        this.tenDvt,
        this.maKho,
        this.tenKho,
        this.soLuong,
        this.soCan,
        this.qtyTotal,
        this.serialYn,
        this.maViTri,
        this.maLo,
        this.tenLo,
        this.pallet,
        this.qcYn,
        this.tien,this.cheBien,this.sanXuat,this.ck,this.tienThue,this.tyLeCK,this.kmYn,
        this.tyLeThue,this.qrCode,this.expirationDate,this.productionDate,this.isMark = 0, this.actualQuantity});

  ListItem.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    tenDvt = json['ten_dvt'];
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
    soLuong = json['so_luong'];
    soCan = json['so_can'];
    qtyTotal = json['qty_total'];
    maViTri = json['ma_vi_tri'];
    maLo = json['ma_lo'];
    tenLo = json['ten_lo'];
    pallet = json['pallet'];
    qcYn = json['qc_yn'];
    serialYn = json['serial_yn'];
    tien = json['tien'];
    cheBien = json['cheBien'];
    sanXuat = json['sanXuat'];
    ck = json['ck'];
    tyLeCK = json['tl_ck'];
    tienThue = json['thue'];
    tyLeThue = json['thue_suat'];
    kmYn = json['km_yn'];
    qrCode = json['qr_code'];
    expirationDate = json['expiration_date'];
    productionDate = json['production_date'];
    actualQuantity = json['actual_quantity'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt_rec0'] = sttRec0;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['ten_dvt'] = tenDvt;
    data['ma_kho'] = maKho;
    data['ten_kho'] = tenKho;
    data['so_luong'] = soLuong;
    data['so_can'] = soCan;
    data['qty_total'] = qtyTotal;
    data['ma_vi_tri'] = maViTri;
    data['ma_lo'] = maLo;
    data['ten_lo'] = tenLo;
    data['pallet'] = pallet;
    data['qc_yn'] = qcYn;
    data['serial_yn'] = serialYn;
    data['tien'] = tien;
    data['cheBien'] = cheBien;
    data['sanXuat'] = sanXuat;
    data['ck'] = ck;
    data['tl_ck'] = tyLeCK;
    data['thue'] = tienThue;
    data['thue_suat'] = tyLeThue;
    data['km_yn'] = kmYn;
    data['qr_code'] = qrCode;
    data['expiration_date'] = expirationDate;
    data['production_date'] = productionDate;
    data['actual_quantity'] = actualQuantity;
    return data;
  }
}

class RuleActionInfoCard {
  int? status;
  String? statusname;
  String? statusname2;

  RuleActionInfoCard({this.status, this.statusname, this.statusname2});

  RuleActionInfoCard.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusname = json['statusname'];
    statusname2 = json['statusname2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusname'] = statusname;
    data['statusname2'] = statusname2;
    return data;
  }
}

class FormatProvider {
  int? canYn;
  int? canTu;
  int? canDen;
  String? donVi;
  String? soThapPhan;
  int? hsdYn;
  int? hsdTu;
  int? hsdDen;
  String? dateformat;

  FormatProvider(
      {this.canYn,
        this.canTu,
        this.canDen,
        this.donVi,
        this.soThapPhan,
        this.hsdYn,
        this.hsdTu,
        this.hsdDen,
        this.dateformat});

  FormatProvider.fromJson(Map<String, dynamic> json) {
    canYn = json['can_yn'];
    canTu = json['can_tu'];
    canDen = json['can_den'];
    donVi = json['don_vi'];
    soThapPhan = json['so_thap_phan'];
    hsdYn = json['hsd_yn'];
    hsdTu = json['hsd_tu'];
    hsdDen = json['hsd_den'];
    dateformat = json['dateformat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['can_yn'] = canYn;
    data['can_tu'] = canTu;
    data['can_den'] = canDen;
    data['don_vi'] = donVi;
    data['so_thap_phan'] = soThapPhan;
    data['hsd_yn'] = hsdYn;
    data['hsd_tu'] = hsdTu;
    data['hsd_den'] = hsdDen;
    data['dateformat'] = dateformat;
    return data;
  }
}


