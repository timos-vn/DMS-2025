class GetListHistoryRefundOrderResponse {
  List<GetListHistoryRefundOrderResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GetListHistoryRefundOrderResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GetListHistoryRefundOrderResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GetListHistoryRefundOrderResponseData>[];
      json['data'].forEach((v) {
        data!.add(new GetListHistoryRefundOrderResponseData.fromJson(v));
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

class GetListHistoryRefundOrderResponseData {
  String? sttRec;
  String? soCt;
  String? ngayCt;
  String? maKh;
  String? tenKh;
  String? diaChi;
  String? dienThoai;
  String? maNvbh;
  String? maNvlhd;
  double? tTienNt2;
  double? tCkNt;
  double? tTtNt;
  double? tSoLuong;
  String? maThue;
  double? tThueNt;
  String? dienGiai;
  String? tenNvbh;
  String? tenNvlhd;

  GetListHistoryRefundOrderResponseData(
      {this.sttRec,
        this.soCt,
        this.ngayCt,
        this.maKh,
        this.tenKh,
        this.diaChi,
        this.dienThoai,
        this.maNvbh,
        this.maNvlhd,
        this.tTienNt2,
        this.tCkNt,
        this.tTtNt,
        this.tSoLuong,
        this.maThue,
        this.tThueNt,
        this.dienGiai,
        this.tenNvbh,
        this.tenNvlhd});

  GetListHistoryRefundOrderResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soCt = json['so_ct'];
    ngayCt = json['ngay_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    maNvbh = json['ma_nvbh'];
    maNvlhd = json['ma_nvlhd'];
    tTienNt2 = json['t_tien_nt2'];
    tCkNt = json['t_ck_nt'];
    tTtNt = json['t_tt_nt'];
    tSoLuong = json['t_so_luong'];
    maThue = json['ma_thue'];
    tThueNt = json['t_thue_nt'];
    dienGiai = json['dien_giai'];
    tenNvbh = json['ten_nvbh'];
    tenNvlhd = json['ten_nvlhd'];
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
    data['ma_nvbh'] = this.maNvbh;
    data['ma_nvlhd'] = this.maNvlhd;
    data['t_tien_nt2'] = this.tTienNt2;
    data['t_ck_nt'] = this.tCkNt;
    data['t_tt_nt'] = this.tTtNt;
    data['t_so_luong'] = this.tSoLuong;
    data['ma_thue'] = this.maThue;
    data['t_thue_nt'] = this.tThueNt;
    data['dien_giai'] = this.dienGiai;
    data['ten_nvbh'] = this.tenNvbh;
    data['ten_nvlhd'] = this.tenNvlhd;
    return data;
  }
}

