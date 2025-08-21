class TimeKeepingDataResponse {
  TimeKeepingDataResponseMaster? master;
  List<ListTimeKeepingHistory>? listTimeKeepingHistory;
  int? statusCode;
  String? message;

  TimeKeepingDataResponse(
      {this.master,
        this.listTimeKeepingHistory,
        this.statusCode,
        this.message});

  TimeKeepingDataResponse.fromJson(Map<String, dynamic> json) {
    master =
    json['master'] != null ?  TimeKeepingDataResponseMaster.fromJson(json['master']) : null;
    if (json['listTimeKeepingHistory'] != null) {
      listTimeKeepingHistory = <ListTimeKeepingHistory>[];
      json['listTimeKeepingHistory'].forEach((v) {
        listTimeKeepingHistory!.add( ListTimeKeepingHistory.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (master != null) {
      data['master'] = master!.toJson();
    }
    if (listTimeKeepingHistory != null) {
      data['listTimeKeepingHistory'] =
          listTimeKeepingHistory!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class TimeKeepingDataResponseMaster {
  String? maNv;
  String? tenNv;
  String? dienThoai;
  String? ngaySinh;
  String? ngayVao;
  String? ngayChinhThuc;
  String? diaChi;
  String? viTri;
  int? phepDn;
  int? phepCl;
  int? tDiLam;
  int? tCong;
  String? location;
  String? ipSettup;
  double? distance;

  TimeKeepingDataResponseMaster(
      {this.maNv,
        this.tenNv,
        this.dienThoai,
        this.ngaySinh,
        this.ngayVao,
        this.ngayChinhThuc,
        this.diaChi,
        this.viTri,
        this.phepDn,
        this.ipSettup,
        this.phepCl,
        this.tDiLam,this.tCong, this.location,this.distance});

  TimeKeepingDataResponseMaster.fromJson(Map<String, dynamic> json) {
    maNv = json['ma_nv'];
    tenNv = json['ten_nv'];

    dienThoai = json['dien_thoai'];
    ngaySinh = json['ngay_sinh'];
    ngayVao = json['ngay_vao'];
    ngayChinhThuc = json['ngay_chinh_thuc'];
    diaChi = json['dia_chi'];
    tCong = json['t_cong'];

    viTri = json['vi_tri'];
    phepDn = json['phep_dn'];
    phepCl = json['phep_cl'];
    tDiLam = json['t_di_lam'];
    location = json['locationCompany'];
    ipSettup = json['ipSettup'];
    distance = json['distance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_nv'] = maNv;
    data['ten_nv'] = tenNv;

    data['dien_thoai'] = dienThoai;
    data['ngay_sinh'] = ngaySinh;
    data['ngay_vao'] = ngayVao;
    data['ngay_chinh_thuc'] = ngayChinhThuc;
    data['dia_chi'] = diaChi;
    data['t_cong'] = tCong;

    data['vi_tri'] = viTri;
    data['phep_dn'] = phepDn;
    data['phep_cl'] = phepCl;
    data['t_di_lam'] = tDiLam;
    data['locationCompany'] = location;
    data['ipSettup'] = ipSettup;
    data['distance'] = distance;
    return data;
  }
}

class ListTimeKeepingHistory {
  int? id;
  String? dateTime;
  String? timeIn;
  String? timeOut;
  String? reason;
  String? description;
  int? isStatus;
  int? isMeetCustomer;

  ListTimeKeepingHistory(
      {this.id,
        this.dateTime,
        this.timeIn,
        this.timeOut,
        this.reason,
        this.isStatus,
        this.isMeetCustomer,
        this.description});

  ListTimeKeepingHistory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    dateTime = json['date_time'];
    timeIn = json['time_in'];
    timeOut = json['time_out'];
    reason = json['reason'];
    description = json['description'];
    isStatus = json['isStatus'];
    isMeetCustomer = json['isMeetCustomer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['date_time'] = dateTime;
    data['time_in'] = timeIn;
    data['time_out'] = timeOut;
    data['reason'] = reason;
    data['description'] = description;
    data['isStatus'] = isStatus;
    data['isMeetCustomer'] = isMeetCustomer;
    return data;
  }
}