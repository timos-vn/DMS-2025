import '../response/search_list_item_response.dart';
import 'create_order_request.dart';

class UpdateOrderRequest{
  UpdateOrderRequestBody? requestData;

  UpdateOrderRequest({this.requestData});

  UpdateOrderRequest.fromJson(Map<String, dynamic> json) {
    requestData = json['Data'] != null ? new UpdateOrderRequestBody.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.requestData != null) {
      data['Data'] = this.requestData?.toJson();
    }
    return data;
  }
}

class UpdateOrderRequestBody {
  String? sttRec;
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

  UpdateOrderRequestBody(
      {
        this.idDVTC,this.idNguoiNhan,     this.ghiChuKM,this.idMDC,     this.thoiGianGiao,this.tien,this.baoGia,

        this.sttRec,this.customerCode,
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
        this.addressCompany, this.noteCompany, this.typeDelivery, this.idTypeOrder});

  UpdateOrderRequestBody.fromJson(Map<String, dynamic> json) {

    idDVTC = json['s2'];  thoiGianGiao = json['delivery_time'];
    idNguoiNhan = json['fnote1'];  tien = json['payment'];
    ghiChuKM = json['ghi_chu'];  baoGia = json['quotation_validily'];
    idMDC = json['ma_dc'];

    sttRec = json['stt_rec'];
    customerCode = json['CustomerCode'];
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
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};



    data['s2'] = idDVTC;data['delivery_time'] = thoiGianGiao;
    data['fnote1'] = idNguoiNhan;data['payment'] = tien;
    data['ghi_chu'] = ghiChuKM;data['quotation_validily'] = baoGia;
    data['ma_dc'] = idMDC;


    data['stt_rec'] = sttRec;
    data['CustomerCode'] = customerCode;
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
    return data;
  }
}

class ItemTotalMoneyUpdateRequestData {
  String? totalMNProduct;
  String? totalMNDiscount;
  String? totalMNPayment;
  String? preAmount;
  String? discount;

  ItemTotalMoneyUpdateRequestData({ this.totalMNProduct, this.totalMNDiscount, this.totalMNPayment,this.preAmount,this.discount});

  ItemTotalMoneyUpdateRequestData.fromJson(Map<String, dynamic> json) {
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