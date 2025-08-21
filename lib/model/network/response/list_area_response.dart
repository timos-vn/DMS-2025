class ListAreaResponse {
  List<ListAreaResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListAreaResponse({this.data, this.totalPage, this.statusCode, this.message});

  ListAreaResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListAreaResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListAreaResponseData.fromJson(v));
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

class ListAreaResponseData {
  String? maKhuVuc;
  String? tenKhuVuc;

  ListAreaResponseData({this.maKhuVuc, this.tenKhuVuc});

  ListAreaResponseData.fromJson(Map<String, dynamic> json) {
    maKhuVuc = json['ma_khu_vuc'];
    tenKhuVuc = json['ten_khu_vuc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_khu_vuc'] = this.maKhuVuc;
    data['ten_khu_vuc'] = this.tenKhuVuc;
    return data;
  }
}

