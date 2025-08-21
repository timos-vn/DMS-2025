import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class CreateDNCRequest {
  String? deptId;
  CreateDNCData? data;
  CreateDNCRequest({this.data,this.deptId});

  CreateDNCRequest.fromJson(Map<String, dynamic> json) {
    deptId = json['deptId'];
    data = json['data'] != null ? new CreateDNCData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['deptId'] = deptId;
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    return data;
  }
}

class CreateDNCData {
  String? customerCode;
  String? dienGiai;
  String? loaiTt;
  String? maGd;
  String? orderDate;
  String? codeCustomer;
  List<ListAttachFile>? attachFile;
  List<ListDNCDataDetail>? detail;

  CreateDNCData(
      {this.customerCode,
        this.dienGiai,
        this.loaiTt,
        this.maGd,
        this.orderDate,this.attachFile,this.codeCustomer,
        this.detail});

  CreateDNCData.fromJson(Map<String, dynamic> json) {
    customerCode = json['customerCode'];
    dienGiai = json['dien_giai'];
    loaiTt = json['loai_tt'];
    maGd = json['ma_gd'];
    orderDate = json['orderDate'];codeCustomer = json['codeCustomer'];
    if (json['atachFiles'] != null) {
      attachFile = <ListAttachFile>[];
      json['atachFiles'].forEach((v) {
        attachFile!.add(new ListAttachFile.fromJson(v));
      });
    }
    if (json['detail'] != null) {
      detail = <ListDNCDataDetail>[];
      json['detail'].forEach((v) {
        detail!.add(new ListDNCDataDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['customerCode'] = customerCode;
    data['dien_giai'] = dienGiai;
    data['loai_tt'] = loaiTt;
    data['ma_gd'] = maGd;
    data['orderDate'] = orderDate;data['codeCustomer'] = codeCustomer;
    if (attachFile != null) {
      data['atachFiles'] = attachFile!.map((v) => v.toJson()).toList();
    }
    if (detail != null) {
      data['detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListAttachFile {
  String? fileName;
  String? fileExt;
  String? fileSize;
  var fileData;

  ListAttachFile({this.fileName, this.fileExt,this.fileSize,this.fileData});

  ListAttachFile.fromJson(Map<String, dynamic> json) {
    fileName = json['file_name'];
    fileExt = json['file_ext'];
    fileSize = json['file_size'];
    fileData = json['file_data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['file_name'] = fileName;
    data['file_ext'] = fileExt;
    data['file_size'] = fileSize;
    data['file_data'] = fileData;
    return data;
  }
}

class ListDNCDataDetail {
  double? tienNt;
  String? dienGiai;

  ListDNCDataDetail({this.tienNt, this.dienGiai});

  ListDNCDataDetail.fromJson(Map<String, dynamic> json) {
    tienNt = json['tien_nt'];
    dienGiai = json['dien_giai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tien_nt'] = tienNt;
    data['dien_giai'] = dienGiai;
    return data;
  }
}

class ListDNCDataDetail2 {
  TextEditingController textEditingController ;
  double tienNt;
  String dienGiai;

  ListDNCDataDetail2({required this.textEditingController,required this.tienNt, required this.dienGiai});
}