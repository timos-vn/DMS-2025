class CreateTaskFromCustomerResponse {
  List<CreateTaskFromCustomerResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  CreateTaskFromCustomerResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  CreateTaskFromCustomerResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <CreateTaskFromCustomerResponseData>[];
      json['data'].forEach((v) {
        data!.add(CreateTaskFromCustomerResponseData.fromJson(v));
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

class CreateTaskFromCustomerResponseData {
  int? id;
  String? customerId;

  CreateTaskFromCustomerResponseData({this.id, this.customerId});

  CreateTaskFromCustomerResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    customerId = json['customerId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customerId'] = customerId;
    return data;
  }
}