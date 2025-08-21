class DetailCheckInResponse {
  List<DetailCheckInMaster>? master;
  List<ListAlbum>? listAlbum;
  List<ListAlbumTicketOffLine>? listTicket;
  int? statusCode;
  String? message;

  DetailCheckInResponse(
      {this.master, this.listAlbum, this.statusCode, this.message});

  DetailCheckInResponse.fromJson(Map<String, dynamic> json) {
    if (json['master'] != null) {
      master = <DetailCheckInMaster>[];
      json['master'].forEach((v) {
        master!.add( DetailCheckInMaster.fromJson(v));
      });
    }
    if (json['listAlbum'] != null) {
      listAlbum = <ListAlbum>[];
      json['listAlbum'].forEach((v) {
        listAlbum!.add( ListAlbum.fromJson(v));
      });
    }
    if (json['listTicket'] != null) {
      listTicket = <ListAlbumTicketOffLine>[];
      json['listTicket'].forEach((v) {
        listTicket!.add( ListAlbumTicketOffLine.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (master != null) {
      data['master'] = master!.map((v) => v.toJson()).toList();
    }
    if (listAlbum != null) {
      data['listAlbum'] = listAlbum!.map((v) => v.toJson()).toList();
    }
    if (listTicket != null) {
      data['listTicket'] = listTicket!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class DetailCheckInMaster {
  int? id;
  String? tieuDe;
  String? ngayCheckin;
  String? maKh;
  String? tenKh;
  String? tenCh;
  String? diaChi;
  String? dienThoai;
  String? gps;
  String? trangThai;
  String? tgHoanThanh;
  double? hanMucCn;
  dynamic timeCheckOut;

  DetailCheckInMaster(
      {this.id,
        this.tieuDe,
        this.ngayCheckin,
        this.maKh,
        this.tenKh,
        this.tenCh,
        this.diaChi,
        this.dienThoai,
        this.gps,
        this.trangThai,
        this.tgHoanThanh,
        this.hanMucCn,
        this.timeCheckOut});

  DetailCheckInMaster.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    tieuDe = json['tieu_de'];
    ngayCheckin = json['ngay_checkin'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    tenCh = json['ten_ch'];
    diaChi = json['dia_chi'];
    dienThoai = json['dien_thoai'];
    gps = json['gps'];
    trangThai = json['trang_thai'];
    tgHoanThanh = json['tg_hoan_thanh'];
    hanMucCn = json['han_muc_cn'];
    timeCheckOut = json['tg_checkout'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id'] = id;
    data['tieu_de'] = tieuDe;
    data['ngay_checkin'] = ngayCheckin;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['ten_ch'] = tenCh;
    data['dia_chi'] = diaChi;
    data['dien_thoai'] = dienThoai;
    data['gps'] = gps;
    data['trang_thai'] = trangThai;
    data['tg_hoan_thanh'] = tgHoanThanh;
    data['han_muc_cn'] = hanMucCn;
    data['tg_checkout'] = timeCheckOut;
    return data;
  }
}

class ListAlbum {
  String? maAlbum;
  String? tenAlbum;
  bool? ycAnhYn;

  ListAlbum({this.maAlbum, this.tenAlbum, this.ycAnhYn});

  ListAlbum.fromJson(Map<String, dynamic> json) {
    maAlbum = json['ma_album'];
    tenAlbum = json['ten_album'];
    ycAnhYn = json['yc_anh_yn'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_album'] = maAlbum;
    data['ten_album'] = tenAlbum;
    data['yc_anh_yn'] = ycAnhYn;
    return data;
  }
}

class ListAlbumTicketOffLine {
  dynamic maTicket;
  String? tenTicket;

  ListAlbumTicketOffLine({this.maTicket, this.tenTicket});

  ListAlbumTicketOffLine.fromJson(Map<String, dynamic> json) {
    maTicket = json['ticket_id'];
    tenTicket = json['ten_loai'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ticket_id'] = maTicket;
    data['ten_loai'] = tenTicket;
    return data;
  }
}

