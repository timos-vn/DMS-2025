class DetailHistorySaleOutResponse {
  List<DetailHistorySaleOutResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  DetailHistorySaleOutResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  DetailHistorySaleOutResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <DetailHistorySaleOutResponseData>[];
      json['data'].forEach((v) {
        data!.add( DetailHistorySaleOutResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DetailHistorySaleOutResponseData {
  String? sttRec;
  String? sttRec0;
  String? maVt;
  String? tenVt;
  double? soLuong;
  String? dvt;
  bool? kmYn;
  double? giaNt2;
  double? giaSan;
  double? tienNt2;

  DetailHistorySaleOutResponseData(
      {this.sttRec,
        this.sttRec0,
        this.maVt,
        this.tenVt,
        this.soLuong,
        this.dvt,
        this.kmYn,
        this.giaNt2,
        this.giaSan,
        this.tienNt2});

  DetailHistorySaleOutResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    soLuong = json['so_luong'];
    dvt = json['dvt'];
    kmYn = json['km_yn'];
    giaNt2 = json['gia_nt2'];
    giaSan = json['gia_san'];
    tienNt2 = json['tien_nt2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['stt_rec0'] = this.sttRec0;
    data['ma_vt'] = this.maVt;
    data['ten_vt'] = this.tenVt;
    data['so_luong'] = this.soLuong;
    data['dvt'] = this.dvt;
    data['km_yn'] = this.kmYn;
    data['gia_nt2'] = this.giaNt2;
    data['gia_san'] = this.giaSan;
    data['tien_nt2'] = this.tienNt2;
    return data;
  }
}

