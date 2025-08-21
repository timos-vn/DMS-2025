class CreateManufacturingRequest {
  CreateManufacturingRequestData? data;

  CreateManufacturingRequest({this.data});

  CreateManufacturingRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? CreateManufacturingRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateManufacturingRequestData {
  String? sttRec;
  String? maDvcs;
  String? maGd;
  String? ngayCt;
  String? ghiChu;
  int? tSoLuong;
  String? maNc;
  String? maPx;
  String? maLsx;
  String? maCd;
  String? maCa;
  String? slNc;
  String? gioBd;
  String? gioKt;
  List<CreateManufacturingRequestDetail>? detail;
  List<RawTable>? rawTable;
  List<WasteTable>? wasteTable;
  List<MachineTable>? machineTable;

  CreateManufacturingRequestData(
      {this.sttRec,
        this.maDvcs,
        this.maGd,
        this.ngayCt,
        this.ghiChu,
        this.tSoLuong,
        this.maNc,
        this.maPx,
        this.maLsx,
        this.maCd,
        this.maCa,
        this.slNc,
        this.gioBd,
        this.gioKt,
        this.detail,
        this.rawTable,
        this.wasteTable,
        this.machineTable});

  CreateManufacturingRequestData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    maGd = json['ma_gd'];
    ngayCt = json['ngay_ct'];
    ghiChu = json['ghi_chu'];
    tSoLuong = json['t_so_luong'];
    maNc = json['ma_nc'];
    maPx = json['ma_px'];
    maLsx = json['ma_lsx'];
    maCd = json['ma_cd'];
    maCa = json['ma_ca'];
    slNc = json['sl_nc'];
    gioBd = json['gio_bd'];
    gioKt = json['gio_kt'];
    if (json['Detail'] != null) {
      detail = <CreateManufacturingRequestDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(CreateManufacturingRequestDetail.fromJson(v));
      });
    }
    if (json['RawTable'] != null) {
      rawTable = <RawTable>[];
      json['RawTable'].forEach((v) {
        rawTable!.add(RawTable.fromJson(v));
      });
    }
    if (json['WasteTable'] != null) {
      wasteTable = <WasteTable>[];
      json['WasteTable'].forEach((v) {
        wasteTable!.add(WasteTable.fromJson(v));
      });
    }
    if (json['MachineTable'] != null) {
      machineTable = <MachineTable>[];
      json['MachineTable'].forEach((v) {
        machineTable!.add(MachineTable.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ma_dvcs'] = maDvcs;
    data['ma_gd'] = maGd;
    data['ngay_ct'] = ngayCt;
    data['ghi_chu'] = ghiChu;
    data['t_so_luong'] = tSoLuong;
    data['ma_nc'] = maNc;
    data['ma_px'] = maPx;
    data['ma_lsx'] = maLsx;
    data['ma_cd'] = maCd;
    data['ma_ca'] = maCa;
    data['sl_nc'] = slNc;
    data['gio_bd'] = gioBd;
    data['gio_kt'] = gioKt;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    if (rawTable != null) {
      data['RawTable'] = rawTable!.map((v) => v.toJson()).toList();
    }
    if (wasteTable != null) {
      data['WasteTable'] = wasteTable!.map((v) => v.toJson()).toList();
    }
    if (machineTable != null) {
      data['MachineTable'] = machineTable!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateManufacturingRequestDetail {
  String? maVt;
  String? dvt;
  double? soLuong;
  String? maNc;
  String? nhNc;
  String? ghiChu;
  String? maLo;

  CreateManufacturingRequestDetail(
      {this.maVt,
        this.dvt,
        this.soLuong,
        this.maNc,
        this.nhNc,
        this.ghiChu,
        this.maLo});

  CreateManufacturingRequestDetail.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    dvt = json['dvt'];
    soLuong = json['so_luong'];
    maNc = json['ma_nc'];
    nhNc = json['nh_nc'];
    ghiChu = json['ghi_chu'];
    maLo = json['ma_lo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['dvt'] = dvt;
    data['so_luong'] = soLuong;
    data['ma_nc'] = maNc;
    data['nh_nc'] = nhNc;
    data['ghi_chu'] = ghiChu;
    data['ma_lo'] = maLo;
    return data;
  }
}

class RawTable {
  String? maVt;
  String? dvt;
  double? soLuong;
  int? rework;
  String? maLo;
  double? slTn;
  double? slCl;
  double? slSd;

  RawTable(
      {this.maVt,
        this.dvt,
        this.soLuong,
        this.rework,
        this.maLo,
        this.slTn,
        this.slCl,
        this.slSd});

  RawTable.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    dvt = json['dvt'];
    soLuong = json['so_luong'];
    rework = json['rework'];
    maLo = json['ma_lo'];
    slTn = json['sl_tn'];
    slCl = json['sl_cl'];
    slSd = json['sl_sd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['dvt'] = dvt;
    data['so_luong'] = soLuong;
    data['rework'] = rework;
    data['ma_lo'] = maLo;
    data['sl_tn'] = slTn;
    data['sl_cl'] = slCl;
    data['sl_sd'] = slSd;
    return data;
  }
}

class WasteTable {
  String? maVt;
  String? dvt;
  String? codeStore;
  double? soLuong;

  WasteTable({this.maVt, this.dvt, this.soLuong, this.codeStore});

  WasteTable.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    dvt = json['dvt'];
    codeStore = json['code_store'];
    soLuong = json['so_luong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['dvt'] = dvt;
    data['code_store'] = codeStore;
    data['so_luong'] = soLuong;
    return data;
  }
}

class MachineTable {
  String? maMay;
  String? tenMay;
  String? gioBd;
  String? gioKt;
  double? soGio = 0;
  String? ghiChu;

  MachineTable({this.maMay,this.tenMay, this.gioBd, this.gioKt, this.soGio, this.ghiChu});

  MachineTable.fromJson(Map<String, dynamic> json) {
    maMay = json['ma_may'];
    gioBd = json['gio_bd'];
    gioKt = json['gio_kt'];
    soGio = json['so_gio'];
    ghiChu = json['ghi_chu'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_may'] = maMay;
    data['gio_bd'] = gioBd;
    data['gio_kt'] = gioKt;
    data['so_gio'] = soGio;
    data['ghi_chu'] = ghiChu;
    return data;
  }
}