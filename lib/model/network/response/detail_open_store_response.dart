class DetailOpenStoreResponse {
  DetailRequestOpenStore? detailRequestOpenStore;
  Roles? roles;
  int? statusCode;
  String? message;

  DetailOpenStoreResponse(
      {this.detailRequestOpenStore, this.roles, this.statusCode, this.message});

  DetailOpenStoreResponse.fromJson(Map<String, dynamic> json) {
    detailRequestOpenStore = json['detailRequestOpenStore'] != null
        ? new DetailRequestOpenStore.fromJson(json['detailRequestOpenStore'])
        : null;
    roles = json['roles'] != null ? new Roles.fromJson(json['roles']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.detailRequestOpenStore != null) {
      data['detailRequestOpenStore'] = this.detailRequestOpenStore!.toJson();
    }
    if (this.roles != null) {
      data['roles'] = this.roles!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DetailRequestOpenStore {
  String? maNvbh;
  String? tenNvbh;
  String? hoTen;
  int? hoTenYn;
  String? dienThoai;
  int? dienThoaiYn;
  String? dienThoaiDd;
  int? dienThoaiDdYn;
  String? email;
  int? emailYn;
  String? maTuyen;
  String? tenTuyen;
  int? maTuyenYn;
  String? maSoThue;
  int? maSoThueYn;
  String? tinhThanh;
  String? tenTinh;
  int? tinhThanhYn;
  String? quanHuyen;
  String? tenQuan;
  int? quanHuyenYn;
  String? khuVuc;
  String? tenKhuVuc;
  int? khuVucYn;
  String? xaPhuong;
  String? tenPhuong;
  int? xaPhuongYn;
  String? nguoiLh;
  int? nguoiLhYn;
  String? diaChi;
  int? diaChiYn;
  String? ghiChu;
  String? moTa;
  int? imagesYn;
  String? phanLoai;
  String? tenLoai;
  int? phanLoaiYn;
  String? hinhThuc;
  String? tenHinhThuc;
  int? hinhThucYn;
  String? latlong;
  String? fax;
  String? ngaySinh;
  String? idState;
  String? nameState;

  DetailRequestOpenStore(
      {this.maNvbh,
        this.tenNvbh,
        this.hoTen,
        this.hoTenYn,
        this.dienThoai,
        this.dienThoaiYn,
        this.dienThoaiDd,
        this.dienThoaiDdYn,
        this.email,
        this.emailYn,
        this.maTuyen,
        this.tenTuyen,
        this.maTuyenYn,
        this.maSoThue,
        this.maSoThueYn,
        this.tinhThanh,
        this.tenTinh,
        this.tinhThanhYn,
        this.quanHuyen,
        this.tenQuan,
        this.quanHuyenYn,
        this.khuVuc,
        this.tenKhuVuc,
        this.khuVucYn,
        this.xaPhuong,
        this.tenPhuong,
        this.xaPhuongYn,
        this.nguoiLh,
        this.nguoiLhYn,
        this.diaChi,
        this.diaChiYn,
        this.ghiChu,this.moTa,
        this.imagesYn,
        this.phanLoai,
        this.tenLoai,
        this.phanLoaiYn,
        this.hinhThuc,
        this.tenHinhThuc,
        this.hinhThucYn,
        this.latlong,
        this.fax,this.ngaySinh, this.idState, this.nameState});

  DetailRequestOpenStore.fromJson(Map<String, dynamic> json) {
    maNvbh = json['ma_nvbh'];
    tenNvbh = json['ten_nvbh'];
    hoTen = json['ho_ten'];
    hoTenYn = json['ho_ten_yn'];
    dienThoai = json['dien_thoai'];
    dienThoaiYn = json['dien_thoai_yn'];
    dienThoaiDd = json['dien_thoai_dd'];
    dienThoaiDdYn = json['dien_thoai_dd_yn'];
    email = json['email'];
    emailYn = json['email_yn'];
    maTuyen = json['ma_tuyen'];
    tenTuyen = json['ten_tuyen'];
    maTuyenYn = json['ma_tuyen_yn'];
    maSoThue = json['ma_so_thue'];
    maSoThueYn = json['ma_so_thue_yn'];
    tinhThanh = json['tinh_thanh'];
    tenTinh = json['ten_tinh'];
    tinhThanhYn = json['tinh_thanh_yn'];
    quanHuyen = json['quan_huyen'];
    tenQuan = json['ten_quan'];
    quanHuyenYn = json['quan_huyen_yn'];
    khuVuc = json['khu_vuc'];
    tenKhuVuc = json['ten_khu_vuc'];
    khuVucYn = json['khu_vuc_yn'];
    xaPhuong = json['xa_phuong'];
    tenPhuong = json['ten_phuong'];
    xaPhuongYn = json['xa_phuong_yn'];
    nguoiLh = json['nguoi_lh'];
    nguoiLhYn = json['nguoi_lh_yn'];
    diaChi = json['dia_chi'];
    diaChiYn = json['dia_chi_yn'];
    ghiChu = json['ghi_chu']; moTa = json['mo_ta'];
    imagesYn = json['images_yn'];
    phanLoai = json['phan_loai'];
    tenLoai = json['ten_loai'];
    phanLoaiYn = json['phan_loai_yn'];
    hinhThuc = json['hinh_thuc'];
    tenHinhThuc = json['ten_hinh_thuc'];
    hinhThucYn = json['hinh_thuc_yn'];
    latlong = json['latlong'];
    fax = json['fax']; ngaySinh = json['ngay_sinh'];
    nameState = json['ten_tinh_trang']; idState = json['ma_tinh_trang'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  Map<String, dynamic>();
    data['ma_nvbh'] = this.maNvbh;
    data['ten_nvbh'] = this.tenNvbh;
    data['ho_ten'] = this.hoTen;
    data['ho_ten_yn'] = this.hoTenYn;
    data['dien_thoai'] = this.dienThoai;
    data['dien_thoai_yn'] = this.dienThoaiYn;
    data['dien_thoai_dd'] = this.dienThoaiDd;
    data['dien_thoai_dd_yn'] = this.dienThoaiDdYn;
    data['email'] = this.email;
    data['email_yn'] = this.emailYn;
    data['ma_tuyen'] = this.maTuyen;
    data['ten_tuyen'] = this.tenTuyen;
    data['ma_tuyen_yn'] = this.maTuyenYn;
    data['ma_so_thue'] = this.maSoThue;
    data['ma_so_thue_yn'] = this.maSoThueYn;
    data['tinh_thanh'] = this.tinhThanh;
    data['ten_tinh'] = this.tenTinh;
    data['tinh_thanh_yn'] = this.tinhThanhYn;
    data['quan_huyen'] = this.quanHuyen;
    data['ten_quan'] = this.tenQuan;
    data['quan_huyen_yn'] = this.quanHuyenYn;
    data['khu_vuc'] = this.khuVuc;
    data['ten_khu_vuc'] = this.tenKhuVuc;
    data['khu_vuc_yn'] = this.khuVucYn;
    data['xa_phuong'] = this.xaPhuong;
    data['ten_phuong'] = this.tenPhuong;
    data['xa_phuong_yn'] = this.xaPhuongYn;
    data['nguoi_lh'] = this.nguoiLh;
    data['nguoi_lh_yn'] = this.nguoiLhYn;
    data['dia_chi'] = this.diaChi;
    data['dia_chi_yn'] = this.diaChiYn;
    data['ghi_chu'] = this.ghiChu;   data['mo_ta'] = moTa;
    data['images_yn'] = this.imagesYn;
    data['phan_loai'] = this.phanLoai;
    data['ten_loai'] = this.tenLoai;
    data['phan_loai_yn'] = this.phanLoaiYn;
    data['hinh_thuc'] = this.hinhThuc;
    data['ten_hinh_thuc'] = tenHinhThuc;
    data['hinh_thuc_yn'] = hinhThucYn;
    data['latlong'] = latlong;
    data['fax'] = fax; data['ngay_sinh'] = ngaySinh;
    data['ten_tinh_trang'] = nameState; data['ma_tinh_trang'] = idState;
    return data;
  }
}

class Roles {
  int? userRole;
  int? leadRole;

  Roles({this.userRole,this.leadRole});

  Roles.fromJson(Map<String, dynamic> json) {
    userRole = json['user_role'];
    leadRole = json['lead_role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_role'] = userRole;
    data['lead_role'] = leadRole;
    return data;
  }
}

