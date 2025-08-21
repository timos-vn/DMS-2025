import 'dart:io';

import 'package:flutter/material.dart';

class InventoryControlAndSaleOutRequest {
  InventoryControlAndSaleOutRequestData? data;

  InventoryControlAndSaleOutRequest({this.data});

  InventoryControlAndSaleOutRequest.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ?  InventoryControlAndSaleOutRequestData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class InventoryControlAndSaleOutRequestData {
  String? customerID;
  String? customerAddress;
  String? orderDate;
  String? idCheckIn;
  String? agentId;
  String? desc;
  String? dateEstDelivery;
  int? typePayment;
  List<ProductStore>? detail;

  InventoryControlAndSaleOutRequestData({this.customerID, this.orderDate, this.idCheckIn,
    this.detail, this.customerAddress,this.agentId, this.desc, this.dateEstDelivery,this.typePayment});

  InventoryControlAndSaleOutRequestData.fromJson(Map<String, dynamic> json) {
    customerID = json['CustomerID'];
    orderDate = json['OrderDate'];
    idCheckIn = json['idCheckIn'];
    desc = json['description'];
    dateEstDelivery = json['dateEstDelivery'];

    customerAddress = json['CustomerAddress'];
    agentId = json['AgentID'];
    if (json['Detail'] != null) {
      detail = <ProductStore>[];
      json['Detail'].forEach((v) {
        detail!.add( ProductStore.fromJson(v));
      });
    }
    typePayment = json['typePayment'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['CustomerID'] = customerID;
    data['OrderDate'] = orderDate;
    data['idCheckIn'] = idCheckIn;
    data['CustomerAddress'] = customerAddress;
    data['AgentID'] = agentId;
    data['description'] = desc;
    data['dateEstDelivery'] = dateEstDelivery;data['typePayment'] = typePayment;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductStore {
  String? codeProduct;
  String? nameProduct;
  double? inventoryNumber;
  double? price;
  int? isDiscount;
  String? dvt;
  Color? kColorFormatAlphaB;

  ProductStore({this.codeProduct, this.nameProduct, this.inventoryNumber,this.dvt,this.kColorFormatAlphaB, this.price,this.isDiscount});

  ProductStore.fromJson(Map<String, dynamic> json) {
    codeProduct = json['CodeProduct'];
    nameProduct = json['NameProduct'];
    price = json['Price'];
    isDiscount = json['IsDiscount'];
    inventoryNumber = json['Number'];
    dvt = json['dvt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['CodeProduct'] = codeProduct;
    data['NameProduct'] = nameProduct;
    data['Number'] = inventoryNumber;
    data['Price'] = price;
    data['IsDiscount'] = isDiscount;
    data['dvt'] = dvt;
    return data;
  }
}

class AlbumInStore {
  String? pathImage;
  String? codeImage;
  String? nameImage;
  String? idAlbum;
  File? fileAlbum;

  AlbumInStore({this.pathImage, this.codeImage, this.nameImage,this.idAlbum,this.fileAlbum});

  AlbumInStore.fromJson(Map<String, dynamic> json) {
    pathImage = json['Path'];
    codeImage = json['CodeImage'];
    nameImage = json['NameImage'];
    idAlbum = json['IdAlbum'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['Path'] = pathImage;
    data['CodeImage'] = codeImage;
    data['NameImage'] = nameImage;
    data['IdAlbum'] = idAlbum;
    return data;
  }
}

