class GetListTaxResponse {
  List<GetListTaxResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListTaxResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListTaxResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListTaxResponseData>[];
      json['data'].forEach((v) {
        data!.add( GetListTaxResponseData.fromJson(v));
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
    data['message'] = message;
    return data;
  }
}

class GetListTaxResponseData {
  String? maThue;
  String? tenThue;
  double? thueSuat;

  GetListTaxResponseData({this.maThue, this.tenThue, this.thueSuat});

  GetListTaxResponseData.fromJson(Map<String, dynamic> json) {
    maThue = json['ma_thue'];
    tenThue = json['ten_thue'];
    thueSuat = json['thue_suat'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_thue'] = maThue;
    data['ten_thue'] = tenThue;
    data['thue_suat'] = thueSuat;
    return data;
  }
}

