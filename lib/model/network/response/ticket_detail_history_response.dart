class TicketDetailHistoryResponse {
  TicketDetailHistoryResponseData? data;
  int? statusCode;
  String? message;

  TicketDetailHistoryResponse({this.data, this.statusCode, this.message});

  TicketDetailHistoryResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ?  TicketDetailHistoryResponseData.fromJson(json['data']) : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class TicketDetailHistoryResponseData {
  int? id;
  String? feedBack;
  List<ImageListTicketDetailHistory>? imageList;

  TicketDetailHistoryResponseData({this.id, this.feedBack, this.imageList});

  TicketDetailHistoryResponseData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    feedBack = json['phan_hoi'];
    if (json['imageList'] != null) {
      imageList = <ImageListTicketDetailHistory>[];
      json['imageList'].forEach((v) {
        imageList!.add( ImageListTicketDetailHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =<String, dynamic>{};
    data['id'] = id;
    data['phan_hoi'] = feedBack;
    if (imageList != null) {
      data['imageList'] = imageList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ImageListTicketDetailHistory {
  String? code;
  String? pathL;
  String? maAlbum;
  String? tenAlbum;

  ImageListTicketDetailHistory({this.code, this.pathL, this.maAlbum, this.tenAlbum});

  ImageListTicketDetailHistory.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    pathL = json['path_l'];
    maAlbum = json['ma_album'];
    tenAlbum = json['ten_album'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['code'] = code;
    data['path_l'] = pathL;
    data['ma_album'] = maAlbum;
    data['ten_album'] = tenAlbum;
    return data;
  }
}

