import '../response/GetDetailSaleOutCompetedResponse.dart';
import '../response/get_detail_order_complete_response.dart';


class CreateRefundSaleOutRequest {
  CreateRefundSaleOutRequestData? requestData;

  CreateRefundSaleOutRequest({this.requestData});

  CreateRefundSaleOutRequest.fromJson(Map<String, dynamic> json) {
    requestData = json['Data'] != null ?  CreateRefundSaleOutRequestData.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (requestData != null) {
      data['Data'] = requestData!.toJson();
    }
    return data;
  }
}

class CreateRefundSaleOutRequestData {
  String? sct;
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
  String? codeAgency;
  double? discountPercentAgency;
  String? codeTypePayment;
  double? discountPercentTypePayment;
  String? datePayment;
  List<GetDetailSaleOutCompletedResponseData>? detail;
  TotalCreateOrderV3? total;
  String? codeTax;
  double? totalTax;
  String? codeSell;
  String? tk;

  CreateRefundSaleOutRequestData(
      {this.sct,this.customerCode,
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
        this.total, this.discountPercentAgency,this.datePayment,
        this.discountPercentTypePayment,this.codeAgency,this.codeTypePayment,this.codeTax,this.totalTax, this.codeSell,this.tk});

  CreateRefundSaleOutRequestData.fromJson(Map<String, dynamic> json) {
    sct = json['sct'];
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
    codeTax = json['codeTax'];
    totalTax = json['totalTax'];
    discountPercentAgency = json['discountPercentAgency'];
    discountPercentTypePayment = json['discountPercentTypePayment'];
    tk = json['tk'];

    codeAgency = json['codeAgency'];
    codeTypePayment = json['codeTypePayment'];
    datePayment = json['datePayment'];
    codeSell = json['codeSell'];
    if (json['Detail'] != null) {
      detail = <GetDetailSaleOutCompletedResponseData>[];
      json['Detail'].forEach((v) {
        detail!.add( GetDetailSaleOutCompletedResponseData.fromJson(v));
      });
    }
    total = json['Total'] != null ? TotalCreateOrderV3.fromJson(json['Total']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['sct'] = sct;
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
    data['codeTax'] = codeTax;data['totalTax'] = totalTax;

    data['discountPercentAgency'] = discountPercentAgency;
    data['discountPercentTypePayment'] = discountPercentTypePayment;
    data['codeAgency'] = codeAgency;
    data['codeTypePayment'] = codeTypePayment;
    data['datePayment'] = datePayment;
    data['codeSell'] = codeSell;
    data['tk'] = tk;
    if (detail != null) {
      data['Detail'] = detail!.map((v) => v.toJson()).toList();
    }
    if (total != null) {
      data['Total'] = total!.toJson();
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

  TotalCreateOrderV3({this.preAmount, this.discount, this.tax, this.fee, this.amount});

  TotalCreateOrderV3.fromJson(Map<String, dynamic> json) {
    preAmount = json['PreAmount'];
    discount = json['Discount'];
    tax = json['Tax'];
    fee = json['Fee'];
    amount = json['Amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['PreAmount'] = this.preAmount;
    data['Discount'] = this.discount;
    data['Tax'] = this.tax;
    data['Fee'] = this.fee;
    data['Amount'] = this.amount;
    return data;
  }
}

