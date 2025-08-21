
class SearchListItemRequest {
  String? searchValue;
  int? pageIndex;
  int? pageCount;
  String? idCustomer;
  String? currency;
  String? itemGroup;
  String? itemGroup2;
  String? itemGroup3;
  String? itemGroup4;
  String? itemGroup5;
  String? keyGroup;
  int? isCheckStock;

  SearchListItemRequest({this.searchValue,this.pageIndex,this.pageCount, this.idCustomer,this.isCheckStock,
    this.currency,this.itemGroup,this.itemGroup2,this.itemGroup3, this.itemGroup4,this.itemGroup5, this.keyGroup});

  SearchListItemRequest.fromJson(Map<String, dynamic> json) {
    searchValue = json['SearchValue'];
    pageIndex = json['PageIndex'];
    pageCount = json['PageCount'];
    idCustomer = json['IdCustomer'];
    currency = json['Currency'];
    itemGroup = json['ItemGroup'];
    itemGroup2 = json['ItemGroup2'];
    itemGroup3 = json['ItemGroup3'];
    itemGroup4 = json['ItemGroup4'];
    itemGroup5 = json['ItemGroup5'];
    keyGroup = json['keyGroup'];
    isCheckStock = json['isCheckStock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['SearchValue'] = searchValue;
    data['PageIndex'] = pageIndex;
    data['PageCount'] = pageCount;
    data['IdCustomer'] = idCustomer;
    data['Currency'] = currency;
    data['ItemGroup'] = itemGroup;
    data['ItemGroup2'] = itemGroup2;
    data['ItemGroup3'] = itemGroup3;
    data['ItemGroup4'] = itemGroup4;
    data['ItemGroup5'] = itemGroup5;data['keyGroup'] = keyGroup;data['isCheckStock'] = isCheckStock;
    return data;
  }
}

class GetListItemSearchInOrderRequest {
  String? maKh;
  String? keySearch;
  int? pageIndex;
  int? pageCount;

  GetListItemSearchInOrderRequest({this.maKh, this.pageIndex, this.pageCount, this.keySearch});

  GetListItemSearchInOrderRequest.fromJson(Map<String, dynamic> json) {
    if(maKh.toString().replaceAll('null', '').isNotEmpty){
      maKh = json['ma_kh'];
    }    if(keySearch.toString().replaceAll('null', '').isNotEmpty){
      keySearch = json['ma_nv'];
    }
    pageIndex = json['PageIndex'];
    pageCount = json['PageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    if(maKh.toString().replaceAll('null', '').isNotEmpty){
      data['ma_kh'] = this.maKh;
    }    if(keySearch.toString().replaceAll('null', '').isNotEmpty){
      data['ma_nv'] = this.keySearch;
    }
    data['PageIndex'] = this.pageIndex;
    data['PageCount'] = this.pageCount;
    return data;
  }
}

class GetListItemSearchInOrder2Request {
  String? maKh;
  String? keySearch;
  int? pageIndex;
  int? pageCount;

  GetListItemSearchInOrder2Request({this.maKh, this.pageIndex, this.pageCount, this.keySearch});

  GetListItemSearchInOrder2Request.fromJson(Map<String, dynamic> json) {
    keySearch = json['ma_nv'];
    pageIndex = json['PageIndex'];
    pageCount = json['PageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['ma_nv'] = this.keySearch;
    data['PageIndex'] = this.pageIndex;
    data['PageCount'] = this.pageCount;
    return data;
  }
}