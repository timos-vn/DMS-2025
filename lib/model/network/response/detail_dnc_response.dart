class DetailDNCResponse {
  DetailDNCResponseData? data;
  int? statusCode;
  String? message;

  DetailDNCResponse({this.data, this.statusCode, this.message});

  DetailDNCResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? new DetailDNCResponseData.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data?.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DetailDNCResponseData {
  MasterDNC? master;
  List<DetailListDNC>? detail;

  DetailDNCResponseData({this.master, this.detail});

  DetailDNCResponseData.fromJson(Map<String, dynamic> json) {
    master =
    json['master'] != null ? new MasterDNC.fromJson(json['master']) : null;
    if (json['detail'] != null) {
      detail = <DetailListDNC>[];
      json['detail'].forEach((v) {
        detail?.add(new DetailListDNC.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.master != null) {
      data['master'] = this.master?.toJson();
    }
    if (this.detail != null) {
      data['detail'] = this.detail?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MasterDNC {
  String? sttRec;
  String? soCt;
  String? ngayCt;
  String? ngayLct;
  String? maKh;
  String? dienGiai;
  int? status;
  String? loaiTt;
  String? maGd;
  String? maNt;
  double? tyGia;
  String? statusName;

  MasterDNC(
      {this.sttRec,
        this.soCt,
        this.ngayCt,
        this.ngayLct,
        this.maKh,
        this.dienGiai,
        this.status,
        this.loaiTt,
        this.maGd,
        this.maNt,
        this.tyGia,this.statusName});

  MasterDNC.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soCt = json['so_ct'];
    ngayCt = json['ngay_ct'];
    ngayLct = json['ngay_lct'];
    maKh = json['ma_kh'];
    dienGiai = json['dien_giai'];
    status = json['status'];
    loaiTt = json['loai_tt'];
    maGd = json['ma_gd'];
    maNt = json['ma_nt'];
    tyGia = json['ty_gia'];
    statusName = json['statusname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['so_ct'] = this.soCt;
    data['ngay_ct'] = this.ngayCt;
    data['ngay_lct'] = this.ngayLct;
    data['ma_kh'] = this.maKh;
    data['dien_giai'] = this.dienGiai;
    data['status'] = this.status;
    data['loai_tt'] = this.loaiTt;
    data['ma_gd'] = this.maGd;
    data['ma_nt'] = this.maNt;
    data['ty_gia'] = this.tyGia;
    data['statusname'] = this.statusName;
    return data;
  }
}

class DetailListDNC {
  double? tienNt;
  String? dienGiai;

  DetailListDNC({this.tienNt, this.dienGiai});

  DetailListDNC.fromJson(Map<String, dynamic> json) {
    tienNt = json['tien_nt'];
    dienGiai = json['dien_giai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tien_nt'] = this.tienNt;
    data['dien_giai'] = this.dienGiai;
    return data;
  }
}