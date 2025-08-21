class ListShippingRequest {
  String? dateTimeFrom;
  String? dateTimeTo;
  String? customer;
  String? itemCode;

  ListShippingRequest(
      {this.dateTimeFrom, this.dateTimeTo, this.customer, this.itemCode});

  ListShippingRequest.fromJson(Map<String, dynamic> json) {
    dateTimeFrom = json['DateTimeFrom'];
    dateTimeTo = json['DateTimeTo'];
    customer = json['CusTomer'];
    itemCode = json['Itemcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['DateTimeFrom'] = this.dateTimeFrom;
    data['DateTimeTo'] = this.dateTimeTo;
    data['CusTomer'] = this.customer;
    data['Itemcode'] = this.itemCode;
    return data;
  }
}
