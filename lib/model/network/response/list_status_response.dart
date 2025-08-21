class ListStatusApprovalResponse {
  List<ListStatusApprovalResponseData>? data;
  int? statusCode;
  String? message;

  ListStatusApprovalResponse({this.data, this.statusCode, this.message});

  ListStatusApprovalResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListStatusApprovalResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListStatusApprovalResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class ListStatusApprovalResponseData {
  String? uStatus;
  String? uStatusName;

  ListStatusApprovalResponseData({this.uStatus, this.uStatusName});

  ListStatusApprovalResponseData.fromJson(Map<String, dynamic> json) {
    uStatus = json['u_status'];
    uStatusName = json['u_status_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['u_status'] = this.uStatus;
    data['u_status_name'] = this.uStatusName;
    return data;
  }
}

