class ReportFieldLookupResponse {
  List<ReportFieldLookupResponseData>? data;
  int? statusCode;
  String? message;


  ReportFieldLookupResponse({this.data, this.statusCode, this.message});

  ReportFieldLookupResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ReportFieldLookupResponseData>[];(json['data'] as List).forEach((v) { data!.add(new ReportFieldLookupResponseData.fromJson(v)); });
    }
    statusCode = json['statusCode'];
    message = json['message'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (this.data != null) {
    //   data['data'] = this.data.toJson();
    // }
    if (this.data != null) {
      data['data'] =  this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ReportFieldLookupResponseData {
  String? code;
  String? name;String? gioBd;
  String? gioKt;
  bool isChecked = false;

  ReportFieldLookupResponseData({this.code,this.name,this.gioKt,this.gioBd});

  ReportFieldLookupResponseData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];    gioBd = json['gio_bd'];
    gioKt = json['gio_kt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['code'] = code;data['gio_kt'] = gioKt;
    data['gio_bd'] = gioBd;
    return data;
  }
}

class ReportResultResponseData {
  String? field;
  String? value;

  ReportResultResponseData({this.field,this.value,});

  ReportResultResponseData.fromJson(Map<String, dynamic> json) {
    field = json['field'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['field'] = field;
    data['value'] = value;
    return data;
  }
}
