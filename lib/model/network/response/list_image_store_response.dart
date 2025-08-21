import 'dart:io';

import 'detail_checkin_response.dart';

class ListImageStoreResponse {
  List<ListImage>? listImage;
  List<ListAlbum>? listAlbum;
  int? statusCode;
  String? message;

  ListImageStoreResponse(
      {this.listImage, this.listAlbum, this.statusCode, this.message});

  ListImageStoreResponse.fromJson(Map<String, dynamic> json) {
    if (json['listImage'] != null) {
      listImage = <ListImage>[];
      json['listImage'].forEach((v) {
        listImage!.add( ListImage.fromJson(v));
      });
    }
    if (json['listAlbum'] != null) {
      listAlbum = <ListAlbum>[];
      json['listAlbum'].forEach((v) {
        listAlbum!.add( ListAlbum.fromJson(v));
      });
    }
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (listImage != null) {
      data['listImage'] = listImage!.map((v) => v.toJson()).toList();
    }
    if (listAlbum != null) {
      data['listAlbum'] = listAlbum!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class ListImage {
  String? pathL;
  String? maAlbum;
  String? tenAlbum;

  ListImage({this.pathL, this.maAlbum, this.tenAlbum});

  ListImage.fromJson(Map<String, dynamic> json) {
    pathL = json['path_l'];
    maAlbum = json['ma_album'];
    tenAlbum = json['ten_album'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['path_l'] = pathL;
    data['ma_album'] = maAlbum;
    data['ten_album'] = tenAlbum;
    return data;
  }
}

class ListImageFile {
  File? fileImage;
  String? maAlbum;
  String? tenAlbum;
  String? fileName;
  String id;
  bool isSync;

  ListImageFile({this.fileImage, this.maAlbum, this.tenAlbum,this.fileName, required this.id, required this.isSync});


  Map toJson() => {
    'fileName': fileName,
    'maAlbum': maAlbum,
  };
}