class ListItemScanResponse {
  DataScan? data;
  int? statusCode;
  String? message;

  ListItemScanResponse({this.data, this.statusCode, this.message});

  ListItemScanResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new DataScan.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DataScan {
  String? code;
  String? name;
  String? name2;
  String? dvt;
  String? descript;
  double? price;
  double? discountPercent;
  double? taxPercent;
  double? priceAfter;
  double? stockAmount;
  String? imageUrl;

  DataScan(
      {this.code,
        this.name,
        this.name2,
        this.dvt,
        this.descript,
        this.price,
        this.discountPercent,
        this.taxPercent,
        this.priceAfter,
        this.stockAmount,
        this.imageUrl});

  DataScan.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
    name2 = json['name2'];
    dvt = json['dvt'];
    descript = json['descript'];
    price = json['price'];
    discountPercent = json['discountPercent'];
    taxPercent = json['taxPercent'];
    priceAfter = json['priceAfter'];
    stockAmount = json['stockAmount'];
    imageUrl = json['imageUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['name'] = this.name;
    data['name2'] = this.name2;
    data['dvt'] = this.dvt;
    data['descript'] = this.descript;
    data['price'] = this.price;
    data['discountPercent'] = this.discountPercent;
    data['taxPercent'] = this.taxPercent;
    data['priceAfter'] = this.priceAfter;
    data['stockAmount'] = this.stockAmount;
    data['imageUrl'] = this.imageUrl;
    return data;
  }
}