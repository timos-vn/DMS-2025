class StockResponse{

  List<StockResponseData>? stockList;


  StockResponse({this.stockList});

  StockResponse.fromJson(Map<String, dynamic> json) {
    if (json['stockList'] != null) {
      stockList = <StockResponseData>[];(json['stockList'] as List).forEach((v) { stockList?.add(new StockResponseData.fromJson(v)); });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.stockList != null) {
      data['stockList'] =  this.stockList?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class StockResponseData{
  String? stockCode;
  String? stockName;
  String? stockName2;

  StockResponseData({this.stockCode,this.stockName,this.stockName2});

  StockResponseData.fromJson(Map<String, dynamic> json) {
    stockCode = json['stockCode'];
    stockName = json['stockName'];
    stockName2 = json['stockName2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stockCode'] = this.stockCode;
    data['stockName'] = this.stockName;
    data['stockName2'] = this.stockName2;
    return data;
  }
}

