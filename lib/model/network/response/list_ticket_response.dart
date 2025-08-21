class ListTicketResponse {
  List<ListTicketResponseData>? data;
  int? statusCode;
  String? message;

  ListTicketResponse({this.data, this.statusCode, this.message});

  ListTicketResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <ListTicketResponseData>[];
      json['data'].forEach((v) {
        data!.add( ListTicketResponseData.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListTicketResponseData {
  String? maKh;
  String? tenKh;
  String? tenCv;
  String? tenNv;
  String? idTicketType;
  String? nameTicketType;
  String? noiDung;
  String? idTicket;
  String? thoiGian;
  String? status;
  int? userId0;
  List<ImageList>? imageList;

  ListTicketResponseData(
      {this.maKh,
        this.tenKh,
        this.tenCv,
        this.tenNv,
        this.idTicketType,
        this.nameTicketType,
        this.noiDung,
        this.idTicket,
        this.thoiGian,
        this.status,
        this.userId0,
        this.imageList});

  ListTicketResponseData.fromJson(Map<String, dynamic> json) {
    maKh = json['ma_kh'];
    tenKh = json['ten_kh'];
    tenCv = json['ten_cv'];
    tenNv = json['ten_nv'];
    idTicketType = json['id_ticket_type'];
    nameTicketType = json['name_ticket_type'];
    noiDung = json['noi_dung'];
    idTicket = json['id_ticket'];
    thoiGian = json['thoi_gian'];
    status = json['status'];
    userId0 = json['user_id0'];
    if (json['imageList'] != null) {
      imageList = <ImageList>[];
      json['imageList'].forEach((v) {
        imageList!.add( ImageList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_kh'] = maKh;
    data['ten_kh'] = tenKh;
    data['ten_cv'] = tenCv;
    data['ten_nv'] = tenNv;
    data['id_ticket_type'] = idTicketType;
    data['name_ticket_type'] = nameTicketType;
    data['noi_dung'] = noiDung;
    data['id_ticket'] = idTicket;
    data['thoi_gian'] = thoiGian;
    data['status'] = status;
    data['user_id0'] = userId0;
    if (imageList != null) {
      data['imageList'] = imageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageList {
  String? pathL;
  String? maAlbum;
  String? tenAlbum;
  String? maKh;
  String? keyValue;

  ImageList(
      {this.pathL, this.maAlbum, this.tenAlbum, this.maKh, this.keyValue});

  ImageList.fromJson(Map<String, dynamic> json) {
    pathL = json['path_l'];
    maAlbum = json['ma_album'];
    tenAlbum = json['ten_album'];
    maKh = json['ma_kh'];
    keyValue = json['key_value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['path_l'] = pathL;
    data['ma_album'] = maAlbum;
    data['ten_album'] = tenAlbum;
    data['ma_kh'] = maKh;
    data['key_value'] = keyValue;
    return data;
  }
}

