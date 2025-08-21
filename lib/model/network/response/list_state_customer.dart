class ListStateCustomer {
  List<ListStateCustomerData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListStateCustomer({this.data, this.totalPage, this.statusCode, this.message});

  ListStateCustomer.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListStateCustomerData>[];
      json['data'].forEach((v) {
        data!.add(new ListStateCustomerData.fromJson(v));
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

class ListStateCustomerData {
  String? maTinhTrang;
  String? tenTinhTrang;

  ListStateCustomerData({this.maTinhTrang, this.tenTinhTrang});

  ListStateCustomerData.fromJson(Map<String, dynamic> json) {
    maTinhTrang = json['ma_tinh_trang'];
    tenTinhTrang = json['ten_tinh_trang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_tinh_trang'] = this.maTinhTrang;
    data['ten_tinh_trang'] = this.tenTinhTrang;
    return data;
  }
}

