class GetListHistoryDNNKResponse {
  List<GetListHistoryDNNKResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListHistoryDNNKResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListHistoryDNNKResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListHistoryDNNKResponseData>[];
      json['data'].forEach((v) {
        data!.add(GetListHistoryDNNKResponseData.fromJson(v));
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

class GetListHistoryDNNKResponseData {
  String? sttRec;
  int? index;
  String? barcode;
  double? soCan;
  String? maVt;
  String? tenVt;
  String? hsd;

  GetListHistoryDNNKResponseData(
      {this.sttRec,
        this.index,
        this.barcode,
        this.soCan,
        this.maVt,this.hsd,
        this.tenVt});

  GetListHistoryDNNKResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    index = json['index'];
    barcode = json['barcode'];
    soCan = json['so_can'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['index'] = index;
    data['barcode'] = barcode;
    data['so_can'] = soCan;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    return data;
  }
}