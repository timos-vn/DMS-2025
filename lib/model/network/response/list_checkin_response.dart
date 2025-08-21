class ListCheckInResponse {
  List<ListCheckIn>? listCheckInToDay;
  // List<ListCheckIn>? listCheckInOther;
  int? totalPage;
  int? statusCode;
  String? message;

  ListCheckInResponse(
      {this.listCheckInToDay,
        // this.listCheckInOther,
        this.totalPage,
        this.statusCode,
        this.message});

  ListCheckInResponse.fromJson(Map<String, dynamic> json) {
    if (json['listCheckInToDay'] != null) {
      listCheckInToDay = <ListCheckIn>[];
      json['listCheckInToDay'].forEach((v) {
        listCheckInToDay!.add( ListCheckIn.fromJson(v));
      });
    }
    // if (json['listCheckInOther'] != null) {
    //   listCheckInOther = <ListCheckIn>[];
    //   json['listCheckInOther'].forEach((v) {
    //     listCheckInOther!.add( ListCheckIn.fromJson(v));
    //   });
    // }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (listCheckInToDay != null) {
      data['listCheckInToDay'] =
          listCheckInToDay!.map((v) => v.toJson()).toList();
    }
    // if (listCheckInOther != null) {
    //   data['listCheckInOther'] =
    //       listCheckInOther!.map((v) => v.toJson()).toList();
    // }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListCheckIn {
  int? id;
  String? tieuDe;
  String? ngayCheckin;
  String? maKh;
  String? tenCh;
  String? diaChi;
  String? dienThoai;
  String? gps;
  String? trangThai;
  String? tgHoanThanh;
  String? lastCheckOut;
  bool? isCheckInSuccessful;
  String? latLong;
  String? timeCheckOut;
  int? numberTimeCheckOut;
  bool? isSynSuccessful;
  String? ngayCv;

  ListCheckIn(
      { this.id,this.tieuDe,
        this.ngayCheckin,
        this.maKh,
        this.tenCh,
        this.diaChi,
        this.dienThoai,
        this.gps,
        this.trangThai,
        this.tgHoanThanh,this.lastCheckOut, this.isCheckInSuccessful,
        this.latLong,this.timeCheckOut, this.numberTimeCheckOut, this.isSynSuccessful,this.ngayCv});

  ListCheckIn.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tieuDe = json['tieu_de'];
    ngayCheckin = json['ngay_checkin'];
    maKh = json['ma_kh'];
    tenCh = json['ten_ch'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    gps = json['gps'];
    trangThai = json['trang_thai'];
    tgHoanThanh = json['tg_hoan_thanh'];
    lastCheckOut = json['last_chko'];
    latLong = json['latlong'];
    timeCheckOut = json['time_checkout'];
    ngayCv = json['ngay_cv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['tieu_de'] = tieuDe;
    data['ngay_checkin'] = ngayCheckin;
    data['ma_kh'] = maKh;
    data['ten_ch'] = tenCh;
    data['dia_chi'] = diaChi;
    data['dien_thoai'] = dienThoai;
    data['gps'] = gps;
    data['trang_thai'] = trangThai;
    data['tg_hoan_thanh'] = tgHoanThanh;
    data['last_chko'] = lastCheckOut;
    data['latlong'] = latLong;
    data['time_checkout'] = timeCheckOut;
    data['ngay_cv'] = ngayCv;
    return data;
  }
}

