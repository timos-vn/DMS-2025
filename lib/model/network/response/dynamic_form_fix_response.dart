class FormFixDataResponse {
  FormDatas? formDatas;

  FormFixDataResponse({this.formDatas});

  FormFixDataResponse.fromJson(Map<String, dynamic> json) {
    formDatas = json['formDatas'] != null
        ? new FormDatas.fromJson(json['formDatas'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (formDatas != null) {
      data['formDatas'] = formDatas!.toJson();
    }
    return data;
  }
}

class FormDatas {
  FormDataFix? formDataFix;

  FormDatas({this.formDataFix});

  FormDatas.fromJson(Map<String, dynamic> json) {
    formDataFix = json['formDataFix'] != null
        ? new FormDataFix.fromJson(json['formDataFix'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (formDataFix != null) {
      data['formDataFix'] = formDataFix!.toJson();
    }
    return data;
  }
}

class FormDataFix {
  String? sttRec;
  String? stt_rec_nv;
  String? ma_nv;
  String? maDvcs;
  String? maCt;
  String? soCt;
  String? ngayCt;
  String? ngayDn;
  String? nguoiDeXuat;
  String? maBp;
  String? chucDanh;
  String? ngayTu;
  String? ngayDen;
  String? ngayDeNghi;
  String? dienGiai;
  String? datetime0;
  String? datetime2;
  int? so_luong_anh;
  int? userId0;
  int? userId2;
  String? loai;
  String? tenLoai;
  dynamic soNgay;
  dynamic status;
  dynamic statusName;
  dynamic ngayPhep;
  dynamic caTu;
  dynamic caDen;
  dynamic ghiChu;
  dynamic lyDo;
  dynamic soGio;
  dynamic tongGio;
  dynamic gioTu;
  dynamic gioDen;
  dynamic diemDi;
  dynamic diemDen;
  dynamic idCar;
  dynamic nameCar;
  dynamic thanhPhan;
  dynamic requestOther;
  dynamic idRoom;
  dynamic nameRoom;
  dynamic soLuong;
  bool? request;
  bool? requestHQBK;
  bool? requestDU;
  bool? requestMC;
  String? nameCustomer;
  String? phoneCustomer;
  // BusinessTrip new fields
  String? diaChiDen;
  String? tenNguoiGap;
  String? sdtNguoiGap;
  String? mucDich;

  FormDataFix(
      {this.sttRec,this.stt_rec_nv,this.ma_nv,this.ngayDn,this.idRoom,this.nameRoom,this.soLuong,this.request,this.thanhPhan,
        this.maDvcs,
        this.requestOther,
        this.requestHQBK,
        this.requestDU,
        this.requestMC,
        this.maCt,
        this.soCt,
        this.ngayCt,
        this.nguoiDeXuat,
        this.maBp,
        this.chucDanh,
        this.ngayTu,
        this.ngayDen,
        this.ngayDeNghi,
        this.dienGiai,
        this.status,
        this.datetime0,
        this.datetime2,
        this.userId0,
        this.so_luong_anh,
        this.userId2, this.loai,this.lyDo,
        this.tenLoai,
        this.soNgay,
        this.statusName,
        this.ngayPhep,
        this.caTu,
        this.caDen,this.diemDi,this.diemDen,this.idCar,this.nameCar,this.phoneCustomer,this.nameCustomer,
        this.ghiChu,this.soGio,this.tongGio,this.gioDen,this.gioTu,
        this.diaChiDen,this.tenNguoiGap,this.sdtNguoiGap,this.mucDich});

  FormDataFix.fromJson(Map<String, dynamic> json) {
    sttRec = json['stt_rec'];
    stt_rec_nv = json['stt_rec_nv'];
    ma_nv = json['ma_nv'];
    ngayDn = json['ngay_dn'];
    maDvcs = json['ma_dvcs'];
    maCt = json['ma_ct'];
    soCt = json['so_ct'];
    ngayCt = json['ngay_ct'];
    nguoiDeXuat = json['nguoi_de_xuat'];
    maBp = json['ma_bp'];
    chucDanh = json['chuc_danh'];
    ngayTu = json['ngay_tu'];
    ngayDen = json['ngay_den'];
    ngayDeNghi = json['ngay_dn'];
    dienGiai = json['dien_giai'];
    status = json['status'];
    datetime0 = json['datetime0'];
    datetime2 = json['datetime2'];
    userId0 = json['user_id0'];
    so_luong_anh = json['so_luong_anh'];
    userId2 = json['user_id2'];
    loai = json['loai'];
     tenLoai = json['ten_loai'];soNgay = json['so_ngay'];
     statusName = json['status_name'];
     ngayPhep = json['ngay_phep'];
     caTu = json['ca_tu'];
     caDen = json['ca_den'];
     ghiChu = json['ghi_chu'];
     soGio = json['so_gio'];
     tongGio = json['tong_gio'];
     gioTu = json['gio_tu'];
     gioDen = json['gio_den'];
     diemDi = json['diem_di'];
     diemDen = json['diem_den'];
     idCar = json['loai_xe'];
     nameCar = json['ten_xe'];
     lyDo = json['ly_do'];
     nameCustomer = json['ten_kh'];
     phoneCustomer = json['sdt_lh'];

     thanhPhan = json['thanhphan'];
     idRoom = json['ma_phong'];
     nameRoom = json['ten_phong'];
     request = json['yccb_yn'];
     soLuong = json['so_luong'];
     requestHQBK = json['hqbk_yn'];
     requestDU = json['nuoc_yn'];
    requestMC = json['maychieu_yn'];
    requestOther = json['other'];
    
    // BusinessTrip new fields
    diaChiDen = json['dia_chi_den'];
    tenNguoiGap = json['ten_nguoi_gap'];
    sdtNguoiGap = json['sdt_nguoi_gap'];
    mucDich = json['muc_dich'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ten_kh'] = nameCustomer;
    data['sdt_lh'] = phoneCustomer;
    data['other'] = requestOther;
    data['hqbk_yn'] = requestHQBK;
    data['nuoc_yn'] = requestDU;
    data['maychieu_yn'] = requestMC;
    data['thanhphan'] = thanhPhan;
    data['ma_phong'] = idRoom;
    data['ten_phong'] = nameRoom;
    data['request'] = request;
    data['so_luong'] = soLuong;

    data['stt_rec'] = sttRec;
    data['ngay_dn'] = ngayDn;
    data['stt_rec_nv'] = stt_rec_nv;
    data['ma_nv'] = ma_nv;
    data['ma_dvcs'] = maDvcs;
    data['ma_ct'] = maCt;
    data['so_ct'] = soCt;
    data['ngay_ct'] = ngayCt;
    data['nguoi_de_xuat'] = nguoiDeXuat;
    data['ma_bp'] = maBp;
    data['chuc_danh'] = chucDanh;
    data['ngay_tu'] = ngayTu;
    data['ngay_den'] = ngayDen;
    data['ngay_dn'] = ngayDeNghi;
    data['dien_giai'] = dienGiai;
    data['status'] = status;
    data['datetime0'] = datetime0;
    data['datetime2'] = datetime2;
    data['user_id0'] = userId0;
    data['so_luong_anh'] = so_luong_anh;
    data['user_id2'] = userId2;
    data['loai'] = loai;
    data['ten_loai'] = tenLoai;
    data['so_ngay'] =  soNgay;
    data['status_name'] =  statusName;
    data['ngay_phep'] =  ngayPhep;
    data['ca_tu'] =  caTu;
    data['ca_den'] =  caDen;
    data['ghi_chu'] =  ghiChu;
    data['so_gio'] =  soGio;
    data['tong_gio'] =  tongGio;
    data['gio_tu'] =  gioTu;
    data['gio_den'] =  gioDen;
    data['diem_di'] =  diemDi;
    data['diem_den'] =  diemDen;
    data['loai_xe'] =  idCar;
    data['ten_xe'] =  nameCar;
    data['ly_do'] =  lyDo;
    
    // BusinessTrip new fields
    data['dia_chi_den'] = diaChiDen;
    data['ten_nguoi_gap'] = tenNguoiGap;
    data['sdt_nguoi_gap'] = sdtNguoiGap;
    data['muc_dich'] = mucDich;
    
    return data;
  }
}

class ActionDynamicResponse {
  dynamic data;
  int? totalPage;
  int? statusCode;
  String? message;

  ActionDynamicResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  ActionDynamicResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class GeneralHRMResponse {
  List<GeneralHRMResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  GeneralHRMResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  GeneralHRMResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <GeneralHRMResponseData>[];
      json['data'].forEach((v) {
        data!.add(new GeneralHRMResponseData.fromJson(v));
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

class GeneralHRMResponseData {
  String? data;

  GeneralHRMResponseData({this.data});

  GeneralHRMResponseData.fromJson(Map<String, dynamic> json) {
    data = json['data'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['data'] = this.data;
    return data;
  }
}