class ListEmployeeResponse {
  List<TotalOrder>? totalOrder;
  List<ListEmployee>? listEmployee;
  int? totalPage;
  int? statusCode;
  String? message;

  ListEmployeeResponse(
      {this.totalOrder,
        this.listEmployee,
        this.totalPage,
        this.statusCode,
        this.message});

  ListEmployeeResponse.fromJson(Map<String, dynamic> json) {
    if (json['totalOrder'] != null) {
      totalOrder = <TotalOrder>[];
      json['totalOrder'].forEach((v) {
        totalOrder!.add(new TotalOrder.fromJson(v));
      });
    }
    if (json['listEmployee'] != null) {
      listEmployee = <ListEmployee>[];
      json['listEmployee'].forEach((v) {
        listEmployee!.add(new ListEmployee.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.totalOrder != null) {
      data['totalOrder'] = this.totalOrder!.map((v) => v.toJson()).toList();
    }
    if (this.listEmployee != null) {
      data['listEmployee'] = this.listEmployee!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class TotalOrder {
  int? slDon;
  int? slDonNv;

  TotalOrder({this.slDon, this.slDonNv});

  TotalOrder.fromJson(Map<String, dynamic> json) {
    slDon = json['sl_don'];
    slDonNv = json['sl_don_nv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sl_don'] = this.slDon;
    data['sl_don_nv'] = this.slDonNv;
    return data;
  }
}

class ListEmployee {
  String? maNvbh;
  String? tenNvbh;
  int? capQl;
  String? tenCapql;
  int? userId;
  String? maNvql;
  String? tenNvql;
  int? soLuong;

  ListEmployee(
      {this.maNvbh,
        this.tenNvbh,
        this.capQl,
        this.tenCapql,
        this.userId,
        this.maNvql,
        this.tenNvql,
        this.soLuong});

  ListEmployee.fromJson(Map<String, dynamic> json) {
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
    capQl = json['cap_ql'];
    tenCapql = json['ten_capql'];
    userId = json['user_id'];
    maNvql = json['ma_nvql'];
    tenNvql = json['ten_nvql'];
    soLuong = json['sl_don'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ma_nvbh'] = this.maNvbh;
    data['ten_nvbh'] = this.tenNvbh;
    data['cap_ql'] = this.capQl;
    data['ten_capql'] = this.tenCapql;
    data['user_id'] = this.userId;
    data['ma_nvql'] = this.maNvql;
    data['ten_nvql'] = this.tenNvql;
    data['sl_don'] = this.soLuong;
    return data;
  }
}

