import '../../entity/entity.dart';
import '../response/search_list_item_response.dart';

class CreateOrderRequest{
  CreateOrderRequestBody? requestData;

  CreateOrderRequest({this.requestData});

  CreateOrderRequest.fromJson(Map<String, dynamic> json) {
    requestData = json['Data'] != null ?  CreateOrderRequestBody.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (requestData != null) {
      data['Data'] = requestData?.toJson();
    }
    return data;
  }
}

class CreateOrderRequestBody {
  String? customerCode;
  String? saleCode;
  String? orderDate;
  String? currency;
  String? stockCode;
  String? descript;
  String? phoneCustomer;
  String? addressCustomer;
  String? comment;
  String? idTransaction;
  List<DsCkTongDon>? dsCk;
  List<SearchItemResponseData>? listStore ;
  ItemTotalMoneyRequestData? listTotal;

  CreateOrderRequestBody({ this.customerCode, this.saleCode,this.orderDate,this.currency,this.stockCode,this.descript,this.phoneCustomer,this.addressCustomer,this.comment,this.idTransaction,this.dsCk,this.listStore,this.listTotal});

  CreateOrderRequestBody.fromJson(Map<String, dynamic> json) {

    customerCode = json['CustomerCode'];
    saleCode = json['SaleCode'];
    orderDate = json['OrderDate'];
    currency = json['Currency'];
    stockCode = json['StockCode'];
    descript = json['Descript'];
    phoneCustomer = json['PhoneCustomer'];
    addressCustomer = json['AddressCustomer'];
    comment = json['Comment'];
    idTransaction = json['IdTransaction'];
    if(dsCk!=null){
      dsCk = json['ds_ck'];
    }else{
      dsCk = [];
    }
    listStore = json['Detail'];
    listTotal = json['Total'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['CustomerCode'] = customerCode;
    data['SaleCode'] = saleCode;
    data['OrderDate'] = orderDate;
    data['Currency'] = currency;
    data['StockCode'] = stockCode;
    data['Descript'] = descript;
    data['PhoneCustomer'] = phoneCustomer;
    data['AddressCustomer'] = addressCustomer;
    data['Comment'] = comment;
    data['IdTransaction'] = idTransaction;
    if(dsCk != null){
      data['ds_ck'] = dsCk;
    }else {
      data['ds_ck'] = [];
    }
    data['Detail'] = listStore;
    data['Total'] = listTotal;
    return data;
  }
}

class DsCkTongDon {
  String? maCk;
  double? tCkTt;
  int? kieuCk;

  DsCkTongDon({this.maCk, this.tCkTt, this.kieuCk});

  DsCkTongDon.fromJson(Map<String, dynamic> json) {
    maCk = json['ma_ck'];
    tCkTt = json['t_ck_tt'];
    kieuCk = json['kieu_ck'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ma_ck'] = maCk;
    data['t_ck_tt'] = tCkTt;
    data['kieu_ck'] = kieuCk;
    return data;
  }
}

class ItemTotalMoneyRequestData {
  String? totalMNProduct;
  String? totalMNDiscount;
  String? totalMNPayment;
  String? preAmount;
  String? discount;

  ItemTotalMoneyRequestData({ this.totalMNProduct, this.totalMNDiscount, this.totalMNPayment,this.preAmount,this.discount});

  ItemTotalMoneyRequestData.fromJson(Map<String, dynamic> json) {
    totalMNProduct = json['TotalMNProduct'];
    totalMNDiscount = json['TotalMNDiscount'];
    totalMNPayment = json['TotalMnPayment'];
    preAmount = json['PreAmount'];
    discount = json['Discount'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['TotalMNProduct'] = totalMNProduct;
    data['TotalMNDiscount'] = totalMNDiscount;
    data['TotalMnPayment'] = totalMNPayment;
    data['PreAmount'] = preAmount;
    data['Discount'] = discount;
    return data;
  }
}


class CreateOrderV3Request {
  CreateOrderV3RequestData? requestData;

