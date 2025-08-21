class ListCheckInRequest {
  String? datetime;
  String? userId;
  int? pageIndex;
  int? pageCount;

  ListCheckInRequest({this.datetime, this.userId, this.pageIndex,this.pageCount});

  ListCheckInRequest.fromJson(Map<String, dynamic> json) {
    datetime = json['datetime'];
    userId = json['userId'];
    pageIndex = json['page_index'];
    pageCount = json['page_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =  <String, dynamic>{};
    data['datetime'] = datetime;
    data['userId'] = userId;
    data['page_index'] = pageIndex;
    data['page_count'] = pageCount;
    return data;
  }
}