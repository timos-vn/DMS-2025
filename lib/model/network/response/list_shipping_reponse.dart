class ListShippingResponse {
  List<ListShippingResponseData>? data;
  int? statusCode;
  String? message;

  ListShippingResponse({this.data, this.statusCode, this.message});

  ListShippingResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListShippingResponseData>[];
      json['data'].forEach((v) {
        data!.add(new ListShippingResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListShippingResponseData {
  String? sttRec;
  String? maDvcs;
  String? ngayCt;
  String? soCt;
  String? maKh;
  String? tenKh;
  String? dienGiai;
  double? tTtNt;
  String? maNt;
  String? maCt;
  String? status;
  String? soPhieuXuat;
  String? statusName;
  String? address;
  String? fcode3;

  ListShippingResponseData(
      {this.sttRec,
        this.maDvcs,
        this.ngayCt,
        this.soCt,
        this.maKh,
        this.tenKh,
        this.dienGiai,
        this.tTtNt,
        this.maNt,
        this.maCt,
        this.soPhieuXuat,
        this.address,
        this.fcode3,
        this.status,this.statusName});

  ListShippingResponseData.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    dienGiai = json['dien_giai'];
    tTtNt = json['t_tt_nt'];
    maNt = json['ma_nt'];
    maCt = json['ma_ct'];
    soPhieuXuat = json['so_phieu_xuat'];
    status = json['status'];
    address = json['ten_dc'];
    fcode3 = json['fcode3'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ma_dvcs'] = maDvcs;
    data['ngay_ct'] = ngayCt;
    data['so_ct'] = soCt;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['dien_giai'] = dienGiai;
    data['t_tt_nt'] = tTtNt;
    data['ma_nt'] = maNt;
    data['ma_ct'] = maCt;
    data['so_phieu_xuat'] = soPhieuXuat;
    data['status'] = status;
    data['ten_dc'] = address;
    data['fcode3'] = fcode3;
    return data;
  }
}
