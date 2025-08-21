class ListKPISummaryResponse {
  List<ListKPISummaryResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListKPISummaryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListKPISummaryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListKPISummaryResponseData>[];
      json['data'].forEach((v) {
        data!.add(ListKPISummaryResponseData.fromJson(v));
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

class ListKPISummaryResponseData {
  String? idKpi;
  String? tenKpi;
  String? maNv;
  double? thucHien;

  ListKPISummaryResponseData({this.idKpi, this.tenKpi, this.maNv, this.thucHien});

  ListKPISummaryResponseData.fromJson(Map<String, dynamic> json) {
    idKpi = json['id_kpi'];
    tenKpi = json['ten_kpi'];
    maNv = json['ma_nv'];
    thucHien = json['thuc_hien'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id_kpi'] = this.idKpi;
    data['ten_kpi'] = this.tenKpi;
    data['ma_nv'] = this.maNv;
    data['thuc_hien'] = this.thucHien;
    return data;
  }
}

