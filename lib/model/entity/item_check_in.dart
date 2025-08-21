// ignore_for_file: hash_and_equals

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../network/response/list_image_store_response.dart';

// ignore: must_be_immutable
// class ItemCheckIn extends Equatable {
//   String? id;
//   String? customerId;
//   String? title;
//   String? latLong;
//   String? address;
//   String? idCheckIn;
//   String? timeCheckIn;
//   String? openStore;
//   String? timeCheckOut;
//   String? nameStore;
//   String? note;
//
//   ItemCheckIn({this.id,this.customerId,this.title, this.latLong, this.address, this.idCheckIn,this.timeCheckIn,this.openStore,this.timeCheckOut,this.nameStore,this.note});
//
//   ItemCheckIn.fromDb(Map<String, dynamic> map) :
//         id = map['id'],
//         customerId = map['customerId'],title = map['title'],
//         latLong = map['latLong'],
//         address = map['address'],
//         idCheckIn = map['idCheckIn'],
//         timeCheckIn = map['timeCheckIn'],
//         timeCheckOut = map['timeCheckOut'],
//         openStore = map['openStore'],
//         nameStore = map['nameStore'],
//         note = map['note'];
//
//   Map<String, dynamic> toMapForDb() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['id'] = id; data['customerId'] = customerId;data['title'] = title;
//     data['latLong'] = latLong;
//     data['address'] = address;
//     data['idCheckIn'] = idCheckIn;
//     data['timeCheckIn'] = timeCheckIn;
//     data['openStore'] = openStore;
//     data['timeCheckOut'] = timeCheckOut;
//     data['nameStore'] = nameStore;
//     data['note'] = note;
//     return data;
//   }
//
//   @override
//   List<Object> get props => [
//     id!,customerId!,title!,
//     latLong!,
//     address!,
//     idCheckIn!,
//     timeCheckIn!,openStore!,timeCheckOut!,nameStore!,note!,
//   ];
// }

// ignore: must_be_immutable
class ItemCheckInOffline extends Equatable {
  String? id;
  String? tieuDe;
  String? ngayCheckin;
  String? maKh;
  String? tenCh;
  String? diaChi;
  String? dienThoai;
  String? gps;
  String? trangThai;
  String? tgHoanThanh;
  String? lastChko;
  String? latlong;
  String? dateSave;
  int? numberTimeCheckOut;
  String? timeCheckIn;
  String? timeCheckOut;
  String? openStore;
  String? note;
  String? idCheckIn;
  int? isCheckInSuccessful;
  int? isSynSuccessful;
  String? addressDifferent;
  double? latDifferent;
  double? longDifferent;

  ItemCheckInOffline({this.id,this.tieuDe,this.ngayCheckin, this.maKh, this.tenCh, this.diaChi,
    this.dienThoai,this.gps,this.trangThai,this.tgHoanThanh,this.lastChko, this.latlong, this.dateSave, this.numberTimeCheckOut,
    this.timeCheckOut,this.timeCheckIn, this.openStore,this.note, this.idCheckIn, this.isCheckInSuccessful,
    this.isSynSuccessful, this.addressDifferent, this.latDifferent, this.longDifferent
  });

  ItemCheckInOffline.fromDb(Map<String, dynamic> map) :
        id = map['id'],
        tieuDe = map['tieuDe'],
        ngayCheckin = map['ngayCheckin'],
        maKh = map['maKh'],
        tenCh = map['tenCh'],
        diaChi = map['diaChi'],
        dienThoai = map['dienThoai'],
        gps = map['gps'],
        trangThai = map['trangThai'],
        tgHoanThanh = map['tgHoanThanh'],
        lastChko = map['lastChko'],
        latlong = map['latlong'],
        dateSave = map['dateSave'],
        numberTimeCheckOut = map['numberTimeCheckOut'],
        idCheckIn = map['idCheckIn'],
        timeCheckIn = map['timeCheckIn'],
        timeCheckOut = map['timeCheckOut'],
        openStore = map['openStore'],
        isCheckInSuccessful = map['isCheckInSuccessful'],
        note = map['note'],
        isSynSuccessful = map['isSynSuccessful'],
        addressDifferent = map['addressDifferent'],
        latDifferent = map['latDifferent'],
        longDifferent = map['longDifferent'];

