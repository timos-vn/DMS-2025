class ListApproveOrderResponse {
  List<ListApproveOrderResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  ListApproveOrderResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ListApproveOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListApproveOrderResponseData>[];
      json['data'].forEach((v) {
        data!.add(ListApproveOrderResponseData.fromJson(v));
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

class ListApproveOrderResponseData {
  String? sttRec;
  String? soCt;
  String? ngayCt;
  String? maKh;
  String? tenKh;
  String? diaChi;
  String? dienThoai;
  double? tTienNt2;
  double? tCkNt;
  double? tTtNt;
  double? tSoLuong;
  String? maNvbh;
  String? tenNvbh;

  ListApproveOrderResponseData(
      {this.sttRec,
        this.soCt,
        this.ngayCt,
        this.maKh,
        this.tenKh,
        this.diaChi,
        this.dienThoai,
        this.tTienNt2,
        this.tCkNt,
        this.tTtNt,
        this.tSoLuong,
        this.maNvbh,
        this.tenNvbh});

  ListApproveOrderResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soCt = json['so_ct'];
    ngayCt = json['ngay_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    tTienNt2 = json['t_tien_nt2'];
    tCkNt = json['t_ck_nt'];
    tTtNt = json['t_tt_nt'];
    tSoLuong = json['t_so_luong'];
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stt_rec'] = this.sttRec;
    data['so_ct'] = this.soCt;
    data['ngay_ct'] = this.ngayCt;
    data['ma_kh'] = this.maKh;
    data['ten_kh'] = this.tenKh;
    data['dia_chi'] = this.diaChi;
    data['dien_thoai'] = this.dienThoai;
    data['t_tien_nt2'] = this.tTienNt2;
    data['t_ck_nt'] = this.tCkNt;
    data['t_tt_nt'] = this.tTtNt;
    data['t_so_luong'] = this.tSoLuong;
    data['ma_nvbh'] = this.maNvbh;
    data['ten_nvbh'] = this.tenNvbh;
    return data;
  }
}