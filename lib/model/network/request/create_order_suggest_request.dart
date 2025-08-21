class CreateOrderSuggestRequest {
  CreateOrderSuggestRequestData? data;

  CreateOrderSuggestRequest({this.data});

  CreateOrderSuggestRequest.fromJson(Map<String, dynamic> json) {
    data = json['Data'] != null ? CreateOrderSuggestRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['Data'] = this.data!.toJson();
    }
    return data;
  }
}

class CreateOrderSuggestRequestData {
  String? type;
  String? sttRec;
  String? ngayCt;
  String? maKho;
  String? maKhoNhap;
  String? deptId;
  String? dienGiai;
  List<CreateOrderSuggestRequestDetail>? detail;

  CreateOrderSuggestRequestData(
      {this.type,
        this.sttRec,
        this.ngayCt,
        this.maKho,
        this.maKhoNhap,
        this.deptId,
        this.dienGiai,
        this.detail});

  CreateOrderSuggestRequestData.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    sttRec = json['sttRec'];
    ngayCt = json['ngayCt'];
    maKho = json['maKho'];
    maKhoNhap = json['maKhoNhap'];
    deptId = json['deptId'];
    dienGiai = json['dienGiai'];
    if (json['Detail'] != null) {
      detail = <CreateOrderSuggestRequestDetail>[];
      json['Detail'].forEach((v) {
        detail!.add(CreateOrderSuggestRequestDetail.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['sttRec'] = sttRec;
    data['ngayCt'] = ngayCt;
    data['maKho'] = maKho;
    data['maKhoNhap'] = maKhoNhap;
    data['deptId'] = deptId;
    data['dienGiai'] = dienGiai;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CreateOrderSuggestRequestDetail {
  String? sttRec;
  String? maVt;
  String? dvt;
  dynamic soLuong;

  CreateOrderSuggestRequestDetail({this.sttRec, this.maVt, this.dvt, this.soLuong});

  CreateOrderSuggestRequestDetail.fromJson(Map<String, dynamic> json) {
    sttRec = json['sttRec'];
    maVt = json['maVt'];
    dvt = json['dvt'];
    soLuong = json['soLuong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sttRec'] = sttRec;
    data['maVt'] = maVt;
    data['dvt'] = dvt;
    data['soLuong'] = soLuong;
    return data;
  }
}