class NewStoreApprovalListResponse {
  List<NewStoreApprovalItem>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  NewStoreApprovalListResponse({this.data, this.totalPage, this.statusCode, this.message});

  NewStoreApprovalListResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <NewStoreApprovalItem>[];
      for (var v in (json['data'] as List)) {
        data!.add(NewStoreApprovalItem.fromJson(v));
      }
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

class NewStoreApprovalItem {
  String? keyValue;
  String? tenCuaHang;
  String? tenKhachHang;
  String? dienThoai;
  String? diaChi;
  String? khuVuc;
  String? tenTinh;
  String? tenQuan;
  String? email;
  String? nguoiTao;
  String? ghiChu;
  bool? trangThai;
  String? ngayTao;
  String? latlong;
  String? tenTrangThai;

  NewStoreApprovalItem({
    this.keyValue,
    this.tenCuaHang,
    this.tenKhachHang,
    this.dienThoai,
    this.diaChi,
    this.khuVuc,
    this.tenTinh,
    this.tenQuan,
    this.email,
    this.nguoiTao,
    this.ghiChu,
    this.trangThai,
    this.ngayTao,
    this.latlong,
    this.tenTrangThai,
  });

  NewStoreApprovalItem.fromJson(Map<String, dynamic> json) {
    keyValue = json['key_value'];
    tenCuaHang = json['ten_ch'];
    tenKhachHang = json['ten_kh'];
    dienThoai = json['dien_thoai'];
    diaChi = json['dia_chi'];
    khuVuc = json['khu_vuc'];
    tenTinh = json['ten_tinh'];
    tenQuan = json['ten_quan'];
    email = json['email'];
    nguoiTao = json['nguoi_tao'];
    ghiChu = json['ghi_chu'];
    trangThai = json['trang_thai'];
    ngayTao = json['ngay_tao'];
    latlong = json['latlong'];
    tenTrangThai = json['ten_trang_thai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['key_value'] = keyValue;
    data['ten_ch'] = tenCuaHang;
    data['ten_kh'] = tenKhachHang;
    data['dien_thoai'] = dienThoai;
    data['dia_chi'] = diaChi;
    data['khu_vuc'] = khuVuc;
    data['ten_tinh'] = tenTinh;
    data['ten_quan'] = tenQuan;
    data['email'] = email;
    data['nguoi_tao'] = nguoiTao;
    data['ghi_chu'] = ghiChu;
    data['trang_thai'] = trangThai;
    data['ngay_tao'] = ngayTao;
    data['latlong'] = latlong;
    data['ten_trang_thai'] = tenTrangThai;
    return data;
  }
}

