class ApprovalResponse {
  List<ApprovalResponseData>? data;
  int? statusCode;
  String? message;

  ApprovalResponse({this.data, this.statusCode, this.message});

  ApprovalResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ApprovalResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ApprovalResponseData.fromJson(v));
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

class ApprovalResponseData {
  String? loaiDuyet;
  String? tenLoai;
  int? pendingApproval;

  ApprovalResponseData({this.loaiDuyet, this.tenLoai, this.pendingApproval});

  ApprovalResponseData.fromJson(Map<String, dynamic> json) {
    loaiDuyet = json['loai_duyet'];
    tenLoai = json['ten_loai'];
    pendingApproval = json['pendingApproval'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['loai_duyet'] = this.loaiDuyet;
    data['ten_loai'] = this.tenLoai;
    data['pendingApproval'] = this.pendingApproval;
    return data;
  }
}