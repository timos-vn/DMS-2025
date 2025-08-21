class ManagerCustomerResponse {
  String? message;
  int? statusCode;
  List<ManagerCustomerResponseData>? data;
  int? pageIndex;

  ManagerCustomerResponse({ this.message,  this.statusCode, this.data,this.pageIndex});

  ManagerCustomerResponse.fromJson(Map<String, dynamic> json) {

    message = json['message'];

    statusCode = json['statusCode'];
    pageIndex = json['pageIndex'];

    if (json['data'] != null) {
      data = <ManagerCustomerResponseData>[];
      for (var v in (json['data'] as List)) { data?.add( ManagerCustomerResponseData.fromJson(v)); }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};

    data['message'] = message;
    data['pageIndex'] = pageIndex;
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] =  this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }

}

class ManagerCustomerResponseData {
  String? customerCode;
  String? customerName;
  String? customerName2;
  String? birthday;
  String? phone;
  String? address;
  String? email;
  String? imageUrl;
  String? typeDiscount;

  ManagerCustomerResponseData({this.customerCode,this.customerName,this.customerName2,this.birthday,this.phone,this.address,this.email,this.imageUrl,this.typeDiscount});

  ManagerCustomerResponseData.fromJson(Map<String, dynamic> json) {
    customerCode = json['customerCode'];
    customerName = json['customerName'];
    customerName2 = json['customerName2'];
    birthday = json['birthday'];
    phone = json['phone'];
    address = json['address'];
    email = json['email'];
    imageUrl = json['imageUrl'];
    typeDiscount = json['kieu_kh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['customerCode'] = customerCode;
    data['customerName'] = customerName;
    data['customerName2'] = customerName2;
    data['birthday'] = birthday;
    data['phone'] = phone;
    data['address'] = address;
    data['email'] = email;
    data['imageUrl'] = imageUrl;
    data['kieu_kh'] = typeDiscount;
    return data;
  }
}
