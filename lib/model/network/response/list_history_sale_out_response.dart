class ListHistorySaleOutResponse {
  List<ListHistorySaleOutResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListHistorySaleOutResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListHistorySaleOutResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListHistorySaleOutResponseData>[];
      json['data'].forEach((v) {
        data!.add( ListHistorySaleOutResponseData.fromJson(v));
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

class ListHistorySaleOutResponseData {
  String? sttRec;
  String? ngayCt;
  String? maNpp;
  String? tenNpp;
  String? maNguoiNhan;
  String? tenNguoiNhan;
  String? diaChiNhan;
  String? dienThoaiNhan;
  double? tTtNt;
  double? tSoLuong;
  String? maNvbh;
  String? tenNvbh;

  ListHistorySaleOutResponseData(
      {this.sttRec,
        this.ngayCt,
        this.maNpp,
        this.tenNpp,
        this.maNguoiNhan,
        this.tenNguoiNhan,
        this.diaChiNhan,
        this.dienThoaiNhan,
        this.tTtNt,
        this.tSoLuong,
        this.maNvbh,
        this.tenNvbh});

  ListHistorySaleOutResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    ngayCt = json['ngay_ct'];
    maNpp = json['ma_npp'];
    tenNpp = json['ten_npp'];
    maNguoiNhan = json['ma_nguoi_nhan'];
    tenNguoiNhan = json['ten_nguoi_nhan'];
    diaChiNhan = json['dia_chi_nhan'];
    dienThoaiNhan = json['dien_thoai_nhan'];
    tTtNt = json['t_tt_nt'];
    tSoLuong = json['t_so_luong'];
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ngay_ct'] = ngayCt;
    data['ma_npp'] = maNpp;
    data['ten_npp'] = tenNpp;
    data['ma_nguoi_nhan'] = maNguoiNhan;
    data['ten_nguoi_nhan'] = tenNguoiNhan;
    data['dia_chi_nhan'] = diaChiNhan;
    data['dien_thoai_nhan'] = dienThoaiNhan;
    data['t_tt_nt'] = tTtNt;
    data['t_so_luong'] = tSoLuong;
    data['ma_nvbh'] = maNvbh;
    data['ten_nvbh'] = tenNvbh;
    return data;
  }
}

