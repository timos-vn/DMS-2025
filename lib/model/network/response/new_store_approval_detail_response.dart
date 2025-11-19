class NewStoreApprovalDetailResponse {
  NewStoreApprovalDetailData? data;
  int? totalPage;
  int? statusCode;
  String? message;

  NewStoreApprovalDetailResponse({this.data, this.totalPage, this.statusCode, this.message});

  NewStoreApprovalDetailResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? NewStoreApprovalDetailData.fromJson(json['data']) : null;
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class NewStoreApprovalDetailData {
  String? maNvbh;
  String? tenNvbh;
  String? hoTen;
  String? dienThoai;
  String? dienThoaiDd;
  String? maTuyen;
  String? tenTuyen;
  String? khuVuc;
  String? tenKhuVuc;
  String? maSoThue;
  String? tinhThanh;
  String? tenTinhThanh;
  String? quanHuyen;
  String? tenQuanHuyen;
  String? xaPhuong;
  String? tenXaPhuong;
  String? nguoiLienHe;
  String? ngaySinh;
  String? diaChi;
  String? ghiChu;
  String? moTa;
  String? phanLoai;
  String? tenLoai;
  String? hinhThuc;
  String? tenHinhThuc;
  String? latlong;
  String? maTinhTrang;
  String? tenTinhTrang;

  NewStoreApprovalDetailData({
    this.maNvbh,
    this.tenNvbh,
    this.hoTen,
    this.dienThoai,
    this.dienThoaiDd,
    this.maTuyen,
    this.tenTuyen,
    this.khuVuc,
    this.tenKhuVuc,
    this.maSoThue,
    this.tinhThanh,
    this.tenTinhThanh,
    this.quanHuyen,
    this.tenQuanHuyen,
    this.xaPhuong,
    this.tenXaPhuong,
    this.nguoiLienHe,
    this.ngaySinh,
    this.diaChi,
    this.ghiChu,
    this.moTa,
    this.phanLoai,
    this.tenLoai,
    this.hinhThuc,
    this.tenHinhThuc,
    this.latlong,
    this.maTinhTrang,
    this.tenTinhTrang,
  });

  NewStoreApprovalDetailData.fromJson(Map<String, dynamic> json) {
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
    hoTen = json['ho_ten'];
    dienThoai = json['dien_thoai'];
    dienThoaiDd = json['dien_thoai_dd'];
    maTuyen = json['ma_tuyen'];
    tenTuyen = json['ten_tuyen'];
    khuVuc = json['khu_vuc'];
    tenKhuVuc = json['ten_khu_vuc'];
    maSoThue = json['ma_so_thue'];
    tinhThanh = json['tinh_thanh'];
    tenTinhThanh = json['ten_tinh'];
    quanHuyen = json['quan_huyen'];
    tenQuanHuyen = json['ten_quan'];
    xaPhuong = json['xa_phuong'];
    tenXaPhuong = json['ten_phuong'];
    nguoiLienHe = json['nguoi_lh'];
    ngaySinh = json['ngay_sinh'];
    diaChi = json['dia_chi'];
    ghiChu = json['ghi_chu'];
    moTa = json['mo_ta'];
    phanLoai = json['phan_loai'];
    tenLoai = json['ten_loai'];
    hinhThuc = json['hinh_thuc'];
    tenHinhThuc = json['ten_hinh_thuc'];
    latlong = json['latlong'];
    maTinhTrang = json['ma_tinh_trang'];
    tenTinhTrang = json['ten_tinh_trang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_nvbh'] = maNvbh;
    data['ten_nvbh'] = tenNvbh;
    data['ho_ten'] = hoTen;
    data['dien_thoai'] = dienThoai;
    data['dien_thoai_dd'] = dienThoaiDd;
    data['ma_tuyen'] = maTuyen;
    data['ten_tuyen'] = tenTuyen;
    data['khu_vuc'] = khuVuc;
    data['ten_khu_vuc'] = tenKhuVuc;
    data['ma_so_thue'] = maSoThue;
    data['tinh_thanh'] = tinhThanh;
    data['ten_tinh'] = tenTinhThanh;
    data['quan_huyen'] = quanHuyen;
    data['ten_quan'] = tenQuanHuyen;
    data['xa_phuong'] = xaPhuong;
    data['ten_phuong'] = tenXaPhuong;
    data['nguoi_lh'] = nguoiLienHe;
    data['ngay_sinh'] = ngaySinh;
    data['dia_chi'] = diaChi;
    data['ghi_chu'] = ghiChu;
    data['mo_ta'] = moTa;
    data['phan_loai'] = phanLoai;
    data['ten_loai'] = tenLoai;
    data['hinh_thuc'] = hinhThuc;
    data['ten_hinh_thuc'] = tenHinhThuc;
    data['latlong'] = latlong;
    data['ma_tinh_trang'] = maTinhTrang;
    data['ten_tinh_trang'] = tenTinhTrang;
    return data;
  }
}

