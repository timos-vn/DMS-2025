class DetailCustomerResponse {
  DetailCustomerResponseData? data;
  int? statusCode;
  String? message;

  DetailCustomerResponse({this.data, this.statusCode, this.message});

  DetailCustomerResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? DetailCustomerResponseData.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class DetailCustomerResponseData {
  String? customerCode;
  String? customerName;
  String? customerName2;
  String? birthday;
  String? phone;
  String? address;
  String? gender;
  String? email;
  String? imageUrl;
  String? lastPurchaseDate;
  List<OtherData>? otherData;

  DetailCustomerResponseData(
      {this.customerCode,
        this.customerName,
        this.customerName2,
        this.birthday,
        this.phone,
        this.address,
        this.gender,
        this.email,
        this.imageUrl,
        this.lastPurchaseDate,
        this.otherData});

  DetailCustomerResponseData.fromJson(Map<String, dynamic> json) {
    customerCode = json['customerCode'];
    customerName = json['customerName'];
    customerName2 = json['customerName2'];
    birthday = json['birthday'];
    phone = json['phone'];
    address = json['address'];
    gender = json['gender'];
    email = json['email'];lastPurchaseDate = json['lastPurchaseDate'];
    imageUrl = json['imageUrl'];
    if (json['otherData'] != null) {
      otherData = <OtherData>[];
      json['otherData'].forEach((v) {
        otherData?.add( OtherData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['customerCode'] = customerCode;
    data['customerName'] = customerName;
    data['customerName2'] = customerName2;
    data['birthday'] = birthday;
    data['phone'] = phone;
    data['address'] = address;
    data['gender'] = gender;
    data['email'] = email;
    data['imageUrl'] = imageUrl;
    data['lastPurchaseDate'] = lastPurchaseDate;
    if (otherData != null) {
      data['otherData'] = otherData?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class OtherData {
  String? name;
  String? text;
  double? value;
  String? iconUrl;
  String? formatString;

  OtherData({this.name, this.text, this.value, this.iconUrl});

  OtherData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    text = json['text'];
    value = json['value'];
    iconUrl = json['iconUrl'];
    formatString = json['formatString'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['text'] = text;
    data['value'] = value;
    data['iconUrl'] = iconUrl;
    data['formatString'] = formatString;
    return data;
  }
}