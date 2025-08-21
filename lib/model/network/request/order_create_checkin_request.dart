import '../response/search_list_item_response.dart';
import 'create_order_request.dart';

class CreateOrderFromCheckInRequest{
  CreateOrderFromCheckInRequestBody? requestData;

  CreateOrderFromCheckInRequest({this.requestData});

  CreateOrderFromCheckInRequest.fromJson(Map<String, dynamic> json) {
    requestData = json['Data'] != null ?  CreateOrderFromCheckInRequestBody.fromJson(json['Data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    if (requestData != null) {
      data['Data'] = requestData?.toJson();
    }
    return data;
  }
}

class CreateOrderFromCheckInRequestBody {
  String? customerCode;
  String? saleCode;
  String? orderDate;
  String? currency;
  String? stockCode;
  String? descript;
  String? phoneCustomer;
  String? addressCustomer;
  String? comment;
  List<String>? dsCk;
  List<SearchItemResponseData>? listStore ;
  List<ListImageInvoice>? listImage;
  ItemTotalMoneyRequestData? listTotal;

  CreateOrderFromCheckInRequestBody({ this.customerCode, this.saleCode,this.orderDate,this.currency,this.stockCode,this.descript,this.phoneCustomer,this.addressCustomer,this.comment,this.dsCk,this.listStore,this.listImage,this.listTotal});

  CreateOrderFromCheckInRequestBody.fromJson(Map<String, dynamic> json) {

    customerCode = json['CustomerCode'];
    saleCode = json['SaleCode'];
    orderDate = json['OrderDate'];
    currency = json['Currency'];
    stockCode = json['StockCode'];
    descript = json['Descript'];
    phoneCustomer = json['PhoneCustomer'];
    addressCustomer = json['AddressCustomer'];
    comment = json['Comment'];
    if(dsCk!=null){
      dsCk = json['ds_ck'];
    }else{
      dsCk = [];
    }
    listStore = json['Detail'];
    if (json['ListImage'] != null) {
      listImage = <ListImageInvoice>[];
      json['ListImage'].forEach((v) {
        listImage!.add( ListImageInvoice.fromJson(v));
      });
    }
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
    if(dsCk != null){
      data['ds_ck'] = dsCk;
    }else {
      data['ds_ck'] = [];
    }
    data['Detail'] = listStore;
    if(dsCk != null){
      data['ds_ck'] = dsCk;
    }else {
      data['ds_ck'] = [];
    }
    data['Total'] = listTotal;
    return data;
  }
}

class ListImageInvoice {
  String? pathBase64;
  String? nameImage;

  ListImageInvoice({this.pathBase64, this.nameImage});

  ListImageInvoice.fromJson(Map<String, dynamic> json) {
    pathBase64 = json['PathBase64'];
    nameImage = json['NameImage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['PathBase64'] = pathBase64;
    data['NameImage'] = nameImage;
    return data;
  }
}