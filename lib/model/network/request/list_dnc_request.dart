class ListDNCRequest {
  String? dateFrom;
  String? dateTo;
  int? pageIndex;
  int? pageCount;

  ListDNCRequest(
      {this.dateFrom, this.dateTo,this.pageIndex, this.pageCount});

  ListDNCRequest.fromJson(Map<String, dynamic> json) {
    dateFrom = json['dateFrom'];
    dateTo = json['dateTo'];
    pageIndex = json['pageIndex'];
    pageCount = json['pageCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dateFrom'] = this.dateFrom;
    data['dateTo'] = this.dateTo;
    data['pageIndex'] = this.pageIndex;
    data['pageCount'] = this.pageCount;
    return data;
  }
}