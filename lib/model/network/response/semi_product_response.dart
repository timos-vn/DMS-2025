class SemiProductionResponse {
  List<SemiProductionResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  SemiProductionResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  SemiProductionResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SemiProductionResponseData>[];
      json['data'].forEach((v) {
        data!.add(SemiProductionResponseData.fromJson(v));
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

class SemiProductionResponseData {
  String? maVt;
  String? tenVt;
  String? tenVt2;
  bool? nhieuDvt;
  String? ndvt;
  String? dvt;
  String? codeWorker;
  String? nameWorker;
  String? codeGWorker;
  String? nameGWorker;
  String? codeStore;
  String? nameStore;
  double soLuong = 0;
  String? descript;
  String? ma_lo;
  String? ten_kh;
  String? ten_nvbh;

  SemiProductionResponseData(
      {this.maVt,
        this.tenVt,
        this.tenVt2,
        this.nhieuDvt,
        this.ndvt,
        this.dvt,this.codeGWorker,this.codeWorker,this.nameGWorker,this.nameWorker,this.codeStore,this.nameStore,
        this.ma_lo,this.ten_kh,this.ten_nvbh,
        this.descript,this.soLuong = 0});

  SemiProductionResponseData.fromJson(Map<String, dynamic> json) {
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    tenVt2 = json['ten_vt2'];
    nhieuDvt = json['nhieu_dvt'];
    ndvt = json['ndvt'];
    dvt = json['Dvt'];
    descript = json['Descript'];
    codeStore = json['codeStore'];
    nameStore = json['nameStore'];ten_nvbh = json['ten_nvbh'];
    ten_kh = json['ten_kh'];
    ma_lo = json['ma_lo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['ten_vt2'] = tenVt2;
    data['nhieu_dvt'] = nhieuDvt;
    data['ndvt'] = ndvt;
    data['Dvt'] = dvt;
    data['Descript'] = descript;
    data['codeStore'] = codeStore;
    data['nameStore'] = nameStore;data['ma_lo'] = ma_lo;
    data['ten_kh'] = ten_kh;
    data['ten_nvbh'] = ten_nvbh;
    return data;
  }
}