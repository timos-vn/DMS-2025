class TicketHistoryResponse {
  List<TicketHistoryResponseData>? data;
  int? totalPage;
  int? statusCode;
  String? message;

  TicketHistoryResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  TicketHistoryResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <TicketHistoryResponseData>[];
      json['data'].forEach((v) {
        data!.add( TicketHistoryResponseData.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = totalPage;
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class TicketHistoryResponseData {
  String? idTicket;
  String? maKh;
  String? tenKh;
  String? maNv;
  String? tenNvbh;
  String? time;
  String? dienGiai;
  String? loaiTk;
  String? tenLoaiTk;

  TicketHistoryResponseData(
      {this.idTicket,
        this.maKh,
        this.tenKh,
        this.maNv,
        this.tenNvbh,
        this.time,
        this.dienGiai,
        this.loaiTk,
        this.tenLoaiTk});

  TicketHistoryResponseData.fromJson(Map<String, dynamic> json) {
    idTicket = json['id_ticket'];
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    maNv = json['ma_nv'];
    tenNvbh = json['ten_nvbh'];
    time = json['time'];
    dienGiai = json['dien_giai'];
    loaiTk = json['loai_tk'];
    tenLoaiTk = json['ten_loai_tk'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['id_ticket'] = idTicket;
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['ma_nv'] = maNv;
    data['ten_nvbh'] = tenNvbh;
    data['time'] = time;
    data['dien_giai'] = dienGiai;
    data['loai_tk'] = loaiTk;
    data['ten_loai_tk'] = tenLoaiTk;
    return data;
  }
}

