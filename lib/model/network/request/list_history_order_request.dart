class ListHistoryOrderRequest {
  String? userCode;
  String? letterTypeId;
  int? pageIndex;
  String? status;
  String? timeFilter;
  String? dateFrom;
  String? dateTo;
  String? firstElement;
  String? lastElement;
  int? totalRec;

  ListHistoryOrderRequest(
      {this.userCode,this.letterTypeId,
        this.pageIndex,
        this.status,
        this.timeFilter,
        this.dateFrom,
        this.dateTo,
        this.firstElement,
        this.lastElement,
        this.totalRec});

  ListHistoryOrderRequest.fromJson(Map<String, dynamic> json) {
    userCode = json['UserCode'];
    letterTypeId = json['LetterTypeId'];
    pageIndex = json['PageIndex'];
    status = json['Status'];
    timeFilter = json['TimeFilter'];
    dateFrom = json['DateFrom'];
    dateTo = json['DateTo'];
    firstElement = json['FirstElement'];
    lastElement = json['LastElement'];
    totalRec = json['TotalRec'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['UserCode'] = this.userCode;
    data['LetterTypeId'] = this.letterTypeId;
    data['PageIndex'] = this.pageIndex;
    data['Status'] = this.status;
    data['TimeFilter'] = this.timeFilter;
    data['DateFrom'] = this.dateFrom;
    data['DateTo'] = this.dateTo;
    data['FirstElement'] = this.firstElement;
    data['LastElement'] = this.lastElement;
    data['TotalRec'] = this.totalRec;
    return data;
  }
}

