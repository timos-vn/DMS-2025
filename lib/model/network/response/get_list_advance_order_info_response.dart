import 'dart:convert';

import 'package:dms/model/network/response/report_field_lookup_response.dart';
import 'package:flutter/cupertino.dart';

class GetListAdvanceOrderInfo {
  List<ListInfor>? listInfo;
  dynamic listValues;
  int? statusCode;
  String? message;

  GetListAdvanceOrderInfo(
      {this.listInfo, this.listValues, this.statusCode, this.message});

  GetListAdvanceOrderInfo.fromJson(Map<String, dynamic> json) {
    if (json['listInfor'] != null) {
      listInfo = <ListInfor>[];
      json['listInfor'].forEach((v) {
        listInfo!.add(ListInfor.fromJson(v));
      });
    }
    // if (json['listValues'] != null) {
    //   listValues = <ListValues>[];
    //   json['listValues'].forEach((v) {
    //     listValues!.add(ListValues.fromJson(v));
    //   });
    // }
    listValues = json['listValues'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listInfo != null) {
      data['listInfor'] = listInfo!.map((v) => v.toJson()).toList();
    }
    // if (listValues != null) {
    //   data['listValues'] = listValues!.map((v) => v.toJson()).toList();
    // }
    data['listValues'] = listValues;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListInfor {
  String? title;
  String? colName;
  String? type;
  String? format;
  List<DropDownList>? options;
  bool? nullable;
  String? controller;  String? defaultValue;
  TextEditingController textEditingController = TextEditingController();
  ReportFieldLookupResponseData? selectValue;
  bool c = false;
  String? listItemPush;
  List<ReportFieldLookupResponseData>? listItem;

  ListInfor(
      {this.title,
        this.colName,
        this.type,
        this.format,
        this.options,
        this.nullable,this.defaultValue,
        this.controller,required this.textEditingController,});

  ListInfor.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    colName = json['colName'];
    type = json['type'];
    format = json['format'];
    defaultValue = json['defaultValue'];
    // ignore: unnecessary_null_comparison
    if ((json['options']) !=null) {
      options = (jsonDecode(json['options']) as List).map((i) => DropDownList.fromJson(i)).toList();
    } else {
      options = null;
    }
    nullable = json['nullable'];
    controller = json['controller'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['colName'] = colName;
    data['type'] = type;
    data['format'] = format;data['defaultValue'] = defaultValue;
    // if (options != null) {
    //   data['options'] = options?.map((i) => i.toJson()).toList();
    // } else {
    //   data['options'] = null;
    // }
    data['nullable'] = nullable;
    data['controller'] = controller;
    return data;
  }
}

class ListValues {
  String? dinhLuong;
  String? maMau;

  ListValues({this.dinhLuong, this.maMau});

  ListValues.fromJson(Map<String, dynamic> json) {
    dinhLuong = json['dinh_luong'];
    maMau = json['ma_mau'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dinh_luong'] = dinhLuong;
    data['ma_mau'] = maMau;
    return data;
  }
}

class DropDownList {
  String? title;
  String? value;


  DropDownList({title, value});

  DropDownList.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['title'] = title;
    data['value'] = value;
    return data;
  }
}
