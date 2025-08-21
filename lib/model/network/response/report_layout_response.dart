import 'package:dms/model/network/response/report_field_lookup_response.dart';
import 'package:flutter/cupertino.dart';

class ReportLayoutResponse {
  String? message;
  int? statusCode;
  List<DataReportLayout>? reportLayoutData;

  ReportLayoutResponse({ this.message,  this.statusCode, this.reportLayoutData});

  ReportLayoutResponse.fromJson(Map<String, dynamic> json) {

    message = json['message'];

    statusCode = json['statusCode'];

    if (json['data'] != null) {
      reportLayoutData =  <DataReportLayout>[];for (var v in (json['data'] as List)) { reportLayoutData?.add(DataReportLayout.fromJson(v)); }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};

    data['message'] = message;

    data['statusCode'] = statusCode;
    if (reportLayoutData != null) {
      data['data'] =  reportLayoutData?.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class DataReportLayout {
  String? field;
  String? name;
  String? name2;
  int? type;
  String? controller;
  bool? isNull;
  String? defaultValue;
  List<DropDownList>? dropDownList;
  ReportFieldLookupResponseData? selectValue;
  List<ReportFieldLookupResponseData>? listItem;
  TextEditingController textEditingController = TextEditingController();
  String? listItemPush;
  bool c = false;

  DataReportLayout({required this.textEditingController,selectValue,field,name,name2,type,controller,isNull,defaultValue,dropDownList});

  DataReportLayout.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    name = json['name'];
    name2 = json['name2'];
    type = json['type'];
    controller = json['controller'];
    isNull = json['isNull'];
    defaultValue = json['defaultValue'];
    // ignore: unnecessary_null_comparison
    if ((json['dropDownList'] as List)!=null) {
      dropDownList = (json['dropDownList'] as List).map((i) => DropDownList.fromJson(i)).toList();
    } else {
      dropDownList = null;
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['field'] = field;
    data['name'] = name;
    data['name2'] = name2;
    data['type'] = type;
    data['isNull'] = isNull;
    data['defaultValue'] = defaultValue;
    data['controller'] = controller;
    if (dropDownList != null) {
      data['dropDownList'] = dropDownList?.map((i) => i.toJson()).toList();
    } else {
      data['dropDownList'] = null;
    }

    return data;
  }
}


class DropDownList {
  String? field;
  String? value;
  String? text;
  String? name2;
  double? desc;


  DropDownList({field, value, text, name2, desc,});

  DropDownList.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    value = json['value'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['field'] = field;
    data['value'] = value;
    data['text'] = text;
    return data;
  }
}
