class ListStoreResponse {
  List<ListStoreResponseData>? data;
  int? statusCode;
  String? message;

  ListStoreResponse({this.data, this.statusCode, this.message});

  ListStoreResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListStoreResponseData>[];
      json['data'].forEach((v) {
        data?.add(new ListStoreResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListStoreResponseData {
  String? maKho;
  String? tenKho;

  ListStoreResponseData({this.maKho, this.tenKho});

  ListStoreResponseData.fromJson(Map<String, dynamic> json) {
    maKho = json['ma_kho'];
    tenKho = json['ten_kho'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_kho'] = this.maKho;
    data['ten_kho'] = this.tenKho;
    return data;
  }
}