import 'dart:typed_data';

class GetHTMLApprovalResponse {
  String? data;
  List<ListValuesFile>? listValuesFile;
  int? statusCode;
  String? message;

  GetHTMLApprovalResponse(
      {this.data, this.listValuesFile, this.statusCode, this.message});

  GetHTMLApprovalResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    if (json['listValuesFile'] != null) {
      listValuesFile = <ListValuesFile>[];
      json['listValuesFile'].forEach((v) {
        listValuesFile!.add(new ListValuesFile.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data'] = this.data;
    if (this.listValuesFile != null) {
      data['listValuesFile'] =
          this.listValuesFile!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListValuesFile {
  String? fileName;
  String? fileData;
  String? fileExt;

  ListValuesFile({this.fileName, this.fileData,this.fileExt});

  ListValuesFile.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileData = json['valuesFile'];
    fileExt = json['fileExtension'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['valuesFile'] = this.fileData;
    data['fileExtension'] = this.fileExt;
    return data;
  }
}

class ListValuesFilesView {
  String? fileName;
  Uint8List? fileData;
  String? fileExt;

  ListValuesFilesView({this.fileName, this.fileData,this.fileExt});

  ListValuesFilesView.fromJson(Map<String, dynamic> json) {
    fileName = json['fileName'];
    fileData = json['valuesFile'];
    fileExt = json['fileExtension'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fileName'] = this.fileName;
    data['valuesFile'] = this.fileData;
    data['fileExtension'] = this.fileExt;
    return data;
  }
}