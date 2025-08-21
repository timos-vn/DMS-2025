class ListStatusOrderResponse {
  List<ListStatusOrderResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListStatusOrderResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListStatusOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListStatusOrderResponseData>[];
      json['data'].forEach((v) {
        data!.add( ListStatusOrderResponseData.fromJson(v));
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

class ListStatusOrderResponseData {
  String? status;
  String? statusname;
  String? statusname2;

  ListStatusOrderResponseData({this.status, this.statusname, this.statusname2});

  ListStatusOrderResponseData.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusname = json['statusname'];
    statusname2 = json['statusname2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusname'] = statusname;
    data['statusname2'] = statusname2;
    return data;
  }
}

