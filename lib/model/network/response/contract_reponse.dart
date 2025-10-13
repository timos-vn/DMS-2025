import 'package:flutter/material.dart';

class GetListContractResponse {
  List<ContractItem>? data;
  dynamic totalPage;
  dynamic statusCode;
  String? message;

  GetListContractResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListContractResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ContractItem>[];
      json['data'].forEach((v) {
        data!.add(ContractItem.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ContractItem {
  String? sttRec;
  String? maDvcs;
  String? maGd;
  String? maKh;
  String? tenKh;
  String? dienThoai;
  String? diaChi;
  String? maCt;
  String? ngayCt;
  String? ngayHl;
  String? ngayHhl;
  String? soCt;
  String? dienGiai;
  String? soHd0;
  String? soHd;
  String? maNvbh;
  String? tenNvbh;
  dynamic tSoLuong;
  dynamic tTt;
  dynamic status;
  String? statusname;
  String? soHopDong;
  String? hantt;

  ContractItem(
      {this.sttRec,
        this.maDvcs,
        this.maGd,
        this.maKh,
        this.tenKh,
        this.dienThoai,
        this.diaChi,
        this.maCt,
        this.ngayCt,
        this.ngayHl,
        this.ngayHhl,
        this.soCt,
        this.dienGiai,
        this.soHd0,
        this.soHd,
        this.maNvbh,
        this.tenNvbh,
        this.tSoLuong,
        this.tTt,
        this.status,
        this.statusname,
        this.soHopDong,this.hantt});

  ContractItem.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    maGd = json['ma_gd'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    dienThoai = json['dien_thoai'];
    diaChi = json['dia_chi'];
    maCt = json['ma_ct'];
    ngayCt = json['ngay_ct'];
    ngayHl = json['ngay_hl'];
    ngayHhl = json['ngay_hhl'];
    soCt = json['so_ct'];
    dienGiai = json['dien_giai'];
    soHd0 = json['so_hd0'];
    soHd = json['so_hd'];
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
    tSoLuong = json['t_so_luong'];
    tTt = json['t_tt'];
    status = json['status'];
    statusname = json['statusname'];
    soHopDong = json['so_hop_dong'];
    hantt = json['hantt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ma_dvcs'] = maDvcs;
    data['ma_gd'] = maGd;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['dien_thoai'] = dienThoai;
    data['dia_chi'] = diaChi;
    data['ma_ct'] = maCt;
    data['ngay_ct'] = ngayCt;
    data['ngay_hl'] = ngayHl;
    data['ngay_hhl'] = ngayHhl;
    data['so_ct'] = soCt;
    data['dien_giai'] = dienGiai;
    data['so_hd0'] = soHd0;
    data['so_hd'] = soHd;
    data['ma_nvbh'] = maNvbh;
    data['ten_nvbh'] = tenNvbh;
    data['t_so_luong'] = tSoLuong;
    data['t_tt'] = tTt;
    data['status'] = status;
    data['statusname'] = statusname;
    data['so_hop_dong'] = soHopDong;
    data['hantt'] = hantt;
    return data;
  }
}

class GetDetailContractResponse {
  Data? data;
  dynamic totalPage;
  dynamic statusCode;
  String? message;

  GetDetailContractResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetDetailContractResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class Data {
  List<ListKD>? listKD;
  List<ListItem>? listItem;
  Payment? payment;

  Data({this.listItem, this.payment});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['listKD'] != null) {
      listKD = <ListKD>[];
      json['listKD'].forEach((v) {
        listKD!.add(ListKD.fromJson(v));
      });
    }
    if (json['listItem'] != null) {
      listItem = <ListItem>[];
      json['listItem'].forEach((v) {
        listItem!.add(ListItem.fromJson(v));
      });
    }
    payment =
    json['payment'] != null ? Payment.fromJson(json['payment']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listKD != null) {
      data['listKD'] = listKD!.map((v) => v.toJson()).toList();
    }
    if (listItem != null) {
      data['listItem'] = listItem!.map((v) => v.toJson()).toList();
    }
    if (payment != null) {
      data['payment'] = payment!.toJson();
    }
    return data;
  }
}

class ListKD {
  String? maVt2;
  double? totalOrder;
  double? totalAllowsOrder;
  bool? isCheck;

  ListKD({
    this.maVt2,
    this.totalOrder,
    this.totalAllowsOrder,
    this.isCheck = false,
  });

  factory ListKD.fromJson(Map<String, dynamic> json) {
    return ListKD(
      maVt2: json['ma_vt2'],
      totalOrder: json['tong_sl_dh'],
      totalAllowsOrder: json['so_luong_gioi_han_dat_hang'],
      isCheck: json['isCheck'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_vt2': maVt2,
      'tong_sl_dh': totalOrder,
      'so_luong_gioi_han_dat_hang': totalAllowsOrder,
      'isCheck': isCheck,
    };
  }
}

class ListItem {
  String? maVt;
  String? maVt2;
  String? tenVt;
  String? dvt;
  String? tenDvt;
  String? maKho;
  String? tenKho;
  double soLuongTonKho;
  double soLuong;
  double giaBanNt;
  double giaNt2;
  double tienNt2;
  double tlCk;
  double ckNt;
  String? maThue;
  String? tenThue;
  double thueSuat;
  double thueNt;
  String? ngayGiao;
  double giaBan;
  double gia2;
  double tien2;
  double ck;
  double thue;
  double slXuat;
  double slDh;
  bool? nhieuDvt;
  dynamic heSo;
  String? sttRec;
  String? sttRec0;
  dynamic lineNbr;
  String? sttRecHd;
  String? sttRec0hd;
  bool? isCheck;
  double so_luong_kd; // Số lượng cho phép đặt hàng

  ListItem({
    this.maVt,
    this.maVt2,
    this.tenVt,
    this.dvt,
    this.tenDvt,
    this.maKho,
    this.tenKho,this.soLuongTonKho = 0,
    this.soLuong = 0,
    this.giaBanNt = 0,
    this.giaNt2 = 0,
    this.tienNt2 = 0,
    this.tlCk = 0,
    this.ckNt = 0,
    this.maThue,
    this.tenThue,
    this.thueSuat = 0,
    this.thueNt = 0,
    this.ngayGiao,
    this.giaBan = 0,
    this.gia2 = 0,
    this.tien2 = 0,
    this.ck = 0,
    this.thue = 0,
    this.slXuat = 0,
    this.slDh = 0,
    this.nhieuDvt,
    this.heSo,
    this.sttRec,
    this.sttRec0,
    this.lineNbr,
    this.sttRecHd,
    this.sttRec0hd,
    this.isCheck = false,
    this.so_luong_kd = 0,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      maVt: json['ma_vt'],
      maVt2: json['ma_vt2'],
      tenVt: json['ten_vt'],
      dvt: json['dvt'],
      tenDvt: json['ten_dvt'],
      maKho: json['ma_kho'],
      tenKho: json['ten_kho'],
      soLuong: (json['so_luong'] as num?)?.toDouble() ?? 0,
      soLuongTonKho: (json['so_luong_ton_kho'] as num?)?.toDouble() ?? 0,
      giaBanNt: (json['gia_ban_nt'] as num?)?.toDouble() ?? 0,
      giaNt2: (json['gia_nt2'] as num?)?.toDouble() ?? 0,
      tienNt2: (json['tien_nt2'] as num?)?.toDouble() ?? 0,
      tlCk: (json['tl_ck'] as num?)?.toDouble() ?? 0,
      ckNt: (json['ck_nt'] as num?)?.toDouble() ?? 0,
      maThue: json['ma_thue'],
      tenThue: json['ten_thue'],
      thueSuat: (json['thue_suat'] as num?)?.toDouble() ?? 0,
      thueNt: (json['thue_nt'] as num?)?.toDouble() ?? 0,
      ngayGiao: json['ngay_giao'],
      giaBan: (json['gia_ban'] as num?)?.toDouble() ?? 0,
      gia2: (json['gia2'] as num?)?.toDouble() ?? 0,
      tien2: (json['tien2'] as num?)?.toDouble() ?? 0,
      ck: (json['ck'] as num?)?.toDouble() ?? 0,
      thue: (json['thue'] as num?)?.toDouble() ?? 0,
      slXuat: (json['sl_xuat'] as num?)?.toDouble() ?? 0,
      slDh: (json['sl_dh'] as num?)?.toDouble() ?? 0,
      nhieuDvt: json['nhieu_dvt'],
      heSo: json['he_so'],
      sttRec: json['stt_rec'],
      sttRec0: json['stt_rec0'],
      lineNbr: json['line_nbr'],
      sttRecHd: json['stt_rec_hd'],
      sttRec0hd: json['stt_rec0hd'],
      so_luong_kd: (json['so_luong_kd'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ma_vt': maVt,
      'ma_vt2': maVt2,
      'ten_vt': tenVt,
      'dvt': dvt,
      'ten_dvt': tenDvt,
      'ma_kho': maKho,
      'ten_kho': tenKho,
      'so_luong_ton_kho': soLuongTonKho,
      'so_luong': soLuong,
      'gia_ban_nt': giaBanNt,
      'gia_nt2': giaNt2,
      'tien_nt2': tienNt2,
      'tl_ck': tlCk,
      'ck_nt': ckNt,
      'ma_thue': maThue,
      'ten_thue': tenThue,
      'thue_suat': thueSuat,
      'thue_nt': thueNt,
      'ngay_giao': ngayGiao,
      'gia_ban': giaBan,
      'gia2': gia2,
      'tien2': tien2,
      'ck': ck,
      'thue': thue,
      'sl_xuat': slXuat,
      'sl_dh': slDh,
      'nhieu_dvt': nhieuDvt,
      'he_so': heSo,
      'stt_rec': sttRec,
      'stt_rec0': sttRec0,
      'line_nbr': lineNbr,
      'stt_rec_hd': sttRecHd,
      'stt_rec0hd': sttRec0hd,
      'so_luong_kd': so_luong_kd,
    };
  }
}

class Payment {
  dynamic tongSoLuong;
  dynamic tongTien;
  dynamic tongCk;
  dynamic tongThue;
  dynamic tongThanhToan;
  dynamic soLuongKhaDung;

  Payment(
      {this.tongSoLuong,
        this.tongTien,
        this.tongCk,
        this.tongThue,
        this.tongThanhToan, this.soLuongKhaDung});

  Payment.fromJson(Map<String, dynamic> json) {
    tongSoLuong = json['tong_so_luong'];
    tongTien = json['tong_tien'];
    tongCk = json['tong_ck'];
    tongThue = json['tong_thue'];
    tongThanhToan = json['tong_thanh_toan'];
    soLuongKhaDung = json['so_luong_kha_dung'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tong_so_luong'] = tongSoLuong;
    data['tong_tien'] = tongTien;
    data['tong_ck'] = tongCk;
    data['tong_thue'] = tongThue;
    data['tong_thanh_toan'] = tongThanhToan;
    data['so_luong_kha_dung'] = soLuongKhaDung;
    return data;
  }
}

class ListItemOrderFormContractResponse {
  List<ItemOrderFormContract>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListItemOrderFormContractResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListItemOrderFormContractResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ItemOrderFormContract>[];
      json['data'].forEach((v) {
        data!.add(ItemOrderFormContract.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ItemOrderFormContract {
  String? soCt;
  String? sttRecHd;
  String? sttRecDh;
  dynamic statusCode;
  String? statusName;

  ItemOrderFormContract({
    this.soCt,
    this.sttRecHd,
    this.sttRecDh,
    this.statusCode,
    this.statusName,
  });

  ItemOrderFormContract.fromJson(Map<String, dynamic> json) {
    soCt = json['so_ct'];
    sttRecHd = json['stt_rec_hd'];
    sttRecDh = json['stt_rec_dh'];
    statusCode = json['status_code'];
    statusName = json['status_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['so_ct'] = soCt;
    data['stt_rec_hd'] = sttRecHd;
    data['stt_rec_dh'] = sttRecDh;
    data['status_code'] = statusCode;
    data['status_name'] = statusName;
    return data;
  }

  String get hiddenSttRec {
    final s = sttRecDh ?? '';
    return s.length > 3 ? '${s.substring(0, s.length - 3)}***' : '***';
  }

  Color get statusColor {
    switch ((statusName ?? '').toLowerCase()) {
      case 'đã xác nhận':
        return Colors.green;
      case 'Lập chứng từ':
        return Colors.orange;
      case 'đã huỷ':
      case 'hủy':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  IconData get statusIcon {
    switch ((statusName ?? '').toLowerCase()) {
      case 'đã xác nhận':
        return Icons.check_circle;
      case 'chờ duyệt':
        return Icons.hourglass_top;
      case 'đã huỷ':
      case 'hủy':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }
}


