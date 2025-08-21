import 'package:flutter/material.dart';

class GetKPIHome {
  List<DoanhThuTheoNV>? doanhThuTheoNV;
  List<DoanhThuTheoSP>? doanhThuTheoSP;
  List<TopNVMoMoi>? topNVMoMoi;
  List<KhachHangMoiGanDay>? khachHangMoiGanDay;
  List<TyTrongDoanhThuTheoCuaHang>? tyTrongDoanhThuTheoCuaHang;
  List<DoanhThuThuan>? doanhThuThuan;
  List<LoiNhuanGop>? loiNhuanGop;
  int? statusCode;
  String? message;

  GetKPIHome(
      {this.doanhThuTheoNV,
        this.doanhThuTheoSP,
        this.topNVMoMoi,
        this.khachHangMoiGanDay,
        this.tyTrongDoanhThuTheoCuaHang,
        this.doanhThuThuan,
        this.loiNhuanGop,
        this.statusCode,
        this.message});

  GetKPIHome.fromJson(Map<String, dynamic> json) {
    if (json['doanhThuTheoNV'] != null) {
      doanhThuTheoNV = <DoanhThuTheoNV>[];
      json['doanhThuTheoNV'].forEach((v) {
        doanhThuTheoNV!.add(DoanhThuTheoNV.fromJson(v));
      });
    }
    if (json['doanhThuTheoSP'] != null) {
      doanhThuTheoSP = <DoanhThuTheoSP>[];
      json['doanhThuTheoSP'].forEach((v) {
        doanhThuTheoSP!.add(DoanhThuTheoSP.fromJson(v));
      });
    }
    if (json['topNVMoMoi'] != null) {
      topNVMoMoi = <TopNVMoMoi>[];
      json['topNVMoMoi'].forEach((v) {
        topNVMoMoi!.add(TopNVMoMoi.fromJson(v));
      });
    }
    if (json['khachHangMoiGanDay'] != null) {
      khachHangMoiGanDay = <KhachHangMoiGanDay>[];
      json['khachHangMoiGanDay'].forEach((v) {
        khachHangMoiGanDay!.add(KhachHangMoiGanDay.fromJson(v));
      });
    }
    if (json['tyTrongDoanhThuTheoCuaHang'] != null) {
      tyTrongDoanhThuTheoCuaHang = <TyTrongDoanhThuTheoCuaHang>[];
      json['tyTrongDoanhThuTheoCuaHang'].forEach((v) {
        tyTrongDoanhThuTheoCuaHang!
            .add(TyTrongDoanhThuTheoCuaHang.fromJson(v));
      });
    }
    if (json['doanhThuThuan'] != null) {
      doanhThuThuan = <DoanhThuThuan>[];
      json['doanhThuThuan'].forEach((v) {
        doanhThuThuan!.add(DoanhThuThuan.fromJson(v));
      });
    }
    if (json['loiNhuanGop'] != null) {
      loiNhuanGop = <LoiNhuanGop>[];
      json['loiNhuanGop'].forEach((v) {
        loiNhuanGop!.add(LoiNhuanGop.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (doanhThuTheoNV != null) {
      data['doanhThuTheoNV'] =
          doanhThuTheoNV!.map((v) => v.toJson()).toList();
    }
    if (doanhThuTheoSP != null) {
      data['doanhThuTheoSP'] =
          doanhThuTheoSP!.map((v) => v.toJson()).toList();
    }
    if (topNVMoMoi != null) {
      data['topNVMoMoi'] = topNVMoMoi!.map((v) => v.toJson()).toList();
    }
    if (khachHangMoiGanDay != null) {
      data['khachHangMoiGanDay'] =
          khachHangMoiGanDay!.map((v) => v.toJson()).toList();
    }
    if (tyTrongDoanhThuTheoCuaHang != null) {
      data['tyTrongDoanhThuTheoCuaHang'] =
          tyTrongDoanhThuTheoCuaHang!.map((v) => v.toJson()).toList();
    }
    if (doanhThuThuan != null) {
      data['doanhThuThuan'] =
          doanhThuThuan!.map((v) => v.toJson()).toList();
    }
    if (loiNhuanGop != null) {
      data['loiNhuanGop'] = loiNhuanGop!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class DoanhThuTheoNV {
  String? maNvbh;
  String? name;
  double? value;

  DoanhThuTheoNV({this.maNvbh, this.name, this.value});

  DoanhThuTheoNV.fromJson(Map<String, dynamic> json) {
    maNvbh = json['ma_nvbh'];
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_nvbh'] = maNvbh;
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class DoanhThuTheoSP {
  String? maVt;
  String? title;
  double? value;

  DoanhThuTheoSP({this.maVt, this.title, this.value});

  DoanhThuTheoSP.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}

class TopNVMoMoi {
  String? maNvbh;
  String? title;
  double? value;

  TopNVMoMoi({this.maNvbh, this.title, this.value});

  TopNVMoMoi.fromJson(Map<String, dynamic> json) {
    maNvbh = json['ma_nvbh'];
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_nvbh'] = maNvbh;
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}

class KhachHangMoiGanDay {
  String? maKh;
  String? title;
  String? value;

  KhachHangMoiGanDay({this.maKh, this.title, this.value});

  KhachHangMoiGanDay.fromJson(Map<String, dynamic> json) {
    maKh = json['ma_kh'];
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_kh'] = maKh;
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}

class TyTrongDoanhThuTheoCuaHang {
  String? maBp;
  String? tenBp;
  dynamic value;
  dynamic ratio;
  Color? color;

  TyTrongDoanhThuTheoCuaHang({this.maBp, this.tenBp, this.value, this.ratio, this.color});

  TyTrongDoanhThuTheoCuaHang.fromJson(Map<String, dynamic> json) {
    maBp = json['ma_bp'];
    tenBp = json['ten_bp'];
    value = json['value'];
    ratio = json['ratio'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_bp'] = maBp;
    data['ten_bp'] = tenBp;
    data['value'] = value;
    data['ratio'] = ratio;
    return data;
  }
}

class DoanhThuThuan {
  String? type;
  String? ngayTu;
  String? ngayDen;
  double? tien;
  double? changes;
  double? soDonHang;

  DoanhThuThuan(
      {this.type, this.ngayTu, this.ngayDen, this.tien, this.changes, this.soDonHang});

  DoanhThuThuan.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    ngayTu = json['ngay_tu'];
    ngayDen = json['ngay_den'];
    tien = json['tien'];
    changes = json['Changes'];
    soDonHang = json['so_dh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['ngay_tu'] = ngayTu;
    data['ngay_den'] = ngayDen;
    data['tien'] = tien;
    data['Changes'] = changes;
    data['so_dh'] = soDonHang;
    return data;
  }
}

class LoiNhuanGop {
  String? type;
  String? ngayTu;
  String? ngayDen;
  double? loiNhuan;
  dynamic changes;
  double? tySuatLn;
  double? doanhThu;
  double? tienVon;

  LoiNhuanGop(
      {this.type,
        this.ngayTu,
        this.ngayDen,
        this.loiNhuan,
        this.changes,
        this.doanhThu,
        this.tienVon,
        this.tySuatLn});

  LoiNhuanGop.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    ngayTu = json['ngay_tu'];
    ngayDen = json['ngay_den'];
    loiNhuan = json['loi_nhuan'];
    changes = json['Changes'];
    tySuatLn = json['ty_suat_ln'];
    doanhThu = json['doanh_thu'];
    tienVon = json['tien_von'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['ngay_tu'] = ngayTu;
    data['ngay_den'] = ngayDen;
    data['loi_nhuan'] = loiNhuan;
    data['Changes'] = changes;
    data['ty_suat_ln'] = tySuatLn;
    data['doanh_thu'] = doanhThu;
    data['tien_von'] = tienVon;
    return data;
  }
}