  Map<String, dynamic> toMapForDb() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['tieuDe'] = tieuDe;
    data['ngayCheckin'] = ngayCheckin;
    data['maKh'] = maKh;
    data['tenCh'] = tenCh;
    data['diaChi'] = diaChi;
    data['dienThoai'] = dienThoai;
    data['gps'] = gps;
    data['trangThai'] = trangThai;
    data['tgHoanThanh'] = tgHoanThanh;
    data['lastChko'] = lastChko;
    data['latlong'] = latlong;
    data['dateSave'] = dateSave;
    data['numberTimeCheckOut'] = numberTimeCheckOut;
    data['idCheckIn'] = idCheckIn;
    data['timeCheckIn'] = timeCheckIn;
    data['openStore'] = openStore;
    data['timeCheckOut'] = timeCheckOut;
    data['note'] = note;
    data['isCheckInSuccessful'] = isCheckInSuccessful;
    data['isSynSuccessful'] = isSynSuccessful;
    data['addressDifferent'] = addressDifferent;
    data['latDifferent'] = latDifferent;
    data['longDifferent'] = longDifferent;
    return data;
  }

  @override
  List<Object> get props => [
    id!,
    tieuDe!,
    ngayCheckin!,
    maKh!,
    tenCh!,
    diaChi!,
    dienThoai!,
    gps!,
    trangThai!,
    tgHoanThanh!,
    lastChko!,
    latlong!,
    dateSave!,
    numberTimeCheckOut!,
    timeCheckOut!,
    timeCheckIn!,
    idCheckIn!,
    openStore!,
    note!,isCheckInSuccessful!,isSynSuccessful!,addressDifferent!,latDifferent!,longDifferent!
  ];
}

// ignore: must_be_immutable
class ItemAlbum extends Equatable {
  String? maAlbum;
  String? tenAlbum;
  int? ycAnhYN;


  ItemAlbum({this.maAlbum,this.tenAlbum,this.ycAnhYN});

  ItemAlbum.fromDb(Map<String, dynamic> map) :
        maAlbum = map['maAlbum'],
        tenAlbum = map['tenAlbum'],
        ycAnhYN = map['ycAnhYN'];

  Map<String, dynamic> toMapForDb() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maAlbum'] = maAlbum;
    data['tenAlbum'] = tenAlbum;
    data['ycAnhYN'] = ycAnhYN;
    return data;
  }

  @override
  List<Object> get props => [
    maAlbum!,
    tenAlbum!,
    ycAnhYN!,
  ];
}


// ignore: must_be_immutable
class ItemTicket extends Equatable {
  String? ticketId;
  String? tenLoai;

  ItemTicket({this.ticketId,this.tenLoai});

  ItemTicket.fromDb(Map<String, dynamic> map) :
        ticketId = map['ticketId'],
        tenLoai = map['tenLoai'];

  Map<String, dynamic> toMapForDb() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ticketId'] = ticketId;
    data['tenLoai'] = tenLoai;
    return data;
  }

  @override
  List<Object> get props => [
    ticketId!,
    tenLoai!,
  ];
}

// ignore: must_be_immutable
class ItemListTicketOffLine extends Equatable {
  int? idIncrement;
  String? customerCode;
  String? idTicketType;
  String? nameTicketType;
  String? id;
  String? idCheckIn;
  String? comment;
  String? fileName;
  String? filePath;
  String? dateTimeCreate;
  String? status;
  List<String>? listFileTicket;

  ItemListTicketOffLine({this.idIncrement,this.customerCode,this.idTicketType,this.nameTicketType,this.id,this.idCheckIn,this.comment,this.fileName,this.filePath,this.dateTimeCreate,this.status, this.listFileTicket});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is ItemListTicketOffLine &&
              runtimeType == other.runtimeType &&
              id == other.id;

  ItemListTicketOffLine.fromDb(Map<String, dynamic> map) :
        idIncrement = map['idIncrement'],
        customerCode = map['customerCode'],
        idTicketType = map['idTicketType'],
        id = map['id'],
        idCheckIn = map['idCheckIn'],
        nameTicketType = map['nameTicketType'],
        comment = map['comment'],
        fileName = map['fileName'],
        filePath = map['filePath'],
        dateTimeCreate = map['dateTimeCreate'],
        status = map['status'];

  Map<String, dynamic> toMapForDb() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idIncrement'] = idIncrement;
    data['customerCode'] = customerCode;
    data['idTicketType'] = idTicketType;
    data['nameTicketType'] = nameTicketType;
    data['id'] = id;
    data['idCheckIn'] = idCheckIn;
    data['comment'] = comment;
    data['fileName'] = fileName;
    data['filePath'] = filePath;
    data['dateTimeCreate'] = dateTimeCreate;
    data['status'] = status;
    return data;
  }

  @override
  List<Object> get props => [
    idIncrement!,
    customerCode!,
    idTicketType!,
    nameTicketType!,
    id!,
    idCheckIn!,
    comment!,
    fileName!,
    filePath!,
    dateTimeCreate!,
    status!,
  ];
}
