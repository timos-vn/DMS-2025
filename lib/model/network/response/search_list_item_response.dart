import 'package:flutter/material.dart';

import 'apply_discount_response.dart';

class SearchListItemResponse {
  String? message;
  int? statusCode;
  List<SearchItemResponseData>? data;
  int? pageIndex;
  int? totalCount;

  SearchListItemResponse({this.message, this.statusCode, this.data, this.pageIndex});

  SearchListItemResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];

    statusCode = json['statusCode'];
    pageIndex = json['pageIndex'];
    totalCount = json['totalCount'];

    if (json['data'] != null) {
      data = <SearchItemResponseData>[];
      for (var v in (json['data'] as List)) {
        data!.add( SearchItemResponseData.fromJson(v));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['totalCount'] = totalCount;
    data['message'] = message;
    data['pageIndex'] = pageIndex;
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SearchItemResponseData {
  String? code;
  String? sttRec0;
  String? name;
  String? name2;
  String? dvt;
  String? descript;
  double? price = 0;
  double? priceAfterTax = 0;
  double? valuesTax = 0;
  bool? applyPriceAfterTax = false;
  double? woPrice = 0;
  double? woPriceAfter = 0;
  double? priceOk = 0;
  double? discountPercent = 0;
  double? priceAfter = 0;
  double? priceAfter2 = 0;
  double? stockAmount = 0;
  double? totalMoneyProduct = 0;
  double? totalMoneyDiscount = 0;
  double? taxPercent;
  String? imageUrl;
  double? count = 0;
  double? countMax = 0;
  int? isMark = 1;
  String? discountMoney;
  String? discountProduct;
  String? budgetForItem;
  String? budgetForProduct;
  double? residualValueProduct = 0;
  double? residualValue = 0;
  String? unit;
  String? unitProduct;
  String? maCk;
  String? maCkOld;
  bool? allowDvt;
  String? contentDvt;
  Color? kColorFormatAlphaB;
  List<ListCk>? listDiscount;
  List<ListCkMatHang>? listDiscountProduct;
  String? maVtGoc;
  String? sctGoc;
  double ck=0;
  double? cknt;
  String? sttRecCK;
  String? typeCK;
  bool? gifProduct = false;
  bool? gifProductByHand = false;
  bool? discountByHand = false;
  double discountPercentByHand = 0;
  double? ckntByHand = 0;
  String? stockCode;
  String? stockName;
  bool? chooseVuViec;
  String? idVv;
  String? idHd;
  String? nameVv;
  String? nameHd;
  String? idHdForVv;
  bool? isCheBien;
  bool? isSanXuat;
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
  String? nuocsx;
  String? quycach;
  bool? isChecked = false;
  String? maThue;
  String? tenThue;
  double? thueSuat = 0;
  String? maVt2; // Mã vật tư 2 (dùng cho contract)
  double so_luong_kd = 0; // Số lượng cho phép đặt hàng (dùng cho contract)

  SearchItemResponseData({ this.code,this.sttRec0, this.name, this.name2, this.dvt, this.descript, this.price = 0,this.applyPriceAfterTax,this.priceAfterTax,this.woPrice,
    this.woPriceAfter,this.totalMoneyDiscount,this.totalMoneyProduct,this.valuesTax,
    this.discountPercent, this.imageUrl, this.priceAfter, this.stockAmount,this.count,this.countMax = 0,this.isMark,this.taxPercent,this.priceOk,
    this.discountMoney,this.discountProduct,this.budgetForItem,this.budgetForProduct,this.residualValueProduct,this.residualValue,this.priceAfter2,
    this.unit,this.unitProduct,this.maCk, this.maCkOld, this.allowDvt, this.contentDvt,this.kColorFormatAlphaB,this.listDiscount,this.maVtGoc,this.listDiscountProduct,
    this.ck = 0,this.cknt, this.sttRecCK,this.typeCK, this.gifProduct, this.gifProductByHand, this.discountByHand,this.discountPercentByHand = 0,
    this.stockCode, this.stockName, this.chooseVuViec, this.idHd, this.idVv,this.nameVv,this.nameHd, this.idHdForVv,this.sctGoc,
    this.isCheBien, this.isSanXuat, this.giaSuaDoi = 0, this.giaGui = 0, this.priceMin = 0, this.codeUnit, this.nameUnit, this.note, this.jsonOtherInfo,
    this.isChecked, this.heSo,this.idNVKD,this.nameNVKD,this.nuocsx,this.quycach,this.maThue,this.tenThue,this.thueSuat = 0, this.maVt2, this.so_luong_kd = 0
  });

  SearchItemResponseData.fromJson(Map<String, dynamic> json) {
    maThue = json['ma_thue'];
    tenThue = json['ten_thue'];
    thueSuat = json['thue_suat'];

    code = json['code'];
    sttRec0 = json['sttRec0'];
    name = json['name'];
    name2 = json['name2'];
    dvt = json['dvt'];

    descript = json['descript'];
    price = json['price'];
    woPrice = json['wo_price'];
    woPriceAfter = json['wo_priceAfter'];
    discountPercent = json['discountPercent'];
    imageUrl = json['imageUrl'];
    priceAfter = json['priceAfter'];
    stockAmount = json['stockAmount'];
    taxPercent = json['taxPercent'];
    taxPercent = json['taxPercent'];
    count = json['count'];
    budgetForItem = json['ten_ns'];
    residualValueProduct = json['gt_cl_product'];
    residualValue = json['gt_cl'];
    unit = json['loai_ct'];
    maCk = json['ma_ck'];
    budgetForProduct = json['ten_ns_product'];
    unitProduct = json['loai_ct_product'];
    allowDvt = json['nhieu_dvt'];
    contentDvt = json['ndvt'];
    nuocsx = json['nuoc_sx'];
    quycach = json['quy_cach'];
    
    // Contract fields
    maVt2 = json['ma_vt2'];
    so_luong_kd = (json['so_luong_kd'] as num?)?.toDouble() ?? 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['ma_thue'] = maThue;
    data['ten_thue'] = tenThue;
    data['thue_suat'] = thueSuat;

    data['nuoc_sx'] = nuocsx;
    data['quy_cach'] = quycach;
    data['code'] = code;
    data['sttRec0'] = sttRec0;
    data['name'] = name;
    data['name2'] = name2;
    data['dvt'] = dvt;
    data['descript'] = descript;
    data['price'] = price;
    data['wo_price'] = woPrice;
    data['wo_priceAfter'] = woPriceAfter;
    data['discountPercent'] = discountPercent;
    data['imageUrl'] = imageUrl;
    data['priceAfter'] = priceAfter;
    data['stockAmount'] = stockAmount;
    data['count'] = count;
    data['ten_ns'] = budgetForItem;
    data['gt_cl_product'] = residualValueProduct;
    data['gt_cl'] = residualValue;
    data['loai_ct'] = unit;
    data['ma_ck'] = maCk;

    data['ten_ns_product'] = budgetForProduct;
    data['loai_ct_product'] = unitProduct;
    data['nhieu_dvt'] = allowDvt;
    data['ndvt'] = contentDvt;
    
    // Contract fields
    data['ma_vt2'] = maVt2;
    data['so_luong_kd'] = so_luong_kd;
    return data;
  }
}


class SearchItemResponse {
  List<SearchItemResponseDataOrder>? data;
  int? totalPage;
  int? statusCode;
  dynamic message;

  SearchItemResponse(
      {this.data, this.totalPage, this.statusCode, this.message});

  SearchItemResponse.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <SearchItemResponseDataOrder>[];
      json['data'].forEach((v) {
        data!.add(new SearchItemResponseDataOrder.fromJson(v));
      });
    }
    totalPage = json['totalPage'];
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalPage'] = this.totalPage;
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class SearchItemResponseDataOrder {
  String? name;
  String? values;

  SearchItemResponseDataOrder({this.name, this.values});

  SearchItemResponseDataOrder.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    values = json['values'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['values'] = this.values;
    return data;
  }
}