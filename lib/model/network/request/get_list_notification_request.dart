class GetListNotificationRequest {
  int? pageIndex;
  int? pageSize;

  GetListNotificationRequest({
    this.pageIndex,
    this.pageSize,
  });

  GetListNotificationRequest.fromJson(Map<String, dynamic> json) {
    pageIndex = json['pageIndex'];
    pageSize = json['pageSize'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['pageIndex'] = pageIndex;
    data['pageSize'] = pageSize;
    return data;
  }
}
