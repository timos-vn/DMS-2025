class DataDefaultResponse {
  List<FilterTimes>? filterTimes;
  List<ReportCategories>? reportCategories;
  List<CurrencyList>? currencyList;
  List<StockList>? stockList;
  bool? isCallServerCart;
  List<NumberFormatType>? numberFormat;
  // List<ReportData>? reportData;
  ReportInfo? reportInfo;
  int? statusCode;
  String? message;

  DataDefaultResponse(
      {this.filterTimes,
        this.reportCategories,
        this.currencyList,
        this.stockList,
        this.isCallServerCart,
        this.numberFormat,
        //this.reportData,
        this.reportInfo,
        this.statusCode,
        this.message});

  DataDefaultResponse.fromJson(Map<String, dynamic> json) {
    if (json['filterTimes'] != null) {
      filterTimes = <FilterTimes>[];
      json['filterTimes'].forEach((v) {
        filterTimes!.add(FilterTimes.fromJson(v));
      });
    }
    if (json['reportCategories'] != null) {
      reportCategories = <ReportCategories>[];
      json['reportCategories'].forEach((v) {
        reportCategories!.add(ReportCategories.fromJson(v));
      });
    }
    if (json['currencyList'] != null) {
      currencyList = <CurrencyList>[];
      json['currencyList'].forEach((v) {
        currencyList!.add(CurrencyList.fromJson(v));
      });
    }
    if (json['stockList'] != null) {
      stockList = <StockList>[];
      json['stockList'].forEach((v) {
        stockList!.add(StockList.fromJson(v));
      });
    }
    isCallServerCart = json['isCallServerCart'];
    if (json['numberFormat'] != null) {
      numberFormat = <NumberFormatType>[];
      json['numberFormat'].forEach((v) {
        numberFormat!.add(NumberFormatType.fromJson(v));
      });
    }
    // if (json['reportData'] != null) {
    //   reportData = <ReportData>[];
    //   json['reportData'].forEach((v) {
    //     reportData!.add(new ReportData.fromJson(v));
    //   });
    // }
    reportInfo = json['reportInfo'] != null
        ? ReportInfo.fromJson(json['reportInfo'])
        : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (filterTimes != null) {
      data['filterTimes'] = filterTimes!.map((v) => v.toJson()).toList();
    }
    if (reportCategories != null) {
      data['reportCategories'] =
          reportCategories!.map((v) => v.toJson()).toList();
    }
    if (currencyList != null) {
      data['currencyList'] = currencyList!.map((v) => v.toJson()).toList();
    }
    if (stockList != null) {
      data['stockList'] = stockList!.map((v) => v.toJson()).toList();
    }
    data['isCallServerCart'] = isCallServerCart;
    if (numberFormat != null) {
      data['numberFormat'] = numberFormat!.map((v) => v.toJson()).toList();
    }
    // if (this.reportData != null) {
    //   data['reportData'] = this.reportData!.map((v) => v.toJson()).toList();
    // }
    if (reportInfo != null) {
      data['reportInfo'] = reportInfo!.toJson();
    }
    data['statusCode'] = statusCode;
    data['message'] = message;
    return data;
  }
}

class FilterTimes {
  String? filterTimeId;
  String? filterTimeName;

  FilterTimes({this.filterTimeId, this.filterTimeName});

  FilterTimes.fromJson(Map<String, dynamic> json) {
    filterTimeId = json['filterTimeId'];
    filterTimeName = json['filterTimeName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['filterTimeId'] = filterTimeId;
    data['filterTimeName'] = filterTimeName;
    return data;
  }
}

class ReportCategories {
  String? reportId;
  String? reportName;
  String? viewType;
  String? chartType;

  ReportCategories(
      {this.reportId, this.reportName, this.viewType, this.chartType});

  ReportCategories.fromJson(Map<String, dynamic> json) {
    reportId = json['reportId'];
    reportName = json['reportName'];
    viewType = json['viewType'];
    chartType = json['chartType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reportId'] = reportId;
    data['reportName'] = reportName;
    data['viewType'] = viewType;
    data['chartType'] = chartType;
    return data;
  }
}

class CurrencyList {
  String? currencyCode;
  String? currencyName;
  String? currencyName2;
  double tyGia = 1;

  CurrencyList({this.currencyCode, this.currencyName, this.currencyName2, this.tyGia = 1});

  CurrencyList.fromJson(Map<String, dynamic> json) {
    currencyCode = json['currencyCode'];
    currencyName = json['currencyName'];
    currencyName2 = json['currencyName2'];
    tyGia = json['ty_gia'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['currencyCode'] = currencyCode;
    data['currencyName'] = currencyName;
    data['currencyName2'] = currencyName2;
    data['ty_gia'] = tyGia;
    return data;
  }
}

class StockList {
  String? stockCode;
  String? stockName;
  String? stockName2;

  StockList({this.stockCode, this.stockName, this.stockName2});

  StockList.fromJson(Map<String, dynamic> json) {
    stockCode = json['stockCode'];
    stockName = json['stockName'];
    stockName2 = json['stockName2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['stockCode'] = stockCode;
    data['stockName'] = stockName;
    data['stockName2'] = stockName2;
    return data;
  }
}

class NumberFormatType {
  String? name;
  String? value;

  NumberFormatType({this.name, this.value});

  NumberFormatType.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['value'] = value;
    return data;
  }
}

class ReportData {
  int? colName;
  double? value1;
  double? value2;
  ReportData({this.colName, this.value1, this.value2});

  ReportData.fromJson(Map<String, dynamic> json) {
    colName = json['colName'];
    value1 = json['value1'];
    value2 = json['value2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['colName'] = colName;
    data['value1'] = value1;
    data['value2'] = value2;
    return data;
  }
}

class ReportInfo {
  String? reportId;
  String? timeId;
  String? unitId;
  String? dataType;
  String? chartType;
  String? title;
  String? legend1;
  String? legend2;
  String? subtitle;
  String? defaultData;
  String? colors;

  ReportInfo(
      {this.reportId,
        this.timeId,
        this.unitId,
        this.dataType,
        this.chartType,
        this.title,
        this.legend1,
        this.legend2,
        this.subtitle,
        this.defaultData,
        this.colors});

  ReportInfo.fromJson(Map<String, dynamic> json) {
    reportId = json['reportId'];
    timeId = json['timeId'];
    unitId = json['unitId'];
    dataType = json['dataType'];
    chartType = json['chartType'];
    title = json['title'];
    legend1 = json['legend1'];
    legend2 = json['legend2'];
    subtitle = json['subtitle'];
    defaultData = json['defaultData'];
    colors = json['colors'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['reportId'] = reportId;
    data['timeId'] = timeId;
    data['unitId'] = unitId;
    data['dataType'] = dataType;
    data['chartType'] = chartType;
    data['title'] = title;
    data['legend1'] = legend1;
    data['legend2'] = legend2;
    data['subtitle'] = subtitle;
    data['defaultData'] = defaultData;
    data['colors'] = colors;
    return data;
  }
}