  CreateOrderV3Request({this.requestData});

  CreateOrderV3Request.fromJson(Map<String, dynamic> json) {
    requestData = json['Data'] != null ?  CreateOrderV3RequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (requestData != null) {
      data['Data'] = requestData!.toJson();
    }
    return data;
  }
}

class CreateOrderV3RequestData {
  String? customerCode;
  String? saleCode;
  String? orderDate;
  String? currency;
  String? stockCode;
  String? description;
  String? phoneCustomer;
  String? addressCustomer;
  String? comment;
  String? idTransaction;
  String? idVv;
  String? idHd;
  String? codeAgency;
  double? discountPercentAgency;
  String? codeTypePayment;
  double? discountPercentTypePayment;
  String? datePayment;
  String? dateEstDelivery;
  int? orderStatus;
  String? typeDelivery;
  List<DetailOrderV3>? detail;
  List<DsCkTongDon>? dsCk;
  TotalCreateOrderV3? total;
  String? nameCompany;
  String? mstCompany;
  String? addressCompany;
  String? noteCompany;
  String? idTypeOrder;

  String? idDVTC;
  String? idNguoiNhan;
  String? ghiChuKM;
  String? idMDC;
  String? thoiGianGiao;
  String? tien;
  String? baoGia;
  String? sttRecHD;

  CreateOrderV3RequestData(
      {this.customerCode, this.idDVTC,this.idNguoiNhan,     this.ghiChuKM,this.idMDC,     this.thoiGianGiao,this.tien,this.baoGia,
        this.sttRecHD,
        this.saleCode,
        this.orderDate,
        this.currency,
        this.stockCode,
        this.description,
        this.phoneCustomer,
        this.addressCustomer,
        this.comment,
        this.idTransaction,
        this.detail,
        this.dsCk,
        this.total, this.idVv,this.idHd, this.discountPercentAgency,this.datePayment,
        this.discountPercentTypePayment,this.codeAgency,this.codeTypePayment,this.orderStatus,this.dateEstDelivery,
        this.nameCompany, this.mstCompany,
        this.addressCompany, this.noteCompany, this.typeDelivery,this.idTypeOrder});

