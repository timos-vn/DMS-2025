class GetDynamicListVoucherResponse {
  List<ListVoucher>? listVoucher;
  List<ListStatus>? listStatus;
  int? statusCode;
  String? message;

  GetDynamicListVoucherResponse(
      {this.listVoucher, this.listStatus, this.statusCode, this.message});

  GetDynamicListVoucherResponse.fromJson(Map<String, dynamic> json) {
    if (json['listVoucher'] != null) {
      listVoucher = <ListVoucher>[];
      json['listVoucher'].forEach((v) {
        listVoucher!.add(ListVoucher.fromJson(v));
      });
    }
    if (json['listStatus'] != null) {
      listStatus = <ListStatus>[];
      json['listStatus'].forEach((v) {
        listStatus!.add(ListStatus.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (listVoucher != null) {
      data['listVoucher'] = listVoucher!.map((v) => v.toJson()).toList();
    }
    if (listStatus != null) {
      data['listStatus'] = listStatus!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListVoucher {
  String? sttRec;
  String? soCt;
  String? ngayCt;
  String? maCt;
  String? status;
  String? maNvbh;
  String? maKh;
  double? tTien;
  double? tCk;
  double? tTt;
  double? tSoLuong;
  String? dienGiai;
  String? tenNvbh;
  String? tenKh;
  String? diaChi;
  String? dienThoai;
  String? statusname;

  ListVoucher(
      {this.sttRec,
        this.soCt,
        this.ngayCt,
        this.maCt,
        this.status,
        this.maNvbh,
        this.maKh,
        this.tTien,
        this.tCk,
        this.tTt,
        this.tSoLuong,
        this.dienGiai,
        this.tenNvbh,
        this.tenKh,
        this.diaChi,
        this.dienThoai,
        this.statusname});

  ListVoucher.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    soCt = json['so_ct'];
    ngayCt = json['ngay_ct'];
    maCt = json['ma_ct'];
    status = json['status'];
    maNvbh = json['ma_nvbh'];
    maKh = json['ma_kh'];
    tTien = json['t_tien'];
    tCk = json['t_ck'];
    tTt = json['t_tt'];
    tSoLuong = json['t_so_luong'];
    dienGiai = json['dien_giai'];
    tenNvbh = json['ten_nvbh'];
    tenKh = json['ten_kh'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    statusname = json['statusname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['so_ct'] = soCt;
    data['ngay_ct'] = ngayCt;
    data['ma_ct'] = maCt;
    data['status'] = status;
    data['ma_nvbh'] = maNvbh;
    data['ma_kh'] = maKh;
    data['t_tien'] = tTien;
    data['t_ck'] = tCk;
    data['t_tt'] = tTt;
    data['t_so_luong'] = tSoLuong;
    data['dien_giai'] = dienGiai;
    data['ten_nvbh'] = tenNvbh;
    data['ten_kh'] = tenKh;
    data['dia_chi'] = diaChi;
    data['dien_thoai'] = dienThoai;
    data['statusname'] = statusname;
    return data;
  }
}

class ListStatus {
  String? status;
  String? statusname;
  String? key;
  bool? delete;
  bool? update;
  bool? view;

  ListStatus(
      {this.status, this.statusname, this.delete, this.update, this.view, this.key});

  ListStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    statusname = json['statusname'];
    key = json['key'];
    delete = json['delete'];
    update = json['update'];
    view = json['view'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['statusname'] = statusname;
    data['key'] = key;
    data['delete'] = delete;
    data['update'] = update;
    data['view'] = view;
    return data;
  }
}