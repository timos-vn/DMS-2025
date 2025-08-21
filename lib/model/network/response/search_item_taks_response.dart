import 'package:flutter/foundation.dart';

class SearchItemTaskResponse {
  List<SearchItemTaskResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  SearchItemTaskResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  SearchItemTaskResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SearchItemTaskResponseData>[];
      json['data'].forEach((v) {
        data!.add( SearchItemTaskResponseData.fromJson(v));
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
    data['statusCode'] =statusCode;
    data['message'] = message;
    return data;
  }
}

class SearchItemTaskResponseData {
  int? id;
  String? tieuDe;
  String? ngayCheckin;
  String? maKh;
  String? tenCh;
  String? diaChi;
  String? dienThoai;
  String? gps;
  String? trangThai;
  String? tgHoanThanh;
  String? album;
  String? lastCheckOut;
  String? latLong;
  String? numberTimeCheckOut;

  SearchItemTaskResponseData(
      {this.id,
        this.tieuDe,
        this.ngayCheckin,
        this.maKh,
        this.tenCh,
        this.diaChi,
        this.dienThoai,
        this.gps,
        this.trangThai,
        this.tgHoanThanh,
        this.album,
        this.lastCheckOut, this.latLong,this.numberTimeCheckOut});

  SearchItemTaskResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tieuDe = json['tieu_de'];
    ngayCheckin = json['ngay_checkin'];
    maKh = json['ma_kh'];
    tenCh = json['ten_ch'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    gps = json['gps'];
    trangThai = json['trang_thai'];
    tgHoanThanh = json['tg_hoan_thanh'];
    album = json['album'];
    lastCheckOut = json['last_chko'];
    latLong = json['latlong'];
    numberTimeCheckOut = json['time_checkout'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['tieu_de'] = tieuDe;
    data['ngay_checkin'] = ngayCheckin;
    data['ma_kh'] = maKh;
    data['ten_ch'] = tenCh;
    data['dia_chi'] = diaChi;
    data['dien_thoai'] = dienThoai;
    data['gps'] = gps;
    data['trang_thai'] = trangThai;
    data['tg_hoan_thanh'] = tgHoanThanh;
    data['album'] = album;
    data['last_chko'] = lastCheckOut;
    data['latlong'] = latLong;
    data['time_checkout'] = numberTimeCheckOut;
    return data;
  }
}