  CreateOrderV3RequestData.fromJson(Map<String, dynamic> json) {
    customerCode = json['CustomerCode'];  idDVTC = json['s2'];  thoiGianGiao = json['delivery_time'];
    idNguoiNhan = json['fnote1'];  tien = json['payment'];
    ghiChuKM = json['ghi_chu'];  baoGia = json['quotation_validily'];
    idMDC = json['ma_dc'];
    saleCode = json['SaleCode'];
    orderDate = json['OrderDate'];
    currency = json['Currency'];
    stockCode = json['StockCode'];
    description = json['Descript'];
    phoneCustomer = json['PhoneCustomer'];
    addressCustomer = json['AddressCustomer'];
    comment = json['Comment'];
    idTransaction = json['IdTransaction'];
    idVv = json['idVv'];
    idHd = json['idHd'];
    discountPercentAgency = json['discountPercentAgency'];
    discountPercentTypePayment = json['discountPercentTypePayment'];
    typeDelivery = json['typeDelivery'];

    codeAgency = json['codeAgency'];
    codeTypePayment = json['codeTypePayment'];
    datePayment = json['datePayment'];
    orderStatus = json['orderStatus'];dateEstDelivery = json['dateEstDelivery'];
    if (json['Detail'] != null) {
      detail = <DetailOrderV3>[];
      json['Detail'].forEach((v) {
        detail!.add( DetailOrderV3.fromJson(v));
      });
    }
    if (json['ds_ck'] != null) {
      dsCk = <DsCkTongDon>[];
      json['ds_ck'].forEach((v) {
        dsCk!.add( DsCkTongDon.fromJson(v));
      });
    }
    total = json['Total'] != null ? TotalCreateOrderV3.fromJson(json['Total']) : null;
    nameCompany = json['nameCompany'];
    mstCompany = json['mstCompany'];
    addressCompany = json['addressCompany'];
    noteCompany = json['noteCompany'];
    idTypeOrder = json['idTypeOrder'];
    sttRecHD = json['sttRecHD'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['CustomerCode'] = customerCode;  data['s2'] = idDVTC;data['delivery_time'] = thoiGianGiao;
    data['fnote1'] = idNguoiNhan;data['payment'] = tien;
    data['ghi_chu'] = ghiChuKM;data['quotation_validily'] = baoGia;
    data['ma_dc'] = idMDC;

    data['SaleCode'] = saleCode;
    data['OrderDate'] = orderDate;
    data['Currency'] = currency;
    data['StockCode'] = stockCode;
    data['Descript'] = description;
    data['PhoneCustomer'] = phoneCustomer;
    data['AddressCustomer'] = addressCustomer;
    data['Comment'] = comment;
    data['IdTransaction'] = idTransaction;
    data['idVv'] = idVv;
    data['idHd'] = idHd;

    data['discountPercentAgency'] = discountPercentAgency;
    data['discountPercentTypePayment'] = discountPercentTypePayment;
    data['codeAgency'] = codeAgency;
    data['codeTypePayment'] = codeTypePayment;
    data['datePayment'] = datePayment;
    data['orderStatus'] = orderStatus;data['dateEstDelivery'] = dateEstDelivery;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    if (dsCk != null) {
      data['ds_ck'] = dsCk!.map((v) => v.toJson()).toList();
    }
    if (total != null) {
      data['Total'] = total!.toJson();
    }
    data['nameCompany'] = nameCompany;
    data['mstCompany'] = mstCompany;
    data['addressCompany'] = addressCompany;
    data['noteCompany'] = noteCompany;
    data['typeDelivery'] = typeDelivery;
    data['idTypeOrder'] = idTypeOrder;
    data['sttRecHD'] = sttRecHD;
    return data;
  }
}

class DetailOrderV3 {
  String? nameProduction;
  String? code;
  String? sttRec0;
  double? count;
  double? price;
  double? priceAfter;
  double? discountPercent;
  String? dvt;
  double? ck;
  double? cknt;
  String? maCk;
  int? kmYN;
  String? stockCode;
  double? taxValues;
  String? codeTax;
  double? priceOk;
  double? taxPercent;
  String? idVv;
  String? idHd;
  String? note;
  int? isCheBien;
  int? isSanXuat;
  double? giaSuaDoi;
  double? giaGui;
  double? giaGuiNT;
  double? tienGuiNT;
  double? tienGui;
  dynamic heSo;
  dynamic idNVKD;
  dynamic ncsx;
  dynamic quycach;

  // Số lượng B (theo hợp đồng) để map vào trường SL_KD
  double? slKd;

  List<ListObjectJson>? listAdvanceOrderInfo;

  DetailOrderV3(
      {this.nameProduction,this.code,this.sttRec0,
        this.count,
        this.price,
        this.priceAfter,
        this.discountPercent,
        this.dvt,
        this.ck,
        this.cknt,
        this.maCk, this.kmYN,this.stockCode, this.taxValues, this.codeTax, this.priceOk,this.taxPercent,this.idVv,this.idHd,
        this.isCheBien, this.isSanXuat, this.giaSuaDoi, this.giaGui, this.tienGuiNT,
        this.tienGui, this.giaGuiNT, this.note, this.listAdvanceOrderInfo, this.heSo,
        this.idNVKD,
        this.ncsx,
        this.quycach,
        this.slKd,
      });

