import 'detail_checkin_response.dart';
import 'list_checkin_response.dart';

class ListTaskOfflineResponse {
  List<ListCheckIn>? listCheckInToDay;
  List<ListAlbum>? listAlbum;
  List<ListAlbumTicketOffLine>? listTicket;
  int? statusCode;
  String? message;

  ListTaskOfflineResponse(
      {this.listCheckInToDay,
        this.listAlbum,
        this.listTicket,
        this.statusCode,
        this.message});

  ListTaskOfflineResponse.fromJson(Map<String, dynamic> json) {
    if (json['listCustomer'] != null) {
      listCheckInToDay = <ListCheckIn>[];
      json['listCustomer'].forEach((v) {
        listCheckInToDay!.add( ListCheckIn.fromJson(v));
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
    if (listCheckInToDay != null) {
      data['listCustomer'] = listCheckInToDay!.map((v) => v.toJson()).toList();
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

// class ListCustomer {
//   int? id;
//   String? tieuDe;
//   String? ngayCheckin;
//   String? maKh;
//   String? tenCh;
//   String? diaChi;
//   String? dienThoai;
//   String? gps;
//   String? trangThai;
//   String? tgHoanThanh;
//   String? album;
//   String? lastChko;
//   String? latlong;
//
//
//   ListCustomer(
//       {this.id,
//         this.tieuDe,
//         this.ngayCheckin,
//         this.maKh,
//         this.tenCh,
//         this.diaChi,
//         this.dienThoai,
//         this.gps,
//         this.trangThai,
//         this.tgHoanThanh,
//         this.album,
//         this.lastChko,
//         this.latlong,
//         });
//
//   ListCustomer.fromJson(Map<String, dynamic> json) {
//     id = json['id'];
//     tieuDe = json['tieu_de'];
//     ngayCheckin = json['ngay_checkin'];
//     maKh = json['ma_kh'];
//     tenCh = json['ten_ch'];
//     diaChi = json['dia_chi'];
//     dienThoai = json['dien_thoai'];
//     gps = json['gps'];
//     trangThai = json['trang_thai'];
//     tgHoanThanh = json['tg_hoan_thanh'];
//     album = json['album'];
//     lastChko = json['last_chko'];
//     latlong = json['latlong'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  <String, dynamic>{};
//     data['id'] = id;
//     data['tieu_de'] = tieuDe;
//     data['ngay_checkin'] = ngayCheckin;
//     data['ma_kh'] = maKh;
//     data['ten_ch'] = tenCh;
//     data['dia_chi'] = diaChi;
//     data['dien_thoai'] = dienThoai;
//     data['gps'] = gps;
//     data['trang_thai'] = trangThai;
//     data['tg_hoan_thanh'] = tgHoanThanh;
//     data['album'] = album;
//     data['last_chko'] = lastChko;
//     data['latlong'] = latlong;
//     return data;
//   }
// }

// class ListAlbum {
//   String? maAlbum;
//   String? tenAlbum;
//   bool? ycAnhYn;
//
//   ListAlbum({this.maAlbum, this.tenAlbum, this.ycAnhYn});
//
//   ListAlbum.fromJson(Map<String, dynamic> json) {
//     maAlbum = json['ma_album'];
//     tenAlbum = json['ten_album'];
//     ycAnhYn = json['yc_anh_yn'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  <String, dynamic>{};
//     data['ma_album'] = maAlbum;
//     data['ten_album'] = tenAlbum;
//     data['yc_anh_yn'] = ycAnhYn;
//     return data;
//   }
// }
//
// class ListTicket {
//   String? ticketId;
//   String? tenLoai;
//
//   ListTicket({this.ticketId, this.tenLoai});
//
//   ListTicket.fromJson(Map<String, dynamic> json) {
//     ticketId = json['ticket_id'];
//     tenLoai = json['ten_loai'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data =  <String, dynamic>{};
//     data['ticket_id'] = ticketId;
//     data['ten_loai'] = tenLoai;
//     return data;
//   }
// }