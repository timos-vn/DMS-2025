class ListItemSuggestResponse {
  List<ListItemSuggestResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListItemSuggestResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListItemSuggestResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListItemSuggestResponseData>[];
      json['data'].forEach((v) {
        data!.add(ListItemSuggestResponseData.fromJson(v));
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

class ListItemSuggestResponseData {
  String? sttRec;
  String? maKho;
  String? tenKho;
  String? maVt;
  String? tenVt;
  String? dvt;
  dynamic qty;
  bool? allowDvt;
  String? contentDvt;
  String? chiTieu;
  bool? isChecked = false;

  ListItemSuggestResponseData({this.sttRec,this.maVt, this.tenVt, this.dvt, this.chiTieu,this.isChecked
    , this.allowDvt, this.contentDvt, this.maKho, this.tenKho, this.qty});

  ListItemSuggestResponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    chiTieu = json['chi_tieu'];
    allowDvt = json['nhieu_dvt'];
    contentDvt = json['ndvt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['chi_tieu'] = chiTieu;
    data['nhieu_dvt'] = allowDvt;
    data['ndvt'] = contentDvt;
    return data;
  }
}