  DetailOrderV3.fromJson(Map<String, dynamic> json) {
    idNVKD = json['ma_td3'];
    ncsx = json['nuoc_sx'];
    quycach = json['quy_cach'];
    nameProduction = json['nameProduction'];
    code = json['code'];
    sttRec0 = json['sttRec0'];
    count = json['Count'];
    price = json['Price'];
    priceAfter = json['PriceAfter'];
    discountPercent = json['DiscountPercent'];
    dvt = json['Dvt'];
    ck = json['ck'];
    cknt = json['cknt'];
    maCk = json['ma_ck'];
    kmYN = json['km_yn'];
    stockCode = json['stockCode'];
    taxValues = json['TaxValues'];
    taxPercent = json['TaxPercent'];
    codeTax = json['TaxCode'];
    priceOk = json['PriceOk'];
    idVv = json['idVv'];
    idHd = json['idHd'];
    isCheBien = json['isCheBien'];
    isSanXuat = json['isSanXuat'];
    giaSuaDoi = json['giaSuaDoi'];
    giaGui = json['giaGui'];

    tienGuiNT = json['tienGuiNT'];
    tienGui = json['tienGui'];
    giaGuiNT = json['giaGuiNT'];
    note = json['note'];
    heSo = json['heSo'];
    slKd = json['SL_KD'];
    if (json['listAdvanceOrderInfo'] != null) {
      listAdvanceOrderInfo = <ListObjectJson>[];
      json['ds_ck'].forEach((v) {
        listAdvanceOrderInfo!.add( ListObjectJson.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};



    data['ma_td3'] = idNVKD;

    data['nuoc_sx'] = ncsx;
    data['quy_cach'] = quycach;
    data['nameProduction'] = nameProduction;

    data['code'] = code;
    data['sttRec0'] = sttRec0 ?? '0';
    data['Count'] = count;
    data['Price'] = price;
    data['PriceAfter'] = priceAfter;
    data['DiscountPercent'] = discountPercent;
    data['Dvt'] = dvt;
    data['ck'] = ck;
    data['cknt'] = cknt;
    data['ma_ck'] = maCk;
    data['km_yn'] = kmYN;
    data['stockCode'] = stockCode;
    data['TaxValues'] = taxValues;
    data['TaxPercent'] = taxPercent;
    data['TaxCode'] = codeTax;
    data['PriceOk'] = priceOk;
    data['idVv'] = idVv;
    data['idHd'] = idHd;    data['isCheBien'] = isCheBien;
    data['isSanXuat'] = isSanXuat;
    data['giaSuaDoi'] = giaSuaDoi;
    data['giaGui'] = giaGui;    data['tienGuiNT'] = tienGuiNT;
    data['tienGui'] = tienGui;
    data['giaGuiNT'] = giaGuiNT;
    data['note'] = note;
    data['heSo'] = heSo;
    if (slKd != null) {
      data['SL_KD'] = slKd;
    }
    if (listAdvanceOrderInfo != null) {
      data['listAdvanceOrderInfo'] = listAdvanceOrderInfo!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TotalCreateOrderV3 {
  double? preAmount;
  double? discount;
  double? tax;
  double? fee;
  double? amount;
  double? totalDiscountForItem;
  double? totalDiscountForOrder;

  TotalCreateOrderV3({this.preAmount, this.discount, this.tax, this.fee, this.amount, this.totalDiscountForItem, this.totalDiscountForOrder});

  TotalCreateOrderV3.fromJson(Map<String, dynamic> json) {
    preAmount = json['PreAmount'];
    discount = json['Discount'];
    tax = json['Tax'];
    fee = json['Fee'];
    amount = json['Amount'];
    totalDiscountForItem = json['TotalDiscountForItem'];
    totalDiscountForOrder = json['TotalDiscountForOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['PreAmount'] = preAmount;
    data['Discount'] = discount;
    data['Tax'] = tax;
    data['Fee'] = fee;
    data['Amount'] = amount;
    data['TotalDiscountForItem'] = totalDiscountForItem;
    data['TotalDiscountForOrder'] = totalDiscountForOrder;
    return data;
  }
}

