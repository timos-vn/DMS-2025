class StageStatisticRequest {
  String? to;
  String? unitId;
  int? pageIndex;
  int? pageCount;

  StageStatisticRequest({this.to, this.unitId, this.pageIndex, this.pageCount});

  StageStatisticRequest.fromJson(Map<String, dynamic> json) {
    to = json['to'];
    unitId = json['unitId'];
    pageIndex = json['page_Index'];
    pageCount = json['page_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['to'] = this.to;
    data['unitId'] = this.unitId;
    data['page_Index'] = this.pageIndex;
    data['page_count'] = this.pageCount;
    return data;
  }
}