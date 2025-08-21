class DeliveryPlanRequest {
  String? dateTimeFrom;
  String? dateTimeTo;
  int? pageIndex;
  int? pageCount;

  DeliveryPlanRequest(
      {this.dateTimeFrom, this.dateTimeTo, this.pageIndex, this.pageCount});

  DeliveryPlanRequest.fromJson(Map<String, dynamic> json) {
    dateTimeFrom = json['DateTimeFrom'];
    dateTimeTo = json['DateTimeTo'];
    pageIndex = json['page_Index'];
    pageCount = json['page_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DateTimeFrom'] = this.dateTimeFrom;
    data['DateTimeTo'] = this.dateTimeTo;
    data['page_Index'] = this.pageIndex;
    data['page_count'] = this.pageCount;
    return data;
  }
}

