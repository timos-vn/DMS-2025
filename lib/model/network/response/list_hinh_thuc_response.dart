class ListStoreFormResponse {
  List<ListStoreFormResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListStoreFormResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListStoreFormResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListStoreFormResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListStoreFormResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListStoreFormResponseData {
  String? maHinhThuc;
  String? tenHinhThuc;
  String? tenHinhThuc2;

  ListStoreFormResponseData({this.maHinhThuc, this.tenHinhThuc, this.tenHinhThuc2});

  ListStoreFormResponseData.fromJson(Map<String, dynamic> json) {
    maHinhThuc = json['ma_hinh_thuc'];
    tenHinhThuc = json['ten_hinh_thuc'];
    tenHinhThuc2 = json['ten_hinh_thuc2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_hinh_thuc'] = this.maHinhThuc;
    data['ten_hinh_thuc'] = this.tenHinhThuc;
    data['ten_hinh_thuc2'] = this.tenHinhThuc2;
    return data;
  }
}

