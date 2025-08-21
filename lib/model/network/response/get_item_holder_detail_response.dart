class ItemHolderDetailResponse {
  ItemHolderDetailResponseMaster? master;
  List<ListItemHolderDetailResponse>? listItem;
  int? statusCode;
  String? message;

  ItemHolderDetailResponse(
      {this.master, this.listItem, this.statusCode, this.message});

  ItemHolderDetailResponse.fromJson(Map<String, dynamic> json) {
    master =
    json['master'] != null ? ItemHolderDetailResponseMaster.fromJson(json['master']) : null;
    if (json['listItem'] != null) {
      listItem = <ListItemHolderDetailResponse>[];
      json['listItem'].forEach((v) {
        listItem!.add(ListItemHolderDetailResponse.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (master != null) {
      data['master'] = master!.toJson();
    }
    if (listItem != null) {
      data['listItem'] = listItem!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ItemHolderDetailResponseMaster {
  String? sttRec;
  String? maDvcs;
  String? maCt;
  String? ngayCt;
  String? soCt;
  String? maNvbh;
  String? tenNvbh;
  String? dienGiai;
  double? tSoLuong;
  String? status;
  String? statusname;
  String? ngayHetHan;

  ItemHolderDetailResponseMaster(
      {this.sttRec,
        this.maDvcs,
        this.maCt,
        this.ngayCt,
        this.soCt,
        this.maNvbh,
        this.tenNvbh,
        this.dienGiai,
        this.tSoLuong,
        this.status,
        this.statusname,this.ngayHetHan});

  ItemHolderDetailResponseMaster.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    maDvcs = json['ma_dvcs'];
    maCt = json['ma_ct'];
    ngayCt = json['ngay_ct'];
    soCt = json['so_ct'];
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
    dienGiai = json['dien_giai'];
    tSoLuong = json['t_so_luong'];
    status = json['status'];
    statusname = json['statusname'];
    ngayHetHan = json['ngay_het_han'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['ma_dvcs'] = maDvcs;
    data['ma_ct'] = maCt;
    data['ngay_ct'] = ngayCt;
    data['so_ct'] = soCt;
    data['ma_nvbh'] = maNvbh;
    data['ten_nvbh'] = tenNvbh;
    data['dien_giai'] = dienGiai;
    data['t_so_luong'] = tSoLuong;
    data['status'] = status;
    data['statusname'] = statusname;
    data['ngay_het_han'] = ngayHetHan;
    return data;
  }
}

class ListItemHolderDetailResponse {
  String? sttRec;
  String? sttRec0;
  String? maDVCS;
  String? tenDVCS;
  String? maVt;
  String? tenVt;
  String? dvt;
  String? tenDvt;
  double? soLuong;
  double? gia;
  double? giaNT2;
  List<ListCustomerItemHolderDetailResponse>? listCustomer;

  ListItemHolderDetailResponse(
      {this.sttRec,
        this.sttRec0,
        this.maDVCS,
        this.tenDVCS,
        this.maVt,
        this.tenVt,
        this.dvt,
        this.tenDvt,
        this.soLuong,
        this.gia,
        this.giaNT2,
        this.listCustomer});

  ListItemHolderDetailResponse.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    tenDvt = json['ten_dvt'];
    soLuong = json['so_luong'];
    maDVCS = json['ma_dvcs'];
    gia = json['gia'];
    giaNT2 = json['gia_nt2'];
    if (json['listCustomer'] != null) {
      listCustomer = <ListCustomerItemHolderDetailResponse>[];
      json['listCustomer'].forEach((v) {
        listCustomer!.add(ListCustomerItemHolderDetailResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt_rec0'] = sttRec0;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['ten_dvt'] = tenDvt;
    data['so_luong'] = soLuong;
    data['ma_dvcs'] = maDVCS;
    data['gia'] = gia;
    data['gia_nt2'] = giaNT2;
    if (listCustomer != null) {
      data['listCustomer'] = listCustomer!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListCustomerItemHolderDetailResponse {
  String? sttRec;
  String? sttRec0;
  String? maDVCS;
  String? tenDVCS;
  String? maKh;
  String? tenKh;
  String? maVt;
  String? tenVt;
  String? dvt;
  String? tenDvt;
  double? soLuong;

  ListCustomerItemHolderDetailResponse(
      {this.sttRec,
        this.sttRec0,
        this.maDVCS,
        this.tenDVCS,
        this.maKh,
        this.tenKh,
        this.maVt,
        this.tenVt,
        this.dvt,
        this.tenDvt,
        this.soLuong});

  ListCustomerItemHolderDetailResponse.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    sttRec0 = json['stt_rec0'];
    maDVCS = json['ma_dvcs'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    maVt = json['ma_vt'];
    tenVt = json['ten_vt'];
    dvt = json['dvt'];
    tenDvt = json['ten_dvt'];
    soLuong = json['so_luong'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stt_rec'] = sttRec;
    data['stt_rec0'] = sttRec0;
    data['ma_dvcs'] = maDVCS;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['ma_vt'] = maVt;
    data['ten_vt'] = tenVt;
    data['dvt'] = dvt;
    data['ten_dvt'] = tenDvt;
    data['so_luong'] = soLuong;
    return data;
  }
}

