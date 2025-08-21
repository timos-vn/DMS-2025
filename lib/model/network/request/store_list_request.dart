class StoreListRequest {
  String? unitId;
  int? pageIndex;
  int? pageCount;

  StoreListRequest({this.unitId, this.pageIndex, this.pageCount});

  StoreListRequest.fromJson(Map<String, dynamic> json) {
    unitId = json['unitId'];
    pageIndex = json['page_Index'];
    pageCount = json['page_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unitId'] = this.unitId;
    data['page_Index'] = this.pageIndex;
    data['page_count'] = this.pageCount;
    return data;
  }
}