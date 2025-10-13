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
  String? sttRec0;
  int? index;
  String? barcode;
  double? soCan;
  double? soCanView;
  double? soLuong;
  String? maVt;
  String? tenVt;
  String? hsd;
  String? nsx;
  String? maLo;
  String? maKho;
  String? pallet;
  String? maViTri;
  String? timeScan;
  String? dvt;
  bool? isCallAPI;

  GetListHistoryDNNKResponseData(
      {this.sttRec,
        this.sttRec0,
        this.index,
        this.barcode,
        this.soCan,
        this.soCanView,
        this.soLuong,
        this.dvt,
        this.isCallAPI,
        this.maVt,
        this.hsd,
        this.nsx,
        this.maKho,
        this.maLo,
        this.pallet,
        this.timeScan,
        this.tenVt,
        this.maViTri});

  GetListHistoryDNNKResponseData.fromJson(Map<String, dynamic> json) {
    dvt = json['dvt'];
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    index = json['index'];
    barcode = json['barcode'];
    soCan = json['so_can'];
    soCanView = json['so_can_view'];
    soLuong = json['so_luong'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    pallet = json['pallet'];
    maViTri = json['maViTri'];
    maLo = json['maLo'];
    nsx = json['nsx'];
    timeScan = json['time_scan'];
    isCallAPI = json['is_call_api'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['dvt'] = dvt;
    data['stt_rec0'] = sttRec0;
    data['index'] = index;
    data['barcode'] = barcode;
    data['so_can'] = soCan;
    data['so_can_view'] = soCanView;
    data['so_luong'] = soLuong;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['pallet'] = pallet;
    data['maViTri'] = maViTri;
    data['maLo'] = maLo;
    data['nsx'] = nsx;
    data['time_scan'] = timeScan;
    data['is_call_api'] = isCallAPI;
    return data;
  }
}