class ListTypeStoreResponse {
  List<ListTypeStoreResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListTypeStoreResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListTypeStoreResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListTypeStoreResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListTypeStoreResponseData.fromJson(v));
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

class ListTypeStoreResponseData {
  String? maLoai;
  String? tenLoai;
  String? tenLoai2;

  ListTypeStoreResponseData({this.maLoai, this.tenLoai, this.tenLoai2});

  ListTypeStoreResponseData.fromJson(Map<String, dynamic> json) {
    maLoai = json['ma_loai'];
    tenLoai = json['ten_loai'];
    tenLoai2 = json['ten_loai2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_loai'] = this.maLoai;
    data['ten_loai'] = this.tenLoai;
    data['ten_loai2'] = this.tenLoai2;
    return data;
  }
}

