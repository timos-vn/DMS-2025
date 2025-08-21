class GetInformationItemFromBarResponse {
  InformationProduction? informationProduction;
  int? statusCode;
  String? message;

  GetInformationItemFromBarResponse(
      {this.informationProduction, this.statusCode, this.message});

  GetInformationItemFromBarResponse.fromJson(Map<String, dynamic> json) {
    informationProduction = json['informationProduction'] != null
        ? InformationProduction.fromJson(json['informationProduction'])
        : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (informationProduction != null) {
      data['informationProduction'] = informationProduction!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class InformationProduction {
  String? maIn;
  String? maVt;
  String? tenVt;
  double? soLuong;
  String? hsd;

  InformationProduction({this.maIn, this.maVt, this.tenVt,this.soLuong, this.hsd});

  InformationProduction.fromJson(Map<String, dynamic> json) {
    maIn = json['ma_in'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    soLuong = json['so_luong'];
    hsd = json['hsd'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_in'] = maIn;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;data['so_luong'] = soLuong;
    data['hsd'] = hsd;
    return data;
  }
}

