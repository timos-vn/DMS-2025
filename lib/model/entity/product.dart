import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Product extends Equatable {
  String? code;
  String? maVt2;
  String? name;
  String? name2;
  String? dvt;
  String? description;
  double? price = 0;
  double? priceAfterTax;
  double? valuesTax;
  double? discountPercent;
  double? priceAfter;
  double? stockAmount;
  double? taxPercent;
  String? imageUrl;
  double? count = 0;
  double? countMax = 0;
  double so_luong_kd = 0;
  int? isMark = 0;
  String? discountMoney;
  String? discountProduct;
  String? budgetForItem;
  String? budgetForProduct;
  double? residualValueProduct;
  double? residualValue;
  String? unit;
  String? unitProduct;
  String? dsCKLineItem;
  int? allowDvt;
  String? contentDvt;
  int? kColorFormatAlphaB;
  String? codeStock;
  String? nameStock;
  String? idVv;
  String? idHd;
  String? nameVv;
  String? nameHd;
  String? maVtGoc;
  String? sctGoc;
  int? editPrice;
  int isCheBien = 0;
  int isSanXuat = 0;
  double giaSuaDoi = 0;
  double giaGui = 0;
  double priceMin = 0;
  String? codeUnit;
  String? nameUnit;
  String? note;
  String? jsonOtherInfo;
  String? heSo;
  String? idNVKD;
  String? nameNVKD;
  String?  nuocsx;
  String?  quycach;
  String? maThue ;
  String? tenThue ;
  dynamic thueSuat;
  int? applyPriceAfterTax = 0;
  int? discountByHand = 0;
  double? discountPercentByHand = 0;
  double? ckntByHand = 0;
  double? priceOk = 0;
  double? woPrice = 0;
  double? woPriceAfter = 0;
  String? sttRec0;


  Product({this.code,this.maVt2 = '', this.name, this.name2, this.dvt, this.description, this.price = 0,this.priceAfterTax,this.valuesTax,
    this.discountPercent, this.imageUrl, this.priceAfter, this.stockAmount,this.count,this.countMax,this.so_luong_kd = 0,this.isMark,
    this.discountMoney,this.discountProduct,this.budgetForItem,this.budgetForProduct,this.residualValueProduct,this.residualValue,
    this.unit,this.unitProduct,this.dsCKLineItem, this.taxPercent, this.allowDvt, this.contentDvt,this.kColorFormatAlphaB,
    this.codeStock,this.nameStock, this.idVv, this.idHd, this.nameVv, this.nameHd,this.maVtGoc,this.sctGoc, this.editPrice,
    this.isCheBien = 0, this.isSanXuat = 0, this.giaSuaDoi = 0, this.giaGui = 0,this.priceMin = 0, this.codeUnit,this.nameUnit,this.note,this.jsonOtherInfo,this.heSo,
    this.idNVKD,this.nameNVKD,this.nuocsx,this.quycach,this.maThue,this.tenThue,this.thueSuat,
    this.applyPriceAfterTax,this.discountByHand,this.discountPercentByHand,this.ckntByHand,this.priceOk,this.woPrice,this.woPriceAfter,this.sttRec0,
  });


  Product.fromDb(Map<String, dynamic> map) :
        maThue = map['maThue'],
        tenThue = map['tenThue'],
        thueSuat = map['thueSuat'],
        code = map['code'],
        maVt2 = map['maVt2'],
        name = map['name'],
        name2 = map['name2'],
        dvt = map['dvt'],
        description = map['description'],
        price = map['price'],
        discountPercent = map['discountPercent'],
        imageUrl = map['imageUrl'],
        priceAfter = map['priceAfter'],
        stockAmount = map['stockAmount'],
        taxPercent = map['taxPercent'],
        count = map['count'],
        countMax = map['countMax'],
        so_luong_kd = map['so_luong_kd'],
        sttRec0 = map['sttRec0'],
        budgetForItem = map['budgetForItem'],
        residualValueProduct = map['residualValueProduct'],
        residualValue = map['residualValue'],
        isMark = map['isMark'],
        discountMoney = map['discountMoney'],
        discountProduct = map['discountProduct'],
        unit = map['unit'],
        dsCKLineItem = map['dsCKLineItem'],
        budgetForProduct = map['budgetForProduct'],
        unitProduct = map['unitProduct'],
        allowDvt = map['nhieu_dvt'],
        contentDvt = map['ndvt'],
        kColorFormatAlphaB = map['kColorFormatAlphaB'],
        codeStock = map['codeStock'],
        nameStock = map['nameStock'],
        idVv = map['idVv'],
        idHd = map['idHd'],
        nameVv = map['nameVv'],
        nameHd = map['nameHd'],
        editPrice = map['editPrice'],
        isCheBien = map['isCheBien'],
        isSanXuat = map['isSanXuat'],
        giaSuaDoi = map['giaSuaDoi'],
        giaGui = map['giaGui'],
        priceMin = map['priceMin'],
        codeUnit = map['codeUnit'],
        nameUnit = map['nameUnit'],
        note = map['note'],
        jsonOtherInfo = map['jsonOtherInfo'],
        heSo = map['heSo'],
        idNVKD = map['idNVKD'],
        nameNVKD = map['nameNVKD'],
        nuocsx = map['nuocsx'],
        quycach = map['quycach'],
        applyPriceAfterTax = map['applyPriceAfterTax'],
        discountByHand = map['discountByHand'],
        discountPercentByHand = map['discountPercentByHand'],
        ckntByHand = map['ckntByHand'],
        priceOk = map['priceOk'],
        woPrice = map['woPrice'],
        woPriceAfter = map['woPriceAfter'];

  Map<String, dynamic> toMapForDb() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['maThue'] = maThue;
    data['tenThue'] = tenThue;
    data['thueSuat'] = thueSuat;
    data['idVv'] = idVv;
    data['idHd'] = idHd;
    data['nameVv'] = nameVv;
    data['nameHd'] = nameHd;
    data['code'] = code;
    data['maVt2'] = maVt2;
    data['name'] = name;
    data['name2'] = name2;
    data['dvt'] = dvt;
    data['description'] = description;
    data['price'] = price;
    data['discountPercent'] = discountPercent;
    data['imageUrl'] = imageUrl;
    data['priceAfter'] = priceAfter;
    data['stockAmount'] = stockAmount;
    data['taxPercent'] = taxPercent;
    data['isMark'] = isMark;
    data['count'] = count;
    data['countMax'] = countMax;
    data['so_luong_kd'] = so_luong_kd;
    data['sttRec0'] = sttRec0;
    data['discountMoney'] = discountMoney;
    data['discountProduct'] = discountProduct;
    data['budgetForItem'] = budgetForItem;
    data['residualValueProduct'] = residualValueProduct;
    data['residualValue'] = residualValue;
    data['unit'] = unit;
    if(dsCKLineItem!=null){
      data['dsCKLineItem'] = dsCKLineItem;
    }else {
      data['dsCKLineItem'] = [];
    }
    data['budgetForProduct'] = budgetForProduct;
    data['unitProduct'] = unitProduct;
    data['nhieu_dvt'] = allowDvt;
    data['ndvt'] = contentDvt;
    data['kColorFormatAlphaB'] = kColorFormatAlphaB;
    data['codeStock'] = codeStock;
    data['nameStock'] = nameStock;
    data['editPrice'] = editPrice;
    data['isCheBien'] = isCheBien;
    data['isSanXuat'] = isSanXuat;
    data['giaSuaDoi'] = giaSuaDoi;
    data['giaGui'] = giaGui;
    data['priceMin'] = priceMin;
    data['codeUnit'] = codeUnit;
    data['nameUnit'] = nameUnit;
    data['note'] = note;
    data['jsonOtherInfo'] = jsonOtherInfo;
    data['heSo'] = heSo;
    data['idNVKD'] = idNVKD;
    data['nameNVKD'] = nameNVKD;
    data['nuocsx'] = nuocsx;
    data['quycach'] = quycach;
    data['applyPriceAfterTax'] = applyPriceAfterTax;
    data['discountByHand'] = discountByHand;
    data['discountPercentByHand'] = discountPercentByHand;
    data['ckntByHand'] = ckntByHand;
    data['priceOk'] = priceOk;
    data['woPrice'] = woPrice;
    data['woPriceAfter'] = woPriceAfter;
    return data;
  }


  @override
  List<Object> get props => [
   code!,
   maVt2.toString(),
   name!,
   name2!,
   dvt!,
   description!,
   price!,
   discountPercent!,
   priceAfter!,
   stockAmount!,
   taxPercent!,
   count!,
    countMax!,
    so_luong_kd,
   sttRec0!,
   isMark!,
    imageUrl!,
   discountMoney!,
   discountProduct!,
   budgetForItem!,
   budgetForProduct!,
   residualValueProduct!,
   residualValue!,
   unit!,
   unitProduct!,
   dsCKLineItem!,
    kColorFormatAlphaB!,
    codeStock!,
    nameStock!,
    idVv!,
    idHd!,
    nameVv!,
    nameHd!,
    editPrice!,
    isSanXuat,
    isCheBien,
    giaSuaDoi,
    giaGui,
    priceMin,
    codeUnit.toString(),
    nameUnit.toString(),
    note.toString(),
    jsonOtherInfo.toString(),
    heSo!,
    idNVKD.toString(),
    nameNVKD.toString(),
    nuocsx.toString(),
    quycach.toString(),
    maThue.toString(),
    tenThue.toString(),
    thueSuat!,
    applyPriceAfterTax!,
    discountByHand!,
    discountPercentByHand!,
    ckntByHand!,
     priceOk!,
     woPrice!,
     woPriceAfter!,
   ];
}
