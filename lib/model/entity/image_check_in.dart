import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ImageCheckIn extends Equatable {
  String? id;
  String? idCheckIn;
  String? maAlbum;
  String? tenAlbum;
  String? fileName;
  String? filePath;
  int isSync;

  ImageCheckIn({this.id,this.idCheckIn, this.maAlbum, this.tenAlbum, this.fileName,this.filePath, required this.isSync});

  ImageCheckIn.fromDb(Map<String, dynamic> map) :
        id = map['id'],
        idCheckIn = map['idCheckIn'],
        maAlbum = map['maAlbum'],
        tenAlbum = map['tenAlbum'],
        fileName = map['fileName'],
        filePath = map['filePath'],
        isSync = map['isSync'];

  Map<String, dynamic> toMapForDb() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['idCheckIn'] = idCheckIn;
    data['maAlbum'] = maAlbum;
    data['tenAlbum'] = tenAlbum;
    data['fileName'] = fileName;
    data['filePath'] = filePath;
    data['isSync'] = isSync;
    return data;
  }


  @override
  List<Object> get props => [
    id!,
    idCheckIn!,
    maAlbum!,
    tenAlbum!,
    fileName!,
    filePath!,
    isSync,
  ];
}
