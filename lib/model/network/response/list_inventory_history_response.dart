import 'package:flutter/material.dart';

class GetListInventoryHistoryResponse {
  List<GetListInventoryHistoryResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListInventoryHistoryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListInventoryHistoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListInventoryHistoryResponseData>[];
      json['data'].forEach((v) {
        data!.add( GetListInventoryHistoryResponseData.fromJson(v));
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
    data['message'] =message;
    return data;
  }
}

class GetListInventoryHistoryResponseData {
  String? maVt;
  String? tenVt;
  double? slTon;
  String? dvt;
  Color? kColorFormatAlphaB;

  GetListInventoryHistoryResponseData({this.maVt, this.tenVt, this.slTon, this.dvt, this.kColorFormatAlphaB});

  GetListInventoryHistoryResponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    slTon = json['sl_ton'];
    dvt = json['dvt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['sl_ton'] = slTon;
    data['dvt'] = dvt;
    return data;
  }
}

