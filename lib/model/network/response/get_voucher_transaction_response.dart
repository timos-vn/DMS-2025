class VoucherTransactionResponse {
  List<VoucherTransactionResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  VoucherTransactionResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  VoucherTransactionResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <VoucherTransactionResponseData>[];
      json['data'].forEach((v) {
        data!.add(VoucherTransactionResponseData.fromJson(v));
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

class VoucherTransactionResponseData {
  String? maGd;
  String? tenGd;
  String? tenGd2;

  VoucherTransactionResponseData({this.maGd, this.tenGd, this.tenGd2});

  VoucherTransactionResponseData.fromJson(Map<String, dynamic> json) {
    maGd = json['ma_gd'];
    tenGd = json['ten_gd'];
    tenGd2 = json['ten_gd2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_gd'] = maGd;
    data['ten_gd'] = tenGd;
    data['ten_gd2'] = tenGd2;
    return data;
  }
}